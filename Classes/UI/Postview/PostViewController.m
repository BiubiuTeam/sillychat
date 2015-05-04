//
//  PostViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PostViewController.h"
#import "UIViewController+HUD.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "EMRoundButton.h"
#import "EMRoundButton+DragEffect.h"
#import "PostTextView.h"
#import "SillyService.h"
#import "UIImageAdditions.h"

#import "CameraSessionView.h"

@interface PostViewController ()<UITextViewDelegate,CACameraSessionDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    BOOL switchOperating;
    CGFloat _textViewWidth;
    UIColor* _textViewTintColor;
}

@property (strong, nonatomic) UIImage* selectedImage; //**从图库选择的图片

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic, strong) CameraSessionView *cameraView;

@property (nonatomic, strong) EMRoundButton* roundButton;

@property (nonatomic, strong) PostTextView* textView;

@property (nonatomic, strong) UILabel* countLabel;

@property (nonatomic, strong) PostSwitchMenu* switchButton;

@property (nonatomic, strong) UIImageView* captureView;//主要是在照相模式下，绘制成图片
@property (nonatomic, strong) UIImageView* dotLightView;
@property (nonatomic, strong) UIButton* randomPostButton; //随机Post按钮
@end

@implementation PostViewController

- (void)dealloc
{
    if (_cameraView) {
        [_cameraView closeCameraWithAnimate:NO];
    }
    self.cameraView = nil;
    self.imagePicker = nil;
    self.selectedImage = nil;
    
    self.switchButton = nil;
    self.textView = nil;
    self.roundButton = nil;
    self.countLabel = nil;
    self.captureView = nil;
}

- (instancetype)initWithViewType:(PostViewType)type
{
    if (self = [super init]) {
        _viewType = type;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _viewType = PostViewType_Plaza;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.containerView];
    self.selectedImage = nil;
    // Do any additional setup after loading the view.
    [_containerView addSubview:self.roundButton];
    [_containerView addSubview:self.countLabel];
    [_containerView addSubview:self.randomPostButton];
    [_containerView addSubview:self.switchButton];
    
    [_containerView addSubview:self.captureView];
    
    [_captureView addSubview:self.textView];
    
    [_containerView addSubview:self.dotLightView];
    _dotLightView.centerX = _roundButton.centerX;
    _dotLightView.top = _roundButton.bottom + _size_S(4);
    
    [self addKeyboardNotification];
    
    [_containerView sendSubviewToBack:_captureView];
    
    [self asyncLoadCameraView];
}

- (UIView *)containerView
{
    if (nil == _containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
        _containerView.backgroundColor = APPLICATIONCOLOR;
    }
    return _containerView;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    }
    return _imagePicker;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _textViewTintColor = [[UITextView appearance] tintColor];
    
    [[UITextView appearance] setTintColor:TEXTVIEW_TINT_COLOR];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UITextView appearance] setTintColor:_textViewTintColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textView becomeFirstResponder];
}

- (void)addKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (UIImageView *)captureView
{
    if (nil == _captureView) {
        CGFloat top = STATUSBAR_HEIGHT;// self.switchButton.bottom + 9;
        _captureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, SCREEN_HEIGHT - top)];
        _captureView.contentMode = UIViewContentModeScaleAspectFill;
        _captureView.layer.masksToBounds = YES;
        _captureView.backgroundColor = [UIColor clearColor];
    }
    return _captureView;
}

- (UILabel *)countLabel
{
    if (_countLabel == nil && _viewType == PostViewType_Plaza) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.font = [DPFont systemFontOfSize:20];
        
        _countLabel.text = @"100/100";
        [_countLabel sizeToFit];
        _countLabel.text = @"";
        
        _countLabel.right = SCREEN_WIDTH - MARGIN_LG;
        _countLabel.bottom = SCREEN_HEIGHT - MARGIN_CR;
    }
    return _countLabel;
}

- (UIImageView *)dotLightView
{
    if (nil == _dotLightView) {
        _dotLightView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _dotLightView.backgroundColor = [UIColor clearColor];
        _dotLightView.image = LOAD_ICON_USE_POOL_CACHE(@"private/silly_arrow_highlight.png");
        _dotLightView.frame = CGRectMake(0, 0, 20, 25);
        _dotLightView.contentMode = UIViewContentModeCenter;
    }
    return _dotLightView;
}

