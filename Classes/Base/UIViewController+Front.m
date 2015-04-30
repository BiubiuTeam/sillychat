//
//  UIViewController+Front.m
//  sillyChat
//
//  Created by haowenliang on 15/4/12.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UIViewController+Front.h"

@implementation UIViewController (Front)

- (UIViewController *)frontViewController{
    if (self.presentedViewController) {
        return [self.presentedViewController frontViewController];
    }
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [[(UINavigationController *)self topViewController] frontViewController];
    }
    else if ([self isKindOfClass:[UITabBarController class]]){
        return [[(UITabBarController *)self selectedViewController] frontViewController];
    }
    return self;
}


- (BOOL)viewControllerInStack:(Class)theClass
{
    if ([self isKindOfClass:theClass]) {
        return YES;
    }
    if (self.presentedViewController) {
        return [self.presentedViewController viewControllerInStack:theClass];
    }
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [[(UINavigationController *)self topViewController] viewControllerInStack:theClass];
    }
    else if ([self isKindOfClass:[UITabBarController class]]){
        return [[(UITabBarController *)self selectedViewController] viewControllerInStack:theClass];
    }
    return NO;
}


@end
