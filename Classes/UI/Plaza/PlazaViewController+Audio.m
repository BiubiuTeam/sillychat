//
//  PlazaViewController+Audio.m
//  sillyChat
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaViewController+Audio.h"
#import "UIViewController+HUD.h"
#import "PlazaViewController+Uploader.h"
#import "SillyVoiceDownloader.h"

#import "UmLogEngine.h"
@implementation PlazaViewController (Audio)

- (DXRecordView *)recordView
{
    if (nil == _recordView) {
        _recordView = [[DXRecordView alloc] initWithFrame:CGRectZero];
    }
    return _recordView;
}

-(void)longPressGestureOpt:(UILongPressGestureRecognizer *)longGer
{
    [UmLogEngine logEvent:EventPressureMode];
    switch (longGer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"_UIGestureRecognizerStateBegan_");
            [self recordButtonTouchDown];
            break;
        case UIGestureRecognizerStateChanged:{
            NSLog(@"_UIGestureRecognizerStateChanged_");
            UIView* view = longGer.view;
            CGSize size = view.size;
            CGPoint location = [longGer locationInView:longGer.view];
            if ((location.x < 0 || location.x > size.width) || (location.y < 0 || location.y > size.height)) {
                DPTrace("outside");
                [self recordDragOutside];
            }else{
                [self recordDragInside];
            }
        } break;
        case UIGestureRecognizerStateEnded:{
            NSLog(@"_UIGestureRecognizerStateEnded_");
            UIView* view = longGer.view;
            CGSize size = view.size;
            CGPoint location = [longGer locationInView:longGer.view];
            if ((location.x < 0 || location.x > size.width) || (location.y < 0 || location.y > size.height)) {
                DPTrace("outside");
                [self recordButtonTouchUpOutside];
            }else{
                [self recordButtonTouchUpInside];
            }
            _roundButton.highlighted = NO;
        }break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"_UIGestureRecognizerStateCancelled_");
            [self recordButtonTouchUpOutside];
            _roundButton.highlighted = NO;
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"_UIGestureRecognizerStateFailed_");
            [self recordButtonTouchUpOutside];
            _roundButton.highlighted = NO;
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"_UIGestureRecognizerStatePossible_");
            _roundButton.highlighted = NO;
            break;
        default:
            break;
    }
    
}

#pragma mark -
- (void)recordButtonTouchDown
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchDown];
    }
    
    [self didStartRecordingVoiceAction];
}

- (void)recordButtonTouchUpOutside
{
    [self didCancelRecordingVoiceAction];
    
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpOutside];
    }
    
    [self.recordView removeFromSuperview];
}

- (void)recordButtonTouchUpInside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpInside];
    }
    [self didFinishRecoingVoiceAction];
    
    [self.recordView removeFromSuperview];
}

- (void)recordDragOutside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonDragOutside];
    }
    
}

- (void)recordDragInside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonDragInside];
    }
    
}

#pragma mark -
/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction
{
    if ([self canRecord]) {
        self.recordView.center = self.view.center;
        [self.view addSubview:self.recordView];
        [self.view bringSubviewToFront:self.recordView];
        
        NSError *error = nil;
        [[EaseMob sharedInstance].chatManager startRecordingAudioWithError:&error];
        if (error) {
            NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
        }
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction
{
    [[EaseMob sharedInstance].chatManager asyncCancelRecordingAudioWithCompletion:nil onQueue:nil];
    
    [_recordView removeFromSuperview];
    self.recordView = nil;
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction
{
    [[EaseMob sharedInstance].chatManager
     asyncStopRecordingAudioWithCompletion:^(EMChatVoice *aChatVoice, NSError *error){
         if (!error) {
             [self showHudInView:self.view hint:@"语音上传中..."];
             [self addAudioFileUploadTask:aChatVoice.localPath withExtension:@{@"duration":@(aChatVoice.duration)}];
         }else{
             if (error.code == EMErrorAudioRecordNotStarted) {
                 [self showHint:error.domain yOffset:-40];
             } else {
                 [self showHint:error.domain];
             }
         }
     } onQueue:nil];
    
    [_recordView removeFromSuperview];
    self.recordView = nil;
}

#pragma mark - private

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

- (void)asyncPlayAudioWithPath:(NSString*)path
{
    NSURL* url = [NSURL URLWithString:path];
    [[SillyVoiceDownloader shareInstance] loadVoiceDataWithURL:url target:self action:@selector(playVoice:)];
}

- (void)stopVoicePlay
{
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
    });
}

- (void)playVoice:(NSData*)data
{
    [[[EaseMob sharedInstance] deviceManager] enableProximitySensor];
    EMChatVoice* chatVoice = [[EMChatVoice alloc] initWithData:data displayName:@""];
    [[EaseMob sharedInstance].chatManager asyncPlayAudio:chatVoice completion:^(EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
        });
    } onQueue:nil];
}

@end
