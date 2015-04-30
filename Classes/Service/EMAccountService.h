//
//  EMAccountService.h
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

/**
 *  帐户相关的服务（注册，登陆）
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString* const kEMNotificationLogin;
extern NSString* const kEMNotificationRegist;

@interface EMAccountService : NSObject

+ (instancetype)shareInstance;
- (NSString*)username;

- (BOOL)registerProcessFail;
- (BOOL)loginProcessFail;
- (void)loginStateChange:(BOOL)loginSuccess;


- (BOOL)hasSettingAccountInfo;
- (void)updateSettingAccountInfo:(BOOL)value;

- (NSInteger)getAccountGendar;
- (void)setAccountGendar:(NSInteger)gendar;

@end
