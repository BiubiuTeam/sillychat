//
//  ChatRoomViewController+EaseMob.m
//  sillyChat
//
//  Created by haowenliang on 15/4/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatRoomViewController+EaseMob.h"
#import "EMChatViewController.h"
#import "UIViewController+Front.h"

#import "RelationShipService.h"

@implementation ChatRoomViewController (EaseMob)
#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification
{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

-(void)didReceiveMessage:(EMMessage *)message
{
//    //消息未读，需要更新关系链数据
//    [[RelationShipService shareInstance] performSelector:@selector(updateRelationShips) withObject:nil afterDelay:0.3];
}

@end
