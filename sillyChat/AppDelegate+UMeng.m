//
//  AppDelegate+UMeng.m
//  sillyChat
//
//  Created by haowenliang on 15/4/21.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "AppDelegate+UMeng.h"
#import "MobClick.h"
@implementation AppDelegate (UMeng)

- (void)registUmeng
{
    [MobClick startWithAppkey:@"5535b96367e58e9af50006ee" reportPolicy:BATCH channelId:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
}

@end