- (PostTextView *)textView
{
    if (nil == _textView) {
        _textView = [[PostTextView alloc] initWithFrame:CGRectZero];
     
        _textView.width = _textView.defaultWidth = DEFAUTL_TEXTVIEW_WIDTH;
        _textView.height = 30;
        _textView.delegate = self;
        
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.font = TEXTVIEW_FONT;
        _textView.textColor = [UIColor whiteColor];
        
        _textView.centerX = SCREEN_WIDTH/2;
        _textView.centerY = SCREEN_HEIGHT/2;
        
        _textView.countLabel = self.countLabel;
        if (_viewType == PostViewType_Chat) {
            _textView.maxCount = NSIntegerMax;
        }
    }
    return _textView;
}

- (UIButton *)randomPostButton
{
    if (nil == _randomPostButton && _viewType == PostViewType_Plaza) {
        
        UIImage* random = LOAD_ICON_USE_POOL_CACHE(@"silly_random_button.png");
        _randomPostButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, random.size.width, random.size.height)];
        _randomPostButton.backgroundColor = [UIColor clearColor];
        [_randomPostButton addTarget:self action:@selector(getRandomPost) forControlEvents:UIControlEventTouchUpInside];
        
        [_randomPostButton setImage:random forState:UIControlStateNormal];
        [_randomPostButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_random_button_pressed.png") forState:UIControlStateHighlighted];
        [_randomPostButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_random_button_pressed.png") forState:UIControlStateSelected];
        
        _randomPostButton.left = MARGIN_LG;
        _randomPostButton.bottom = SCREEN_HEIGHT - MARGIN_LG;
    }
    return _randomPostButton;
}

- (EMRoundButton *)roundButton
{
    if (nil == _roundButton) {
        _roundButton = [[EMRoundButton alloc] initWithFrame:CGRectZero];
        [_roundButton addTarget:self action:@selector(sendOutThisPost) forControlEvents:UIControlEventTouchUpInside];
        _roundButton.topActionViewController = self;
        _roundButton.centerX = BUBBLE_CENTERX;
        _roundButton.bottom = BUBBLE_MARGIN_BOTTOM;
        
        [_roundButton setTitle:@"发" forState:UIControlStateNormal];
        [_roundButton addDragEffectAbility];
    }
    return _roundButton;
}

- (PostSwitchMenu *)switchButton
{
    if (nil == _switchButton) {
        _switchButton = [[PostSwitchMenu alloc] initWithFrame:CGRectZero];
        _switchButton.top = 29;
        _switchButton.centerX = SCREEN_WIDTH/2;
        [_switchButton addTarget:self action:@selector(switchCameraState) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

#pragma mark - actions

- (void)getRandomPost
{
    if (_randomPostButton.selected) {
        return;
    }
    _randomPostButton.selected = YES;
    __weak PostViewController* weakSelf = self;
    [[SillyService shareInstance] fetchRandomMessage:BroacastType_Text comletion:^(id json, JSONModelError *err) {
        if (nil == err) {
            SillyRandomMsgModel* msgModel = [[SillyRandomMsgModel alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                if ([msgModel.statusCode integerValue] == 0) {
                    DPTrace("随机文案：%@",msgModel.preTitle);
                    weakSelf.textView.text = msgModel.preTitle;
                    //改变高度，和输入数量
                    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:weakSelf.textView];
                }
            }
        }
        [weakSelf.randomPostButton setSelected:NO];
    }];
}

- (void)switchCameraState
{
    if (switchOperating) {
        return;
    }
    switchOperating = YES;
    [_switchButton switchState];
    if (_switchButton.onState) {
        [self removeCamera];
        if (_selectedImage == nil) {
            [self presentViewController:self.imagePicker animated:YES completion:NULL];
        }
    }else{
        [self launchCamera];
    }
}

- (UIImage *)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    // [view.layer renderInContext:UIGraphicsGetCurrentContext()]; // <- same result...
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)sendOutThisPost
{
//    [self showHudInTopWindowWithHint:@"发送中..."];
    if (!_switchButton.onState && _cameraView) {
        [_cameraView takeAPicture];
    }else if(_selectedImage){
        [self didCaptureImage:_selectedImage];
    }
}

- (void)showHudInTopWindowWithHint:(NSString*)hint
{
    UIWindow *topWindow = [[[UIApplication sharedApplication].windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *win1, UIWindow *win2) {
        return win1.windowLevel - win2.windowLevel;
    }] lastObject];
    
    [self showHudInView:topWindow hint:hint];
}

- (void)dismissPostView
{
    [_textView resignAllFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)operationRespondsWhenTouchEdges
{
    [self dismissPostView];
}

#pragma mark - helper



#pragma mark - keyboard notification

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self updateBottomControlPositionWithKeybordRect:keyboardRect];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self updateBottomControlPositionWithKeybordRect:CGRectMake(0, self.view.height, 0, 0)];
    }];
}

