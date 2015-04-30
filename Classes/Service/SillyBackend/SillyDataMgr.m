//
//  SillyDataMgr.m
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyDataMgr.h"

@implementation SillyDataMgr

+ (instancetype)shareInstance
{
    static SillyDataMgr* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[SillyDataMgr alloc] init];
    });
    return s_instance;
}

@end
