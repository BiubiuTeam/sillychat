//
//  DPAsyncImageLoader.m
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPAsyncImageLoader.h"
#import "DPAsyncImageConnection.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>
#import <Availability.h>
#import <SDWebImage/SDImageCache.h>

NSString *const DPAsyncImageLoadDidFinish = @"_DPAsyncImageLoadDidFinish_";
NSString *const DPAsyncImageLoadDidFail = @"_DPAsyncImageLoadDidFail_";
NSString *const DPAsyncImageImageKey = @"dp_image";
NSString *const DPAsyncImageURLKey = @"DP_URL";
NSString *const DPAsyncImageCacheKey = @"dp_cache";
NSString *const DPAsyncImageErrorKey = @"dp_error";

@interface DPAsyncImageLoader ()

@property (nonatomic, strong) NSMutableArray *connections;

@end

@implementation DPAsyncImageLoader

+ (instancetype)sharedLoader
{
    static DPAsyncImageLoader *sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [(DPAsyncImageLoader *)[self alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _concurrentLoads = 2;
        _loadingTimeout = 60.0;
        _connections = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageLoaded:) name:DPAsyncImageLoadDidFinish object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageFailed:) name:DPAsyncImageLoadDidFail object:nil];
    }
    return self;
}

- (void)updateQueue
{
    @synchronized(_connections){
        //start connections
        NSUInteger count = 0;
        NSMutableArray* tmpConnects = [self.connections mutableCopy];
        for (DPAsyncImageConnection *connection in tmpConnects)
        {
            if (![connection isLoading])
            {
                if ([connection isInCache])
                {
                    [connection start];
                }else if (count < self.concurrentLoads){
                    count ++;
                    [connection start];
                }
            }
        }
    }
}

- (void)imageLoaded:(NSNotification *)notification
{
    //complete connections for URL
    NSURL *URL = (notification.userInfo)[DPAsyncImageURLKey];
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.URL == URL || [connection.URL isEqual:URL])
        {
            //cancel earlier connections for same target/action
            NSMutableArray* tmpConnection = [self.connections mutableCopy];
            
            for (NSInteger j = i - 1; j >= 0; j--)
            {
                DPAsyncImageConnection *earlier = tmpConnection[(NSUInteger)j];
                if (earlier.target == connection.target &&
                    earlier.success == connection.success)
                {
                    [earlier cancel];
                    [tmpConnection removeObjectAtIndex:(NSUInteger)j];
                    i--;
                }
            }
            
            //cancel connection (in case it's a duplicate)
            [connection cancel];
            
            //perform action
            UIImage *image = (notification.userInfo)[DPAsyncImageImageKey];
            ((void (*)(id, SEL, id, id))objc_msgSend)(connection.target, connection.success, image, connection.URL);
            
            //remove from queue
            [tmpConnection removeObjectAtIndex:(NSUInteger)i];
            
            self.connections = tmpConnection;
        }
    }
    
    //update the queue
    [self updateQueue];
}

- (void)imageFailed:(NSNotification *)notification
{
    //remove connections for URL
    NSURL *URL = (notification.userInfo)[DPAsyncImageURLKey];
    
    NSInteger count = [self.connections count];
    for (NSInteger i = count - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL])
        {
            //cancel connection (in case it's a duplicate)
            [connection cancel];
            
            //perform failure action
            if (connection.failure)
            {
                NSError *error = (notification.userInfo)[DPAsyncImageErrorKey];
                ((void (*)(id, SEL, id, id))objc_msgSend)(connection.target, connection.failure, error, URL);
            }
            
            //remove from queue
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
    
    //update the queue
    [self updateQueue];
}

- (UIImage*)getCacheImageWithKey:(NSString*)key
{
    UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (nil == image) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    return image;
}

- (void)loadImageWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure
{
    __weak DPAsyncImageLoader* weakSelf = self;
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:[URL absoluteString] done:^(UIImage *image, SDImageCacheType cacheType) {
        //check cache
        if (image)
        {
            [weakSelf cancelLoadingImagesForTarget:weakSelf action:success];
            if (success)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    ((void (*)(id, SEL, id, id))objc_msgSend)(target, success, image, URL);
                });
            }
            return;
        }
        
        //create new connection
        DPAsyncImageConnection *connection = [[DPAsyncImageConnection alloc] initWithURL:URL target:target success:success failure:failure];
        
        BOOL added = NO;
        for (NSUInteger i = 0; i < [weakSelf.connections count]; i++)
        {
            DPAsyncImageConnection *existingConnection = weakSelf.connections[i];
            if (!existingConnection.loading)
            {
                [weakSelf.connections insertObject:connection atIndex:i];
                added = YES;
                break;
            }
        }
        if (!added)
        {
            [weakSelf.connections addObject:connection];
        }
        
        [weakSelf updateQueue];
    }];
}

- (void)loadImageWithURL:(NSURL *)URL target:(id)target action:(SEL)action
{
    [self loadImageWithURL:URL target:target success:action failure:NULL];
}

- (void)loadImageWithURL:(NSURL *)URL
{
    [self loadImageWithURL:URL target:nil success:NULL failure:NULL];
}

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action
{
    NSInteger count = [self.connections count];
    for (NSInteger i = count - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL] && connection.target == target && connection.success == action)
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target
{
    NSInteger count = [self.connections count];
    for (NSInteger i = count - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL] && connection.target == target)
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingURL:(NSURL *)URL
{
    NSInteger count = [self.connections count];
    for (NSInteger i = count - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL])
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingImagesForTarget:(id)target action:(SEL)action
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target && connection.success == action)
        {
            [connection cancel];
        }
    }
}

- (void)cancelLoadingImagesForTarget:(id)target
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target)
        {
            [connection cancel];
        }
    }
}

- (NSURL *)URLForTarget:(id)target action:(SEL)action
{
    //return the most recent image URL assigned to the target for the given action
    //this is not neccesarily the next image that will be assigned
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target && connection.success == action)
        {
            return connection.URL;
        }
    }
    return nil;
}

- (NSURL *)URLForTarget:(id)target
{
    //return the most recent image URL assigned to the target
    //this is not neccesarily the next image that will be assigned
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        DPAsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target)
        {
            return connection.URL;
        }
    }
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
