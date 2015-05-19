/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "DXRecordView.h"

@interface DXRecordView ()
{
    NSTimer *_timer;
    // 显示动画的ImageView
    UIImageView *_recordAnimationView;
    // 提示文字
    UILabel *_textLabel;
    
    BOOL _isRecording;
}

@end

@implementation DXRecordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.size = CGSizeMake(120, 120);
    self.backgroundColor = RGBACOLOR(0x66, 0x55, 0x00, 1);
    self.layer.cornerRadius = 60;
    self.layer.masksToBounds = YES;
    
    _isRecording = NO;
    _recordAnimationView = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"voice/silly_voice_feedback1.png")];
    _recordAnimationView.contentMode = UIViewContentModeCenter;
    _recordAnimationView.center = CGPointMake(self.width/2, self.height/2 - 11);
    [self addSubview:_recordAnimationView];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                           _recordAnimationView.bottom + _size_S(8),
                                                           self.bounds.size.width - 20,
                                                           14)];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.text = @"手指上滑，取消发送";
    [self addSubview:_textLabel];
    _textLabel.font = [UIFont systemFontOfSize:10];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.layer.cornerRadius = 5;
    _textLabel.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
    _textLabel.layer.masksToBounds = YES;
}

// 录音按钮按下
-(void)recordButtonTouchDown
{
    // 需要根据声音大小切换recordView动画
    _textLabel.text = @"手指上滑，取消发送";
    _textLabel.backgroundColor = [UIColor clearColor];
    _isRecording = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                              target:self
                                            selector:@selector(setVoiceImage)
                                            userInfo:nil
                                             repeats:YES];
    
}
// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside
{
    [_timer invalidate];
}
// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside
{
    [_timer invalidate];
}
// 手指移动到录音按钮内部
-(void)recordButtonDragInside
{
    _isRecording = YES;
    _textLabel.text = @"手指上滑，取消发送";
    _textLabel.backgroundColor = [UIColor clearColor];
}

// 手指移动到录音按钮外部
-(void)recordButtonDragOutside
{
    _isRecording = NO;
    _textLabel.text = @"松开手指，取消发送";
    _textLabel.backgroundColor = [UIColor redColor];
}

-(void)setVoiceImage
{
    if (_isRecording == NO) {
        
        return;
    }
    _recordAnimationView.image = LOAD_ICON_USE_POOL_CACHE(@"voice/silly_voice_feedback1.png");
    double voiceSound = 0;
    voiceSound = [[EaseMob sharedInstance].deviceManager peekRecorderVoiceMeter];
    if (0 < voiceSound <= 0.25) {
        [_recordAnimationView setImage:LOAD_ICON_USE_POOL_CACHE(@"voice/silly_voice_feedback1.png")];
    }else if (0.25<voiceSound<=0.50) {
        [_recordAnimationView setImage:LOAD_ICON_USE_POOL_CACHE(@"voice/silly_voice_feedback2.png")];
    }else if (0.50<voiceSound<=0.75) {
        [_recordAnimationView setImage:LOAD_ICON_USE_POOL_CACHE(@"voice/silly_voice_feedback3.png")];
    }else {
        [_recordAnimationView setImage:LOAD_ICON_USE_POOL_CACHE(@"voice/silly_voice_feedback4.png")];
    }
}

@end
