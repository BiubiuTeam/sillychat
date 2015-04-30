//
//  EMDragButton.m
//  sillyChat
//
//  Created by haowenliang on 15/3/17.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMDragButton.h"

@implementation EMDragButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _dragEnable = YES;
        _isAlphaEffect = NO;
        self.layer.borderColor = [self.borderColor colorWithAlphaComponent:1.0].CGColor;
        self.highLightView.alpha = 1;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.borderColor = [self.borderColor colorWithAlphaComponent:1.0].CGColor;
    self.highLightView.alpha = 1;
}

- (void)blink
{
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [self.superview convertPoint:self.center fromView:self.superview];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = self.borderColor.CGColor;
    circleShape.lineWidth = 2.0;
    
    [self.superview.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.7f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [circleShape addAnimation:animation forKey:nil];
}

#pragma mark -
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (!_dragEnable) {
//        return;
//    }
//    UITouch *touch = [touches anyObject];
//    _beginPoint = [touch locationInView:self];
//    _originCenter = self.center;
//    
//    [_delegate notifyStartLocation:self.center withButton:self];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (!_dragEnable) {
//        return;
//    }
//    UITouch *touch = [touches anyObject];
//    CGPoint nowPoint = [touch locationInView:self];
//    float offsetY = nowPoint.y - _beginPoint.y;
//    self.center = CGPointMake(self.center.x, self.center.y + offsetY);
//    [_delegate notifyTheCenterLocation:self.center withButton:self];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (!_dragEnable) {
//        return;
//    }
//    self.center = _originCenter;
//    [_delegate notifyLastLocation:self.center withButton:self];
//}

@end
