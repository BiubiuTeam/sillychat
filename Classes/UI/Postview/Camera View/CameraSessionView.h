//
//  CACameraSessionDelegate.h
//
//  Created by Christopher Cohen & Gabriel Alvarado on 1/23/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

///Protocol Definition
@protocol CACameraSessionDelegate <NSObject>

@optional - (void)didCaptureImage:(UIImage *)image;
@optional - (void)didCaptureImageWithData:(NSData *)imageData;

@end

@interface CameraSessionView : UIView

//Delegate Property
@property (nonatomic, weak) id <CACameraSessionDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame withType:(CameraType)type;

- (void)takeAPicture;
- (void)stopLiveSession;
- (void)stopRunning;
- (void)closeCameraWithAnimate:(BOOL)animation;
- (void)toggleCamera;

@end
