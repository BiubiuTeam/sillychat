//
//  UIViewControllerAdditions.h
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Additions)

- (void)operationRespondsWhenTouchEdges;

- (CGFloat)getBarsHeight;
- (CGFloat)getNavStatusBarHeight;
- (BOOL)isSupportLeftDragBack;
//返回按钮
- (void)didClickBackBarButton;

- (void)resetBackBarButtonWithImage;
- (void)removeLeftNavigationBarButton;
- (void)removeRightNavigationBarButton;

- (void)resetTextLeftButtonWithTitle:(NSString*)title andSel:(SEL)selector;
//右上角按钮
- (void)resetTextRightButtonWithTitle:(NSString*)title andSel:(SEL)selector;
- (void)resetLeftBarButtonWithNormal:(NSString*)normal highLighted:(NSString*)higlighted andSel:(SEL)selector;
- (void)resetRightBarButtonWithNormal:(NSString*)normal highLighted:(NSString*)higlighted andSel:(SEL)selector;

//标题
- (void)setCustomTitleView:(UIView*)titleView;

//导航栏
- (void)setDefaultNavBackground;
- (void)setTranslucentNavBackground;

@end
