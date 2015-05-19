//
//  EMChatViewController+Message.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMChatViewController+Message.h"
#import "UIViewController+HUD.h"
#import "EMChatViewController+Audio.h"

#import "ChatSendHelper.h"
#import "MessageModel.h"
#import "SillyEmojiMgr.h"
#import "MessageModelManager.h"
#import "EMMessage.h"
#import "SillyBroacastModel.h"
#import "EMAccountService.h"
#import "EmojiAnimationView.h"

#import "RelationShipService.h"
#import "EmojiAnimationView.h"
#import "NSDateAdditions.h"

#define KPageCount 30

@implementation EMChatViewController (Message)

- (NSArray *)formatMessages:(NSArray *)messagesArray
{
    NSMutableArray *formatArray = [NSMutableArray array];
    if ([messagesArray count] > 0) {
        for (EMMessage *message in messagesArray) {
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                [formatArray addObject:[NSDate formatterDateForMDHM:createDate]];
                self.chatTagDate = createDate;
            }
            
            MessageModel *model = [MessageModelManager modelWithMessage:message];
            if (model) {
                [formatArray addObject:model];
            }
        }
    }
    return formatArray;
}

- (NSMutableArray *)formatMessage:(EMMessage *)message
{
    NSMutableArray *ret = [NSMutableArray array];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[NSDate formatterDateForMDHM:createDate]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    if (model) {
        [ret addObject:model];
    }
    return ret;
}

- (void)loadMoreMessages
{
    @autoreleasepool {
        __weak typeof(self) weakSelf = self;
        dispatch_async(_messageQueue, ^{
            long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
            
            NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:(_curMessagesCount + KPageCount) before:timestamp];
            _curMessagesCount = [messages count];
            if ([messages count] > 0) {
                [weakSelf.messages removeAllObjects];
                for (EMMessage *message in messages)
                {
                    if (message.ext && [message.ext count]) {
                        NSString* sort = [message.ext objectForKey:@"broadcast"];
                        if ([sort integerValue] == [[self.broadcastModel sortId] integerValue]) {
                            [weakSelf.messages addObject:message];
                        }
                    }
                }
                NSInteger currentCount = [weakSelf.dataSource count];
                weakSelf.dataSource = [[weakSelf formatMessages:[weakSelf.messages copy]] mutableCopy];
                if (weakSelf.dataSource.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                        
                        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, [weakSelf.dataSource count] - currentCount - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    });
                }
            }
        });
    }
}
//haowen， 5-19，置低的操作，先这样的···没有好方法
-(void)addMessage:(EMMessage *)message
{
    __weak EMChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
//        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//        
//        for (int i = 0; i < messages.count; i++) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.dataSource.count+i inSection:0];
//            [indexPaths addObject:indexPath];
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

//            [weakSelf.tableView beginUpdates];
            [weakSelf.dataSource addObjectsFromArray:messages];
//            [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//            [weakSelf.tableView endUpdates];
            [weakSelf.tableView reloadData];
            
            [weakSelf scrollViewToBottom:YES];
        });
    });
}

#pragma mark - send message
- (NSDictionary*)messageExt
{
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setObject:[[EMAccountService shareInstance] username] forKey:@"from"];
    if (self.broadcastModel) {
        NSString* modelId = [NSString stringWithFormat:@"%@",[self.broadcastModel sortId]];
        [dict setObject:modelId forKey:@"broadcast"];
    }
    return dict;
}

- (void)sendEmojiMessage:(NSString*)emojiName
{
    //emoji
    [ChatSendHelper sendEmojiMessageToUsername:_conversation.chatter isChatGroup:NO requireEncryption:NO emojiName:emojiName ext:[self messageExt]];
    [EmojiAnimationView showEmoji:emojiName aboveView:self.view yPosition:-1 leftOrientation:YES];
}

- (void)sendReportCmdMessage:(ReportReasonType)reason
{
    [ChatSendHelper sendReportCmdMessageToUsername:_conversation.chatter reportReason:reason ext:[self messageExt]];
}

-(void)sendTextMessage:(NSString *)textMessage
{
    [[RelationShipService shareInstance] linkDeviceWithBroadcast:self.broadcastModel];
    
    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage toUsername:_conversation.chatter isChatGroup:NO requireEncryption:NO ext:[self messageExt]];
    [self addMessage:tempMessage];
}

-(void)sendImageMessage:(UIImage *)imageMessage
{
    [[RelationShipService shareInstance] linkDeviceWithBroadcast:self.broadcastModel];
    
    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:imageMessage toUsername:_conversation.chatter isChatGroup:NO requireEncryption:NO ext:[self messageExt]];
    [self addMessage:tempMessage];
}

-(void)sendAudioMessage:(EMChatVoice *)voice
{
    [[RelationShipService shareInstance] linkDeviceWithBroadcast:self.broadcastModel];
    
    EMMessage *tempMessage = [ChatSendHelper sendVoice:voice toUsername:_conversation.chatter isChatGroup:NO requireEncryption:NO ext:[self messageExt]];
    [self addMessage:tempMessage];
}

-(void)sendVideoMessage:(EMChatVideo *)video
{
    [[RelationShipService shareInstance] linkDeviceWithBroadcast:self.broadcastModel];
    
    EMMessage *tempMessage = [ChatSendHelper sendVideo:video toUsername:_conversation.chatter isChatGroup:NO requireEncryption:NO ext:[self messageExt]];
    [self addMessage:tempMessage];
}


#pragma mark - IChatManagerDelegate

-(void)didSendMessage:(EMMessage *)message error:(EMError *)error;
{
    [self reloadTableViewDataWithMessage:message];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message
{
    __weak EMChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    EMMessage *currMsg = [weakSelf.dataSource objectAtIndex:i];
                    if ([message.messageId isEqualToString:currMsg.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                        });
                        
                        break;
                    }
                }
            }
        }
    });
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
    }
}

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress{
    NSLog(@"didFetchingMessageAttachment: %f", progress);
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        _curMessagesCount ++;
        
        if (message.ext) {
            NSString* sortid = [message.ext objectForKey:@"broadcast"];
            if ([sortid integerValue] == [[self.broadcastModel sortId] integerValue]) {
                [self addMessage:message];
                [_messages addObject:message];
            }
        }
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        if (message.ext) {
            NSString* sortid = [message.ext objectForKey:@"broadcast"];
            if ([sortid integerValue] == [[self.broadcastModel sortId] integerValue]) {
                NSString* emojiName = nil;
                BOOL isEmoji = [MessageModelManager emojiModelWithMessage:message emojiName:&emojiName];
                if (isEmoji) {
                    [EmojiAnimationView showEmoji:emojiName aboveView:self.view yPosition:0 leftOrientation:NO];
                }
            }
        }
    }
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self loadMoreMessages];
}

- (void)didInterruptionRecordAudio
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    [self stopAudioPlaying];
}

@end
