//
//  EMChatImageStillBubbleView.m
//  sillyChat
//
//  Created by haowenliang on 15/5/4.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMChatImageStillBubbleView.h"
#import "EMChatTextBubbleView.h"
#import "UIImageAdditions.h"

#define IMAGE_DEFAULT_WIDTH _size_S(172)
#define IMAGE_DEFAULT_HEIGHT _size_S(118)
#define IMAGE_DEFAULT_RADIUS _size_S(4)

@implementation EMChatImageStillBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.userInteractionEnabled = NO;
        _textLabel.multipleTouchEnabled = NO;
        _textLabel.text = @"长按查看\n松手销毁";
        [_textLabel sizeToFit];
        [self addSubview:_textLabel];
        
        [self addSubview:self.progressView];
        _progressView.frame = CGRectMake(0, 2*BUBBLE_VIEW_PADDING, IMAGE_DEFAULT_WIDTH - 2*BUBBLE_VIEW_PADDING, BUBBLE_PROGRESSVIEW_HEIGHT);
        _progressView.hidden = YES;
        
        UIImage *image = [UIImage imageWithColor:RGBACOLOR(0x97, 0x97, 0x97, 1) size:CGSizeMake(IMAGE_DEFAULT_WIDTH, IMAGE_DEFAULT_HEIGHT)];
        self.imageView.image = image;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _progressView.centerX = self.width/2;
    _textLabel.center = CGPointMake(self.width/2, self.height/2);
    [self bringSubviewToFront:_textLabel];
    [self bringSubviewToFront:_progressView];
}

- (void)progress:(CGFloat)progress;
{
    self.progressView.hidden = NO;
    [super progress:progress];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(IMAGE_DEFAULT_WIDTH + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, 2 * BUBBLE_VIEW_PADDING + IMAGE_DEFAULT_HEIGHT);
}

+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return 2 * BUBBLE_VIEW_PADDING + IMAGE_DEFAULT_HEIGHT;
}

- (void)setModel:(MessageModel *)model
{
    [super setModel:model];
    UIImage *image = [UIImage imageWithColor:RGBACOLOR(0x97, 0x97, 0x97, 1) size:CGSizeMake(IMAGE_DEFAULT_WIDTH, IMAGE_DEFAULT_HEIGHT)];
    self.imageView.image = image;
}

- (void)setProgress:(float)progress
         forMessage:(EMMessage *)message
     forMessageBody:(id<IEMMessageBody>)messageBody
{
    if ([[_model.message messageId] isEqualToString:[message messageId]]) {
        DPTrace("下载进度: %f",progress);
        [self progress:progress];
    }else {
        DPTrace("%@ 的进度 %f",message.messageId,progress);
    }
}

- (void)setProgress:(float)progress
         forMessage:(EMMessage *)message
{
    DPTrace("下载进度: %f",progress);
}

- (void)setProgress:(float)progress
{
    DPTrace("下载进度: %f",progress);
}
@end
