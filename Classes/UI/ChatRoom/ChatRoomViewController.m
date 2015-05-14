//
//  ChatRoomViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "EMChatViewController.h"

#import "SillyService.h"
#import "SillyRelationshipModel.h"

#import "BBTableView.h"
#import "BBCell.h"

#import "ChatRoomBubbleView.h"
#import "ChatRoomTextBubbleView.h"
#import "ChatRoomImageBubbleView.h"

#import "UmLogEngine.h"
#import "ChatRoomViewController+EaseMob.h"
#import "RelationShipService.h"
#import "SvUDIDTools.h"
#import "UIViewController+HUD.h"

#define CONTAINER_VIEW_TAG (0x1234)

@interface ChatRoomViewController ()<UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate,ChatRoomBubbleProtocol>
{
    BOOL _dismissingVC;
    BOOL _firstLoadingView;
    
    NSIndexPath* _topIndexPath;
}
@property (nonatomic, strong) NSMutableArray* buddyList;
@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) BBTableView* tableView;

@property (nonatomic, strong) UIButton* roundButton;
@property (nonatomic, strong) UIImageView* emptyView;
@property (nonatomic, strong) ChatRoomBubbleView* bubbleView;

@end

@implementation ChatRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor clearColor]];
    _dismissingVC = NO;
    _firstLoadingView = YES;
    [self.view addSubview:self.containerView];
    [_containerView addSubview:self.tableView];
    
    [_containerView addSubview:self.roundButton];
    [_containerView bringSubviewToFront:_roundButton];
    
    [self registerEaseMobNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadByNotification:) name:RelationShipsDidReload object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadByNotification:) name:RelationShipsDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadByNotification:) name:RelationShipsUnReadMessageDidUpdate object:nil];
    if (SYSTEM_VERSION < 8.0) {
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
}

- (void)reloadByNotification:(NSNotification*)notification
{
    NSMutableArray* convShips = [[[RelationShipService shareInstance] relationShips] mutableCopy];
    [self updateRelationshipsList:convShips];
    convShips = nil;
    [_tableView setContentOffset:CGPointZero animated:YES];
    [self centerTableView];
}

- (void)loadAllAvailableConversation
{
    NSMutableArray* convShips = [[[RelationShipService shareInstance] relationShips] mutableCopy];
    [self updateRelationshipsList:convShips];
    convShips = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unRegisterEaseMobNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _tableView.hidden = _firstLoadingView;
    [self loadAllAvailableConversation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _tableView.hidden = NO;
    
    if ([_buddyList count] && _firstLoadingView) {
        //这里是为了出现的时候有个动画
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_buddyList count] -1 inSection:0];
//        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        [_tableView setContentOffset:CGPointMake(0, (_tableView.contentSize.height + _tableView.height)) animated:NO];
        
        [_bubbleView removeFromSuperview];
        _bubbleView = nil;
        _topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_tableView scrollToRowAtIndexPath:_topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [[RelationShipService shareInstance] reloadRelationShipsWithSequence];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _firstLoadingView = NO;
    [RelationShipService shareInstance].hasUnhandleMessage = NO;
}

- (UIView*)containerView
{
    if (nil == _containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
        _containerView.backgroundColor = APPLICATIONCOLOR;
        _containerView.tag = CONTAINER_VIEW_TAG;
    }
    return _containerView;
}

-(void)viewDidDisappear:(BOOL)animated {
    self.transitioningDelegate = nil;
    [super viewDidDisappear:animated];
}

