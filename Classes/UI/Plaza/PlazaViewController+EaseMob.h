//
//  PlazaViewController+EaseMob.h
//  sillyChat
//
//  Created by haowenliang on 15/3/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaViewController.h"

@interface PlazaViewController (EaseMob)<EMChatManagerDelegate>

- (void)registerEaseMobNotification;
- (void)unRegisterEaseMobNotification;

@end
