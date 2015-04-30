//
//  UmLogEngine.h
//  sillyChat
//
//  Created by haowenliang on 15/4/25.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

extern NSString* const EventPublishStatus;/**发布状态*/
extern NSString* const EventPickStatus;/**筛选状态*/
extern NSString* const EventViewStatus;/**查看信息详情*/
extern NSString* const EventStartChat;/**发起聊天*/
extern NSString* const EventViewChat;/**查看过往聊天*/
extern NSString* const EventBrowse;/**浏览信息广场*/
extern NSString* const EventPressureMode;/**宣泄模式*/

#import <Foundation/Foundation.h>

@interface UmLogEngine : NSObject
+ (void)logEvent:(NSString*)event attribute:(NSDictionary*)attr;
+ (void)logEvent:(NSString*)event;
+ (void)logEventWithFilterAutoly:(NSString*)event;
@end
