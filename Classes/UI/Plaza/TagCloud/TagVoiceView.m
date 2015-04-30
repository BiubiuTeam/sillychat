//
//  TagVoiceView.m
//  sillyChat
//
//  Created by haowenliang on 15/3/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "TagVoiceView.h"

#define ANIMATION_IMAGEVIEW_SIZE 30 // 小喇叭图片尺寸
#define ANIMATION_IMAGEVIEW_SPEED 1 // 小喇叭动画播放速度
#define ANIMATION_TIME_IMAGEVIEW_PADDING 5 // 时间与动画间距
#define ANIMATION_TIME_LABEL_WIDHT 30 // 时间宽度
#define ANIMATION_TIME_LABEL_HEIGHT 15 // 时间高度
#define ANIMATION_TIME_LABEL_FONT_SIZE 14 // 时间字体

// 接收
#define VOICE_ANIMATION_IMAGE_DEFAULT @"private/silly_voice_play_right3.png" // 小喇叭默认图片
#define VOICE_ANIMATION_IMAGE_01 @"private/silly_voice_play_right1.png" // 小喇叭动画第一帧
#define VOICE_ANIMATION_IMAGE_02 @"private/silly_voice_play_right2.png" // 小喇叭动画第二帧
#define VOICE_ANIMATION_IMAGE_03 @"private/silly_voice_play_right3.png" // 小喇叭动画第三帧

@interface TagVoiceView ()
{
    NSMutableArray *_animationImages;
}

@end

@implementation TagVoiceView

- (instancetype)initWithFrame:(CGRect)frame viewType:(BroacastType)viewType
{
    if (self = [super initWithFrame:frame viewType:viewType]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        self.viewType = BroacastType_Voice;
    }
    return self;
}

- (void)setupUiControls
{
    _animationImages = [[NSMutableArray alloc] initWithObjects:LOAD_ICON_USE_POOL_CACHE(VOICE_ANIMATION_IMAGE_01), LOAD_ICON_USE_POOL_CACHE(VOICE_ANIMATION_IMAGE_02), LOAD_ICON_USE_POOL_CACHE(VOICE_ANIMATION_IMAGE_03), nil];
    
    _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ANIMATION_IMAGEVIEW_SIZE, ANIMATION_IMAGEVIEW_SIZE)];
    _animationImageView.animationImages = _animationImages;
    _animationImageView.contentMode = UIViewContentModeCenter;
    _animationImageView.animationDuration = ANIMATION_IMAGEVIEW_SPEED;
    [self addSubview:_animationImageView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ANIMATION_TIME_LABEL_WIDHT, ANIMATION_TIME_LABEL_HEIGHT)];
    _timeLabel.font = [UIFont boldSystemFontOfSize:ANIMATION_TIME_LABEL_FONT_SIZE];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_timeLabel];
}

- (void)sizeToFit
{
    CGFloat width = 8*2 + 5 + ANIMATION_TIME_LABEL_WIDHT +ANIMATION_TIME_IMAGEVIEW_PADDING + ANIMATION_IMAGEVIEW_SIZE;
    self.width = width;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _animationImageView.frame;
    UIImage* voiceImage = LOAD_ICON_USE_POOL_CACHE(VOICE_ANIMATION_IMAGE_DEFAULT);
    _animationImageView.image = voiceImage;
    frame.origin.x = _size_S(8);
    frame.origin.y = self.height / 4;
    frame.size.height = self.height/2;
    _animationImageView.frame = frame;
    
    frame = _timeLabel.frame;
    frame.origin.x = ANIMATION_TIME_IMAGEVIEW_PADDING + _animationImageView.right;
    frame.origin.y = _animationImageView.center.y - frame.size.height / 2;
    frame.size.width = self.width - frame.origin.x - ANIMATION_TIME_IMAGEVIEW_PADDING;
    _timeLabel.frame = frame;
}

#pragma mark - public

- (void)setViewContent:(id)content
{
    _timeLabel.text = [NSString stringWithFormat:@"%zd \"",[(NSNumber*)content integerValue]];
}

- (void)setDatasource:(NSObject *)datasource
{
    [super setDatasource:datasource];
    [self sizeToFit];
}

-(void)startAudioAnimation
{
    [_animationImageView startAnimating];
    _animation = YES;
}

-(void)stopAudioAnimation
{
    [_animationImageView stopAnimating];
    _animation = NO;
}

@end
