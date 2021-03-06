//
//  BaseViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BaseViewController.h"
#import "MobClick.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.weakSelf = self;
    _mainVCtrColor = APPLICATIONCOLOR;
    
    [self.view setBackgroundColor:APPLICATIONCOLOR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass(self.class)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass(self.class)];
}


#pragma mark -ImagePicker导航栏颜色改变问题
//修改相册选择界面的导航栏颜色
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]])
    {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        
        if ([UINavigationBar instancesRespondToSelector:@selector(setBarTintColor:)])
        {
            viewController.navigationController.navigationBar.barTintColor = _mainVCtrColor;
            viewController.navigationController.navigationBar.tintColor = [UIColor clearColor];
        }
        viewController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:FONT_SIZE_LARGE]};
        /* Left button */
        viewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        /* Right button color  */
        viewController.navigationController.navigationBar.topItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
