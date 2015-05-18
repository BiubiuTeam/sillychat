//
//  EMChatViewController+Broadcast.m
//  sillyChat
//
//  Created by haowenliang on 15/4/10.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMChatViewController+Broadcast.h"
#import "EMChatViewController+Message.h"
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
    [sheet setDestructiveButtonWithTitle:@"含政治敏感信息" atIndex:0 block:^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"举报后将不会再看到该内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 0x2009;
        [alert show];
    }];
    [sheet setDestructiveButtonWithTitle:@"含色情等不良信息" atIndex:1 block:^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"举报后将不会再看到该内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 0x2010;
        [alert show];
    }];
    [sheet setDestructiveButtonWithTitle:@"受到谩骂或人身攻击" atIndex:2 block:^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"举报后将不会再看到该内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 0x2011;
        [alert show];
    }];
    [sheet addButtonWithTitle:@"取消" block:nil];
    
    [sheet showInView:self.view completion:^(BOOL finished) {
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x1456) {
        //举报成功
        [self dismissChatViewController];
    }else if (alertView.tag == 0x2009) {
        //政治
        if(buttonIndex == 1){
            [self reportWithType:ReportReasonType_Policy extension:@"政治、敏感信息"];
        }
    }else if(alertView.tag == 0x2010){
        //色情
        if(buttonIndex == 1){
            [self reportWithType:ReportReasonType_Porn extension:@"色情、广告信息"];
        }
    }else if(alertView.tag == 0x2011){
        //人身攻击
        if(buttonIndex == 1){
            [self reportWithType:ReportReasonType_Attacks extension:@"人身攻击"];
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
        BOOL ret = NO;
        if (err == nil) {
            SillyResponseModel* model = [[SillyResponseModel alloc] initWithDictionary:json error:&err];
            if (model.statusCode && [model.statusCode integerValue] == 0) {
                DPTrace("举报成功");
                message = @"举报成功";
                ret = YES;
                //重新更新关系链
                [[RelationShipService shareInstance] reloadRelationShips:@0];
                //发命令消息给对方
                [strong sendReportCmdMessage:reason];
                
                //更新广场数据、关系链数据
                [[NSNotificationCenter defaultCenter] removeObserver:strong];
                NSDictionary* dict = @{@"broadcast":[strong.broadcastModel titleId],@"from":[strong.broadcastModel dvcId]};
                [[NSNotificationCenter defaultCenter] postNotificationName:Key_ReportOperation object:nil userInfo:dict];
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
        [strong showAlertViewWithMessage:message succeed:ret];
    }];
}

- (void)showAlertViewWithMessage:(NSString*)message succeed:(BOOL)ret
{
    id delegate = ret?self:nil;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:delegate cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alert.tag = 0x1456;
    [alert show];
}

@end
