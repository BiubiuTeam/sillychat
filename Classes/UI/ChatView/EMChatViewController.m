//
//  EMChatViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMChatViewController.h"
#import "EMChatViewController+Category.h"
#import "EMChatViewController+Message.h"
#import "EMChatViewController+Broadcast.h"
#import "EMChatViewController+Responder.h"
#import "EMChatViewController+Audio.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SRRefreshView.h"
#import "ChatSendHelper.h"

#import "EMChatTimeCell.h"
#import "EMChatViewCell.h"
#import "MessageReadManager.h"
#import "MessageModel.h"
#import "BlockActionSheet.h"

#import "EMChatImageStillBubbleView.h"
#import "PlazaPhotoBrowser.h"
#import "RelationShipService.h"
#import "SillyMediaDevice.h"
@interface EMChatViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SRRefreshDelegate, IChatManagerDelegate,IDeviceManagerDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    
    CGFloat _footerViewHeight;
    
    BOOL _fisrtShowUp;
}
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (nonatomic, strong) MessageToolBar* chatToolBar;
@end

@implementation EMChatViewController

- (instancetype)initWithChatter:(NSString *)chatter
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.chatter = chatter;
        _curMessagesCount = 0;
        _animationType = IMAGE_ANIMATION_TYPE_LARGE;
        //根据接收者的username获取当前会话的管理者
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter isGroup:NO];
        [_conversation markAllMessagesAsRead:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _fisrtShowUp = YES;
    _isScrollToBottom = YES;
    _showLargeIndexPath = nil;
    [self addNotificationObserver];
    [self addEaseMobDelegate];
    
    _messageQueue = dispatch_queue_create("nuxsoft.com#sillychat", NULL);
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.broadcastView];
    [self.view addSubview:self.containerView];
    
    [_containerView addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [_containerView addSubview:self.chatToolBar];
    [_containerView addSubview:self.contentView];
    
    //通过会话管理者获取已收发消息
    [self loadMoreMessages];
    
    [self.view bringSubviewToFront:_broadcastView];
    [_containerView bringSubviewToFront:_contentView];
    [_containerView bringSubviewToFront:_chatToolBar];
    
    _mainVCtrColor = APPBLACKCOLOR;
}

- (void)dealloc
{
    [self removeChatterSet];
    
    _slimeView.delegate = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    self.tableView = nil;
    self.slimeView = nil;
    
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeEaseMobDelegate];
//    dispatch_release(_messageQueue);
    _messageQueue = nil;
    
    self.messages = nil;
    self.dataSource = nil;
    self.chatter = nil;
    self.messageReadManager = nil;
    self.conversation = nil;
    
    _chatToolBar.delegate = nil;
    self.chatToolBar = nil;
    
    DPTrace("\n--------------聊天页面销毁完成--------------");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_fisrtShowUp && (!CGRectIsNull(_originFrame) && !CGRectEqualToRect(_originFrame, CGRectZero))) {
        [self showUpWithAnimation];
    }else{
        if (_isScrollToBottom) {
            [self scrollViewToBottom:YES];
        }
        else{
            _isScrollToBottom = YES;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _fisrtShowUp = NO;
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    [[EaseMob sharedInstance].deviceManager disableProximitySensor];
    
    //移除未读数
    NSString* from = _conversation.chatter;
    NSString* titleid = [NSString stringWithFormat:@"%@",_broadcastModel.sortId];
    [[RelationShipService shareInstance] removeUnreadCountOfChat:[NSString stringWithFormat:@"%@%@",from,titleid]];
    //特殊处理会话列表页面，因为从这里回去不会相应viewwillappear
}

- (void)removeChatterSet
{
    //判断当前会话是否为空，若符合则删除该会话
//    EMMessage *message = [_conversation latestMessage];
//    if (message == nil) {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:NO append2Chat:YES];
//    }
}

#pragma mark -
- (void)addEaseMobDelegate
{
    [self removeEaseMobDelegate];
    [[[EaseMob sharedInstance] deviceManager] addDelegate:self onQueue:nil];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)removeEaseMobDelegate
{
    [[[EaseMob sharedInstance] deviceManager] removeDelegate:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relationshipDidReload) name:RelationShipsDidReload object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optHandleWithReportNotification:) name:Key_ReportOperation object:nil];
}

