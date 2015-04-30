//
//  PlazaViewController+EaseMob.m
//  sillyChat
//
//  Created by haowenliang on 15/3/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaViewController+EaseMob.h"
#import "UIViewController+HUD.h"
#import "EMChatViewController.h"

#import "UIViewController+Front.h"
#import "RelationShipService.h"
#import "ChatRoomViewController.h"

@implementation PlazaViewController (EaseMob)

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
    NSDictionary* ext = message.ext;
    if ([ext count]) {
        NSString* from = [ext objectForKey:@"from"];
        NSString* titleid = [ext objectForKey:@"broadcast"];
        [[RelationShipService shareInstance] addUnreadCountOfChat:[NSString stringWithFormat:@"%@%@",from,titleid]];
    }
    [RelationShipService shareInstance].hasUnhandleMessage = YES;
    
    if([self frontViewController] == self)
    {
        [_chatRoomButton setSelected:YES];
        [_chatRoomButton startAnimation];
    }
    
//    if(NO == [self viewControllerInStack:[ChatRoomViewController class]])
    {
        //是否需要做频率限制
        [[RelationShipService shareInstance] performSelector:@selector(updateRelationShips) withObject:nil afterDelay:0.5];
    }
}

@end
