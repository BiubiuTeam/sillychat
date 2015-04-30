//
//  UIViewControllerAdditions.m
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UIViewControllerAdditions.h"

@implementation UIViewController (Additions)

- (void)operationRespondsWhenTouchEdges
{
    
}

- (CGFloat)getBarsHeight
{
    return self.navigationController.navigationBar.height + STATUSBAR_HEIGHT + self.tabBarController.tabBar.height;
}

- (CGFloat)getNavStatusBarHeight
{
    return self.navigationController.navigationBar.height + STATUSBAR_HEIGHT;
}

- (BOOL)isSupportLeftDragBack
{
    return YES;
}

#pragma mark --- 标题设置

/*
 *  设置自定义TitleView
 */
- (void)setCustomTitleView:(UIView*)titleView
{
    if (titleView != nil) {
        CGRect frame = titleView.frame;
        frame.origin.x = (SCREEN_WIDTH -frame.size.width)/2.0f;
        titleView.frame = frame;
        self.navigationItem.titleView = nil;
        self.navigationItem.titleView = titleView;
    }
}

#pragma mark ---左右按钮

/**
 *  统一的返回按钮
 */
- (void)resetBackBarButtonWithImage
{
    UIImage* tImage = nil;
    UIImage* pImage = nil;
    tImage = LOAD_ICON_USE_POOL_CACHE(@"bb_navigation_back_normal.png");
    pImage = LOAD_ICON_USE_POOL_CACHE(@"bb_navigation_back_press.png");
    // Custom initialization
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5.0, 0.0, tImage.size.width,tImage.size.height);
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    [backButton setBackgroundImage:tImage forState:UIControlStateNormal];
    [backButton setBackgroundImage:pImage forState:UIControlStateHighlighted];
    
    UIEdgeInsets  insets = UIEdgeInsetsMake(1, 15, 1, 10);
    [backButton setTitleEdgeInsets:insets];

    [backButton addTarget:self action:@selector(didClickBackBarButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem=temporaryBarButtonItem;
}

/*
 *  返回操作
 */
- (void)didClickBackBarButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetTextRightButtonWithTitle:(NSString*)title andSel:(SEL)selector
{
    UIButton *rightButtonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 30)];
    [rightButtonItem addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    rightButtonItem.titleLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
    
    [rightButtonItem setTitleColor:[UIColor colorWithColorType:ColorType_NavBtnNormal] forState:UIControlStateNormal];
    [rightButtonItem setTitleColor:[UIColor colorWithColorType:ColorType_NavBtnPressed] forState:UIControlStateHighlighted];
    
    [rightButtonItem setTitle:title forState:UIControlStateNormal];
    [rightButtonItem sizeToFit];
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightButtonItem];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)resetTextLeftButtonWithTitle:(NSString*)title andSel:(SEL)selector
{
    UIButton *rightButtonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 30)];
    [rightButtonItem addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    rightButtonItem.titleLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
    [rightButtonItem setTitleColor:[UIColor colorWithColorType:ColorType_NavBtnNormal] forState:UIControlStateNormal];
    [rightButtonItem setTitleColor:[UIColor colorWithColorType:ColorType_NavBtnPressed] forState:UIControlStateHighlighted];
    
    [rightButtonItem setTitle:title forState:UIControlStateNormal];
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightButtonItem];
    self.navigationItem.leftBarButtonItem = rightBarButtonItem;
}

- (void)removeLeftNavigationBarButton
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = nil;
}

- (void)removeRightNavigationBarButton
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)resetLeftBarButtonWithNormal:(NSString*)normal highLighted:(NSString*)higlighted andSel:(SEL)selector
{
    UIImage* tImage = nil;
    UIImage* pImage = nil;
    tImage = LOAD_ICON_USE_POOL_CACHE(normal);
    pImage = LOAD_ICON_USE_POOL_CACHE(higlighted);
    
    // Custom initialization
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(5.0, 0.0, tImage.size.width,tImage.size.height);
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn setBackgroundImage:tImage forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:pImage forState:UIControlStateHighlighted];
    
    UIEdgeInsets  insets = UIEdgeInsetsMake(1, 15, 1, 10);
    [rightBtn setTitleEdgeInsets:insets];
    
    [rightBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
}

- (void)resetRightBarButtonWithNormal:(NSString*)normal highLighted:(NSString*)higlighted andSel:(SEL)selector
{
    UIImage* tImage = nil;
    UIImage* pImage = nil;
    tImage = LOAD_ICON_USE_POOL_CACHE(normal);
    pImage = LOAD_ICON_USE_POOL_CACHE(higlighted);
    
    // Custom initialization
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(5.0, 0.0, tImage.size.width,tImage.size.height);
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn setBackgroundImage:tImage forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:pImage forState:UIControlStateHighlighted];
    
    UIEdgeInsets  insets = UIEdgeInsetsMake(1, 15, 1, 10);
    [rightBtn setTitleEdgeInsets:insets];
    
    [rightBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
}

#pragma mark ---导航栏
- (void)setDefaultNavBackground
{
    if ([UINavigationBar instancesRespondToSelector:@selector(setBarTintColor:)])
    {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithColorType:ColorType_NavBar];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    if ([UINavigationBar instancesRespondToSelector:@selector(setShadowImage:)])
    {
        [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    }
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)setTranslucentNavBackground
{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:LOAD_ICON_USE_POOL_CACHE(@"bb_transparent.png") forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(shadowImage)])
    {
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    }
    self.navigationController.navigationBar.translucent = YES;
}

- (void)setMaskHomeNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:LOAD_ICON_USE_POOL_CACHE(@"desktop_navigate_background.png") forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(shadowImage)])
    {
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    }
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
}



@end
