//
//  SillyUserModel.m
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyUserModel.h"

@implementation SillyUserModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"statusCode": @"statusCode",
                                                       @"statusInfo":@"statusInfo",
                                                       @"returnData.userConfig": @"userConfig",
                                                       @"returnData.city": @"city",
                                                       @"returnData.latitude": @"latitude",
                                                       @"returnData.longitude": @"longitude"
                                                       }];
}

@end
