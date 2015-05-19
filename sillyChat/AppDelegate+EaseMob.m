//
//  AppDelegate+EaseMob.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "UIViewController+Front.h"
#import "EMChatViewController.h"
#import "SillyBroacastModel.h"
#import "HomePageViewController.h"
#import "RelationShipService.h"
#import "PlazaViewController.h"
#import "UIViewController+Front.h"

#import "EMAccountService.h"
//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 5.0;

@implementation AppDelegate (EaseMob)


- (BOOL)easemobApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions
{
    BOOL withLaunchInfo = NO;
    if (launchOptions) {
        NSDictionary*userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if(userInfo)
        {
            withLaunchInfo = [self didReiveceRemoteNotificatison:userInfo];
        }
    }
    _connectionState = eEMConnectionConnected;
    
    [self registerRemoteNotification];
    //注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"sillychat_dev";
#else
    apnsCertName = @"sillychat_pro";
#endif
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"nuxsoft#sillychat" apnsCertName:apnsCertName];
    
    // 登录成功后，自动去取好友列表
    // SDK获取结束后，会回调
    // - (void)didFetchedBuddyList:(NSArray *)buddyList error:(EMError *)error方法。
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    
    // 注册环信监听
    [self registerEaseMobNotification];
    // 需要在注册sdk后写上该方法
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [self setupNotifiers];
    
    return withLaunchInfo;
}

//自定义方法
- (void)registerRemoteNotification
{
#if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

//- (void)applicationWillResignActive:(UIApplication *)application
//{
//    [[EaseMob sharedInstance] applicationWillResignActive:application];
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    [[EaseMob sharedInstance] applicationDidBecomeActive:application];
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    [[EaseMob sharedInstance] applicationWillTerminate:application];
//}
//
//系统方法
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是你的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册推送失败"
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//系统方法

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

//系统方法
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didReceiveLocalNotification:notification];
    
    NSDictionary* userInfo = notification.userInfo;
    NSString* from = [userInfo objectForKey:@"from"];
    NSString* sortid = [userInfo objectForKey:@"broadcast"];
    
    //Open Chat View
    if([self.window.rootViewController isKindOfClass:[HomePageViewController class]]){
        [self changeToPlazaViewControllerWithDatasource:nil];
    }
    
    EMChatViewController* chat = [[EMChatViewController alloc] initWithChatter:from];
    NSNumber* titleId = [NSNumber numberWithInteger:[sortid integerValue]];
    SillyBroacastModel* model = [[RelationShipService shareInstance] getBroadcastOf:from titleId:titleId];
    if (model == nil) {
        model = [[SillyBroacastModel alloc] init];
        model.sortId = titleId;
        model.isLocalTmp = @YES;
    }
    chat.broadcastModel = model;
    [[(UIViewController*)self.window.rootViewController frontViewController] presentViewController:chat animated:NO completion:^{
    }];
}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark - IChatManagerDelegate
// 开始自动登录回调
-(void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    DPTrace(@"Start automatic login...");
}

// 结束自动登录回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    DPTrace(@"End automatic login...");
}

// 绑定deviceToken回调
- (void)didBindDeviceWithError:(EMError *)error
{
    if (error) {
        DPTrace(@"Fail to bind device token");
    }
}

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
}

// 打印收到的apns信息
-(BOOL)didReiveceRemoteNotificatison:(NSDictionary *)userInfo
{
    [[RelationShipService shareInstance] setHasUnhandleMessage:YES];
    
//    [self changeToPlazaViewControllerWithDatasource:nil];
    //需要找到对应Message，才能解析到Message内容来标识哪个会话
    return YES;
#if DEBUG
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送内容"
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
#endif
}

#pragma mark -系统生命周期
// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

#pragma mark - notifiers
- (void)appDidEnterBackgroundNotif:(NSNotification*)notif{
    [[EaseMob sharedInstance] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:notif.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
#if !TARGET_IPHONE_SIMULATOR
    [(UIApplication*)notif.object setApplicationIconBadgeNumber:0];
#endif
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}

//这里主要是管理本地推送、消息提醒、未读数管理
-(void)didReceiveMessage:(EMMessage *)message
{
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        [self showNotificationWithMessage:message];
    }else {
        UIViewController* root = self.window.rootViewController;
        if ([[root frontViewController] isKindOfClass:[EMChatViewController class]]) {
            EMChatViewController* chatViewCtr = (EMChatViewController*)[root frontViewController];
            if ([message.from isEqualToString:[chatViewCtr chatter]]) {
                if (message.ext) {
                    NSString* bid = [message.ext objectForKey:@"broadcast"];
                    if ([bid integerValue] == [[chatViewCtr.broadcastModel sortId] integerValue]) {
                        //这个时候不需要提示
                        return;
                    }
                }
            }
        }
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
#endif
        NSDictionary* ext = message.ext;
        if ([ext count]) {
            NSString* from = [ext objectForKey:@"from"];
            NSString* titleid = [ext objectForKey:@"broadcast"];
            [[RelationShipService shareInstance] addUnreadCountOfChat:[NSString stringWithFormat:@"%@%@",from,titleid]];
        }
        [RelationShipService shareInstance].hasUnhandleMessage = YES;
        //触发主页面的动画
        if([_plazaViewController frontViewController] == _plazaViewController)
        {
            [_plazaViewController.chatRoomButton setSelected:YES];
            [_plazaViewController.chatRoomButton startAnimation];
        }
        //是否需要做频率限制
        [[RelationShipService shareInstance] performSelector:@selector(updateRelationShips) withObject:nil afterDelay:0.5];
    }
}

//处理被举报消息
- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    NSString* from = cmdMessage.from;
    //cmd from yourself
    if ([[[EMAccountService shareInstance] username] isEqualToString:from]) {
        return;
    }
    
    NSDictionary* ext = [cmdMessage ext];
    if ([ext objectForKey:@"sillychat#report"]) {
        //举报操作
        [[NSNotificationCenter defaultCenter] postNotificationName:Key_ReportOperation object:nil userInfo:ext];
    }else if ([ext objectForKey:@"sillychat#emoji"]){
        //表情，不管
        
    }
}

- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (abs(timeInterval) < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        DPTrace(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }

    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_simpleBanner) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = @"你有一条图片消息";
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = @"你有一条位置分享消息";
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = @"你有一条语音消息";
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = @"你有一条视频消息";
            }
                break;
            default:
                break;
        }
        notification.alertBody = messageStr;
    }else{
        notification.alertBody = @"你有一条新消息";
    }
    
    //去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    if (message.ext) {
        notification.userInfo = message.ext;
//        NSString* from = [message.ext objectForKey:@"from"];
//        NSString* sortid = [message.ext objectForKey:@"broadcast"];
//        notification.alertBody = [NSString stringWithFormat:@"来自 %@ 关于 %@ \n %@",from,sortid,notification.alertBody];
    }
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber += 1;
}


/*!
 @method
 @brief 离线非透传消息接收完成的回调
 @discussion
 @param offlineMessages 接收到的离线列表
 @result
 */
- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages
{
    //从离线数据中获取关键信息，标识未读关系链
    if ([offlineMessages count]) {
        for (EMMessage* message in offlineMessages) {
            NSDictionary* ext = message.ext;
            NSString* from = [ext objectForKey:@"from"];
            NSString* broadcast = [ext objectForKey:@"broadcast"];
            [[RelationShipService shareInstance] addUnreadCountOfChat:[NSString stringWithFormat:@"%@%@",from,broadcast]];
        }
    }
}

@end
