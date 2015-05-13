//
//  EMChatViewController.h
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BaseViewController.h"
#import "MessageReadManager.h"
#import "BroadcastBaseView.h"
#import "MessageToolBar.h"

#import "BroadcastContentView.h"

typedef NS_ENUM(NSUInteger, IMAGE_ANIMATION_TYPE) {
    IMAGE_ANIMATION_TYPE_LARGE = 0,//Default
    IMAGE_ANIMATION_TYPE_SMALL = 1,
    IMAGE_ANIMATION_TYPE_NONE = 2,
};

@interface EMChatViewController : BaseViewController<BroadcastBaseViewProtocol,MessageToolBarProtocol>
{
    dispatch_queue_t _messageQueue;
    EMConversation *_conversation;
    BOOL _isPlayingAudio;
    BOOL _isScrollToBottom;
    
    NSMutableArray* _messages;
    UIView* _containerView;
    BroadcastBaseView* _broadcastView;
    DXRecordView* _recordView;
    
    MessageToolBar* _chatToolBar;
    NSUInteger _curMessagesCount;
    
    BroadcastContentView* _contentView;
    
    NSIndexPath *_longPressIndexPath;
    NSIndexPath *_showLargeIndexPath;//大图打开位置
}
- (instancetype)initWithChatter:(NSString *)chatter;
@property (nonatomic) IMAGE_ANIMATION_TYPE animationType;
@property (nonatomic, strong) BroadcastContentView* contentView;
@property (nonatomic, assign) CGRect originFrame;

@property (nonatomic, strong) UIView* containerView;

@property (nonatomic, strong) NSString* chatter;
@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;
@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (strong, nonatomic) NSDate *chatTagDate;

@property (nonatomic, strong) UITableView* tableView;
@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (nonatomic, strong) NSMutableArray* dataSource;
@property (strong, nonatomic) NSMutableArray *messages;

@property (nonatomic, strong) BroadcastBaseView* broadcastView;
@property (nonatomic, strong) SillyBroacastModel* broadcastModel;

- (void)reloadData;
- (void)scrollViewToBottom:(BOOL)animated;

- (void)dismissChatViewController;
- (void)smallContentView;
- (void)showUpWithAnimation;
@end
