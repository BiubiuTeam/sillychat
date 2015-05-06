//
//  EMRoundButton.h
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMRoundButton : UIButton
{
    CGPoint _lastLocation;
}
@property (nonatomic, assign) CGPoint lastLocation;
@property (nonatomic, strong) UIView *highLightView;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) CAGradientLayer *gradientLayerTop;
@property (nonatomic, strong) CAGradientLayer *gradientLayerBottom;

@property (nonatomic) BOOL animateTap;
@property (nonatomic) BOOL displayShading;
@property (nonatomic) CGFloat borderSize;

@property (nonatomic, assign) UIViewController* topActionViewController;

- (void)setBackgroundImage:(UIImage *)image;

- (void)blink;

@end