- (NSMutableArray *)buddyList
{
    if (nil == _buddyList) {
        _buddyList = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _buddyList;
}

- (UIButton *)roundButton
{
    if (nil == _roundButton) {
        _roundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _roundButton.size = CGSizeMake(SMALL_BUBBLE_RADIUS, SMALL_BUBBLE_RADIUS);
        _roundButton.centerX = self.view.width/2;
        _roundButton.bottom = SCREEN_HEIGHT - ALL_BUBBLE_BOTTOM2;
        
        _roundButton.backgroundColor = [UIColor clearColor];
        [_roundButton setBackgroundImage:LOAD_ICON_USE_POOL_CACHE(@"silly_state_cancel.png") forState:UIControlStateNormal];
        [_roundButton setBackgroundImage:LOAD_ICON_USE_POOL_CACHE(@"silly_state_cancel.png") forState:UIControlStateHighlighted];
        [_roundButton addTarget:self action:@selector(didClickBackButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _roundButton;
}

- (void)didClickBackButton
{
    _dismissingVC = YES;
//    [_bubbleView removeFromSuperview];
//    [self dismissChatRoomView];

    CATransition *applicationLoadViewOut = [CATransition animation];
    applicationLoadViewOut.delegate = self;
    [applicationLoadViewOut setValue:@"applicationLoadViewOut" forKey:@"CATransitionName"];
    [applicationLoadViewOut setDuration:0.3];
    [applicationLoadViewOut setType:kCATransitionFade];
    [applicationLoadViewOut setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self.view layer] addAnimation:applicationLoadViewOut forKey:@"applicationLoadViewOut"];
    self.view.alpha = 0;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if ([[theAnimation valueForKey:@"CATransitionName"] isEqualToString:@"applicationLoadViewOut"]) {
        [self dismissChatRoomView];
    }
}

- (void)dismissChatRoomView
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

static NSUInteger NumberOfRow = 5;
- (UITableView *)tableView
{
    if (nil == _tableView) {
        CGRect frame = self.view.bounds;
        frame.origin.y = STATUSBAR_HEIGHT;
        frame.origin.x = 2*SCREEN_WIDTH/3;
        frame.size.width = abs(SCREEN_WIDTH - frame.origin.x);
        CGFloat height = SCREEN_HEIGHT - ALL_BUBBLE_BOTTOM2 - STATUSBAR_HEIGHT;
        CGFloat rowHeight = abs(height/NumberOfRow);
        frame.size.height = NumberOfRow*rowHeight;
        
        _tableView = [[BBTableView alloc] initWithFrame:frame];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.opaque = NO;
        _tableView.rowHeight = rowHeight;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setEnableInfiniteScrolling:NO];
    }
    return _tableView;
}

- (void)updateRelationshipsList:(NSArray*)shiplist
{
    [self.buddyList removeAllObjects];
    if (shiplist && [shiplist count]) {
        [self.buddyList addObjectsFromArray:shiplist];
        [_tableView setEnableInfiniteScrolling:NO];
        SillyRelationshipModel* tmpModel = [SillyRelationshipModel new];
        tmpModel.localTemp = @YES;
        [self.buddyList insertObject:tmpModel atIndex:0];
        [self.buddyList insertObject:tmpModel atIndex:0];
        [self.buddyList addObject:tmpModel];
        [self.buddyList addObject:tmpModel];
        
        if (_emptyView) {
            [_emptyView removeFromSuperview];
            self.emptyView = nil;
        }
    }else{
        [_bubbleView removeFromSuperview];
        self.bubbleView = nil;
        //展示图片

        [_emptyView removeFromSuperview];
        [self.view addSubview:self.emptyView];
    }
    [_tableView reloadData];
}

- (UIImageView *)emptyView
{
    if (nil == _emptyView) {
        _emptyView = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"silly_list_empty.png")];
        _emptyView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        _emptyView.backgroundColor = [UIColor clearColor];
        _emptyView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _emptyView;
}
#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row < [_buddyList count]) {
        SillyRelationshipModel* model = _buddyList[indexPath.row];
        if ([model.localTemp boolValue]) {
            return;
        }
        //点击中间位置
        if (_topIndexPath.row == (indexPath.row - NumberOfRow/2)) {
            return;
        }
        [_bubbleView removeFromSuperview];
        _bubbleView = nil;
        _topIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - NumberOfRow/2) inSection:0];
        [_tableView scrollToRowAtIndexPath:_topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.buddyList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* pCellIndentifier = @"pCellIndentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:pCellIndentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pCellIndentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    SillyRelationshipModel* relationship = _buddyList[indexPath.row];
    if ([[relationship localTemp] boolValue] == YES) {
        [cell.imageView setImage:nil];
        return cell;
    }
    
    if([[relationship.broadcastModel userConfig] integerValue]%2 == 1){
        cell.imageView.animationImages = @[LOAD_ICON_USE_POOL_CACHE(@"private/silly_female_buddy_highlight.png"),LOAD_ICON_USE_POOL_CACHE(@"private/silly_female_buddy_normal.png")];
        [cell.imageView setImage:LOAD_ICON_USE_POOL_CACHE(@"private/silly_female_buddy_normal.png")];
    }else{
        cell.imageView.animationImages = @[LOAD_ICON_USE_POOL_CACHE(@"private/silly_male_buddy_highlight.png"),LOAD_ICON_USE_POOL_CACHE(@"private/silly_male_buddy_normal.png")];
        [cell.imageView setImage: LOAD_ICON_USE_POOL_CACHE(@"private/silly_male_buddy_normal.png")];
    }
    cell.imageView.animationDuration = 1;
    
    //在后台进入的时候，未读计数并不能统计到，所以只能是让第一个跳动
    if ([relationship.hasUnreadMessage boolValue] || ([RelationShipService shareInstance].hasUnhandleMessage && indexPath.row == 0)) {
        [cell.imageView startAnimating];
    }else{
        [cell.imageView stopAnimating];
    }
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        DPTrace("无缓冲");
        [self centerTableView];
    }else {
        DPTrace("有缓冲");
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.isDragging || scrollView.isTracking) {
        return;
    }
    [self centerTableView];
}

