//
//  SillyVoiceCache.m
//  sillyChat
//
//  Created by haowenliang on 15/4/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyVoiceCache.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24; // 1 day
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread])\
{\
block();\
}\
else\
{\
dispatch_sync(dispatch_get_main_queue(), block);\
}


@interface SillyVoiceCache ()
{
    NSFileManager *_fileManager;
}

@property (strong, nonatomic) NSCache *memCache;
@property (strong, nonatomic) NSString *diskCachePath;
@property (strong, nonatomic) NSMutableArray *customPaths;

@property (strong, nonatomic) dispatch_queue_t ioQueue;

@end

@implementation SillyVoiceCache

+ (instancetype)sharedVoiceCache
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^
    {
        instance = self.new;
    });
    return instance;
}

- (id)init
{
    return [self initWithNamespace:@"default"];
}

- (id)initWithNamespace:(NSString *)ns
{
    if ((self = [super init]))
    {
        NSString *fullNamespace = [@"com.nuxsoft.SillyVoiceCahce." stringByAppendingString:ns];
        
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.nuxsoft.SillyVoiceCahce", DISPATCH_QUEUE_SERIAL);
        
        // Init default values
        _maxCacheAge = kDefaultCacheMaxCacheAge;
        
        // Init the memory cache
        _memCache = [[NSCache alloc] init];
        _memCache.name = fullNamespace;
        
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];
        
        dispatch_sync(_ioQueue, ^
                      {
                          _fileManager = NSFileManager.new;
                      });
        
#if TARGET_OS_IPHONE
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
#endif
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.ioQueue = nil;
}

