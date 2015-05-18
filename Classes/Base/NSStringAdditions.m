//
//  NSString+NSString_NSJson.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//


#import "NSStringAdditions.h"

@implementation NSString (NSJson)

+ (NSString *)jsonStringForNSJsonData:(id)object options:(NSJSONWritingOptions)options
{
    if (nil == object)
    {
        return nil;
    }
    
    if (![NSJSONSerialization isValidJSONObject:object])
    {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:options error:nil];
    if (jsonData)
    {
        NSString *urlArrStr = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
        return urlArrStr;
    }

    return nil;
}

- (id)objectForJsonString:(NSJSONReadingOptions)options
{
    NSInputStream *steam = [[NSInputStream alloc] initWithData:[self dataUsingEncoding:NSUTF8StringEncoding]];
    [steam open];
    id object = [NSJSONSerialization JSONObjectWithStream:steam options:options error:nil];
    [steam release];
    return object;
}

- (NSString*)base64Encode
{
    if (![self length]) {
        return self;
    }
    // Create NSData object
    NSData *nsdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];

    return base64Encoded;
}

- (NSString*)base64Decode
{
    if (![self length]) {
        return self;
    }
    // NSData from the Base64 encoded str
    NSData *nsdataFromBase64String = [[[NSData alloc]
                                      initWithBase64EncodedString:self options:0] autorelease];
    // Decoded NSString from the NSData
    NSString *base64Decoded = [[[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding] autorelease];

    return base64Decoded;
}


#pragma mark -
+ (NSUInteger)stringLengthOfType:(int)type str:(NSString*)str
{
    NSUInteger length = 0;
    
    if (str == nil) {  //nil为引发异常
        str = @"";
    }
    
    if (type == TEXT_CONSTRAIN_UTF8)
    {
        //os在中文状态时候输入拼音后不选择中文字符输入，输入英文字母这个时候输出的字符会带一个小的utf8空格 \xe2\x80\x86 (SIX-PER-EM SPACE ) 这个空格需要干掉它
        char* utf8Replace = "\xe2\x80\x86\0";
        NSData* data = [NSData dataWithBytes:utf8Replace length:strlen(utf8Replace)];
        NSString* utf8_str_format = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSMutableString* mutableAblumName = [NSMutableString stringWithString:str];
        NSString* strAblum =  [mutableAblumName stringByReplacingOccurrencesOfString:utf8_str_format withString:@""];
        [utf8_str_format  release];
        length = [strAblum lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    }
    else if (type == TEXT_CONSTRAIN_STRING_LENGTH)
    {
        length = [str length];
    }
    else if (type == TEXT_CONSTRAIN_ASCII_UNICODE)
    {
        for (int i = 0; i < [str length]; i ++)
        {
            unichar c = [str characterAtIndex:i];
            if (c <= 127)
            {
                length ++;
            }
            else
            {
                length += 2;
            }
        }
    }
    
    return length;
}

+ (NSString *)hexValue:(NSNumber*)number
{
    NSString *hex = [NSString stringWithFormat:@"%llX", number.longLongValue];
    NSUInteger digitsLeft = 16 - hex.length;
    
    if (digitsLeft > 0) {
        NSMutableString *zeros = [[[NSMutableString alloc] init] autorelease];
//        for (int i = 0; i < digitsLeft; i++)
            [zeros appendString:@"0x"];
        hex = [zeros stringByAppendingString:hex];
    }
    
    return hex;
}

-(BOOL)isChinese
{
    NSString *match=@"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

@end
