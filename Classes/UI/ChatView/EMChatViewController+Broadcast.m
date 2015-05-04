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
#import "SillyService.h"

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
    __weak EMChatViewController* weakChat = self;
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:nil];
    [sheet setDestructiveButtonWithTitle:@"举报图片或文字内容" atIndex:0 block:^{

        [weakChat reportWithType:ReportReasonType_Content extension:@"举报图片或文字内容"];
    }];
    [sheet setDestructiveButtonWithTitle:@"聊天过程中受到骚扰" atIndex:1 block:^{

        [weakChat reportWithType:ReportReasonType_Chat extension:@"聊天过程中受到骚扰"];
    }];
    [sheet addButtonWithTitle:@"取消" block:nil];
    
    [sheet showInView:self.view completion:^(BOOL finished) {
        
    }];
}

- (void)reportWithType:(ReportReasonType)reason extension:(NSString*)extension
{
    DPTrace("举报：%@ - %@",[self.broadcastModel titleId],extension);
    [[SillyService shareInstance] reportContentOptWithId:[[self.broadcastModel titleId] unsignedIntegerValue] contentType:ReportType_Cont reason:reason reasonCont:extension comletion:^(id json, JSONModelError *err) {
        DPTrace("举报回调");
        if (err == nil) {
            SillyResponseModel* model = [[SillyResponseModel alloc] initWithDictionary:json error:&err];
            if (model.statusCode && [model.statusCode integerValue] == 0) {
                DPTrace("举报成功");
            }else if (err){
                DPTrace("返回数据出错: %@ \n %@",json,err);
            }else{
                DPTrace("举报操作失败: code : %@ \n info : %@",model.statusCode ,model.statusInfo);
            }
        }else{
            DPTrace("举报操作请求发送失败： %@",err);
        }
    }];
}

@end
