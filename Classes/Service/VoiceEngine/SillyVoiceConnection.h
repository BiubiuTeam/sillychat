//
//  SillyVoiceConnection.h
//  sillyChat
//
//  Created by haowenliang on 15/4/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SillyVoiceDownloadDidFail;
extern NSString *const SillyVoiceURLKey;
extern NSString *const SillyVoiceErrorKey;
extern NSString *const SillyVoiceDownloadDidFinish;
extern NSString *const SillyVoiceKey;

@interface SillyVoiceConnection : NSObject

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL success;
@property (nonatomic, assign) SEL failure;
@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic, getter = isCancelled) BOOL cancelled;

- (instancetype)initWithURL:(NSURL *)URL
                     target:(id)target
                    success:(SEL)success
                    failure:(SEL)failure;

- (void)start;
- (void)cancel;
- (BOOL)isInCache;

@end
