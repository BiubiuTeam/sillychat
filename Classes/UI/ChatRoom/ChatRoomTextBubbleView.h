//
//  ChatRoomTextBubbleView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatRoomBubbleView.h"

#define TEXTLABEL_MAX_WIDTH 200 // textLaebl 最大宽度
#define LABEL_FONT_SIZE 14      // 文字大小
#define LABEL_LINESPACE 5       // 行间距

@interface ChatRoomTextBubbleView : ChatRoomBubbleView

@property (nonatomic, strong) UILabel *textLabel;

+ (CGFloat)lineSpacing;
+ (UIFont *)textLabelFont;
+ (NSLineBreakMode)textLabelLineBreakModel;

@end
