//
//  ChatRoomBubbleView.m
//  sillyChat
//
//  Created by haowenliang on 15/4/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatRoomBubbleView.h"
#import "MessageModel.h"

@interface ChatRoomBubbleView ()
@property (nonatomic, strong) UIImageView* arrowImgView;
@end

@implementation ChatRoomBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.multipleTouchEnabled = YES;
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _backImageView.image = [self bubbleBackgroundImage];
        [self addSubview:_backImageView];
        
        _arrowImgView = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"silly_broadcast_info_arrow.png")];
        _arrowImgView.backgroundColor = [UIColor clearColor];
        _arrowImgView.contentMode = UIViewContentModeCenter;
        [self addSubview:_arrowImgView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)bubbleViewPressed:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didPressedBubbleView:datasource:)]) {
        [_delegate didPressedBubbleView:self datasource:_datasource];
    }
}

- (UIImage*)bubbleBackgroundImage
{
    NSString* bubbleName = @"silly_broadcast_info_bg.png";
    UIImage* image = LOAD_ICON_USE_POOL_CACHE(bubbleName);
    
    NSInteger leftCapWidth = 4;
    NSInteger topCapHeight =  6;
    return [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

- (void)setTextContent:(NSString *)content
{
    
}

- (void)setImagePath:(NSString *)path
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backImageView.frame = self.bounds;
    
    _arrowImgView.centerY = self.height/2;
    _arrowImgView.right = self.width;
}
@end
