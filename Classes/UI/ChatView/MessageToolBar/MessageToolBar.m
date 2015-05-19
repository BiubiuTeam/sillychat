//
//  MessageToolBar.m
//  sillyChat
//
//  Created by haowenliang on 15/4/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "MessageToolBar.h"
#import "ToolBarButton.h"

@interface MessageToolBar()<UITextViewDelegate, SillyEmojiViewDelegate>
{
    CGFloat _previousTextViewContentHeight;//上一次inputTextView的contentSize.height
}

@property (nonatomic, strong) NSString* tmpInputTxt;//缓存用户输入
/**
 *  背景
 */
@property (strong, nonatomic) UIImageView *toolbarBackgroundImageView;
@property (strong, nonatomic) UIImageView *backgroundImageView;

/**
 *  按钮、输入框、toolbarView
 */
@property (strong, nonatomic) UIView *toolbarView;

@property (strong, nonatomic) ToolBarButton *styleChangeButton;
@property (strong, nonatomic) ToolBarButton *pictureButton;
@property (strong, nonatomic) ToolBarButton *faceButton;
@property (strong, nonatomic) UIButton *recordButton;

/**
 *  底部扩展页面
 */
@property (nonatomic) BOOL isShowButtomView;
@property (strong, nonatomic) UIView *activityButtomView;//当前活跃的底部扩展页面

@end

@implementation MessageToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height < (kVerticalPadding * 2 + kInputTextViewMinHeight)) {
        frame.size.height = kVerticalPadding * 2 + kInputTextViewMinHeight;
    }
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self setupConfigure];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    if (frame.size.height < (kVerticalPadding * 2 + kInputTextViewMinHeight)) {
        frame.size.height = kVerticalPadding * 2 + kInputTextViewMinHeight;
    }
    [super setFrame:frame];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupSubviews];
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _delegate = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    DPTrace("\n--------------聊天页面消息输入框销毁完成--------------");
}

#pragma mark - getter

- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.backgroundColor = APPBLACKCOLOR;
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return _backgroundImageView;
}

- (UIImageView *)toolbarBackgroundImageView
{
    if (_toolbarBackgroundImageView == nil) {
        _toolbarBackgroundImageView = [[UIImageView alloc] init];
        _toolbarBackgroundImageView.backgroundColor = [UIColor clearColor];
        _toolbarBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return _toolbarBackgroundImageView;
}

- (UIView *)toolbarView
{
    if (_toolbarView == nil) {
        _toolbarView = [[UIView alloc] init];
        _toolbarView.backgroundColor = [UIColor clearColor];
    }
    
    return _toolbarView;
}

#pragma mark - setter

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}

- (void)setToolbarBackgroundImage:(UIImage *)toolbarBackgroundImage
{
    _toolbarBackgroundImage = toolbarBackgroundImage;
    self.toolbarBackgroundImageView.image = toolbarBackgroundImage;
}

- (void)setMaxTextInputViewHeight:(CGFloat)maxTextInputViewHeight
{
    if (maxTextInputViewHeight > kInputTextViewMaxHeight) {
        maxTextInputViewHeight = kInputTextViewMaxHeight;
    }
    _maxTextInputViewHeight = maxTextInputViewHeight;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    
    self.faceButton.selected = NO;
    self.styleChangeButton.selected = NO;
    self.pictureButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.text];
            
            [self.inputTextView setText:@""];
            [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];;
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
}

- (void)emojiView:(SillyEmojView *)emojiView didSelectEmoji:(NSString *)emoji
{
    if (emoji.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didSendFace:)]) {
            [self.delegate didSendFace:emoji];
        }
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

#pragma mark - private

/**
 *  设置初始属性
 */
