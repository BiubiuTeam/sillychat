//
//  ChatRoomBubbleView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BUBBLE_ARROW_WIDTH 7 // bubbleView中，箭头的宽度
#define BUBBLE_VIEW_PADDING 8 // bubbleView 与 在其中的控件内边距

@class SillyBroacastModel;
@class ChatRoomBubbleView;

@protocol ChatRoomBubbleProtocol <NSObject>

@optional
- (void)didPressedBubbleView:(SillyBroacastModel*)datasource;

- (void)didPressedBubbleView:(ChatRoomBubbleView*)bubble datasource:(SillyBroacastModel*)datasource;

@end

@interface ChatRoomBubbleView : UIView

@property (nonatomic, assign) id<ChatRoomBubbleProtocol> delegate;
@property (nonatomic, strong) SillyBroacastModel* datasource;

@property (nonatomic, assign) CGRect absoluteFrame;

@property (nonatomic, strong) UIImageView *backImageView;

- (void)bubbleViewPressed:(id)sender;
- (void)setTextContent:(NSString *)content;
- (void)setImagePath:(NSString *)path;

@end
