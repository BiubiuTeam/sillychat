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
    [[EMAccountService shareInstance] loginStateChange:NO];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = APPLICATIONCOLOR;

    
    if (nil == _homePageViewController) {
        _homePageViewController = [[HomePageViewController alloc] init];
    }
    _window.rootViewController = _homePageViewController;
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)changeToPlazaViewControllerWithDatasource:(NSArray*)datasource
{
    if (nil == _plazaViewController) {
        _plazaViewController = [[PlazaViewController alloc] initWithTagsArray:datasource];
    }
    _window.rootViewController = _plazaViewController;
    [_window makeKeyAndVisible];
    
    self.homePageViewController = nil;
}
@end
