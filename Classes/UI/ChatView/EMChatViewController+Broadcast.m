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
#import "RelationShipService.h"

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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"举报后将不会再看到该内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 0x2009;
        [alert show];
    }];
    [sheet setDestructiveButtonWithTitle:@"聊天过程中受到骚扰" atIndex:1 block:^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"向系统举报，且永久不再联系" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 0x2010;
        [alert show];
    }];
    [sheet addButtonWithTitle:@"取消" block:nil];
    
    [sheet showInView:self.view completion:^(BOOL finished) {
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x2009) {
        //举报内容
        if(buttonIndex == 1){
            [self reportWithType:ReportReasonType_Content extension:@"举报图片或文字内容"];
        }
    }else if(alertView.tag == 0x2010){
        //举报聊天
        if(buttonIndex == 1){
            [self reportWithType:ReportReasonType_Chat extension:@"聊天过程中受到骚扰"];
            //加入黑名单
            EMError *error = [[EaseMob sharedInstance].chatManager blockBuddy:self.chatter relationship:eRelationshipBoth];
            if (!error) {
                NSLog(@"发送成功");
            }
        }
    }
}

- (void)reportWithType:(ReportReasonType)reason extension:(NSString*)extension
{
    DPTrace("举报：%@ - %@",[self.broadcastModel titleId],extension);
    [[SillyService shareInstance] reportContentOptWithId:[[self.broadcastModel titleId] unsignedIntegerValue] contentType:ReportType_Cont reason:reason reasonCont:extension comletion:^(id json, JSONModelError *err) {
        DPTrace("举报回调");
        EMChatViewController* strong = (EMChatViewController*)_weakSelf;
        NSString* message = nil;
        if (err == nil) {
            SillyResponseModel* model = [[SillyResponseModel alloc] initWithDictionary:json error:&err];
            if (model.statusCode && [model.statusCode integerValue] == 0) {
                DPTrace("举报成功");
                message = @"举报成功";
                
                [[RelationShipService shareInstance] reloadRelationShips:@0];
            }else if (err){
                DPTrace("返回数据出错: %@ \n %@",json,err);
                message = @"举报操作出错";
            }else{
                DPTrace("举报操作失败: code : %@ \n info : %@",model.statusCode ,model.statusInfo);
                message = @"举报操作失败";
            }
        }else{
            DPTrace("举报操作请求发送失败： %@",err);
            message = @"举报失败，请检查你当前的网络状况";
        }
        [strong showAlertViewWithMessage:message];
    }];
}

- (void)showAlertViewWithMessage:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

@end
