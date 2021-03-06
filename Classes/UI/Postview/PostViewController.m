//
//  PostViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PostViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "PostTextView.h"
#import "SillyService.h"
#import "UIImageAdditions.h"
#import "UIImage+Helper.h"
#import "CameraSessionView.h"
#import "SillyMediaDevice.h"

typedef NS_ENUM(NSUInteger, PHOTO_STATE) {
    PHOTO_STATE_LIVE = 0,
    PHOTO_STATE_STILL = 1,
};

#define TOP_BTN_HOR_MARGIN _size_S(37)
#define TOP_BTN_MGTOP _size_S(25)
#define TOP_BTN_WIDTH _size_S(50)
#define TOP_BTN_HEIGHT _size_S(50)

#define CRAP_IMAGE_TOP _size_S(56)
#define CRAP_IMAGE_LEFT _size_S(12)
#define CRAP_IMAGE_RADIUS _size_S(25)

@interface PostViewController ()<UITextViewDelegate,CACameraSessionDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PostAccessoryViewProtocol>
{
    BOOL switchOperating;
    CGFloat _textViewWidth;
    UIColor* _textViewTintColor;
    
    BOOL _firstLoadedPostView;
    BOOL _dismissOpt;
}

@property (strong, nonatomic) UIImage* selectedImage; //**从图库选择的图片

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic, strong) CameraSessionView *cameraView;

@property (nonatomic, strong) PostTextView* textView;
@property (nonatomic, strong) PostTextViewAccessoryView* accessoryView;

@property (nonatomic) PHOTO_STATE currentState; //live for default
@property (nonatomic, strong) UIButton* cancelButton;//取消按钮
@property (nonatomic, strong) UIButton* photoLibaryButton;//图库按钮，唤起图库
@property (nonatomic, strong) UIButton* switchButton;//如果是摄像状态，切换前后摄像头，若是静态图片，切换相机模式

@property (nonatomic, strong) UIImageView* captureView;//
@property (nonatomic, strong) UIButton* confirmButton;
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
    self.captureView = nil;
    
    DPTrace("\n------------发表页面销毁----------");
}

- (instancetype)initWithViewType:(PostViewType)type
{
    if (self = [super init]) {
        _launchCameraType = RearFacingCamera;
        _viewType = type;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _launchCameraType = RearFacingCamera;
        _viewType = PostViewType_Plaza;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    _firstLoadedPostView = YES;
    [self containerView];
    self.selectedImage = nil;
    // Do any additional setup after loading the view.

    [_containerView addSubview:self.cancelButton];
    [_containerView addSubview:self.photoLibaryButton];
    [_containerView addSubview:self.switchButton];
    _cancelButton.top = _photoLibaryButton.top = _switchButton.top = TOP_BTN_MGTOP;
    
    [_containerView addSubview:self.captureView];
    
    [_containerView addSubview:self.textView];
    [_containerView sendSubviewToBack:_captureView];
    
    [_containerView addSubview:self.confirmButton];
    
    [self addKeyboardNotification];
    [self asyncLoadCameraView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    _textViewTintColor = [[UITextView appearance] tintColor];
    [[UITextView appearance] setTintColor:TEXTVIEW_TINT_COLOR];
    
    [self showViewsWithAnimate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [[UITextView appearance] setTintColor:_textViewTintColor];
}

static BOOL everShowCameraAuthorized = NO;
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (everShowCameraAuthorized == NO) {
        [SillyMediaDevice isCameraAvailable];
        everShowCameraAuthorized = YES;
    }
}

- (void)addKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)showViewsWithAnimate
{
    if (!_firstLoadedPostView) {
        return;
    }
    _firstLoadedPostView = NO;
    _containerView.alpha = 0;
    //Apply animation effect to present the camera view
    CATransition *applicationLoadViewIn =[CATransition animation];
    applicationLoadViewIn.delegate = self;
    [applicationLoadViewIn setDuration:0.3];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self.containerView layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    _containerView.alpha = 1;
    
    [self.view addSubview:_containerView];
}

#pragma mark - getter
- (UIView *)containerView
{
    if (nil == _containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
        _containerView.backgroundColor = APPLICATIONCOLOR;
    }
    return _containerView;
}

- (PostTextViewAccessoryView *)accessoryView
{
    if (nil == _accessoryView) {
        _accessoryView = [[PostTextViewAccessoryView alloc] initWithFrame:CGRectZero];
        _accessoryView.delegate = self;
    }
    return _accessoryView;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
//        _imagePicker.allowsEditing = YES;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    }
    return _imagePicker;
}

- (UIImageView *)captureView
{
    if (nil == _captureView) {
        _captureView = [[UIImageView alloc] initWithFrame:_containerView.frame];
        _captureView.contentMode = UIViewContentModeScaleAspectFill;
        _captureView.layer.masksToBounds = YES;
        _captureView.backgroundColor = [UIColor clearColor];
    }
    return _captureView;
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
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.centerX = SCREEN_WIDTH/2;
        _textView.centerY = SCREEN_HEIGHT/2;
        
        _textView.inputAccessoryView = self.accessoryView;
        _textView.countLabel = _accessoryView.countLabel;
        if (_viewType == PostViewType_Chat) {
            _textView.maxCount = NSIntegerMax;
        }
        
        _textView.defaultPlaceholder = @"说点什么吧，24小时销毁";
    }
    return _textView;
}

