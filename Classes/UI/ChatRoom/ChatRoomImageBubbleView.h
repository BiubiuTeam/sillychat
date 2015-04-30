//
//  ChatRoomImageBubbleView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatRoomTextBubbleView.h"

#define MAX_SIZE 160 //　图片最大显示大小

@interface ChatRoomImageBubbleView : ChatRoomTextBubbleView

@property (nonatomic, strong) UIImageView *imageView;

@end
