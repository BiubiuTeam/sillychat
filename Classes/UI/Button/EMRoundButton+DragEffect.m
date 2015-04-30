//
//  EMRoundButton+DragEffect.m
//  sillyChat
//
//  Created by haowenliang on 15/3/17.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMRoundButton+DragEffect.h"

@implementation EMRoundButton (DragEffect)

- (void)addDragEffectAbility
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPan:)];
    [self addGestureRecognizer:panRecognizer];
    
    _lastLocation = self.center;
}

- (void) detectPan:(UIPanGestureRecognizer *) uiPanGestureRecognizer
{
    if (uiPanGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _lastLocation = self.center;
    }else if (uiPanGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [uiPanGestureRecognizer translationInView:self.superview];
        self.center = CGPointMake(_lastLocation.x ,
                                  _lastLocation.y + MAX(0,translation.y));
        if (self.bottom > self.superview.height) {
            [uiPanGestureRecognizer removeTarget:self action:@selector(detectPan:)];
            
            if (self.topActionViewController && [self.topActionViewController respondsToSelector:@selector(operationRespondsWhenTouchEdges)]) {
                [self.topActionViewController performSelector:@selector(operationRespondsWhenTouchEdges) withObject:nil];
            }
        }
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            // Offset for gesture location.
            self.center = _lastLocation;
            self.transform = CGAffineTransformMakeScale(0.99, 0.99);
            self.highlighted = NO;
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
            self.transform = CGAffineTransformMakeScale(1/0.99, 1/0.99);
        }];
    }
}

@end
