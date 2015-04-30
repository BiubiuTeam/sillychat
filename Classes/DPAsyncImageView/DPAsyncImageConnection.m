//
//  DPAsyncImageConnection.m
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPAsyncImageConnection.h"
#import "DPAsyncImageLoader.h"
#import "UIImage+Helper.h"
//利用SDImageCache来管理图片缓存
#import <SDWebImage/SDImageCache.h>

@implementation DPAsyncImageConnection

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


- (UIImage *)cachedImage
{
    if ([self.URL isFileURL])
    {
        NSString *path = [[self.URL absoluteURL] path];
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        if ([path hasPrefix:resourcePath])
        {
            return [UIImage imageNamed:[path substringFromIndex:[resourcePath length]]];
        }
    }
    UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[self.URL absoluteString]];
    if (nil == image) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self.URL absoluteString]];
     }
    return image;
}

- (BOOL)isInCache
{
    return [self cachedImage] != nil;
}

- (void)loadFailedWithError:(NSError *)error
{
    self.loading = NO;
    self.cancelled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:DPAsyncImageLoadDidFail object:self.target userInfo:@{DPAsyncImageURLKey: self.URL, DPAsyncImageErrorKey: error}];
}

- (void)cacheImage:(UIImage *)image
{
    if (!self.cancelled)
    {
        if (image && self.URL)
        {
            BOOL storeInCache = YES;
            if ([self.URL isFileURL])
            {
                if ([[[self.URL absoluteURL] path] hasPrefix:[[NSBundle mainBundle] resourcePath]])
                {
                    //do not store in cache
                    storeInCache = NO;
                }
            }
            if (storeInCache)
            {
                [[SDImageCache sharedImageCache] storeImage:[UIImage fixOrientation:image] forKey:[self.URL absoluteString] toDisk:YES];
            }
        }
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, DPAsyncImageImageKey,
                                         self.URL, DPAsyncImageURLKey,
                                         nil];
        self.loading = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:DPAsyncImageLoadDidFinish object:self.target userInfo:[userInfo copy]];
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
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image)
            {
                //redraw to prevent deferred decompression
                UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
                [image drawAtPoint:CGPointZero];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                //add to cache (may be cached already but it doesn't matter)
                [self performSelectorOnMainThread:@selector(cacheImage:)
                                       withObject:image
                                    waitUntilDone:YES];
            }
            else
            {
                @autoreleasepool
                {
                    NSError *error = [NSError errorWithDomain:@"DPAsyncImageLoader" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid image data"}];
                    [self performSelectorOnMainThread:@selector(loadFailedWithError:) withObject:error waitUntilDone:YES];
                }
            }
        }
        else
        {
            //clean up
            [self performSelectorOnMainThread:@selector(cacheImage:)
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
        [self cacheImage:nil];
        return;
    }
    
    //check for cached image
    UIImage *image = [self cachedImage];
    if (image)
    {
        //add to cache (cached already but it doesn't matter)
        [self performSelectorOnMainThread:@selector(cacheImage:)
                               withObject:image
                            waitUntilDone:NO];
        return;
    }
    
    //begin load
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:[DPAsyncImageLoader sharedLoader].loadingTimeout];
    
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
