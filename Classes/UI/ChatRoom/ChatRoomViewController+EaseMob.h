//
//  ChatRoomViewController+EaseMob.h
//  sillyChat
//
//  Created by haowenliang on 15/4/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatRoomViewController.h"

@interface ChatRoomViewController (EaseMob)<EMChatManagerDelegate>

- (void)registerEaseMobNotification;
- (void)unRegisterEaseMobNotification;

@end