- (void)updateBottomControlPositionWithKeybordRect:(CGRect)keyboardRect
{
    _containerView.height = keyboardRect.origin.y;
    
    _captureView.height = _containerView.height - _captureView.origin.y;
    _textView.defaultCenterY = _textView.centerY = _captureView.height/2 - MARGIN_LG;
    
    [_textView dpTextDidChanged:nil];
    _roundButton.bottom = _containerView.height - MARGIN_LG;
    _randomPostButton.bottom = _countLabel.bottom = _containerView.height - MARGIN_CR;

    _dotLightView.centerX = _roundButton.centerX;
    _dotLightView.top = _roundButton.bottom + _size_S(4);
}

#pragma mark -
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    if(_viewType == PostViewType_Chat)
        return YES;
    
    if(textView.markedTextRange || ![text length]){
        return YES;
    }
    
    if (range.length >= [text length]) {
        return YES;
    }
    
    if([textView isKindOfClass:[PostTextView class]]){
        PostTextView* post = (PostTextView*)textView;
        NSInteger more = [text length] - range.length;
        
        if (post.inputCount + more > post.maxCount) {
            return NO;
        }
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.markedTextRange) {
        return;
    }
    if([textView isKindOfClass:[PostTextView class]]){
        PostTextView* post = (PostTextView*)textView;
        NSString* text = textView.text;
        if ([text length] > post.maxCount) {
            textView.text = [text substringToIndex:post.maxCount];
        }
    }
}

#pragma mark - camera

- (void)asyncLoadCameraView
{
    dispatch_queue_t cameraLoadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(cameraLoadQueue, ^{
        switchOperating = YES;
        [self cameraView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self launchCamera];
            switchOperating = NO;
        });
    });
}

- (CameraSessionView *)cameraView
{
    if (nil == _cameraView) {
        //Instantiate the camera view & assign its frame
        _cameraView = [[CameraSessionView alloc] initWithFrame:_captureView.bounds];
        //Set the camera view's delegate and add it as a subview
        _cameraView.delegate = self;
    }
    return _cameraView;
}

- (void)launchCamera
{
    //Apply animation effect to present the camera view
    CATransition *applicationLoadViewIn =[CATransition animation];
    applicationLoadViewIn.delegate = self;
    [applicationLoadViewIn setDuration:0.3];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self.cameraView layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    _cameraView.alpha = 1;
    [_captureView addSubview:_cameraView];
    [_captureView sendSubviewToBack:_cameraView];
}

-(void)didCaptureImage:(UIImage *)image {
    NSLog(@"CAPTURED IMAGE");
    //不把文字写入图片
    //image = [UIImage drawTextView:_textView inImage:image];
    if (_delegate && [_delegate respondsToSelector:@selector(postOptWithContent:contentType:postType:extension:completion:)]) {
        __weak PostViewController* weakSelf = self;
        NSString* msg = [_textView.text length]?_textView.text:@"";
        [_delegate postOptWithContent:image contentType:PostContentType_IMG postType:_viewType extension:@{@"Text":msg} completion:^(BOOL succeed, NSError *error) {
            [weakSelf hideHud];
            if (succeed) {
                [weakSelf dismissPostView];
            }else{
                [weakSelf showHudInTopWindowWithHint:@"发送失败"];
                [weakSelf performSelector:@selector(hideHud) withObject:nil afterDelay:0.3];
            }
        }];
    }
}

