//
//  ServiceConstants.h
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#ifndef sillyChat_ServiceConstants_h
#define sillyChat_ServiceConstants_h

#define Key_ReportOperation @"_kNotificationKey_ReportOperation_"

typedef NS_ENUM(NSUInteger, BroacastType) {
    BroacastType_Text = 1,
    BroacastType_Voice = 2,
    BroacastType_Image = 3,
    BroacastType_Emoji = 4,
    
    BroacastType_Video = 5,//后台暂时不支持，未定义
};

#endif
