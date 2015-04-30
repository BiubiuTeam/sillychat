//
//  NSDateAdditions.m
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "NSDateAdditions.h"

@implementation NSDate (biubiu)

+ (NSDateFormatter*)singletonFormatter
{
    __strong static NSDateFormatter* fmt = nil;
    static dispatch_once_t fmtOnce;
    dispatch_once(&fmtOnce, ^{
        fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    });
    return fmt;
}

/**
 * MM月dd日
 */
+ (NSString*)formatterDateForMD:(NSDate*)date
{
    if (nil == date)
        return @"";
    NSDateFormatter* formatter = [NSDate singletonFormatter];
    formatter.dateFormat = @"MM月dd日";
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

/**
 * MM-dd HH:mm
 */
+ (NSString*)formatterDateForMDHM:(NSDate*)date
{
    if (nil == date)
        return @"";
    NSDateFormatter* formatter = [NSDate singletonFormatter];
    formatter.dateFormat = @"MM-dd HH:mm";
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

/**
 * HH:mm
 */
+ (NSString*)formatterDateForHM:(NSDate*)date
{
    if (nil == date)
        return @"";
    NSDateFormatter* formatter = [NSDate singletonFormatter];
    formatter.dateFormat = @"HH:mm";
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (DPDateState)getDayStateOfDate:(NSDate*)date
{
    if (nil == date)
        return DPDateState_Morning;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    NSInteger hour = [components hour];
    
    if ( hour < 10 ) {
        return DPDateState_Morning;
    }
    if ( hour < 18 ) {
        return DPDateState_Noon;
    }
    return DPDateState_Night;
}

+ (BOOL)isTheSameDate:(NSDate*)date1 toDate:(NSDate*)date2
{
    /*
     double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
     if (
     (int)(([date1 timeIntervalSince1970] + timezoneFix)/(24*3600)) -
     (int)(([date2 timeIntervalSince1970] + timezoneFix)/(24*3600))
     == 0)
     {
     return YES;
     }
     return NO;
     */
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
}

/**
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */
+ (NSString *)compareCurrentTime:(NSDate*)compareDate
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;

    if((temp = (timeInterval/60 + 1)) < 60){
        result = [NSString stringWithFormat:NSLocalizedString(@"BB_TXTID_%zd分钟前", nil),MAX(temp,1)];
    }
    else if((temp = temp/60) < 24){
        result = [NSString stringWithFormat:NSLocalizedString(@"BB_TXTID_%zd小时前", nil),MIN(temp,23)];
    }else if((temp = temp/24) < 1){
        result = NSLocalizedString(@"BB_TXTID_昨天", nil);
    }else{
        result = [NSString stringWithFormat:NSLocalizedString(@"BB_TXTID_%zd天前", nil),temp];
    }
    return  result;
}

+ (NSString *)sinceTodayTime:(NSDate*)compareDate
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = timeInterval/(24*60*60);
    NSString *result = [NSString stringWithFormat:@"%zd",temp];
    
    return  result;
}

@end
