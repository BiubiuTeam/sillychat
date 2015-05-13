//
//  PlazaViewController+Service.m
//  sillyChat
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaViewController+Service.h"
#import "SillyService.h"
#import "SCStateService.h"
#import "UmLogEngine.h"

@implementation PlazaViewController (Service)

- (void)postTextBroadcast:(NSString*)content
{
    [UmLogEngine logEvent:EventPublishStatus attribute:@{@"StatusType":_wording4Tag.length?_wording4Tag:@"",@"ContentType":@"text"}];
    
    [[SillyService shareInstance] sendBroacastToPlaza:BroacastType_Text titleContent:content msgTag:_msgTag extension:nil comletion:^(id json, JSONModelError *err) {
        PlazaViewController* tmpself = (PlazaViewController*)_weakSelf;
        BOOL succeed = NO;
        if (err == nil) {
            SillyResponseModel* response = [[SillyResponseModel alloc] initWithDictionary:json error:&err];
            if (response && [response.statusCode integerValue] == 0) {
                DPTrace("广播成功");
                [tmpself forceToUpdatePlazaSillyMessage];
                succeed = YES;
            }else {
                DPTrace("广播无聊消息失败");
            }
        }else{
            DPTrace("广播无聊消息发送失败");
        }
        if (tmpself.postOptComletionCallback) {
            tmpself.postOptComletionCallback(succeed, err);
        }
        tmpself.postOptComletionCallback = nil;
    }];
}

/**
 *  需要在Extension里面携带文本
 */
- (void)postImageBroadcast:(NSString*)picPath withExtension:(NSDictionary*)extension
{
    [UmLogEngine logEvent:EventPublishStatus attribute:@{@"StatusType":_wording4Tag.length?_wording4Tag:@"",@"ContentType":@"text"}];
    __block NSNumber* msgTag = [extension objectForKey:@"msgTag"];
    [[SillyService shareInstance] sendBroacastToPlaza:BroacastType_Image titleContent:picPath  msgTag:[msgTag unsignedIntegerValue] extension:extension comletion:^(id json, JSONModelError *err) {
        PlazaViewController* tmpself = (PlazaViewController*)_weakSelf;
        if (err == nil) {
            SillyResponseModel* response = [[SillyResponseModel alloc] initWithDictionary:json error:&err];
            if (response && [response.statusCode integerValue] == 0) {
                DPTrace("广播成功");
                if ([msgTag unsignedIntegerValue] == [[SCStateService shareInstance] selectedMsgTag]) {
                    [tmpself forceToUpdatePlazaSillyMessage];
                }
            }else {
                DPTrace("广播无聊消息失败");
            }
        }else{
            DPTrace("广播无聊消息发送失败");
        }
    }];
}

/**
 *  在extension里面携带语音的长度
 */
- (void)postAudioBroadcast:(NSString*)audioPath withExtension:(NSDictionary*)extension
{
    [[SillyService shareInstance] sendBroacastToPlaza:BroacastType_Voice titleContent:audioPath  msgTag:_msgTag extension:extension comletion:^(id json, JSONModelError *err) {
        PlazaViewController* tmpself = (PlazaViewController*)_weakSelf;
        if (err == nil) {
            SillyResponseModel* response = [[SillyResponseModel alloc] initWithDictionary:json error:&err];
            if (response && [response.statusCode integerValue] == 0) {
                DPTrace("语音广播成功");
                [tmpself forceToUpdatePlazaSillyMessage];
            }else {
                DPTrace("广播无聊语音消息失败");
            }
        }else{
            DPTrace("广播无聊语音消息发送失败");
        }
    }];
}
@end