- (void)setupConfigure
{
    self.tmpInputTxt = @"";
    self.maxTextInputViewHeight = kInputTextViewMaxHeight;
    self.activityButtomView = nil;
    self.isShowButtomView = NO;
    
    [self addSubview:self.backgroundImageView];
    
    self.toolbarView.frame = CGRectMake(0, 0, self.frame.size.width, kVerticalPadding * 2 + kInputTextViewMinHeight);
    self.toolbarBackgroundImageView.frame = self.toolbarView.bounds;
    [self.toolbarView addSubview:self.toolbarBackgroundImageView];
    [self addSubview:self.toolbarView];
    
    [self addTopBorderLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setupSubviews
{
    CGFloat allButtonWidth = 0.0;
    CGFloat textViewLeftMargin = 6.0;
    
    //转变输入样式
    self.styleChangeButton = ({
        ToolBarButton* button = [[ToolBarButton alloc] initWithFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, kInputTextViewMinHeight, kInputTextViewMinHeight)];
        
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setImage:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_voice_normal.png") forState:UIControlStateNormal];
        [button setHighlightImg:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_voice_pressed.png")];
        [button setImage:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_keyboard_normal.png") forState:UIControlStateSelected];
        
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 0;
        
        button;
    });
    allButtonWidth += CGRectGetMaxX(_styleChangeButton.frame);
    textViewLeftMargin += CGRectGetMaxX(_styleChangeButton.frame);
    
    //照相
    self.pictureButton = ({
        ToolBarButton* pictureButton = [[ToolBarButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kHorizontalPadding - kInputTextViewMinHeight, kVerticalPadding, kInputTextViewMinHeight, kInputTextViewMinHeight)];
        pictureButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        [pictureButton setImage:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_session_normal.png") forState:UIControlStateNormal];
        [pictureButton setHighlightImg:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_session_pressed.png")];
        [pictureButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        pictureButton.tag = 2;
        
        pictureButton;
    });

    allButtonWidth += CGRectGetWidth(_pictureButton.frame) + kHorizontalPadding * 2.5;
    
    //表情
    self.faceButton = ({
        ToolBarButton* faceButton = [[ToolBarButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.pictureButton.frame) - kInputTextViewMinHeight - kHorizontalPadding, kVerticalPadding, kInputTextViewMinHeight, kInputTextViewMinHeight)];
        faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [faceButton setImage:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_emoji_normal.png") forState:UIControlStateNormal];
        [faceButton setHighlightImg:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_emoji_pressed.png")];
        
        [faceButton setImage:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_keyboard_normal.png") forState:UIControlStateSelected];
        [faceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        faceButton.tag = 1;
        
        faceButton;
    });
    allButtonWidth += CGRectGetWidth(_faceButton.frame) + kHorizontalPadding * 1.5;
    
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? allButtonWidth : (textViewLeftMargin * 2));
    
    // 初始化输入框
    self.inputTextView = [[XHMessageTextView  alloc] initWithFrame:CGRectMake(textViewLeftMargin, kVerticalPadding, width, kInputTextViewMinHeight)];
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    _inputTextView.scrollEnabled = YES;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    _inputTextView.placeHolder = @"输入新消息";
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UIColor whiteColor];
    _inputTextView.layer.borderColor = [UIColor blackColor].CGColor;
    _inputTextView.layer.borderWidth = 0.5f;
    _inputTextView.layer.cornerRadius = 4.0f;
    _previousTextViewContentHeight = [self getTextViewContentH:_inputTextView];
    
    //录制
    self.recordButton = ({
        UIButton* recordButton = [[UIButton alloc] initWithFrame:CGRectMake(textViewLeftMargin, kVerticalPadding, width, kInputTextViewMinHeight)];
        recordButton.titleLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        [recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        UIImage* rimg = LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_voice_btn_normal.png");
        [recordButton setBackgroundImage:[rimg stretchableImageWithLeftCapWidth:rimg.size.width/2 topCapHeight:rimg.size.height/2] forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_voice_btn_pressed.png") stretchableImageWithLeftCapWidth:rimg.size.width/2 topCapHeight:rimg.size.height/2] forState:UIControlStateHighlighted];
        
        [recordButton setTitle:kTouchToRecord forState:UIControlStateNormal];
        [recordButton setTitle:kTouchToFinish forState:UIControlStateHighlighted];
        [recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [recordButton addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [recordButton addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
        recordButton.hidden = YES;
        
        recordButton;
    });
    
    [self.toolbarView addSubview:_styleChangeButton];
    [self.toolbarView addSubview:_pictureButton];
    [self.toolbarView addSubview:_faceButton];
    [self.toolbarView addSubview:_inputTextView];
    [self.toolbarView addSubview:_recordButton];
}

- (UIView *)recordView
{
    if (nil == _recordView) {
        _recordView = [[DXRecordView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
    }
    return _recordView;
}

- (UIView *)faceView
{
    if (nil == _faceView) {
        _faceView = [[SillyEmojView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), self.frame.size.width, 200)];
        [(SillyEmojView *)_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor lightGrayColor];
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _faceView;
}

#pragma mark - change frame

- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.frame.size.height + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    //如果需要将所有扩展页面都隐藏，而此时已经隐藏了所有扩展页面，则不进行任何操作
    if(bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height)
    {
        return;
    }
    
    if (bottomHeight == 0) {
        self.isShowButtomView = NO;
    }
    else{
        self.isShowButtomView = YES;
    }
    
    self.frame = toFrame;
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
        [_delegate didChangeFrameToHeight:toHeight];
    }
}

- (void)willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        
        if (bottomHeight == 0) {
            [UIView animateWithDuration:.3 animations:^{
                [self willShowBottomHeight:bottomHeight];
                _activityButtomView.top = self.top;
            } completion:^(BOOL finished) {
                if (finished) {
                    if (self.activityButtomView) {
                        [self.activityButtomView removeFromSuperview];
                    }
                    self.activityButtomView = nil;
                }
            }];
        }else{
            [self addSubview:bottomView];
            CGRect rect = bottomView.frame;
            rect.origin.y = _toolbarView.height;
            [UIView animateWithDuration:.3 animations:^{
                [self willShowBottomHeight:bottomHeight];
                bottomView.frame = rect;
            } completion:^(BOOL finished) {
                if (finished) {
                    if (self.activityButtomView) {
                        [self.activityButtomView removeFromSuperview];
                    }
                    self.activityButtomView = bottomView;
                }
            }];
        }
    }
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        //一定要把self.activityButtomView置为空
        [self willShowBottomHeight:toFrame.size.height];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    }
    else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self willShowBottomHeight:0];
    }
    else{
        [self willShowBottomHeight:toFrame.size.height];
    }
}

- (void)willShowInputTextViewToHeight:(CGFloat)toHeight
{
    if (toHeight < kInputTextViewMinHeight) {
        toHeight = kInputTextViewMinHeight;
    }
    if (toHeight > self.maxTextInputViewHeight) {
        toHeight = self.maxTextInputViewHeight;
    }
    
    if (toHeight == _previousTextViewContentHeight)
    {
        return;
    }
    else{
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolbarView.frame;
        rect.size.height += changeHeight;
        self.toolbarView.frame = rect;
        
        if (SYSTEM_VERSION < 7.0) {
            [self.inputTextView setContentOffset:CGPointMake(0.0f, (self.inputTextView.contentSize.height - self.inputTextView.frame.size.height) / 2) animated:YES];
        }
        _previousTextViewContentHeight = toHeight;
        
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
            [_delegate didChangeFrameToHeight:self.frame.size.height];
        }
    }
}

- (CGFloat)getTextViewContentH:(UITextView *)textView
{
    if (SYSTEM_VERSION >= 7.0)
    {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

#pragma mark - action

- (void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    NSInteger tag = button.tag;
    
    switch (tag) {
        case 0://切换状态
        {
            if (button.selected) {
                self.faceButton.selected = NO;
                self.pictureButton.selected = NO;
                //录音状态下，不显示底部扩展页面
                [self willShowBottomView:nil];
                
                //将inputTextView内容置空，以使toolbarView回到最小高度
                self.tmpInputTxt = self.inputTextView.text;
                self.inputTextView.text = @"";
                [self textViewDidChange:self.inputTextView];
                [self.inputTextView resignFirstResponder];
            }
            else{
                self.inputTextView.text = self.tmpInputTxt;
                [self textViewDidChange:self.inputTextView];
                //键盘也算一种底部扩展页面
                [self.inputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.recordButton.hidden = !button.selected;
                self.inputTextView.hidden = button.selected;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didStyleChangeToRecord:)]) {
                [self.delegate didStyleChangeToRecord:button.selected];
            }
        }
            break;
        case 1://表情
        {
            if (button.selected) {
                self.pictureButton.selected = NO;
                //如果选择表情并且处于录音状态，切换成文字输入状态，但是不显示键盘
                if (self.styleChangeButton.selected) {
                    self.styleChangeButton.selected = NO;
                    self.inputTextView.text = self.tmpInputTxt;
                    [self textViewDidChange:self.inputTextView];
                }
                else{//如果处于文字输入状态，使文字输入框失去焦点
                    [self.inputTextView resignFirstResponder];
                }
                
                [self willShowBottomView:self.faceView];
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.recordButton.hidden = button.selected;
                    self.inputTextView.hidden = !button.selected;
                } completion:^(BOOL finished) {
                    
                }];
            } else {
                if (!self.styleChangeButton.selected) {
                    [self.inputTextView becomeFirstResponder];
                }
                else{
                    [self willShowBottomView:nil];
                }
            }
            if (_delegate && [_delegate respondsToSelector:@selector(didFaceButtonClick)]) {
                [_delegate didFaceButtonClick];
            }
        }
            break;
        case 2://相机
        {
            self.faceButton.selected = NO;
            self.pictureButton.selected = NO;
            [self.inputTextView resignFirstResponder];
            [self willShowBottomView:nil];
            
            if (_delegate && [_delegate respondsToSelector:@selector(didCameraButtonClick)]) {
                [_delegate didCameraButtonClick];
            }
        }
            break;
        default:
            break;
    }
}

- (void)recordButtonTouchDown
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchDown];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
        [_delegate didStartRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)])
    {
        [_delegate didCancelRecordingVoiceAction:self.recordView];
    }
    
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpOutside];
    }
    
    [self.recordView removeFromSuperview];
}

