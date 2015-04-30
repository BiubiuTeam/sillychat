//
//  SillyVoiceEngine.h
//  sillyChat
//
//  Created by haowenliang on 15/4/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const SillyVoiceEngineFinishedPlay;
extern NSString* const SillyVoiceEngineStartPlay;

@interface SillyVoiceEngine : NSObject

+ (instancetype)shareInstance;

- (void)asyncPlayAudioWithPath:(NSString*)path;
- (void)stopVoicePlay;

@end
