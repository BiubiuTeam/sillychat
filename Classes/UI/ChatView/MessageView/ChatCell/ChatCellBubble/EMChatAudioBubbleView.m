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

#import "EMChatAudioBubbleView.h"

NSString *const kRouterEventAudioBubbleTapEventName = @"kRouterEventAudioBubbleTapEventName";

@interface EMChatAudioBubbleView ()
{
    NSMutableArray *_senderAnimationImages;
    NSMutableArray *_recevierAnimationImages;
    UIImageView    *_isReadView;
}

@end

@implementation EMChatAudioBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ANIMATION_IMAGEVIEW_SIZE, ANIMATION_IMAGEVIEW_SIZE)];
        _animationImageView.contentMode = UIViewContentModeCenter;
        _animationImageView.animationDuration = ANIMATION_IMAGEVIEW_SPEED;
        [self addSubview:_animationImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ANIMATION_TIME_LABEL_WIDHT, ANIMATION_TIME_LABEL_HEIGHT)];
        _timeLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE_SMALL];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
        
        _isReadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        _isReadView.layer.cornerRadius = 3;
        [_isReadView setClipsToBounds:YES];
        [_isReadView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_isReadView];
        
        _senderAnimationImages = [[NSMutableArray alloc] initWithObjects:LOAD_ICON_USE_POOL_CACHE(SENDER_ANIMATION_IMAGEVIEW_IMAGE_01), LOAD_ICON_USE_POOL_CACHE(SENDER_ANIMATION_IMAGEVIEW_IMAGE_02), LOAD_ICON_USE_POOL_CACHE(SENDER_ANIMATION_IMAGEVIEW_IMAGE_03), nil];
        
        _recevierAnimationImages = [[NSMutableArray alloc] initWithObjects:LOAD_ICON_USE_POOL_CACHE(RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_01), LOAD_ICON_USE_POOL_CACHE(RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_02), LOAD_ICON_USE_POOL_CACHE(RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_03), nil];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = BUBBLE_VIEW_PADDING*2 + BUBBLE_ARROW_WIDTH + ANIMATION_TIME_LABEL_WIDHT +ANIMATION_TIME_IMAGEVIEW_PADDING + ANIMATION_IMAGEVIEW_SIZE;
    
    CGFloat maxHeight = MAX(ANIMATION_IMAGEVIEW_SIZE, ANIMATION_TIME_LABEL_HEIGHT);
    CGFloat height = BUBBLE_VIEW_PADDING*2 + maxHeight;
    return CGSizeMake(width, height);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _animationImageView.frame;
    if (self.model.isSender) {
        frame.origin.x = self.frame.size.width - BUBBLE_ARROW_WIDTH - frame.size.width - BUBBLE_VIEW_PADDING;
        frame.origin.y = self.frame.size.height / 2 - frame.size.height / 2;
        _animationImageView.frame = frame;
        
        frame = _timeLabel.frame;
        frame.origin.x = _animationImageView.frame.origin.x - ANIMATION_TIME_IMAGEVIEW_PADDING - ANIMATION_TIME_LABEL_WIDHT;
        frame.origin.y = _animationImageView.center.y - frame.size.height / 2;
        _timeLabel.frame = frame;

    }
    else {
        _animationImageView.image = LOAD_ICON_USE_POOL_CACHE(RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT);
        
        frame.origin.x = BUBBLE_ARROW_WIDTH + BUBBLE_VIEW_PADDING;
        frame.origin.y = self.frame.size.height / 2 - frame.size.height / 2;
        _animationImageView.frame = frame;
        
        frame = _timeLabel.frame;
        frame.origin.x = ANIMATION_TIME_IMAGEVIEW_PADDING + BUBBLE_ARROW_WIDTH + _animationImageView.frame.size.width + _animationImageView.frame.origin.x;
        frame.origin.y = _animationImageView.center.y - frame.size.height / 2;
        _timeLabel.frame = frame;
        
        _isReadView.top = _isReadView.height/2;
        _isReadView.right = self.width - _isReadView.height/2;
    }
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    [super setModel:model];
    
    _timeLabel.text = [NSString stringWithFormat:@"%zd'",self.model.time];
    
    if (self.model.isSender) {
        [_isReadView setHidden:YES];
        _animationImageView.image = LOAD_ICON_USE_POOL_CACHE(SENDER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT);
        _animationImageView.animationImages = _senderAnimationImages;
    }
    else{
        if (model.isPlayed) {
            [_isReadView setHidden:YES];
        }else{
            [_isReadView setHidden:NO];
        }

        _animationImageView.image = LOAD_ICON_USE_POOL_CACHE(RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT);
        _animationImageView.animationImages = _recevierAnimationImages;
    }
    
    if (self.model.isPlaying)
    {
        [self startAudioAnimation];
    }else {
        [self stopAudioAnimation];
    }
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventAudioBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}


+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return 2 * BUBBLE_VIEW_PADDING + ANIMATION_IMAGEVIEW_SIZE;
}

-(void)startAudioAnimation
{
    [_animationImageView startAnimating];
}

-(void)stopAudioAnimation
{
    [_animationImageView stopAnimating];
}

@end
