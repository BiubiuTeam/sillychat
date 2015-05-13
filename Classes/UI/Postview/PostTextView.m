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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dpBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dpEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
    
    _textLength = 0;
    _maxCount = 30;
    _minCount = 0;
    _inputCount = 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.countLabel = nil;
    DPTrace("\n------------输入框销毁----------");
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

- (void)dpBeginEditing:(NSNotification*)notification
{
    [self updateEditingPlaceholderState];
}

- (void)dpEndEditing:(NSNotification*)notification
{
    [self updateEditingPlaceholderState];
}

- (void)drawRect:(CGRect)rect
{
    if ([self.text length] == 0) {
        NSString *text = nil;
        if (_isEditing) {
            if (_editingPlaceholder) {
                text = _editingPlaceholder;
            }
        }else{
            if (_defaultPlaceholder) {
                text = _defaultPlaceholder;
            }
        }
        
        if (text) {
            _isPlaceholderDisplayed = YES;
            [RGBACOLOR(0xee, 0xee, 0xee, 1) set];
            [text drawInRect:self.bounds withFont:self.font lineBreakMode:NSLineBreakByWordWrapping alignment:self.textAlignment];
        }else{
            _isPlaceholderDisplayed = NO;
        }
    }else{
        _isPlaceholderDisplayed = NO;
    }
}

-(void)setText:(NSString *)text
{
    // http://stackoverflow.com/questions/19948394/textviewdidchange-crashes-in-ios-7
    // 加 markedTextRange 判断，防止crash，见上面的帖子
    if (self.markedTextRange) {
        return;
    }
    
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

-(void)setText:(NSString *)text withRange:(NSRange)range
{
    [self setText:text];
    self.selectedRange = range;
}

- (BOOL)becomeFirstResponder
{
    self.isEditing = YES;
    BOOL ret = [super becomeFirstResponder];
    return ret;
}

- (BOOL)resignFirstResponder
{
    self.isEditing = NO;
    BOOL ret = [super resignFirstResponder];
    return ret;
}

- (void)setDefaultPlaceholder:(NSString *)defaultPlaceholder
{
    if (_defaultPlaceholder != defaultPlaceholder) {
        _defaultPlaceholder = defaultPlaceholder;
        [self setNeedsDisplay];
    }
}

- (void)setEditingPlaceholder:(NSString *)editingPlaceholder
{
    if (_editingPlaceholder != editingPlaceholder) {
        _editingPlaceholder = editingPlaceholder;
        [self setNeedsDisplay];
    }
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (isEditing != _isEditing) {
        _isEditing  = isEditing;
        
        [self setNeedsDisplay];
    }
}

- (void)updateEditingPlaceholderState
{
    BOOL needPlaceholderDisplayed = NO;
    if ([self.text length] == 0) {
        if (_isEditing) {
            if (_editingPlaceholder) {
                needPlaceholderDisplayed = YES;
            }
        }else{
            if (_defaultPlaceholder) {
                needPlaceholderDisplayed = YES;
            }
        }
    }
    
    if (needPlaceholderDisplayed != _isPlaceholderDisplayed) {
        [self setNeedsDisplay];
    }
}

@end

#define PTVAV_BTN_WIDTH _size_S(20)
#define PTVAV_BTN_HEIGHT _size_S(48)

#define PTVAV_HEIGHT _size_S(80)
#define PTVAV_LABEL_BOTTOM _size_S(45)

#define PTVAV_MARGIN_HOR _size_S(19)

@implementation PostTextViewAccessoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size = CGSizeMake(SCREEN_WIDTH, PTVAV_HEIGHT);
    if (self = [super initWithFrame:frame]) {
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - PTVAV_BTN_HEIGHT, self.width, PTVAV_BTN_HEIGHT)];
        _bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bgView];
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height -1 , self.width, 1)];
        _sepLine.backgroundColor = RGBACOLOR(0x97, 0x97, 0x97, 1);
        [self addSubview:_sepLine];
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.shuffleButton];
        [self addSubview:self.closeButton];
        [self addSubview:self.countLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self bringSubviewToFront:_sepLine];
}

- (UIButton *)shuffleButton
{
    if (nil == _shuffleButton) {
        _shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shuffleButton.size = CGSizeMake(PTVAV_BTN_WIDTH, PTVAV_BTN_HEIGHT);
        _shuffleButton.left = PTVAV_MARGIN_HOR;
        _shuffleButton.bottom = self.height;
        _shuffleButton.backgroundColor = [UIColor clearColor];
        _shuffleButton.contentMode = UIViewContentModeScaleAspectFit;
        
        [_shuffleButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_shuffle.png") forState:UIControlStateNormal];
        [_shuffleButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_shuffle2.png") forState:UIControlStateHighlighted];
        [_shuffleButton addTarget:self action:@selector(shufflePostOpt) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shuffleButton;
}

- (UIButton *)closeButton
{
    if (nil == _closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.size = CGSizeMake(PTVAV_BTN_WIDTH, PTVAV_BTN_HEIGHT);
        _closeButton.right = self.width - PTVAV_MARGIN_HOR;
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.contentMode = UIViewContentModeScaleAspectFit;
        _closeButton.bottom = self.height;
        [_closeButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_arrow.png") forState:UIControlStateNormal];
        [_closeButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_arrow2.png") forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(endEdittingOpt) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)countLabel
{
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.font = [DPFont systemFontOfSize:20];
        
        _countLabel.text = @"100/100";
        [_countLabel sizeToFit];
        _countLabel.text = @"";
        
        _countLabel.right = SCREEN_WIDTH - PTVAV_MARGIN_HOR;
        
        self.height = _countLabel.height + PTVAV_LABEL_BOTTOM;
    }
    return _countLabel;
}

#pragma mark - actions 
- (void)endEdittingOpt
{
    if (_delegate && [_delegate respondsToSelector:@selector(endTextViewEditting)]) {
        [_delegate endTextViewEditting];
    }
}

- (void)shufflePostOpt
{
    if (_delegate && [_delegate respondsToSelector:@selector(getRandomPost)]) {
        [_delegate getRandomPost];
    }
}

- (void)dealloc
{
    DPTrace("\n------------输入框accessoryview销毁----------");
}
@end