- (void)optHandleWithReportNotification:(NSNotification*)notification
{
    NSDictionary* dict = notification.userInfo;
    NSString* dvcId = [dict objectForKey:@"from"];
    if ([dvcId isEqualToString:[SillyService sillyDeviceIdentifier]]) {
        return;
    }
    
    NSInteger titleId = [[dict objectForKey:@"broadcast"] integerValue];
    if (titleId == [[self.broadcastModel titleId] integerValue]) {
        if ([dvcId isEqualToString:[self.broadcastModel dvcId]]) {
            //弹框、强退
            [self showAlertViewWithMessage:@"你已被对方举报，无法再进行会话或信息查看" succeed:YES];
        }
    }
}

- (void)relationshipDidReload
{
    if ([self.broadcastModel.isLocalTmp boolValue]) {
        SillyBroacastModel* model = [[RelationShipService shareInstance] getBroadcastOf:_chatter titleId:self.broadcastModel.titleId];
        if (model) {
            self.broadcastModel = model;
        }
    }
}

#pragma mark - getter
- (BroadcastContentView *)contentView
{
    if (nil == _contentView) {
        _contentView = [[BroadcastContentView alloc] initWithFrame:CGRectZero];
        _contentView.top = _size_S(14);
        _contentView.right = self.containerView.width - _size_S(17);
        
        [_contentView addTarget:self action:@selector(didClickContentView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contentView;
}

- (void)reloadData
{
    self.dataSource = [[self formatMessages:self.messages] mutableCopy];
    [self.tableView reloadData];
}

- (MessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    return _messageReadManager;
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = APPLIGHTCOLOR;
        _slimeView.slime.skinColor = APPLIGHTCOLOR;
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = APPLIGHTCOLOR;
    }
    
    return _slimeView;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        CGRect frame = _containerView.bounds;
        frame.size.height = frame.size.height - [MessageToolBar defaultHeight];
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.backgroundColor = APPLICATIONCOLOR;
        UIView* footer = [[UIView alloc] init];
        _footerViewHeight = _size_S(10);
        footer.height = _footerViewHeight;
        footer.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = footer;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = .5;
        [_tableView addGestureRecognizer:lpgr];
        
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_tableView addGestureRecognizer:tapgr];
    }
    return _tableView;
}

- (UIView *)containerView
{
    if (nil == _containerView) {
        CGRect frame = self.view.bounds;
        frame.origin.y = _broadcastView.height;
        frame.size.height = SCREEN_HEIGHT - _broadcastView.height;
        _containerView = [[UIView alloc] initWithFrame:frame];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (NSMutableArray *)messages
{
    if (nil == _messages) {
        _messages = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _messages;
}

- (MessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[MessageToolBar alloc] initWithFrame:CGRectMake(0, self.containerView.height - [MessageToolBar defaultHeight], SCREEN_WIDTH, [MessageToolBar defaultHeight])];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.backgroundColor = [UIColor blackColor];
        _chatToolBar.delegate = self;
    }
    return _chatToolBar;
}

#pragma mark - Operation

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

- (void)setBroadcastModel:(SillyBroacastModel *)broadcastModel
{
    _broadcastModel = broadcastModel;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.broadcastView setBroadcastModel:broadcastModel];
        [self.contentView setContentViewWithDatasource:broadcastModel];
    });
}

