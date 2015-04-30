//
//  PostTextView.m
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PostTextView.h"

@interface PostTextView ()
{
    NSUInteger _textLength;
}

@end

@implementation PostTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dpTextDidChanged:) name:UITextViewTextDidChangeNotification object:self];
    _textLength = 0;
    _maxCount = 30;
    _minCount = 0;
    _inputCount = 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.countLabel = nil;
    
}

- (void)dpTextDidChanged:(NSNotification*)notification
{
    _textLength = [self.text length];
    [self sizeToFit];
    
    self.width = _defaultWidth;
    self.height = self.height + self.font.lineHeight;
    self.centerX = SCREEN_WIDTH/2;
    self.centerY = _defaultCenterY + self.font.lineHeight/2;
    
    if (self.markedTextRange) {
        return;
    }
    
    //统计字数
    NSString* textContent = [self text];
    _inputCount = [textContent length];
    
    if (_countLabel) {
        _countLabel.text = [NSString stringWithFormat:@"%zd/%zd",_inputCount,_maxCount];
    }
}

@end
