//
//  SillyBroacastModel.m
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyBroacastModel.h"
#import "NSString+Emoji.h"

@implementation SillyBroacastModel

- (NSString *)titleCont
{
    return [_titleCont stringByReplacingEmojiCheatCodesWithUnicode];
}

@end



@implementation SillyBroacastResponseModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"statusCode": @"statusCode",
                                                       @"statusInfo":@"statusInfo",
                                                       @"returnData.city": @"city",
                                                       @"returnData.contData": @"broacastArray",
                                                       @"returnData.lineNum": @"lineNum",
                                                       @"returnData.lineLen": @"lineLen"
                                                       }];
}


@end