- (void)dismissChatViewController
{
    [_chatToolBar resignAllFirstResponder];
    _tableView.hidden = YES;
    if (CGRectIsNull(_originFrame) || CGRectEqualToRect(_originFrame, CGRectZero) || _animationType == IMAGE_ANIMATION_TYPE_NONE) {
        _contentView.hidden = YES;
    }
    [UIView animateWithDuration:.3 animations:^{
        _broadcastView.bottom = 0;
        _chatToolBar.top = _chatToolBar.superview.height;
        _contentView.frame = _originFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            timeCell.textLabel.text = (NSString *)obj;
            DPTrace("\n***********%@************\n",(NSString *)obj);
            return timeCell;
        }
        else{
            MessageModel *model = (MessageModel *)obj;
            NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
            EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //设置性别
            if (!model.isSender) {
                cell.gendarIsMale = [_broadcastModel.userConfig integerValue]%2 == 0;
            }
            cell.messageModel = model;
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
        
        if ([obj isKindOfClass:[NSString class]]) {
            return 40;
        }else{
            return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
        }
    }
    return 40;
}

#pragma mark -
- (void)handleTapGesture:(id)sender
{
    [_chatToolBar resignAllFirstResponder];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if ([self.dataSource count] > 0) {
        DPTrace("长按状态: %zd",recognizer.state);
        
        switch (recognizer.state) {
            case UIGestureRecognizerStateBegan:{
                CGPoint location = [recognizer locationInView:self.tableView];
                NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
                id object = [self.dataSource objectAtIndex:indexPath.row];
                if ([object isKindOfClass:[MessageModel class]]) {
                    EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    [cell becomeFirstResponder];
                    _longPressIndexPath = indexPath;
                    
                    //阅后即焚
                    if(cell.messageModel.type == eMessageBodyType_Image){
                        if ([cell.messageModel.localPath length] ) {
                            UIImage *image = [UIImage imageWithContentsOfFile:[cell.messageModel localPath]];
                            if (image) {
                                DPTrace("不需要下载：%@",[cell.messageModel localPath]);
                                [[PlazaPhotoBrowser shareInstance] showImage:image];
                            }else{
                                _showLargeIndexPath = indexPath;
                                //需要去下载啊
                                EMChatImageStillBubbleView* bubble = (EMChatImageStillBubbleView*)cell.bubbleView;
                                [self chatImageDownload:cell.messageModel progress:bubble];
                            }
                        }else{
                            _showLargeIndexPath = indexPath;
                            //需要去下载啊
                            EMChatImageStillBubbleView* bubble = (EMChatImageStillBubbleView*)cell.bubbleView;
                            [self chatImageDownload:cell.messageModel progress:bubble];
                        }
                        return;
                    }
                    
                    [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
                }
            }break;
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
                [[PlazaPhotoBrowser shareInstance] hideBrowserWithAnimate:NO];
                
                id object = [self.dataSource objectAtIndex:_longPressIndexPath.row];
                if ([object isKindOfClass:[MessageModel class]]) {
                    EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:_longPressIndexPath];
                    [cell becomeFirstResponder];
                    
                    //阅后即焚
                    if(cell.messageModel.type == eMessageBodyType_Image){
                        if (_showLargeIndexPath == nil && _longPressIndexPath && _longPressIndexPath.row > 0) {
                            MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
                            NSMutableArray *messages = [NSMutableArray arrayWithObjects:model, nil];
                            [_conversation removeMessage:model.message];
                            
                            NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];
                            [self.dataSource removeObjectsInArray:messages];
                            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        }
                        _showLargeIndexPath = nil;
                        _longPressIndexPath = nil;
                    }
                }
            }break;
            default:
                break;
        }
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_chatToolBar resignAllFirstResponder];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height  - self.tableView.frame.size.height + _footerViewHeight);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadMoreMessages];
    [_slimeView endRefresh];
}

