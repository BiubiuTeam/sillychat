//
//  EmojiAnimationView.m
//  sillyChat
//
//  Created by haowenliang on 15/3/18.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EmojiAnimationView.h"
#import "EmojiConstants.h"
#import "UIImage+Rotate.h"
@interface EmojiAnimationView ()
{
    CGFloat _offsetInfps;
}
@property (nonatomic, strong) CADisplayLink* link;

@end

@implementation EmojiAnimationView

+ (void)showEmoji:(NSString*)emoji aboveView:(UIView*)superView yPosition:(CGFloat)position leftOrientation:(BOOL)toleft
{
    superView = [UIApplication sharedApplication].keyWindow;
    
    position = 5 + random()%abs(SCREEN_HEIGHT-EmojiViewHeight - 5);
    
    NSString* flyEmojiName = [NSString stringWithFormat:@"Emoji-%@.png",emoji];
    UIImage* flyEmoji = [UIImage imageNamed:flyEmojiName];
    if (toleft == NO) {
        flyEmoji = [flyEmoji rotate:UIImageOrientationUpMirrored];
    }
    EmojiAnimationView* flyView = [[EmojiAnimationView alloc] initWithImage:flyEmoji];
    flyView.LeftOrientation = toleft;
    
    flyView.top = position;
    
    [superView addSubview:flyView];
    [superView bringSubviewToFront:flyView];
    [flyView startAnimation];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self animationInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super initWithImage:image]) {
        [self animationInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self animationInit];
}

- (void)animationInit
{
    _LeftOrientation = YES;
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleAspectFit;
    _offsetInfps = 1.5;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    CGRect frame = self.frame;
    frame.size.height = EmojiWidth;
    frame.size.width = image.size.width * EmojiWidth/image.size.height;
    
    [self setFrame:frame];
}

- (void)startAnimation
{
    if (_LeftOrientation) {
        self.left = SCREEN_WIDTH;
    }else{
        self.left = -self.width;
    }

    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
    if (_link) {
        [_link invalidate];
        self.link = nil;
    }
}

- (CADisplayLink *)link
{
    if (nil == _link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    }
    return _link;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    if (_LeftOrientation) {
        self.left = self.left - _offsetInfps;
        if ( - self.left > self.width) {
            [self stopAnimation];
            [self removeFromSuperview];
        }
    }else{
        self.left = self.left + _offsetInfps;
        if (self.left > self.width + SCREEN_WIDTH) {
            [self stopAnimation];
            [self removeFromSuperview];
        }
    }
}

- (void)dealloc
{
    [self stopAnimation];
}

@end
