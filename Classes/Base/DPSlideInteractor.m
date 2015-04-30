//
//  DPSlideInteractor.m
//  sillyChat
//
//  Created by haowenliang on 15/4/8.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPSlideInteractor.h"

@implementation DPSlideInteractor

+ (instancetype)shareInstance
{
    static DPSlideInteractor* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[DPSlideInteractor alloc] init];
    });
    return s_instance;
}

# pragma mark -
- (instancetype)init
{
    if (self = [super init]) {
        _duration = 0.3;
    }
    return self;
}
# pragma mark Helpers

- (CGRect)rectForDismissedState:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController;
    UIView *containerView = [transitionContext containerView];
    
    if (self.presenting)
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    else
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    switch (fromViewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            return CGRectMake(-SCREEN_WIDTH, 0,
                              SCREEN_WIDTH, containerView.bounds.size.height);
        case UIInterfaceOrientationLandscapeLeft:
            return CGRectMake(containerView.bounds.size.width, 0,
                              SCREEN_WIDTH, containerView.bounds.size.height);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectMake(0, -SCREEN_HEIGHT,
                              containerView.bounds.size.width, SCREEN_HEIGHT);
        case UIInterfaceOrientationPortrait:
            return CGRectMake(0, containerView.bounds.size.height,
                              containerView.bounds.size.width, SCREEN_HEIGHT);
        default:
            return CGRectZero;
    }
}


- (CGRect)rectForPresentedState:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController;
    if (self.presenting)
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    else
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    switch (fromViewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            return CGRectOffset([self rectForDismissedState:transitionContext], SCREEN_WIDTH, 0);
        case UIInterfaceOrientationLandscapeLeft:
            return CGRectOffset([self rectForDismissedState:transitionContext], -SCREEN_WIDTH, 0);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectOffset([self rectForDismissedState:transitionContext], 0, SCREEN_HEIGHT);
        case UIInterfaceOrientationPortrait:
            return CGRectOffset([self rectForDismissedState:transitionContext], 0, -SCREEN_HEIGHT);
        default:
            return CGRectZero;
    }
}


# pragma mark -
# pragma mark UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.presenting = YES;
    return self;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presenting = NO;
    return self;
}


# pragma mark -
# pragma mark UIViewControllerAnimatedTransitioning

- (void)animationEnded:(BOOL)transitionCompleted
{
    // reset state
    self.presenting = NO;
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return MAX(0.3, _duration);
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    NSLog(@"containerView frame=%@ bounds=%@", NSStringFromCGRect(containerView.frame), NSStringFromCGRect(containerView.bounds));
    
    if (self.presenting) {
        // set starting rect for animation
        toViewController.view.frame = [self rectForDismissedState:transitionContext];
        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.frame = [self rectForPresentedState:transitionContext];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{            CGRect frame = [self rectForDismissedState:transitionContext];
            frame.origin.y = -frame.size.height;
            fromViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
        }];
    }
}

@end
