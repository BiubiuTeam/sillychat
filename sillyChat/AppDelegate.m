//
//  AppDelegate.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+BMap.h"
#import "PlazaViewController.h"
#import "HomePageViewController.h"
#import "AppDelegate+EaseMob.h"
#import "AppDelegate+UMeng.h"

#import "EMAccountService.h"
#import "MobClick.h"
#import "RelationShipService.h"

#import <SDWebImage/SDImageCache.h>
//void UncaughtExceptionHandler(NSException *exception) {
//    /**
//     *  获取异常崩溃信息
//     */
//    NSArray *callStack = [exception callStackSymbols];
//    NSString *reason = [exception reason];
//    NSString *name = [exception name];
//    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
//    
//    /**
//     *  把异常崩溃信息发送至开发者邮件
//     */
//    NSMutableString *mailUrl = [NSMutableString string];
//    [mailUrl appendString:@"mailto:lianghwen@live.cn"];
//    [mailUrl appendString:@"?subject=此刻程序异常崩溃，请配合发送异常报告，谢谢合作！"];
//    [mailUrl appendFormat:@"&body=%@", content];
//    // 打开地址
//    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
//}

@interface AppDelegate ()

@end

@interface AppDelegate ()

@property (nonatomic, strong) HomePageViewController* homePageViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registBaiduMap];
    [self registUmeng];
    
    [RelationShipService shareInstance];
//    [[EMAccountService shareInstance] updateSettingAccountInfo:NO];
    self.lastPlaySoundDate = [NSDate date];
    
    _connectionState = eEMConnectionConnected;
    
    [self easemobApplication:application withOptions:launchOptions];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = APPLICATIONCOLOR;
//    if (withLaunchInfo) {
//        [self changeToPlazaViewControllerWithDatasource:nil];
//    }else{
        if (nil == _homePageViewController) {
            _homePageViewController = [[HomePageViewController alloc] init];
        }
        _window.rootViewController = _homePageViewController;
        [_window makeKeyAndVisible];
//    }
    
    [[EMAccountService shareInstance] loginStateChange:NO];
    
    //清理旧图片缓存
    [[SDImageCache sharedImageCache] clearDisk];
    
    return YES;
}

- (void)changeToPlazaViewControllerWithDatasource:(NSArray*)datasource
{
    if (nil == _plazaViewController) {
        _plazaViewController = [[PlazaViewController alloc] initWithTagsArray:datasource];
    }
    if (SYSTEM_VERSION < 8.0) {
        _plazaViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    _window.rootViewController = _plazaViewController;
    [_window makeKeyAndVisible];
    
    self.homePageViewController = nil;
}

- (void)optWhenTopViewControllerPopup
{
    if (_plazaViewController) {
        [_plazaViewController judgeIfHasUnreadInfo];
    }
}

@end
