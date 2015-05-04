//
//  CACameraSessionDelegate.h
//
//  Created by Christopher Cohen & Gabriel Alvarado on 1/23/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

#import "CameraSessionView.h"
#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

@interface CameraSessionView () <CaptureSessionManagerDelegate>
{
    //Variable vith the current camera being used (Rear/Front)
    CameraType cameraBeingUsed;
}

//Primative Properties
@property (readwrite) BOOL animationInProgress;

//Object References
@property (nonatomic, strong) CaptureSessionManager *captureManager;

@end

@implementation CameraSessionView

-(instancetype)initWithFrame:(CGRect)frame withType:(CameraType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _animationInProgress = NO;
        [self setupCaptureWithType:type];
        
        [self setupFocusGesture];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _animationInProgress = NO;
        [self setupCaptureWithType:RearFacingCamera];
        [self setupFocusGesture];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _animationInProgress = NO;
        [self setupCaptureWithType:RearFacingCamera];
        [self setupFocusGesture];
    }
    return self;
}

- (void)setupCaptureWithType:(CameraType)cameraType
{
    [self setupCaptureManager:cameraType];
    cameraBeingUsed = cameraType;
    [[_captureManager captureSession] startRunning];
}

#pragma mark - Setup

-(void)setupCaptureManager:(CameraType)camera
{
    
    //If previous intance of a 'CaptureSessionManager' object exists, remove it's preview layer
    if (_captureManager) [_captureManager.previewLayer removeFromSuperlayer];
    _captureManager = nil;
    
    //Create and configure 'CaptureSessionManager' object
    _captureManager = [CaptureSessionManager new];
    
    if (_captureManager) {
        
        //Configure
        [_captureManager setDelegate:self];
        [_captureManager initiateCaptureSessionForCamera:camera];
        [_captureManager addStillImageOutput];
        [_captureManager addVideoPreviewLayer];
        
        //Preview Layer setup
        CGRect layerRect = self.layer.bounds;
        [_captureManager.previewLayer setBounds:layerRect];
        [_captureManager.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
        
        //Add to self.view's layer
        [self.layer addSublayer:_captureManager.previewLayer];
    }
}

- (void)setupFocusGesture
{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    
    [self addGestureRecognizer:tap];
}
#pragma mark - User Interaction

- (void)closeCameraWithAnimate:(BOOL)animation
{
    if (animation == NO) {
        [_captureManager stop];
        [self removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.center = CGPointMake(self.center.x, self.center.y*3);
    } completion:^(BOOL finished) {
        [_captureManager stop];
        [self removeFromSuperview];
    }];
}

- (void)focusGesture:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;
        if (tap.state == UIGestureRecognizerStateRecognized) {
            CGPoint location = [sender locationInView:self];
            
            [self focusAtPoint:location completionHandler:^{
                
             }];
        }
    }
}

- (void)takeAPicture
{
    [_captureManager captureStillImage];
}

- (void)stopLiveSession
{
    [_captureManager stop];
}

- (void)stopRunning
{
    if ([_captureManager.captureSession isRunning]) {
        [[_captureManager captureSession] stopRunning];
    }
}

- (void)toggleCamera
{
    //这里是否需要增加动画
    [self stopLiveSession];
    
    if (cameraBeingUsed == RearFacingCamera) {
        [self setupCaptureWithType:FrontFacingCamera];
    }else if (cameraBeingUsed == FrontFacingCamera){
        [self setupCaptureWithType:RearFacingCamera];
    }
}

#pragma mark - Camera Session Manager Delegate Methods

-(void)cameraSessionManagerDidCaptureImage
{
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(didCaptureImage:)])
            [self.delegate didCaptureImage:[[self captureManager] stillImage]];
        
        if ([self.delegate respondsToSelector:@selector(didCaptureImageWithData:)])
            [self.delegate didCaptureImageWithData:[[self captureManager] stillImageData]];
    }
}

-(void)cameraSessionManagerFailedToCaptureImage {
}

-(void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType {
}

-(void)cameraSessionManagerDidReportDeviceStatistics:(CameraStatistics)deviceStatistics {
}

#pragma mark - Helper Methods

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        //Lock camera for configuration if possible
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [device unlockForConfiguration];
            
            completionHandler();
        }
    }
    else { completionHandler(); }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - API Functions

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
