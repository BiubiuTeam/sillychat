//
//  EmojiItem.m
//  sillyChat
//
//  Created by haowenliang on 15/3/17.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EmojiItem.h"
#import "EmojiConstants.h"

@interface EmojiItem ()

@property (nonatomic, strong) UIButton* emojiButton;
@property (nonatomic, strong) UILabel* emojiLabel;

@end

@implementation EmojiItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.emojiButton];
        [self addSubview:self.emojiLabel];
    }
    return self;
}

- (UIButton *)emojiButton
{
    if (nil == _emojiButton) {
        _emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiButton addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _emojiButton.frame = CGRectMake(0, 0, EmojiWidth, EmojiWidth);
    }
    return _emojiButton;
}

- (UILabel *)emojiLabel
{
    if (nil == _emojiLabel) {
        _emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - EmojiWidth)];
        _emojiLabel.backgroundColor = [UIColor clearColor];
        _emojiLabel.font = [UIFont systemFontOfSize:18];
        _emojiLabel.textAlignment = NSTextAlignmentCenter;
        _emojiLabel.textColor = [UIColor whiteColor];
        _emojiLabel.bottom = self.height;
    }
    return _emojiLabel;
}

- (void)setEmojiName:(NSString *)emojiName
{
    _emojiName = emojiName;
    
    UIImage* emojiIcon = [UIImage imageNamed:_emojiName];
    [_emojiButton setImage:emojiIcon forState:UIControlStateNormal];
    [_emojiButton setImage:emojiIcon forState:UIControlStateHighlighted];
    [_emojiButton setImage:emojiIcon forState:UIControlStateSelected];
    
    [_emojiLabel setText:_emojiName];
}

- (void)emojiButtonPressed:(UIButton *)button
{
    // Add a simple scale animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.byValue = @0.3;
    animation.duration = 0.1;
    animation.autoreverses = YES;
    [button.layer addAnimation:animation forKey:nil];
    
    // Callback
    if ([self.delegate respondsToSelector:@selector(emojiButtonPressed:)]) {
        [self.delegate emojiButtonPressed:_emojiName];
    }
}

@end
