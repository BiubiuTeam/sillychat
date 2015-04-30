//
//  SillyEmojiMgr.h
//  sillyChat
//
//  Created by haowenliang on 15/3/18.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SillyEmojiMgr : NSObject
+ (NSArray*)emojiArray;

+ (BOOL)isEmojiMessage:(NSString*)content;

@end
