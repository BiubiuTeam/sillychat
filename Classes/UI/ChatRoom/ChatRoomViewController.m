//
//  ChatRoomViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "EMChatViewController.h"
#import "EMRoundButton.h"
#import "EMRoundButton+DragEffect.h"

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
@property (nonatomic, strong) EMRoundButton* roundButton;

@property (nonatomic, strong) ChatRoomBubbleView* bubbleView;

@property (nonatomic, strong) UIImageView* dotLightView;
@property (nonatomic, strong) UILabel* msgLabel;

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
    [_containerView addSubview:self.dotLightView];
    [_containerView addSubview:self.msgLabel];
    
    [_containerView bringSubviewToFront:_dotLightView];
    [_containerView bringSubviewToFront:_msgLabel];
    [_containerView bringSubviewToFront:_roundButton];
    
    _dotLightView.centerX = _msgLabel.centerX = _roundButton.centerX = BUBBLE_CENTERX;
    _dotLightView.top = _roundButton.bottom + _size_S(4);
    _msgLabel.top = _dotLightView.bottom + _size_S(4);
    
    [self registerEaseMobNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadByNotification:) name:RelationShipsDidReload object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadByNotification:) name:RelationShipsDidUpdate object:nil];
}

- (void)reloadByNotification:(NSNotification*)notification
{
    NSMutableArray* convShips = [[[RelationShipService shareInstance] relationShips] mutableCopy];
    if ([convShips count]) {
        [self updateRelationshipsList:convShips];
    }
    convShips = nil;
    [_tableView setContentOffset:CGPointZero animated:YES];
    [self centerTableView];
}

- (void)loadAllAvailableConversation
{
    NSMutableArray* convShips = [[[RelationShipService shareInstance] relationShips] mutableCopy];
    if ([convShips count]) {
        [self updateRelationshipsList:convShips];
    }
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

- (EMRoundButton *)roundButton
{
    if (nil == _roundButton) {
        _roundButton = [[EMRoundButton alloc] initWithFrame:CGRectZero];
        _roundButton.centerX = BUBBLE_CENTERX;
        _roundButton.bottom = BUBBLE_MARGIN_BOTTOM;
        _roundButton.topActionViewController = self;
        [_roundButton addDragEffectAbility];
    }
    return _roundButton;
}

- (void)operationRespondsWhenTouchEdges
{
    _dismissingVC = YES;
    [self moveRoundButtonToOldPlace];
    [_bubbleView removeFromSuperview];
    [_tableView setContentOffset:CGPointMake(0, (_tableView.contentSize.height + _tableView.height)) animated:YES];
}

- (void)moveRoundButtonToOldPlace
{
    _roundButton.highlighted = NO;
    [UIView beginAnimations:@"dismissAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25];
    // View changes go here
    _roundButton.bottom = BUBBLE_MARGIN_BOTTOM;
    [UIView commitAnimations];
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
        CGFloat height = BUBBLE_MARGIN_BOTTOM - STATUSBAR_HEIGHT;
        frame.size.height = NumberOfRow*abs(height/NumberOfRow);
        
        _tableView = [[BBTableView alloc] initWithFrame:frame];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.opaque = NO;
        _tableView.rowHeight = abs(height/NumberOfRow);
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setEnableInfiniteScrolling:NO];
    }
    return _tableView;
}

- (UIImageView *)dotLightView
{
    if (nil == _dotLightView) {
        _dotLightView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _dotLightView.backgroundColor = [UIColor clearColor];
        _dotLightView.image = LOAD_ICON_USE_POOL_CACHE(@"private/silly_arrow_highlight.png");
        _dotLightView.frame = CGRectMake(0, 0, 20, 25);
        _dotLightView.contentMode = UIViewContentModeCenter;
    }
    return _dotLightView;
}

- (UILabel *)msgLabel
{
    if (nil == _msgLabel) {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.text = @"下滑返回";
        [_msgLabel sizeToFit];
    }
    return _msgLabel;
}

- (void)updateRelationshipsList:(NSArray*)shiplist
{
    [self.buddyList removeAllObjects];
    [self.buddyList addObjectsFromArray:shiplist];
//    if ([_buddyList count] > 10) {
//        [_tableView setEnableInfiniteScrolling:YES];
//    }else{
    [_tableView setEnableInfiniteScrolling:NO];
    
    SillyRelationshipModel* tmpModel = [SillyRelationshipModel new];
    tmpModel.localTemp = @YES;
    [self.buddyList insertObject:tmpModel atIndex:0];
    [self.buddyList insertObject:tmpModel atIndex:0];
    [self.buddyList addObject:tmpModel];
    [self.buddyList addObject:tmpModel];
//    }
    [_tableView reloadData];
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
    
    if ([relationship.hasUnreadMessage boolValue]) {
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
//            NSDictionary* dict = [relation.broadcastModel extension];
//            [_bubbleView setTextContent:[dict objectForKey:@"Text"]];
        }break;
        default:
            break;
    }
    _bubbleView.datasource = relation.broadcastModel;
    _bubbleView.delegate = self;
    [self.view addSubview:_bubbleView];
    [self.view bringSubviewToFront:_bubbleView];
    _bubbleView.size = [_bubbleView sizeThatFits:CGSizeZero];
    _bubbleView.centerY = _tableView.centerY;
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
    if ([scrollView isKindOfClass:[UITableView class]] && scrollView == _tableView && _dismissingVC) {
        [self dismissChatRoomView];
    }else if (_bubbleView == nil){
        [self displayBubbleView];
    }
}

#pragma mark - delegate
- (void)didPressedBubbleView:(ChatRoomBubbleView *)bubble datasource:(SillyBroacastModel *)datasource
{
    [UmLogEngine logEvent:EventStartChat attribute:@{@"ViewType":@"Click"}];
    EMChatViewController* chatView = [[EMChatViewController alloc] initWithChatter:datasource.dvcId];
    [chatView setBroadcastModel:datasource];
    chatView.modalPresentationStyle = UIModalPresentationCustom;
    CGRect frame = bubble.absoluteFrame;
    frame.origin.y = frame.origin.y - (bubble.height + _tableView.top)/2;
    chatView.originFrame = frame;
    [self presentViewController:chatView animated:NO completion:nil];
}

@end