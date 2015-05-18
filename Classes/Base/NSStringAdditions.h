//
//  NSString+NSString_NSJson.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//


#import <Foundation/Foundation.h>

enum TEXT_CONSTRAIN_TYPE
{
    TEXT_CONSTRAIN_UTF8 = 0,         // utf8编码
    TEXT_CONSTRAIN_STRING_LENGTH,    // 字符数
    TEXT_CONSTRAIN_ASCII_UNICODE,    // ASCII字符占1字节，其它字符占两字节
};

@interface NSString (NSJson)

//生成指定数据对象的json字符串 object：指定的数据对象
+ (NSString *)jsonStringForNSJsonData:(id)object options:(NSJSONWritingOptions)options;
//通过指定字符串获得json对象
- (id)objectForJsonString:(NSJSONReadingOptions)options;

- (NSString*)base64Encode;
- (NSString*)base64Decode;


+ (NSUInteger)stringLengthOfType:(int)type str:(NSString*)str;
+ (NSString *)hexValue:(NSNumber*)number;

-(BOOL)isChinese;
@end
