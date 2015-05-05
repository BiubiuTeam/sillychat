//
//  EMChatViewController+Responder.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMChatViewController+Responder.h"
#import "EMChatViewController+Message.h"
#import "MessageModel.h"
#import "EMChatViewCell.h"
#import "UIViewController+HUD.h"
#import "PlazaPhotoBrowser.h"

#import "EMAccountService.h"

@implementation EMChatViewController (Responder)
#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    }
    else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        //haowenliang，阅后即焚
//        [self chatImageCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
        [self chatLocationCellBubblePressed:model];
    }
    else if([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
        messageModel.status = eMessageDeliveryState_Delivering;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];
    }else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
        [self chatVideoCellPressed:model];
    }else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]){
#if DEBUG
        [[EMAccountService shareInstance] checkUserInfo:model.message.from];
#endif
    }
}

//链接被点击
- (void)chatTextCellUrlPressed:(NSURL *)url
{
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(MessageModel *)model
{
    id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    
    if (downloadStatus == EMAttachmentDownloadSuccessed)
    {
        //缓存文件是否存在，不存在，则认为下载失败
        if ([model.localPath length] && [[NSFileManager defaultManager] fileExistsAtPath:model.localPath] == NO)
        {
            DPTrace("文件不存在 %@",model.localPath);
//            downloadStatus = EMAttachmentDownloadFailure;
        }
    }
    
    if (downloadStatus == EMAttachmentDownloading) {
//        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
//        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        
        return;
    }
    
    // 播放音频
    if (model.type == eMessageBodyType_Voice) {
        __weak EMChatViewController *weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(MessageModel *prevAudioModel, MessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak EMChatViewController *weakSelf = self;
            [[[EaseMob sharedInstance] deviceManager] enableProximitySensor];
            [[EaseMob sharedInstance].chatManager asyncPlayAudio:model.chatVoice completion:^(EMError *error) {
                [weakSelf.messageReadManager stopMessageAudioModel];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    
                    weakSelf.isPlayingAudio = NO;
                    [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
                });
            } onQueue:nil];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

// 位置的bubble被点击
-(void)chatLocationCellBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
//    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
//    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)chatVideoCellPressed:(MessageModel *)model{
    __weak EMChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [weakSelf showHudInView:weakSelf.view hint:NSLocalizedString(@"message.downloadingVideo", @"downloading video...")];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0) {
                [weakSelf playVideoWithVideoPath:localPath];
            }
        }else{
            [weakSelf showHint:NSLocalizedString(@"message.videoFail", @"video for failure!")];
        }
    } onQueue:nil];
}

- (void)playVideoWithVideoPath:(NSString *)videoPath
{
    _isScrollToBottom = NO;
//    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
//    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
//    [moviePlayerController.moviePlayer prepareToPlay];
//    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
//    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(MessageModel *)model
{
    __weak EMChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            [weakSelf showHudInView:weakSelf.view hint:NSLocalizedString(@"message.downloadingImage", @"downloading a image...")];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHud];
                if (!error) {
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        NSURL *url = [NSURL fileURLWithPath:localPath];
                        weakSelf.isScrollToBottom = NO;
                        [weakSelf.messageReadManager showBrowserWithImages:@[url]];
                        return ;
                    }
                }
                [weakSelf showHint:NSLocalizedString(@"message.imageFail", @"image for failure!")];
            } onQueue:nil];
        }
        else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
                }
                
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
                }
            } onQueue:nil];
        }
    }
}

// 图片的bubble被点击
-(void)chatImageDownload:(MessageModel *)model progress:(id<IEMChatProgressDelegate>)progress
{
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        [progress setProgress:.01 forMessage:model.message forMessageBody:model.messageBody];
        [chatManager asyncFetchMessage:model.message progress:progress completion:^(EMMessage *aMessage, EMError *error) {
            DPTrace("加载大图请求回调");
            if (!error) {
                if (_showLargeIndexPath == nil) {
                    return;
                }
                id object = [self.dataSource objectAtIndex:_showLargeIndexPath.row];
                if ([object isKindOfClass:[MessageModel class]]) {
                    EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:_showLargeIndexPath];
                    NSString *reqMsgId = aMessage == nil ? model.message.messageId : [aMessage messageId];
                    if([cell.messageModel.message.messageId isEqualToString:reqMsgId])
                    {
                        _showLargeIndexPath = nil;
                        DPTrace("加载大图完成");
                        NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                        if (localPath && localPath.length > 0) {
                            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                            if (image) {
                                [[PlazaPhotoBrowser shareInstance] showImage:image];
                            }
                        }
                    }
                }
                
            }
            DPTrace("请求失败");
        } onQueue:nil];
    }
}


@end
