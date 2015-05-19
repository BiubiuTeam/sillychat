//
//  EMAccountService.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMAccountService.h"
#import "SvUDIDTools.h"
#import "SillyService.h"

NSString *const kEMNotificationLogin = @"_kEMNotificationLogin_";
NSString* const kEMNotificationRegist = @"_kEMNotificationRegist_";

@interface EMAccountService ()
{
    EMErrorType _registerProcess;
    EMErrorType _loginProcess;
}
@end

@implementation EMAccountService

+ (instancetype)shareInstance
{
    static EMAccountService* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[EMAccountService alloc] init];
    });
    return s_instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _registerProcess = 0;
        _loginProcess = 0;
    }
    return self;
}

- (NSInteger)getAccountGendar
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:@"AccountGendarInfo"];
}

- (void)setAccountGendar:(NSInteger)gendar
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:gendar forKey:@"AccountGendarInfo"];
}

- (BOOL)hasSettingAccountInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"AccountBaseInfo"];
}

- (void)updateSettingAccountInfo:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:@"AccountBaseInfo"];
}

- (BOOL)registerProcessFail
{
    return _registerProcess != 0;
}

- (BOOL)loginProcessFail
{
    return _loginProcess != 0;
}

- (NSString*)nickName
{
    NSString *strName = [[UIDevice currentDevice] name]; //e.g. "My iPhone"
    NSString* phoneModel = [[UIDevice currentDevice] model]; // e.g. @"iPhone", @"iPod touch"
    return [NSString stringWithFormat:@"%@-%@",phoneModel,strName];
}

- (NSString*)password
{
    return @"sillychat";
}

- (NSString*)username
{
    return [SillyService sillyDeviceIdentifier];
}

- (void)registerAccount
{
    //异步注册账号
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:[self username]
                                                         password:[self password]
                                                   withCompletion:
     ^(NSString *username, NSString *password, EMError *error) {
         if (!error) {
             _registerProcess = 0;
             [[NSNotificationCenter defaultCenter] postNotificationName:kEMNotificationRegist object:nil userInfo:nil];
             
             DPTrace(@"环信注册成功");
             [self loginAccount];
         }else{
             _registerProcess = error.errorCode;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kEMNotificationRegist object:nil userInfo:nil];
             
             switch (error.errorCode) {
                 case EMErrorServerNotReachable:{
                     DPTrace(@"连接环信后台失败");
                 }break;
                 case EMErrorServerDuplicatedAccount:{
                     _registerProcess = 0;
                     DPTrace(@"环信重新注册提示");
                     [self loginAccount];
                 }break;
                 case EMErrorServerTimeout:{
                     DPTrace(@"连接环信后台超时");
                 }break;
                 default:{
                     DPTrace(@"环信注册失败");
                 }break;
             }
         }
     } onQueue:nil];
}

- (void)loginAccount
{
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[self username]
                                                        password:[self password]
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         if (loginInfo && !error) {
             DPTrace(@"登录成功");
             _loginProcess = 0;
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             //发送自动登陆状态通知
             [[NSNotificationCenter defaultCenter] postNotificationName:kEMNotificationLogin object:nil userInfo:nil];
             [self loginStateChange:YES];
         }else {
             _loginProcess = error.errorCode;
             [[NSNotificationCenter defaultCenter] postNotificationName:kEMNotificationLogin object:nil userInfo:nil];
             
             DPTrace(@"无法注册和登录，导致私聊无法使用");
             switch (error.errorCode) {
                 case EMErrorServerNotReachable:{
                     DPTrace(@"连接环信后台失败");
                 }break;
                 case EMErrorServerAuthenticationFailure:{
                     DPTrace(@"%@",error.description);
                 }break;
                 case EMErrorServerTimeout:{
                     DPTrace(@"连接环信后台超时");
                 }break;
                 default:{
                     DPTrace(@"登陆失败");
                 }break;
             }
         }
     } onQueue:nil];
}

-(void)loginStateChange:(BOOL)loginSuccess
{
    BOOL isAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
    if (isAutoLogin || loginSuccess){
        _registerProcess = 0;
        _loginProcess = 0;
    }else{
        [self registerAccount];
    }
}

- (void)checkUserInfo:(NSString*)dvcId
{
    DPTrace("检查用户信息");
    [[SillyService shareInstance] fetchSillyUserInformation:dvcId comletion:^(id json, JSONModelError *err) {
        if (err == nil) {
            SillyUserModel* user = [[SillyUserModel alloc] initWithDictionary:json error:&err];
            if (user) {
                DPTrace("用户数据：%@",user);
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:[user toJSONString] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }
    }];
}

@end
