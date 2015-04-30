//
//  UmLogEngine.m
//  sillyChat
//
//  Created by haowenliang on 15/4/25.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UmLogEngine.h"
#import "MobClick.h"

#import "PlazaFilterView.h"

NSString* const EventPublishStatus = @"PublishStatus";/*发布状态被点击的次数和独立用户数*/
NSString* const EventPickStatus = @"PickStatus";/*筛选状态被发起的次数和独立用户数*/
NSString* const EventViewStatus = @"ViewStatus";/*信息被查看的次数*/
NSString* const EventStartChat = @"StartChat";/*成功发起的对话个数和独立用户数*/
NSString* const EventViewChat = @"ViewChat";/*聊天入口被点击的次数和独立用户数*/
NSString* const EventBrowse = @"Browse";/*加载新信息的请求数和独立用户数*/
NSString* const EventPressureMode = @"PressureMode";/*进入宣泄模式的次数和独立用户数*/

@implementation UmLogEngine

+ (void)logEvent:(NSString*)event attribute:(NSDictionary*)attr
{
    [MobClick event:event attributes:attr];
}

+ (void)logEvent:(NSString*)event
{
    [MobClick event:event];
}

+ (void)logEventWithFilterAutoly:(NSString*)event
{
    NSUInteger fnum = [PlazaFilterView selectedFilter];
    NSString* location = @"";
    NSString* user = @"";
    if (fnum%2 == 1) {
        location = @"city";
    }else{
        location = @"global";
    }
    if (fnum/2 == 0) {
        user = @"all";
    }else if(fnum/2 == 1){
        user = @"male";
    }else{
        user = @"female";
    }
    [UmLogEngine logEvent:event attribute:@{@"StatusType":[PlazaFilterView selectedMsgWording],@"LocationType":location,@"UserType":user}];
}

@end
