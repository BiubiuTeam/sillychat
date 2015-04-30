//
//  SillyRandomMsgModel.m
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyRandomMsgModel.h"
#import "NSString+Emoji.h"

@implementation SillyRandomMsgModel

- (NSString<Optional> *)preTitle
{
    return [_preTitle stringByReplacingEmojiCheatCodesWithUnicode];
}

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"statusCode": @"statusCode",
                                                       @"statusInfo":@"statusInfo",
                                                       @"returnData.preTitle": @"preTitle"
                                                       }];
}

@end
