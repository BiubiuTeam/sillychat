//
//  SillyEmojiMgr.m
//  sillyChat
//
//  Created by haowenliang on 15/3/18.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyEmojiMgr.h"

@implementation SillyEmojiMgr

+ (BOOL)isEmojiMessage:(NSString*)content
{
    if ([content length]) {
        if ([[self emojiArray] containsObject:content]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray*)emojiArray
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SillyEmojiList" ofType:@"plist"];
    return [NSArray arrayWithContentsOfFile:plistPath];
}

@end
