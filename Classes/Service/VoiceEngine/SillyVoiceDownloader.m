//
//  SillyVoiceDownloader.m
//  sillyChat
//
//  Created by haowenliang on 15/4/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyVoiceDownloader.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>
#import <Availability.h>
#import "SillyVoiceConnection.h"
#import "SillyVoiceCache.h"
@interface SillyVoiceDownloader ()

@property (nonatomic, strong) NSMutableArray *connections;

@end

@implementation SillyVoiceDownloader

+ (instancetype)shareInstance
{
    static SillyVoiceDownloader* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[SillyVoiceDownloader alloc] init];
    });
    return s_instance;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _concurrentLoads = 2;
        _timeout = 60.0;
        _connections = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceDidLoaded:) name:SillyVoiceDownloadDidFinish object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceDidFailed:) name:SillyVoiceDownloadDidFail object:nil];
    }
    return self;
}

- (void)updateQueue
{
    @synchronized(_connections){
        //start connections
        NSUInteger count = 0;
        NSMutableArray* tmpConnects = [self.connections mutableCopy];
        for (SillyVoiceConnection *connection in tmpConnects)
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

- (void)voiceDidLoaded:(NSNotification *)notification
{
    //complete connections for URL
    NSURL *URL = (notification.userInfo)[SillyVoiceURLKey];
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
        if (connection.URL == URL || [connection.URL isEqual:URL])
        {
            //cancel earlier connections for same target/action
            NSMutableArray* tmpConnection = [self.connections mutableCopy];
            
            for (NSInteger j = i - 1; j >= 0; j--)
            {
                SillyVoiceConnection *earlier = tmpConnection[(NSUInteger)j];
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
            NSData *voiceData = (notification.userInfo)[SillyVoiceKey];
            ((void (*)(id, SEL, id, id))objc_msgSend)(connection.target, connection.success, voiceData, connection.URL);
            
            //remove from queue
            [tmpConnection removeObjectAtIndex:(NSUInteger)i];
            
            self.connections = tmpConnection;
        }
    }
    
    //update the queue
    [self updateQueue];
}

- (void)voiceDidFailed:(NSNotification *)notification
{
    //remove connections for URL
    NSURL *URL = (notification.userInfo)[SillyVoiceURLKey];
    
    NSInteger count = [self.connections count];
    for (NSInteger i = count - 1; i >= 0; i--)
    {
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL])
        {
            //cancel connection (in case it's a duplicate)
            [connection cancel];
            
            //perform failure action
            if (connection.failure)
            {
                NSError *error = (notification.userInfo)[SillyVoiceErrorKey];
                ((void (*)(id, SEL, id, id))objc_msgSend)(connection.target, connection.failure, error, URL);
            }
            
            //remove from queue
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
    
    //update the queue
    [self updateQueue];
}

#pragma mark -
- (void)loadVoiceDataWithURL:(NSURL *)URL target:(id)target action:(SEL)action
{
    [self loadVoiceDataWithURL:URL target:target success:action failure:NULL];
}

- (void)loadVoiceDataWithURL:(NSURL *)URL
{
    [self loadVoiceDataWithURL:URL target:nil success:NULL failure:NULL];
}

- (void)loadVoiceDataWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure
{
    __weak SillyVoiceDownloader* weakSelf = self;
    [[SillyVoiceCache sharedVoiceCache] queryDiskCacheForKey:[URL absoluteString] done:^(NSData *voice, SillyVoiceCacheType cacheType) {
        //check cache
        if (voice.length)
        {
            [weakSelf cancelLoadingVoiceDatasForTarget:target action:success];
            if (success)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    ((void (*)(id, SEL, id, id))objc_msgSend)(target, success, voice, URL);
                });
            }
            return;
        }
        
        //create new connection
        SillyVoiceConnection *connection = [[SillyVoiceConnection alloc] initWithURL:URL target:target success:success failure:failure];
        
        BOOL added = NO;
        for (NSUInteger i = 0; i < [weakSelf.connections count]; i++)
        {
            SillyVoiceConnection *existingConnection = weakSelf.connections[i];
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

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action
{
    NSInteger count = [self.connections count];
    for (NSInteger i = count - 1; i >= 0; i--)
    {
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
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
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
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
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL])
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingVoiceDatasForTarget:(id)target action:(SEL)action
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target && connection.success == action)
        {
            [connection cancel];
        }
    }
}

- (void)cancelLoadingVoiceDatasForTarget:(id)target
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target)
        {
            [connection cancel];
        }
    }
}

- (NSURL *)URLForTarget:(id)target action:(SEL)action
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target && connection.success == action)
        {
            return connection.URL;
        }
    }
    return nil;
}

- (NSURL *)URLForTarget:(id)target
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        SillyVoiceConnection *connection = self.connections[(NSUInteger)i];
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
