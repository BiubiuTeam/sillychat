//
//  SillyEmojiMgr.m
//  sillyChat
//
//  Created by haowenliang on 15/3/18.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyEmojiMgr.h"

@implementation SillyEmojiMgr

static NSArray* _emojiArray = nil;

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
    if (nil == _emojiArray) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SillyEmojiList" ofType:@"plist"];
        _emojiArray =  [NSArray arrayWithContentsOfFile:plistPath];
    }
    return _emojiArray;
}

@end
