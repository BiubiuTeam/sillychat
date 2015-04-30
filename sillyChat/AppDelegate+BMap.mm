//
//  AppDelegate+BMap.m
//  sillyChat
//
//  Created by haowenliang on 15/3/29.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "AppDelegate+BMap.h"
#import "DPLbsServerEngine.h"

@implementation AppDelegate (BMap)

- (void)registBaiduMap
{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"lb4aAHLdZE7zevhDYCGfnzUu"  generalDelegate:self];
    if (!ret) {
        DPTrace("baidu map manager start failed!");
    }else{
        DPTrace("baidu map manager start succeed!");
    }
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [BMKMapView willBackGround];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [BMKMapView didForeGround];
    [[DPLbsServerEngine shareInstance] forceToUpdateLocationWithCacheTime:10*60];
}
@end