-(void)didCaptureImageWithData:(NSData *)imageData {
    NSLog(@"CAPTURED IMAGE DATA");
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //Show error alert if image could not be saved
    if (error) [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (void)removeCamera
{
    if (_cameraView == nil) {
        return;
    }
    
    CATransition *applicationLoadViewOut =[CATransition animation];
    applicationLoadViewOut.delegate = self;
    [applicationLoadViewOut setDuration:0.3];
    [applicationLoadViewOut setType:kCATransitionFade];
    [applicationLoadViewOut setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_cameraView layer] addAnimation:applicationLoadViewOut forKey:@"applicationLoadViewOut"];
    _cameraView.alpha = 0;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    //do what you need to do when animation ends...
    if (theAnimation == [[_cameraView layer] animationForKey:@"applicationLoadViewOut"]) {
        [_cameraView closeCameraWithAnimate:NO];
    }
    switchOperating = NO;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        self.captureView.image = orgImage;
        self.selectedImage = orgImage;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    if (_selectedImage == nil) {
        [self switchCameraState];
    }
}

@end


@interface PostSwitchMenu ()
{
    CGFloat _innerInset;
    CGFloat _innerVertical;
    
    UIColor* _normalColor;
    UIColor* _highlightColor;
}
@property (nonatomic, strong) UILabel* leftLabel;
@property (nonatomic, strong) UILabel* rightLabel;

@property (nonatomic, strong) CALayer* knockLayer;
@end

@implementation PostSwitchMenu

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _normalColor = [UIColor colorWithWhite:0.4 alpha:1];
        _highlightColor = [UIColor colorWithWhite:0.7 alpha:1];
        
        _innerInset = 10;
        _innerVertical = 5;
        
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.backgroundColor = [UIColor clearColor];
        _leftLabel.text = @"照像";
        _leftLabel.textColor = _normalColor;
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        _leftLabel.font = [DPFont systemFontOfSize:14];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.backgroundColor = [UIColor clearColor];
        _rightLabel.text = @"相库";
        _rightLabel.textColor = _normalColor;
        _rightLabel.textAlignment = NSTextAlignmentCenter;
        _rightLabel.font = [DPFont systemFontOfSize:14];
        _rightLabel.right = self.width;
        
        [_leftLabel sizeToFit];
        [_rightLabel sizeToFit];
        
        _leftLabel.width = _rightLabel.width = _rightLabel.width + 2*_innerInset;
        _leftLabel.height = _rightLabel.height = _rightLabel.height + 2*_innerVertical;
        
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = RGBACOLOR(0x00, 0x00, 0x00, 1).CGColor;
        
        _knockLayer = [CALayer layer];
        _knockLayer.backgroundColor = RGBACOLOR(0x00, 0x00, 0x00, 1).CGColor;
        
        self.width = _leftLabel.width + _rightLabel.width + 2*_innerInset;
        self.height = _leftLabel.height + 2*_innerVertical;
        
        
        _knockLayer.frame = CGRectMake(0, 0, _leftLabel.width + (_innerInset - _innerVertical)*2, _leftLabel.height);
        _knockLayer.cornerRadius = _knockLayer.frame.size.height/2;
        [self.layer addSublayer:_knockLayer];
        
        [self addSubview:_leftLabel];
        [self addSubview:_rightLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.layer.cornerRadius = self.height/2;
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _leftLabel.centerY = _rightLabel.centerY = self.height/2;
    
    _leftLabel.left = _innerInset;
    _rightLabel.right = self.width - _innerInset;
    
    [self layoutLayerBaseOnState];
}

- (void)switchState
{
    _onState = !_onState;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutLayerBaseOnState];
    }];
}

- (void)layoutLayerBaseOnState
{
    if (NO == _onState) {
        CGRect frame = _knockLayer.frame;
        frame.origin.x = _leftLabel.centerX - frame.size.width/2;
        frame.origin.y = _leftLabel.centerY - frame.size.height/2;
        _knockLayer.frame = frame;
        
        _leftLabel.textColor = _highlightColor;
        _rightLabel.textColor = _normalColor;
    }else {
        CGRect frame = _knockLayer.frame;
        frame.origin.x = _rightLabel.centerX - frame.size.width/2;
        frame.origin.y = _rightLabel.centerY - frame.size.height/2;
        _knockLayer.frame = frame;
        
        _leftLabel.textColor = _normalColor;
        _rightLabel.textColor = _highlightColor;
    }
}

@end