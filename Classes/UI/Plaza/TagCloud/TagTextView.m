//
//  TagTextView.m
//  sillyChat
//
//  Created by haowenliang on 15/3/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "TagTextView.h"

#define TEXT_INSET _size_S(6)

@interface TagTextView ()
@property (nonatomic, strong) NSString* textContent;
@property (nonatomic, strong) UIFont* font;

@end

@implementation TagTextView

- (void)setupUiControls
{
    [super setupUiControls];
    [self addSubview:self.msgLabel];
}

- (void)setViewContent:(id)content
{
    if ([content isKindOfClass:[NSString class]]) {
        self.textContent = content;
    }
    
    [self updateAppearance];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _msgLabel.height = self.height;
    _msgLabel.width = self.width - 2 * TEXT_INSET;
    _msgLabel.centerX = self.width/2;
}

- (UILabel *)msgLabel
{
    if (nil == _msgLabel) {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.height = self.height;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.font = self.font;
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _msgLabel.numberOfLines = 0;
    }
    return _msgLabel;
}

- (UIFont *)font
{
    if (nil == _font) {
        _font = [UIFont fontWithName:@"STHeitiSC-Medium" size:FONT_SIZE_SMALL];
    }
    return _font;
}

- (void)updateAppearance
{
    _msgLabel.text = _textContent;
}

@end
