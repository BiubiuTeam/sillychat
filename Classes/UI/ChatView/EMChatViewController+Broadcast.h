//
//  EMChatViewController+Broadcast.h
//  sillyChat
//
//  Created by haowenliang on 15/4/10.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMChatViewController.h"

@interface EMChatViewController (Broadcast)<UIAlertViewDelegate>

- (void)showAlertViewWithMessage:(NSString*)message succeed:(BOOL)ret;

@end
