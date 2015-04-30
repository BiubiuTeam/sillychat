//
//  UIViewController+Front.h
//  sillyChat
//
//  Created by haowenliang on 15/4/12.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Front)

//返回当前显示内容的View Controller
- (UIViewController *)frontViewController;

- (BOOL)viewControllerInStack:(Class)theClass;
@end
