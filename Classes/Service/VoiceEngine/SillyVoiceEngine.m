//
//  SillyVoiceEngine.m
//  sillyChat
//
//  Created by haowenliang on 15/4/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyVoiceEngine.h"
#import "SillyVoiceDownloader.h"

NSString* const SillyVoiceEngineFinishedPlay = @"_SillyVoiceEngineFinishedPlay_";
NSString* const SillyVoiceEngineStartPlay = @"_SillyVoiceEngineStartPlay_";

@interface SillyVoiceEngine ()
@property (nonatomic, strong) NSString* currentVoicePath;
@end

@implementation SillyVoiceEngine

+ (instancetype)shareInstance
{
    static SillyVoiceEngine* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[SillyVoiceEngine alloc] init];
    });
    return s_instance;
}

- (void)asyncPlayAudioWithPath:(NSString*)path
{
    self.currentVoicePath = path;
    NSURL* url = [NSURL URLWithString:path];
    [[SillyVoiceDownloader shareInstance] loadVoiceDataWithURL:url target:self action:@selector(playVoice:)];
}

- (void)stopVoicePlay
{
    @synchronized(_currentVoicePath){
        [[EaseMob sharedInstance].chatManager stopPlayingAudio];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
            if (_currentVoicePath.length) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SillyVoiceEngineFinishedPlay object:nil userInfo:@{@"VoicePath":_currentVoicePath}];
            }
            self.currentVoicePath = nil;
        });
    }
}

- (void)playVoice:(NSData*)data
{
    @synchronized(_currentVoicePath){
        [[NSNotificationCenter defaultCenter] postNotificationName:SillyVoiceEngineStartPlay object:nil userInfo:@{@"VoicePath":_currentVoicePath}];
        
        [[[EaseMob sharedInstance] deviceManager] enableProximitySensor];
        EMChatVoice* chatVoice = [[EMChatVoice alloc] initWithData:data displayName:@""];
        
        __block NSString* weakPath = [[NSString alloc] initWithString:_currentVoicePath];
        [[EaseMob sharedInstance].chatManager asyncPlayAudio:chatVoice completion:^(EMError *error) {
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
                    if ([weakPath isEqualToString:_currentVoicePath]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:SillyVoiceEngineFinishedPlay object:nil userInfo:@{@"VoicePath":weakPath}];
                    }
                    weakPath = nil;
                });
            }
        } onQueue:nil];
    }
}

@end
