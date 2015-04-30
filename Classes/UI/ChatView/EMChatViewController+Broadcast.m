//
//  EMChatViewController+Broadcast.m
//  sillyChat
//
//  Created by haowenliang on 15/4/10.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMChatViewController+Broadcast.h"
#import "SillyBroacastModel.h"
#import "BlockActionSheet.h"

@implementation EMChatViewController (Broadcast)

- (instancetype)initWithSillyBroadcast:(SillyBroacastModel *)broadcast
{
    if (self = [self initWithChatter:broadcast.dvcId]) {
        self.broadcastModel = broadcast;
    }
    return self;
}

- (BroadcastBaseView *)broadcastView
{
    if (nil == _broadcastView) {
        _broadcastView = [[BroadcastBaseView alloc] initWithFrame:CGRectZero];
        _broadcastView.delegate = self;
    }
    return _broadcastView;
}
//返回操作
- (void)didClickLeftButton
{
    [self dismissChatViewController];
}
//举报操作
- (void)didClickRightButton
{
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:nil];
    [sheet setDestructiveButtonWithTitle:@"举报图片或文字内容" atIndex:0 block:^{
        
    }];
    [sheet setDestructiveButtonWithTitle:@"聊天过程中受到骚扰" atIndex:1 block:^{
        
    }];
    [sheet addButtonWithTitle:@"取消" block:nil];
    
    [sheet showInView:self.view completion:^(BOOL finished) {
        
    }];
}

@end
