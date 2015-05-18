//
//  EMChatViewController+Message.h
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMChatViewController.h"
#import "SillyService.h"
//将后台的EMMessage 转换成 UI展示的MessageModel

@interface EMChatViewController (Message)

- (NSArray *)formatMessages:(NSArray *)messagesArray;

- (NSMutableArray *)formatMessage:(EMMessage *)message;

- (void)loadMoreMessages;
- (void)addMessage:(EMMessage *)message;

- (NSDictionary*)messageExt;
/////////////////////////
- (void)sendEmojiMessage:(NSString*)emojiName;
- (void)sendReportCmdMessage:(ReportReasonType)reason;

-(void)sendTextMessage:(NSString *)textMessage;
-(void)sendImageMessage:(UIImage *)imageMessage;
-(void)sendAudioMessage:(EMChatVoice *)voice;
-(void)sendVideoMessage:(EMChatVideo *)video;


/////////////////////////
- (void)reloadTableViewDataWithMessage:(EMMessage *)message;

@end
