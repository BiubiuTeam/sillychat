//
//  NSDateAdditions.h
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  消息发送时间段分三个
 *  （早）（午）（晚）
 */
typedef NS_ENUM(NSUInteger, DPDateState) {
    DPDateState_Morning = 0,// < 10（早）
    DPDateState_Noon = 1,//10 ~ 18（午）
    DPDateState_Night = 2,//18 ~ 24（晚）
};

@interface NSDate (biubiu)

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;

/**
 * MM月dd日
 */
+ (NSString*)formatterDateForMD:(NSDate*)date;

/**
 * MM-dd HH:mm
 */
+ (NSString*)formatterDateForMDHM:(NSDate*)date;

/**
 * HH:mm
 */
+ (NSString*)formatterDateForHM:(NSDate*)date;

/**
 *  time state of one day
 */
+ (DPDateState)getDayStateOfDate:(NSDate*)date;

/**
 *  两天是否同一天
 */
+ (BOOL)isTheSameDate:(NSDate*)date1 toDate:(NSDate*)date2;

/**
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */
+ (NSString *)compareCurrentTime:(NSDate*)compareDate;


+ (NSString *)sinceTodayTime:(NSDate*)compareDate;


@end