- (void)recordButtonTouchUpInside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpInside];
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction:)])
    {
        [self.delegate didFinishRecoingVoiceAction:self.recordView];
    }
    
    [self.recordView removeFromSuperview];
}

- (void)recordDragOutside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonDragOutside];
    }
    
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)])
    {
        [self.delegate didDragOutsideAction:self.recordView];
    }
}

- (void)recordDragInside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonDragInside];
    }
    
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)])
    {
        [self.delegate didDragInsideAction:self.recordView];
    }
}

#pragma mark - public

/**
 *  停止编辑
 */
- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    
    self.faceButton.selected = NO;
    self.pictureButton.selected = NO;
    [self willShowBottomView:nil];
    
    return result;
}

/**
 *  取消触摸录音键
 */
- (void)cancelTouchRecord
{
    if ([_recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)_recordView recordButtonTouchUpInside];
        [_recordView removeFromSuperview];
    }
}

+ (CGFloat)defaultHeight
{
    return kVerticalPadding * 2 + kInputTextViewMinHeight;
}

- (void)resignAllFirstResponder
{
    [super resignAllFirstResponder];

    if(self.styleChangeButton.selected == YES)
        return;
    self.faceButton.selected = NO;
    self.pictureButton.selected = NO;
    //录音状态下，不显示底部扩展页面
    [self willShowBottomView:nil];
}

//haowen, 05-13 顶部分割线
- (void)addTopBorderLayer
{
    // Add a bottomBorder.
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 0, self.width, .5f);
    bottomBorder.backgroundColor = RGBACOLOR(0x97, 0x97, 0x97, .75).CGColor;
    [self.layer addSublayer:bottomBorder];
}
@end
