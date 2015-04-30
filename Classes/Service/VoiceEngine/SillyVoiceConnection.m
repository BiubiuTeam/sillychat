//
//  SillyVoiceConnection.m
//  sillyChat
//
//  Created by haowenliang on 15/4/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyVoiceConnection.h"
#import "SillyVoiceDownloader.h"
#import "SillyVoiceCache.h"

NSString *const SillyVoiceDownloadDidFail = @"_SillyVoiceDownloadDidFail_";
NSString *const SillyVoiceURLKey = @"SillyVoiceURLKey";
NSString *const SillyVoiceErrorKey = @"SillyVoiceErrorKey";
NSString *const SillyVoiceDownloadDidFinish = @"SillyVoiceDownloadDidFinish";
NSString *const SillyVoiceKey = @"SillyVoiceKey";

@implementation SillyVoiceConnection

- (instancetype)initWithURL:(NSURL *)URL
                     target:(id)target
                    success:(SEL)success
                    failure:(SEL)failure
{
    if ((self = [self init]))
    {
        self.URL = URL;
        self.target = target;
        self.success = success;
        self.failure = failure;
    }
    return self;
}

- (NSData *)cachedVoice
{
    NSData* voiceData = [[SillyVoiceCache sharedVoiceCache] voiceDataFromMemoryCacheForKey:[self.URL absoluteString]];
    if (!voiceData.length) {
        voiceData = [[SillyVoiceCache sharedVoiceCache] voiceDataFromDiskCacheForKey:[self.URL absoluteString]];
    }
    return voiceData;
}

- (BOOL)isInCache
{
    return [self cachedVoice] != nil;
}

- (void)loadFailedWithError:(NSError *)error
{
    self.loading = NO;
    self.cancelled = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SillyVoiceDownloadDidFail object:self.target userInfo:@{SillyVoiceURLKey: self.URL, SillyVoiceErrorKey: error}];
}

- (void)cacheVoiceData:(NSData *)voiceData
{
    if (!self.cancelled)
    {
        if (voiceData.length && self.URL)
        {
            [[SillyVoiceCache sharedVoiceCache] storeVoiceData:voiceData forKey:[self.URL absoluteString] toDisk:YES];
        }
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:voiceData, SillyVoiceKey, self.URL, SillyVoiceURLKey,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SillyVoiceDownloadDidFinish object:self.target userInfo:[userInfo copy]];
        self.loading = NO;
    }
    else
    {
        self.loading = NO;
        self.cancelled = NO;
    }
}

- (void)processDataInBackground:(NSData *)data
{
    @synchronized ([self class])
    {
        if (!self.cancelled)
        {
            if (data.length)
            {
                //add to cache (may be cached already but it doesn't matter)
                [self performSelectorOnMainThread:@selector(cacheVoiceData:)
                                       withObject:data
                                    waitUntilDone:YES];
            }
            else
            {
                @autoreleasepool
                {
                    NSError *error = [NSError errorWithDomain:@"SillyVoiceDownloader" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid voice data"}];
                    [self performSelectorOnMainThread:@selector(loadFailedWithError:) withObject:error waitUntilDone:YES];
                }
            }
        }
        else
        {
            //clean up
            [self performSelectorOnMainThread:@selector(cacheVoiceData:)
                                   withObject:nil
                                waitUntilDone:YES];
        }
    }
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveResponse:(__unused NSURLResponse *)response
{
    self.data = [NSMutableData data];
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //add data
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(__unused NSURLConnection *)connection
{
    [self performSelectorInBackground:@selector(processDataInBackground:) withObject:self.data];
    self.connection = nil;
    self.data = nil;
}

- (void)connection:(__unused NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.data = nil;
    [self loadFailedWithError:error];
}

- (void)start
{
    if (self.loading && !self.cancelled)
    {
        return;
    }
    
    //begin loading
    self.loading = YES;
    self.cancelled = NO;
    
    //check for nil URL
    if (self.URL == nil)
    {
        [self cacheVoiceData:nil];
        return;
    }
    
    //check for cached image
    NSData *voiceData = [self cachedVoice];
    if (voiceData)
    {
        //add to cache (cached already but it doesn't matter)
        [self performSelectorOnMainThread:@selector(cacheVoiceData:)
                               withObject:voiceData
                            waitUntilDone:NO];
        return;
    }
    
    //begin load
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:[SillyVoiceDownloader shareInstance].timeout];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)cancel
{
    self.cancelled = YES;
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
}

@end