- (UIButton *)switchButton
{
    if (nil == _switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchButton.size = CGSizeMake(TOP_BTN_WIDTH, TOP_BTN_HEIGHT);
        _switchButton.backgroundColor = [UIColor clearColor];
        _switchButton.contentMode = UIViewContentModeScaleAspectFit;
        _switchButton.right = SCREEN_WIDTH - TOP_BTN_HOR_MARGIN;
        [_switchButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_switch.png") forState:UIControlStateNormal];
        [_switchButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_switch.png") forState:UIControlStateSelected];
        [_switchButton addTarget:self action:@selector(switchLiveSessionState) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

- (UIButton *)photoLibaryButton
{
    if (nil == _photoLibaryButton) {
        _photoLibaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoLibaryButton.size = CGSizeMake(TOP_BTN_WIDTH, TOP_BTN_HEIGHT);
        _photoLibaryButton.backgroundColor = [UIColor clearColor];
        _photoLibaryButton.contentMode = UIViewContentModeScaleAspectFit;
        _photoLibaryButton.centerX = SCREEN_WIDTH/2;
        
        [_photoLibaryButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_library.png") forState:UIControlStateNormal];
        [_photoLibaryButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_library.png") forState:UIControlStateSelected];
        [_photoLibaryButton addTarget:self action:@selector(openPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoLibaryButton;
}

- (UIButton *)cancelButton
{
    if (nil == _cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.size = CGSizeMake(TOP_BTN_WIDTH, TOP_BTN_HEIGHT);
        _cancelButton.left = TOP_BTN_HOR_MARGIN;
        _cancelButton.backgroundColor = [UIColor clearColor];
        _cancelButton.contentMode = UIViewContentModeScaleAspectFit;
        
        [_cancelButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_cancel.png") forState:UIControlStateNormal];
        [_cancelButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_cancel.png") forState:UIControlStateSelected];
        [_cancelButton addTarget:self action:@selector(closePostView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton
{
    if (nil == _confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.size = CGSizeMake(BIG_BUBBLE_RADIUS, BIG_BUBBLE_RADIUS);
        _confirmButton.centerX = SCREEN_WIDTH/2;
        _confirmButton.bottom = SCREEN_HEIGHT - ALL_BUBBLE_BOTTOM;
        _confirmButton.backgroundColor = [UIColor clearColor];
    
        [_confirmButton setBackgroundImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_send.png") forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:LOAD_ICON_USE_POOL_CACHE(@"silly_post_send.png") forState:UIControlStateHighlighted];
        
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_MIDDLE];
        [_confirmButton setTitle:@"发送" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(sendOutThisPost) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}
#pragma mark - actions

- (void)switchLiveSessionState
{
    if(_dismissOpt)return;
    [self performSelector:@selector(swithOptWithDelay) withObject:nil afterDelay:.2];
}

- (void)swithOptWithDelay
{
    if(_dismissOpt)return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(swithOptWithDelay) object:nil];
    
    if (switchOperating) {
        return;
    }
    switchOperating = YES;
    if (_currentState == PHOTO_STATE_STILL) {
        _currentState = PHOTO_STATE_LIVE;
        [self launchCameraWithAnimate:YES];
        self.selectedImage = nil;
    }else{
        [_cameraView toggleCamera];
        switchOperating = NO;
    }
}

- (void)openPhotoLibrary
{
    if(_dismissOpt)return;
    __weak PostViewController* weakSelf = self;
    [self presentViewController:self.imagePicker animated:YES completion:^{
        if (_currentState == PHOTO_STATE_LIVE) {
            [weakSelf removeCamera];
        }
        _currentState = PHOTO_STATE_STILL;
    }];
}

- (void)getRandomPost
{
    static BOOL RandomPostOpting = NO;
    if (RandomPostOpting) {
        return;
    }
    RandomPostOpting = YES;
    __weak PostViewController* weakSelf = self;
    [[SillyService shareInstance] fetchRandomMessage:BroacastType_Text comletion:^(id json, JSONModelError *err) {
        RandomPostOpting = NO;
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
    }];
}

- (void)endTextViewEditting
{
    [self.textView resignAllFirstResponder];
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
    if(_dismissOpt)return;
    if(_selectedImage){
        [self uploadImageAndDismissView];
    }else if (_cameraView) {
        @try {
//            [_cameraView stopRunning];
            [_cameraView takeAPicture];
        }
        @catch (NSException *exception) {
            DPTrace("这个操作有异常");
        }
        @finally {
            DPTrace("完成了这个操作");
        }
    }else{
        [self openPhotoLibrary];
    }
}

- (void)dismissPostView
{
    if(_dismissOpt)return;
    _dismissOpt = YES;
    _containerView.backgroundColor = [UIColor clearColor];
    [_textView resignAllFirstResponder];
    /*动画移动图片*/
    [UIView animateWithDuration:.3 animations:^{
        _textView.hidden = YES;
        _photoLibaryButton.hidden = _cancelButton.hidden = _switchButton.hidden = YES;
        _confirmButton.hidden = YES;
        _cameraView.hidden = YES;
        
        _captureView.frame = CGRectMake(CRAP_IMAGE_LEFT, CRAP_IMAGE_TOP, CRAP_IMAGE_RADIUS, CRAP_IMAGE_RADIUS);
        _captureView.layer.cornerRadius = CRAP_IMAGE_RADIUS/2;
        _captureView.layer.masksToBounds = YES;
    } completion:^(BOOL finished) {
        if (finished) {
            [self dismissViewController];
        }
    }];
}
//cancel button event
- (void)closePostView
{
    if(_dismissOpt)return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KenburnsImageViewStateSet" object:@YES];
    _dismissOpt = YES;
    [_textView resignAllFirstResponder];
    [self removeCamera];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KenburnsImageViewStateSet" object:@YES];
    }];
}
#pragma mark - helper

- (void)uploadImageAndDismissView
{
    if (_selectedImage == nil) {
        return;
    }
    _selectedImage = [UIImage image:_selectedImage scaleToFitSizeWithMaxLongSide:SCREEN_HEIGHT];
    
    if (_delegate && [_delegate respondsToSelector:@selector(postOptWithContent:contentType:postType:extension:completion:)]) {
        __weak PostViewController* weakSelf = self;
        NSString* msg = [_textView.text length]?_textView.text:@"";
        [_delegate postOptWithContent:_selectedImage contentType:PostContentType_IMG postType:_viewType extension:@{@"text":msg} completion:^(BOOL succeed, NSError *error) {
            if (succeed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf dismissPostView];
                });
            }else{

            }
        }];
    }
}

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
    //改变textView的大小
    _textView.defaultCenterY = _textView.centerY = keyboardRect.origin.y/2;
    [_textView dpTextDidChanged:nil];
}

#pragma mark -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignAllFirstResponder];
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
            [self launchCameraWithAnimate:YES];
            switchOperating = NO;
        });
    });
}

- (CameraSessionView *)cameraView
{
    if (nil == _cameraView) {
        //Instantiate the camera view & assign its frame
        _cameraView = [[CameraSessionView alloc] initWithFrame:_containerView.bounds withType:_launchCameraType];
        //Set the camera view's delegate and add it as a subview
        _cameraView.delegate = self;
    }
    return _cameraView;
}

- (void)launchCameraWithAnimate:(BOOL)animate
{
    if (animate) {
        //Apply animation effect to present the camera view
        CATransition *applicationLoadViewIn =[CATransition animation];
        applicationLoadViewIn.delegate = self;
        [applicationLoadViewIn setDuration:0.3];
        [applicationLoadViewIn setType:kCATransitionReveal];
        [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[self.cameraView layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    }
    _cameraView.alpha = 1;
    [_containerView addSubview:_cameraView];
    [_containerView insertSubview:_cameraView aboveSubview:_captureView];
}

-(void)didCaptureImage:(UIImage *)image
{
    DPTrace(@"CAPTURED IMAGE");
    self.selectedImage = image;
    _captureView.image = image;
    [self uploadImageAndDismissView];
}

-(void)didCaptureImageWithData:(NSData *)imageData {
    DPTrace(@"CAPTURED IMAGE DATA");
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
    
    CATransition *applicationLoadViewOut = [CATransition animation];
    applicationLoadViewOut.delegate = self;
    
    [applicationLoadViewOut setValue:@"applicationLoadViewOut" forKey:@"CATransitionName"];
    
    [applicationLoadViewOut setDuration:0.3];
    [applicationLoadViewOut setType:kCATransitionFade];
    [applicationLoadViewOut setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_cameraView layer] addAnimation:applicationLoadViewOut forKey:@"applicationLoadViewOut"];
    _cameraView.alpha = 0;
    if (_dismissOpt) {
        [[_containerView layer] addAnimation:applicationLoadViewOut forKey:nil];
        _containerView.alpha = 0;
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    //do what you need to do when animation ends...
    if ([[theAnimation valueForKey:@"CATransitionName"] isEqualToString:@"applicationLoadViewOut"]) {
        if (_dismissOpt) {
            [self dismissViewController];
        }
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
        [self switchLiveSessionState];
    }
    self.imagePicker = nil;
}

@end
