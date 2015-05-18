//
//  FishBubbleView.m
//  sillyChat
//
//  Created by haowenliang on 15/5/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "FishBubbleView.h"

#define FishView_Width _size_S(225)
#define FishView_Height _size_S(186)

#define FishBubbleView_Width _size_S(41)
#define FishBubbleView_Height _size_S(88)

@interface FishBubbleView ()
@property (nonatomic, strong) UIImageView* bubbleView;
@end

@implementation FishBubbleView

- (instancetype)init
{
    if (self = [super init]) {
        [self setupFishView];
    }
    return self;
}

- (UIImageView *)bubbleView
{
    if (nil == _bubbleView) {
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, FishBubbleView_Width, FishBubbleView_Height)];
        _bubbleView.backgroundColor = [UIColor clearColor];
        _bubbleView.contentMode = UIViewContentModeScaleAspectFit;
        _bubbleView.animationDuration = 2;
        _bubbleView.animationImages = @[LOAD_ICON_USE_POOL_CACHE(@"fish_bubble/fish_bubble0.png"),LOAD_ICON_USE_POOL_CACHE(@"fish_bubble/fish_bubble1.png"),LOAD_ICON_USE_POOL_CACHE(@"fish_bubble/fish_bubble2.png"),LOAD_ICON_USE_POOL_CACHE(@"fish_bubble/fish_bubble3.png")];
    }
    return _bubbleView;
}

- (void)setupFishView
{
    self.size = CGSizeMake(FishView_Width, FishView_Height);
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.image = LOAD_ICON_USE_POOL_CACHE(@"fish_bubble/fish_background.png");
    [self addSubview:self.bubbleView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bubbleView.right = self.width;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [_bubbleView startAnimating];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    [_bubbleView startAnimating];
}

- (void)removeFromSuperview
{
    [_bubbleView stopAnimating];
    [super removeFromSuperview];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (hidden) {
        [_bubbleView stopAnimating];
    }else{
        [_bubbleView startAnimating];
    }
}
@end
