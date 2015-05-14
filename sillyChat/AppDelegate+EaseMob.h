//
//  AppDelegate+EaseMob.h
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (EaseMob)<IChatManagerDelegate>
- (BOOL)easemobApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions;
@end
