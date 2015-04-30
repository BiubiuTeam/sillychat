//
//  SillyVoiceCache.h
//  sillyChat
//
//  Created by haowenliang on 15/4/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//


#import <Foundation/Foundation.h>

enum SillyVoiceCacheType
{
    /**
     * The voice data wasn't available the caches, but was downloaded from the web.
     */
    SillyVoiceCacheTypeNone = 0,
    /**
     * The voice data was obtained from the disk cache.
     */
    SillyVoiceCacheTypeDisk,
    /**
     * The voice data was obtained from the memory cache.
     */
    SillyVoiceCacheTypeMemory
};
typedef enum SillyVoiceCacheType SillyVoiceCacheType;


@interface SillyVoiceCache : NSObject

/**
 * The maximum "total cost" of the in-memory image cache. The cost function is the number of pixels held in memory.
 */
@property (assign, nonatomic) NSUInteger maxMemoryCost;

/**
 * The maximum length of time to keep an image in the cache, in seconds
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) unsigned long long maxCacheSize;

/**
 * Returns global shared cache instance
 *
 * @return SillyVoiceCache global instance
 */
+ (instancetype)sharedVoiceCache;

/**
 * Init a new cache store with a specific namespace
 *
 * @param ns The namespace to use for this cache store
 */
- (id)initWithNamespace:(NSString *)ns;

/**
 * Store voice data into memory and disk cache at the given key.
 *
 * @param voice The voice data to store
 * @param key The unique data cache key, usually it's voice data absolute URL
 */
- (void)storeVoiceData:(NSData *)voice forKey:(NSString *)key;

/**
 * Store voice data into memory and optionally disk cache at the given key.
 *
 * @param voice The voice data to store
 * @param key The unique voice cache key, usually it's voice data absolute URL
 * @param toDisk Store the voice to disk cache if YES
 */
- (void)storeVoiceData:(NSData *)voice forKey:(NSString *)key toDisk:(BOOL)toDisk;

/**
 * Query the disk cache asynchronously.
 *
 * @param key The unique key used to store the wanted image
 */
- (NSOperation *)queryDiskCacheForKey:(NSString *)key done:(void (^)(NSData *voice, SillyVoiceCacheType cacheType))doneBlock;

/**
 * Query the memory cache synchronously.
 *
 * @param key The unique key used to store the wanted voice data
 */
- (NSData *)voiceDataFromMemoryCacheForKey:(NSString *)key;

/**
 * Query the disk cache synchronously after checking the memory cache.
 *
 * @param key The unique key used to store the wanted voice data
 */
- (NSData *)voiceDataFromDiskCacheForKey:(NSString *)key;

/**
 * Remove the voice data from memory and disk cache synchronously
 *
 * @param key The unique voice cache cache key
 */
- (void)removeVoiceDataForKey:(NSString *)key;

/**
 * Remove the voice data from memory and optionaly disk cache synchronously
 *
 * @param key The unique voice data cache key
 * @param fromDisk Also remove cache entry from disk if YES
 */
- (void)removeVoiceDataForKey:(NSString *)key fromDisk:(BOOL)fromDisk;

/**
 * Clear all memory cached voice datas
 */
- (void)clearMemory;

/**
 * Clear all disk cached voice datas
 */
- (void)clearDisk;

/**
 * Remove all expired cached voice data from disk
 */
- (void)cleanDisk;

/**
 * Get the size used by the disk cache
 */
- (unsigned long long)getSize;

/**
 * Get the number of images in the disk cache
 */
- (int)getDiskCount;

/**
 * Asynchronously calculate the disk cache's size.
 */
- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, unsigned long long totalSize))completionBlock;

/**
 * Check if voice data exists in cache already
 */
- (BOOL)diskVoiceDataExistsWithKey:(NSString *)key;

@end