- (void)applicationDidEnterBackground
{
    [_chatToolBar cancelTouchRecord];
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    // todo by du. 复制
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSMutableArray *messages = [NSMutableArray arrayWithObjects:model, nil];
        [_conversation removeMessage:model.message];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
        if (_longPressIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
            if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [messages addObject:prevMessage];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataSource removeObjectsInArray:messages];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    _longPressIndexPath = nil;
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(MessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMenuAction:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == eMessageBodyType_Text) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else{
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

#pragma mark - EMDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if (isCloseToUser)//黑屏
    {
        // 使用耳机播放
        [[EaseMob sharedInstance].deviceManager switchAudioOutputDevice:eAudioOutputDevice_earphone];
    } else {
        // 使用扬声器播放
        [[EaseMob sharedInstance].deviceManager switchAudioOutputDevice:eAudioOutputDevice_speaker];
        if (!_isPlayingAudio) {
            [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
        }
    }
}

- (void)didClickContentView
{
    _contentView.largeState = !_contentView.largeState;
    if (_contentView.largeState == NO) {
        [self smallContentView];
    }else{
        [_chatToolBar resignAllFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            _contentView.frame = _tableView.frame;
        }];
    }
}

- (void)smallContentView
{
    _contentView.largeState = NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _contentView.frame;
        frame.size = CGSizeMake(BCV_RADIUS, BCV_RADIUS);
        frame.origin.y = _size_S(14);
        frame.origin.x = _contentView.superview.width - _size_S(17) - BCV_RADIUS;
        _contentView.frame = frame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - animation

- (void)showUpWithAnimation
{
    if (_animationType == IMAGE_ANIMATION_TYPE_NONE) {
        [self showTopAndBottomWithAnimation];
        return;
    }
    self.broadcastView.hidden = YES;
    self.chatToolBar.hidden = YES;
    self.tableView.hidden = YES;
    
    _contentView.frame = self.originFrame;
    [UIView animateWithDuration:0.3 animations:^{
        if (_animationType == IMAGE_ANIMATION_TYPE_LARGE) {
            _contentView.largeState = YES;
            _contentView.frame = self.tableView.frame;
        }else if(_animationType == IMAGE_ANIMATION_TYPE_SMALL){
            _contentView.largeState = NO;
            CGRect frame = _contentView.frame;
            frame.size = CGSizeMake(BCV_RADIUS, BCV_RADIUS);
            frame.origin.y = _size_S(14);
            frame.origin.x = _contentView.superview.width - _size_S(17) - BCV_RADIUS;
            _contentView.frame = frame;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            [self showTopAndBottomWithAnimation];
        }
    }];
}

- (void)showTopAndBottomWithAnimation
{
    _broadcastView.hidden = NO;
    _chatToolBar.hidden = NO;
    _tableView.hidden = NO;
    CGRect bframe = _broadcastView.frame;
    CGRect tframe = _chatToolBar.frame;
    _broadcastView.bottom = 0;
    _chatToolBar.top = _chatToolBar.superview.height;
    [UIView animateWithDuration:0.3 animations:^{
        _broadcastView.frame = bframe;
        _chatToolBar.frame = tframe;
    } completion:^(BOOL finished) {
        if (finished) {
            if (_isScrollToBottom) {
                [self scrollViewToBottom:YES];
            }
            else{
                _isScrollToBottom = YES;
            }
        }
    }];
}

#pragma mark - Message tool bar delegate

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    BOOL growUp = _chatToolBar.top > _tableView.height;
    _tableView.height = /*_containerView.height - toHeight*/_chatToolBar.top;
    if (!growUp) {
        [self scrollViewToBottom:YES];
    }
}

- (void)didSendFace:(NSString *)faceLocalPath
{
    if (faceLocalPath.length) {
        [self sendEmojiMessage:faceLocalPath];
    }
}

- (void)didStyleChangeToRecord:(BOOL)changedToRecord
{
    //输入框获取焦点
    dispatch_async(dispatch_get_main_queue(), ^{
        [self smallContentView];
    });
}

- (void)didFaceButtonClick
{
    //输入框获取焦点
    dispatch_async(dispatch_get_main_queue(), ^{
        [self smallContentView];
    });
}

- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self smallContentView];
    });
}

- (void)didSendText:(NSString *)text
{
    if(text.length)
        [self sendTextMessage:text];
}

- (void)didCameraButtonClick
{
    static BOOL moreOptActing = NO;
    if (moreOptActing) {
        return;
    }
    moreOptActing = YES;
    //输入框获取焦点
    dispatch_async(dispatch_get_main_queue(), ^{
        [self smallContentView];
    });
    
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@"发送给对方的照片不会被保存"];
    __weak EMChatViewController* weakChat = self;
    [sheet addButtonWithTitle:@"拍摄一张照片" block:^{
        [weakChat moreOptTakePicAction];
    }];
    [sheet addButtonWithTitle:@"从相册中挑选" block:^{
        [weakChat moreOptPhotoAction];
    }];
    [sheet addButtonWithTitle:@"取消" block:nil];
    [sheet showInView:self.view completion:^(BOOL finished) {
        if(finished)
            moreOptActing = NO;
    }];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                DPTrace(@"failed to remove file, error:%@.", error);
            }
        }
        EMChatVideo *chatVideo = [[EMChatVideo alloc] initWithFile:[mp4 relativePath] displayName:@"video.mp4"];
        [self sendVideoMessage:chatVideo];
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self sendImageMessage:orgImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (void)moreOptPhotoAction
{
    // 隐藏键盘
    [self keyBoardHidden];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)moreOptTakePicAction
{
    [self keyBoardHidden];
#if TARGET_IPHONE_SIMULATOR
    DPTrace(@"模拟器不支持拍照");
#elif TARGET_OS_IPHONE
    [SillyMediaDevice isCameraAvailable];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (void)moreOptVideoAction
{
    [self keyBoardHidden];
#if TARGET_IPHONE_SIMULATOR
    DPTrace(@"模拟器不支持选择小视频");
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    DPTrace(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    DPTrace(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    DPTrace(@"completed.");
                } break;
                default: {
                    DPTrace(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            DPTrace(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}


@end