- (void)centerTableView
{
    //
    if (![_buddyList count]) {
        return;
    }
    
    NSLog(@"********************centerTableView*******************************");
    
    NSInteger pageIndex;
    pageIndex = floor(_tableView.contentOffset.y / _tableView.rowHeight);
    
    CGFloat more = _tableView.contentOffset.y - pageIndex * _tableView.rowHeight;
    if (more > _tableView.rowHeight/2) {
        pageIndex ++;
    }
    
    pageIndex = MIN(pageIndex, [_buddyList count]-1);
    pageIndex = MAX(0, pageIndex);
    
    _topIndexPath = [NSIndexPath indexPathForRow:pageIndex inSection:0];
    [_tableView scrollToRowAtIndexPath:_topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self displayBubbleView];
}

- (void)displayBubbleView
{
    NSInteger index = _topIndexPath.row + NumberOfRow/2;
    if (index >= _buddyList.count) {
        DPTrace("计算长度超出");
        return;
    }
    SillyRelationshipModel* relation = _buddyList[index];
    DPTrace("%@",relation.broadcastModel);
    
    [_bubbleView removeFromSuperview];
    self.bubbleView = nil;
    
    switch ([relation.broadcastModel.titleType integerValue]) {
        case BroacastType_Text:
        {
            _bubbleView = [[ChatRoomTextBubbleView alloc] initWithFrame:CGRectZero];
            [_bubbleView setTextContent:[relation.broadcastModel titleCont]];
        }break;
        case BroacastType_Image:
        {
            _bubbleView = [[ChatRoomImageBubbleView alloc] initWithFrame:CGRectZero];
            [_bubbleView setImagePath:[relation.broadcastModel titleCont]];
            NSDictionary* dict = [relation.broadcastModel extension];
            [_bubbleView setTextContent:[dict objectForKey:@"Text"]];
        }break;
        default:
            break;
    }
    _bubbleView.datasource = relation.broadcastModel;
    _bubbleView.delegate = self;
    [self.view addSubview:_bubbleView];
    [self.view bringSubviewToFront:_bubbleView];
    _bubbleView.size = [_bubbleView sizeThatFits:CGSizeZero];
    _bubbleView.centerY = CGRectGetMidY(_tableView.frame);
    _bubbleView.right = _tableView.left;
}
#pragma mark - scroll view delegate
// 调用以下函数，来自动滚动到想要的位置，此过程中设置有动画效果，停止时，触发该函数
// UIScrollView的setContentOffset:animated:
// UIScrollView的scrollRectToVisible:animated:
// UITableView的scrollToRowAtIndexPath:atScrollPosition:animated:
// UITableView的selectRowAtIndexPath:animated:scrollPosition:
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndScrollingAnimation  -   End of Scrolling.");
//    if ([scrollView isKindOfClass:[UITableView class]] && scrollView == _tableView && _dismissingVC) {
//        [self dismissChatRoomView];
//    }
    if (_dismissingVC == NO && _bubbleView == nil){
        [self displayBubbleView];
    }
}

#pragma mark - delegate
- (void)didPressedBubbleView:(ChatRoomBubbleView *)bubble datasource:(SillyBroacastModel *)datasource
{
    if (![datasource.dvcId length]) {
        [self showHint:@"关系链dvcid为空"];
        return;
    }
    [UmLogEngine logEvent:EventStartChat attribute:@{@"ViewType":@"Click"}];
    EMChatViewController* chatView = [[EMChatViewController alloc] initWithChatter:datasource.dvcId];
    [chatView setBroadcastModel:datasource];
    if (SYSTEM_VERSION >= 8.0) {
        chatView.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    chatView.animationType = IMAGE_ANIMATION_TYPE_NONE;
    CGRect frame = bubble.absoluteFrame;
    chatView.originFrame = frame;
    [self presentViewController:chatView animated:NO completion:nil];
}

@end
