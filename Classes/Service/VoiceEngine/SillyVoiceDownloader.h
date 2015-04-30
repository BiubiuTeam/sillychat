//
//  SillyVoiceDownloader.h
//  sillyChat
//
//  Created by haowenliang on 15/4/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SillyVoiceDownloader : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, assign) NSUInteger concurrentLoads;
@property (nonatomic, assign) NSTimeInterval timeout;

- (void)loadVoiceDataWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure;
- (void)loadVoiceDataWithURL:(NSURL *)URL target:(id)target action:(SEL)action;
- (void)loadVoiceDataWithURL:(NSURL *)URL;
- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action;
- (void)cancelLoadingURL:(NSURL *)URL target:(id)target;
- (void)cancelLoadingURL:(NSURL *)URL;
- (void)cancelLoadingVoiceDatasForTarget:(id)target action:(SEL)action;
- (void)cancelLoadingVoiceDatasForTarget:(id)target;
- (NSURL *)URLForTarget:(id)target action:(SEL)action;
- (NSURL *)URLForTarget:(id)target;

@end
