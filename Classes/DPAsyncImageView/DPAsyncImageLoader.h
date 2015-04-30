//
//  DPAsyncImageLoader.h
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const DPAsyncImageLoadDidFinish;
extern NSString *const DPAsyncImageLoadDidFail;

extern NSString *const DPAsyncImageImageKey;
extern NSString *const DPAsyncImageURLKey;
extern NSString *const DPAsyncImageCacheKey;
extern NSString *const DPAsyncImageErrorKey;


@interface DPAsyncImageLoader : NSObject

+ (instancetype)sharedLoader;
- (UIImage*)getCacheImageWithKey:(NSString*)key;

@property (nonatomic, assign) NSUInteger concurrentLoads;
@property (nonatomic, assign) NSTimeInterval loadingTimeout;

- (void)loadImageWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure;
- (void)loadImageWithURL:(NSURL *)URL target:(id)target action:(SEL)action;
- (void)loadImageWithURL:(NSURL *)URL;
- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action;
- (void)cancelLoadingURL:(NSURL *)URL target:(id)target;
- (void)cancelLoadingURL:(NSURL *)URL;
- (void)cancelLoadingImagesForTarget:(id)target action:(SEL)action;
- (void)cancelLoadingImagesForTarget:(id)target;
- (NSURL *)URLForTarget:(id)target action:(SEL)action;
- (NSURL *)URLForTarget:(id)target;

@end