#pragma mark -private
- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path
{
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)defaultCachePathForKey:(NSString *)key
{
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

- (NSString *)cachedFileNameForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    if (str == NULL)
    {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

#pragma mark -voice cache

- (void)storeVoiceData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (![data length] || !key.length)
    {
        DPTrace("缓存音频数据");
        return;
    }
    
    [self.memCache setObject:data forKey:key cost:data.length];
    
    if (toDisk)
    {
        dispatch_async(self.ioQueue, ^
        {
            if (data)
            {
                // Can't use defaultManager another thread
                NSFileManager *fileManager = NSFileManager.new;

                if (![fileManager fileExistsAtPath:_diskCachePath])
                {
                    [fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }

                [fileManager createFileAtPath:[self defaultCachePathForKey:key] contents:data attributes:nil];
            }
        });
    }
}

- (void)storeVoiceData:(NSData *)voice forKey:(NSString *)key
{
    [self storeVoiceData:voice forKey:key toDisk:YES];
}

- (BOOL)diskVoiceDataExistsWithKey:(NSString *)key
{
    __block BOOL exists = NO;
    dispatch_sync(_ioQueue, ^
                  {
                      exists = [_fileManager fileExistsAtPath:[self defaultCachePathForKey:key]];
                  });
    
    return exists;
}

- (NSData *)voiceDataFromMemoryCacheForKey:(NSString *)key
{
    return [self.memCache objectForKey:key];
}

- (NSData *)voiceDataFromDiskCacheForKey:(NSString *)key
{
    // First check the in-memory cache...
    NSData *voice = [self voiceDataFromMemoryCacheForKey:key];
    if ([voice length])
    {
        return voice;
    }
    
    // Second check the disk cache...
    NSData *diskVoice = [self diskVoiceDataForKey:key];
    if (diskVoice)
    {
        [self.memCache setObject:diskVoice forKey:key cost:diskVoice.length];
    }
    
    return diskVoice;
}



- (NSData *)diskVoiceDataBySearchingAllPathsForKey:(NSString *)key
{
    NSString *defaultPath = [self defaultCachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:defaultPath];
    if (data)
    {
        return data;
    }
    
    for (NSString *path in self.customPaths)
    {
        NSString *filePath = [self cachePathForKey:key inPath:path];
        NSData *voiceData = [NSData dataWithContentsOfFile:filePath];
        if (voiceData) {
            return voiceData;
        }
    }
    
    return nil;
}

- (NSData *)diskVoiceDataForKey:(NSString *)key
{
    NSData *data = [self diskVoiceDataBySearchingAllPathsForKey:key];
    if (data)
    {
        return data;
    }
    else
    {
        return nil;
    }
}

- (NSOperation *)queryDiskCacheForKey:(NSString *)key done:(void (^)(NSData *, SillyVoiceCacheType))doneBlock
{
    NSOperation *operation = NSOperation.new;
    
    if (!doneBlock) return nil;
    
    if (!key)
    {
        doneBlock(nil, SillyVoiceCacheTypeNone);
        return nil;
    }
    
    // First check the in-memory cache...
    NSData *voiceData = [self voiceDataFromMemoryCacheForKey:key];
    if (voiceData)
    {
        doneBlock(voiceData, SillyVoiceCacheTypeMemory);
        return nil;
    }
    
    dispatch_async(self.ioQueue, ^
                   {
                       if (operation.isCancelled)
                       {
                           return;
                       }
                       
                       @autoreleasepool
                       {
                           NSData *diskVoice = [self diskVoiceDataForKey:key];
                           if (diskVoice)
                           {
                               [self.memCache setObject:diskVoice forKey:key cost:diskVoice.length];
                           }
                           
                           dispatch_main_sync_safe(^
                                                   {
                                                       doneBlock(diskVoice, SillyVoiceCacheTypeDisk);
                                                   });
                       }
                   });
    
    return operation;
}

- (void)removeVoiceDataForKey:(NSString *)key
{
    [self removeVoiceDataForKey:key fromDisk:YES];
}

- (void)removeVoiceDataForKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    if (key == nil)
    {
        return;
    }
    
    [self.memCache removeObjectForKey:key];
    
    if (fromDisk)
    {
        dispatch_async(self.ioQueue, ^
                       {
                           [[NSFileManager defaultManager] removeItemAtPath:[self defaultCachePathForKey:key] error:nil];
                       });
    }
}

- (void)setMaxMemoryCost:(NSUInteger)maxMemoryCost
{
    self.memCache.totalCostLimit = maxMemoryCost;
}

- (NSUInteger)maxMemoryCost
{
    return self.memCache.totalCostLimit;
}

- (void)clearMemory
{
    [self.memCache removeAllObjects];
}

- (void)clearDisk
{
    dispatch_async(self.ioQueue, ^
                   {
                       [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
                       [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:NULL];
                   });
}

- (void)cleanDisk
{
    dispatch_async(self.ioQueue, ^
                   {
                       NSFileManager *fileManager = [NSFileManager defaultManager];
                       NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
                       NSArray *resourceKeys = @[ NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey ];
                       
                       // This enumerator prefetches useful properties for our cache files.
                       NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                                                 includingPropertiesForKeys:resourceKeys
                                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:NULL];
                       
                       NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
                       NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
                       unsigned long long currentCacheSize = 0;
                       
                       // Enumerate all of the files in the cache directory.  This loop has two purposes:
                       //
                       //  1. Removing files that are older than the expiration date.
                       //  2. Storing file attributes for the size-based cleanup pass.
                       for (NSURL *fileURL in fileEnumerator)
                       {
                           NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
                           
                           // Skip directories.
                           if ([resourceValues[NSURLIsDirectoryKey] boolValue])
                           {
                               continue;
                           }
                           
                           // Remove files that are older than the expiration date;
                           NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
                           if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate])
                           {
                               [fileManager removeItemAtURL:fileURL error:nil];
                               continue;
                           }
                           
                           // Store a reference to this file and account for its total size.
                           NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                           currentCacheSize += [totalAllocatedSize unsignedLongLongValue];
                           [cacheFiles setObject:resourceValues forKey:fileURL];
                       }
                       
                       // If our remaining disk cache exceeds a configured maximum size, perform a second
                       // size-based cleanup pass.  We delete the oldest files first.
                       if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize)
                       {
                           // Target half of our maximum cache size for this cleanup pass.
                           const unsigned long long desiredCacheSize = self.maxCacheSize / 2;
                           
                           // Sort the remaining cache files by their last modification time (oldest first).
                           NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                                           usingComparator:^NSComparisonResult(id obj1, id obj2)
                                                   {
                                                       return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                   }];
                           
                           // Delete files until we fall below our desired cache size.
                           for (NSURL *fileURL in sortedFiles)
                           {
                               if ([fileManager removeItemAtURL:fileURL error:nil])
                               {
                                   NSDictionary *resourceValues = cacheFiles[fileURL];
                                   NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                                   currentCacheSize -= [totalAllocatedSize unsignedLongLongValue];
                                   
                                   if (currentCacheSize < desiredCacheSize)
                                   {
                                       break;
                                   }
                               }
                           }
                       }
                   });
}

- (void)backgroundCleanDisk
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^
                                                 {
                                                     // Clean up any unfinished task business by marking where you
                                                     // stopped or ending the task outright.
                                                     [application endBackgroundTask:bgTask];
                                                     bgTask = UIBackgroundTaskInvalid;
                                                 }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       // Do the work associated with the task, preferably in chunks.
                       [self cleanDisk];
                       
                       [application endBackgroundTask:bgTask];
                       bgTask = UIBackgroundTaskInvalid;
                   });
}

- (unsigned long long)getSize
{
    unsigned long long size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

- (int)getDiskCount
{
    int count = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.diskCachePath];
    for (__unused NSString *fileName in fileEnumerator)
    {
        count += 1;
    }
    
    return count;
}

- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, unsigned long long totalSize))completionBlock
{
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    
    dispatch_async(self.ioQueue, ^
                   {
                       NSUInteger fileCount = 0;
                       unsigned long long totalSize = 0;
                       
                       NSFileManager *fileManager = [NSFileManager defaultManager];
                       NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                                                 includingPropertiesForKeys:@[ NSFileSize ]
                                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:NULL];
                       
                       for (NSURL *fileURL in fileEnumerator)
                       {
                           NSNumber *fileSize;
                           [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
                           totalSize += [fileSize unsignedLongLongValue];
                           fileCount += 1;
                       }
                       
                       if (completionBlock)
                       {
                           dispatch_main_sync_safe(^
                                                   {
                                                       completionBlock(fileCount, totalSize);
                                                   });
                       }
                   });
}

@end
