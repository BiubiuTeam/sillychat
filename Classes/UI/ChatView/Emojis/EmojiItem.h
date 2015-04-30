//
//  EmojiItem.h
//  sillyChat
//
//  Created by haowenliang on 15/3/17.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmojiItemProtocol <NSObject>

- (void)emojiButtonPressed:(NSString *)emojiContent;

@end

@interface EmojiItem : UIView

@property (nonatomic, strong) NSString* emojiName;

@property (nonatomic, assign) id<EmojiItemProtocol> delegate;

@end
