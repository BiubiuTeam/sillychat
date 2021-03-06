//
//  PlazaViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaViewController.h"
#import "PlazaViewController+EaseMob.h"
#import "PlazaViewController+Audio.h"
#import "PlazaViewController+Uploader.h"
#import "PlazaViewController+Service.h"

#import "PostViewController.h"
#import "ChatRoomViewController.h"
#import "CheckImageViewController.h"
#import "SvUDIDTools.h"
#import "EMAccountService.h"
#import "SillyService.h"

#import "EMChatViewController.h"
#import "DPLbsServerEngine.h"
#import "SillyStringMapping.h"
#import "TagVoiceView.h"

#import "PlazaFilterButton.h"
#import "PlazaStateSelectedView.h"
#import "PlazaFilterView.h"
#import "SCStateService.h"
#import "PlazaMetroView.h"

#import "UmLogEngine.h"
#import "RelationShipService.h"
#import "UIERealTimeBlurView.h"

@implementation UIButton (Blink)

- (void)startAnimation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAnimation) object:nil];
    [self triggerAnimate];
    [self performSelector:@selector(startAnimation) withObject:nil afterDelay:1];
}

- (void)stopAnimation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAnimation) object:nil];
    NSArray* subLayers = self.superview.layer.sublayers;
    for (CALayer* layer in subLayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [layer removeAllAnimations];
        }
    }
}

- (void)triggerAnimate
{
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [self.superview convertPoint:self.center fromView:self.superview];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = [UIColor blackColor].CGColor;
    circleShape.lineWidth = 1;

    [self.superview.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)];
    scaleAnimation.delegate = self;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}

@end

///////////////////////////////////////////////////////////////
#define PlazaStateTag (0x9898)

@interface PlazaViewController ()<PostViewControllerDelegate,PlazaMetroProtocol,PlazaStateSelectedProtocol>
@property (nonatomic, strong) NSMutableArray* broadcastArray;

@property (nonatomic, strong) UIView* topPlaceView;

@property (nonatomic, strong) UIButton* removeStateButton;

@property (nonatomic, strong) UIView* mainView;

@property (nonatomic, strong) EMRoundButton* roundButton;
@property (nonatomic, strong) PlazaFilterView* filterView;
@property (nonatomic, strong) PlazaMetroView* metroView;
@end


@implementation PlazaViewController

- (instancetype)initWithTagsArray:(NSArray*)array
{
    if (self = [super init]) {
        if ([array count]) {
            [self.broadcastArray addObjectsFromArray:array];
        }else{
            [self forceToUpdatePlazaSillyMessage];
        }
        [self setupUnreadMessageCount];
    }
    return self;
}

// 统计未读消息数
-(void)setupUnreadMessageCount
{
    if (NO == [[RelationShipService shareInstance] hasUnhandleMessage]){
        NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
        NSInteger unreadCount = 0;
        for (EMConversation *conversation in conversations) {
            unreadCount += conversation.unreadMessagesCount;
        }
        if(unreadCount > 0) {
            [[RelationShipService shareInstance] setHasUnhandleMessage:YES];
        }
    }
}

- (UIView *)mainView
{
    if (nil == _mainView) {
#if 0
        _mainView = [[UIERealTimeBlurView alloc] initWithFrame:self.view.bounds];
#else
        _mainView = [[UIView alloc] initWithFrame:self.view.bounds];
#endif
        _mainView.backgroundColor = [UIColor clearColor];
    }
    return _mainView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_filterButton.selected) {
        //关闭
        [self closeFilterSelectView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optHandleWithReportNotification:) name:Key_ReportOperation object:nil];
    
    [self.view addSubview:self.mainView];
    
    [_mainView addSubview:self.topPlaceView];
    // Do any additional setup after loading the view.
    [_mainView addSubview:self.removeStateButton];
    [_mainView addSubview:self.roundButton];
    
    [self.topPlaceView addSubview:self.filterButton];
    [self.topPlaceView addSubview:self.chatRoomButton];
    
    [_mainView addSubview:self.metroView];
    [_mainView bringSubviewToFront:_topPlaceView];
    
    [self adjustControlsPosition];
    self.postOptComletionCallback = nil;
    [self registerEaseMobNotification];
    
    [_metroView setDatasource:self.broadcastArray];
    //注册上传回调监听器
    [self registUploadManager];
    
    [self registLocationNotification];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SCStateService shareInstance] filterDatasource];
        [[SCStateService shareInstance] stateStillList];
    });
}

- (void)optHandleWithReportNotification:(NSNotification*)notification
{
    NSNumber* theId = [notification.userInfo objectForKey:@"broadcast"];
    NSUInteger index = NSNotFound;
    for (SillyBroacastModel* model in self.broadcastArray) {
        if ([model.titleId integerValue] == [theId integerValue]) {
            if (![[SillyService sillyDeviceIdentifier] isEqualToString:model.dvcId]) {
                index = [_broadcastArray indexOfObject:model];
            }
            break;
        }
    }
    
    if (index != NSNotFound) {
        [_broadcastArray removeObjectAtIndex:index];
        [self.metroView setDatasource:_broadcastArray];
    }
}

- (void)registUploadManager
{
    [[DPBaseUploadMgr shareInstance] setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KenburnsImageViewStateSet" object:@YES];
    [self judgeIfHasUnreadInfo];
}

- (void)judgeIfHasUnreadInfo
{
    if ([[RelationShipService shareInstance] hasUnhandleMessage]) {
        [_chatRoomButton setSelected:YES];
        [_chatRoomButton startAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KenburnsImageViewStateSet" object:@NO];
}

- (void)registLocationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUserLocationEndUpdate:) name:DPLocationDidEndUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGeoReverseResultUpdate:) name:DPLocationGetReverseGeoCodeResult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willUserLocationStartUpdate:) name:DPLocationWillStartUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUserLocationStopUpdate:) name:DPLocationDidStopUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUserLocationUpdateFailed:) name:DPLocationDidFailedUpdate object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.broadcastArray = nil;
}

- (void)openFilterSelectView
{
    if (_filterButton.selected) {
        //关闭
        [self closeFilterSelectView];
    }else{
        //打开
        [_mainView addSubview:self.filterView];
        [_mainView bringSubviewToFront:_topPlaceView];
        [_mainView insertSubview:_filterView belowSubview:_topPlaceView];
        
        _filterView.bottom = _topPlaceView.bottom;
        [UIView animateWithDuration:0.3 animations:^{
            _filterView.top = _topPlaceView.bottom;
        } completion:^(BOOL finished) {
            
        }];
        _filterButton.selected = YES;
    }
}

- (void)closeFilterSelectView
{
    if (_filterButton.selected == NO) {
        return;
    }
    BOOL needUpdate = [_filterButton setNeedUpdateContent];
    
    [UIView animateWithDuration:0.3 animations:^{
        _filterView.bottom = _topPlaceView.bottom;
    } completion:^(BOOL finished) {
//        if (finished) {
            [_filterView removeFromSuperview];
            self.filterView = nil;
//        }
    }];
    if (needUpdate) {
        [UmLogEngine logEventWithFilterAutoly:EventPickStatus];
        [self forceToUpdatePlazaSillyMessage];
    }
    _filterButton.selected = NO;
}

#pragma mark - ui
- (PlazaMetroView *)metroView
{
    if (nil == _metroView) {
        CGFloat height = _roundButton.top - 2*TAG_VERTICAL_MARGIN;
        _metroView = [[PlazaMetroView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
        _metroView.delegate = self;
    }
    return _metroView;
}

- (UIView *)topPlaceView
{
    if (nil == _topPlaceView) {
        _topPlaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _size_S(105))];
        _topPlaceView.backgroundColor = APPLICATIONCOLOR;
    }
    return _topPlaceView;
}

- (NSMutableArray *)broadcastArray
{
    if (nil == _broadcastArray) {
        _broadcastArray = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _broadcastArray;
}

- (EMRoundButton *)roundButton
{
    if (nil == _roundButton) {
        _roundButton = [[EMRoundButton alloc] initWithFrame:CGRectZero];
        [_roundButton addTarget:self action:@selector(didPressSendSomethingButton) forControlEvents:UIControlEventTouchUpInside];
        
//        UILongPressGestureRecognizer* longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureOpt:)];
//        longGes.minimumPressDuration = .75;
//        [_roundButton addGestureRecognizer:longGes];
    }
    _roundButton.centerX = _mainView.width/2;
    _roundButton.bottom = SCREEN_HEIGHT - ALL_BUBBLE_BOTTOM;
    return _roundButton;
}

- (UIButton *)chatRoomButton
{
    if (nil == _chatRoomButton) {
        _chatRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chatRoomButton.backgroundColor = [UIColor clearColor];
        _chatRoomButton.contentMode = UIViewContentModeScaleAspectFit;
#if PROGRAM_STYPE
//        UIImage* hroom = LOAD_ICON_USE_POOL_CACHE(@"silly_chat_entrance.png");
        UIImage* room = LOAD_ICON_USE_POOL_CACHE(@"silly_new_info.png");
        [_chatRoomButton setBackgroundImage:room forState:UIControlStateNormal];
//        [_chatRoomButton setImage:hroom forState:UIControlStateHighlighted];
//        [_chatRoomButton setImage:hroom forState:UIControlStateSelected];
#else
        UIImage* room = LOAD_ICON_USE_POOL_CACHE(@"silly_chat_entrance.png");
        UIImage* hroom = LOAD_ICON_USE_POOL_CACHE(@"silly_new_info.png");
        [_chatRoomButton setBackgroundImage:room forState:UIControlStateNormal];
        [_chatRoomButton setImage:hroom forState:UIControlStateHighlighted];
        [_chatRoomButton setImage:hroom forState:UIControlStateSelected];
#endif
        _chatRoomButton.size = room.size;
        [_chatRoomButton addTarget:self action:@selector(didPressOpenChatRoomButton) forControlEvents:UIControlEventTouchUpInside];
        
        _chatRoomButton.right = self.view.width - 18;
        _chatRoomButton.layer.cornerRadius = _chatRoomButton.width/2;
    }
    return _chatRoomButton;
}

- (UIButton *)removeStateButton
{
    if (nil == _removeStateButton) {
        _removeStateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
        _removeStateButton.backgroundColor = [UIColor clearColor];
        [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateSelected];
        [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateNormal];
        [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateHighlighted];
    }
    return _removeStateButton;
}

- (PlazaFilterButton *)filterButton
{
    if (nil == _filterButton) {
        _filterButton = [[PlazaFilterButton alloc] initWithFrame:CGRectMake(0, 0, 0, _size_S(24))];
        [_filterButton addTarget:self action:@selector(openFilterSelectView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterButton;
}

- (void)adjustControlsPosition
{
    _filterButton.top = _size_S(56);
    _chatRoomButton.centerY = _filterButton.centerY;
    [_topPlaceView bringSubviewToFront:_chatRoomButton];
    
    _metroView.top = _topPlaceView.bottom + TAG_VERTICAL_MARGIN;
    CGFloat height = _roundButton.top - TAG_VERTICAL_MARGIN - _metroView.top;
    _metroView.height = height;
    
    [_mainView bringSubviewToFront:_metroView];
    
    _removeStateButton.center = _roundButton.center;
}

- (PlazaFilterView *)filterView
{
    if (nil == _filterView) {
        _filterView = [[PlazaFilterView alloc] initWithFrame:_mainView.bounds];
    }
    return _filterView;
}
#pragma mark - silly view delegate
- (void)didPressSendSomethingButton
{
    PlazaStateSelectedView* stateSelectedView = [[PlazaStateSelectedView alloc] initWithFrame:_mainView.bounds];
    stateSelectedView.tag = PlazaStateTag;
    stateSelectedView.delegate = self;
    [_mainView addSubview:stateSelectedView];
    [_mainView bringSubviewToFront:_removeStateButton];
    
    stateSelectedView.alpha = 0.7;
    stateSelectedView.top = SCREEN_HEIGHT;
    [UIView animateWithDuration:0.3 animations:^{
        stateSelectedView.top = 0;
        stateSelectedView.alpha = 1;
        _removeStateButton.transform = CGAffineTransformMakeRotation(45 *M_PI / 180.0);
    } completion:^(BOOL finished) {
//        if (finished) {
            _removeStateButton.transform = CGAffineTransformMakeRotation(0);
            UIImage* room = LOAD_ICON_USE_POOL_CACHE(@"silly_state_cancel.png");
            [_removeStateButton setImage:room forState:UIControlStateNormal];
            [_removeStateButton setImage:room forState:UIControlStateHighlighted];
            [_removeStateButton setImage:room forState:UIControlStateSelected];
            
            [_removeStateButton addTarget:self action:@selector(removeStateSelectedView) forControlEvents:UIControlEventTouchUpInside];
//        }
    }];
}

- (void)removeStateSelectedView
{
    [self removeStateSelectedViewWithAnimate:YES];
}

- (void)removeStateSelectedViewWithAnimate:(BOOL)animate
{
    PlazaStateSelectedView* stateSelectedView = (PlazaStateSelectedView*)[_mainView findSubview:@"PlazaStateSelectedView" resursion:YES];
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            stateSelectedView.top = SCREEN_HEIGHT;
            _removeStateButton.transform = CGAffineTransformMakeRotation(-45 *M_PI / 180.0);
        } completion:^(BOOL finished) {
//            if (finished) {
                [stateSelectedView removeFromSuperview];
                _removeStateButton.transform = CGAffineTransformMakeRotation(0);
                [_removeStateButton removeTarget:self action:@selector(removeStateSelectedView) forControlEvents:UIControlEventTouchUpInside];
                [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateSelected];
                [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateNormal];
                [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateHighlighted];
                [_mainView insertSubview:_removeStateButton belowSubview:_roundButton];
//            }
        }];
    }else{
        [stateSelectedView removeFromSuperview];
        _removeStateButton.transform = CGAffineTransformMakeRotation(0);
        [_removeStateButton removeTarget:self action:@selector(removeStateSelectedView) forControlEvents:UIControlEventTouchUpInside];
        [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateSelected];
        [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateNormal];
        [_removeStateButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_plaza_add.png") forState:UIControlStateHighlighted];
        [_mainView insertSubview:_removeStateButton belowSubview:_roundButton];
    }
}

- (void)openPostViewController
{
    PostViewController* postview = [[PostViewController alloc] init];
    postview.delegate = self;
    if (_msgTag == 10) {
        postview.launchCameraType = FrontFacingCamera;
    }
    if (SYSTEM_VERSION >= 8.0) {
        postview.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:postview animated:NO completion:^{
        //这里是因为UIModalPresentationCustom 是不会触发viewwilldisappear的
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KenburnsImageViewStateSet" object:@NO];
    }];
}

- (void)didPressOpenChatRoomButton
{
    [RelationShipService shareInstance].hasUnhandleMessage = NO;
    
    [UmLogEngine logEvent:EventViewChat];
    [_chatRoomButton setSelected:NO];
    [_chatRoomButton stopAnimation];
    ChatRoomViewController* chatroom = [[ChatRoomViewController alloc] init];
    [self presentViewController:chatroom animated:NO completion:nil];
}

- (void)startUpdatePlazaSource
{
    [self forceToUpdatePlazaSillyMessage];
}

- (void)didClickBroacast:(id)broacast onFrame:(CGRect)absoluteFrame
{
    SillyBroacastModel* model = (SillyBroacastModel*)broacast;
    DPTrace(@"Open Chat View Controller With Data: %@", model);
    if ([SvUDIDTools isEqualToUdid:model.dvcId]) {

        CheckImageViewController* check = [CheckImageViewController new];
        if (SYSTEM_VERSION >= 8.0) {
            check.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        check.originFrame = absoluteFrame;
        [check setBroadcastModel:model];
        [self presentViewController:check animated:NO completion:nil];
        return;
    }
    
    [UmLogEngine logEvent:EventStartChat attribute:@{@"ViewType":@"Click"}];
    EMChatViewController* chatView = [[EMChatViewController alloc] initWithChatter:model.dvcId];
    chatView.originFrame = absoluteFrame;
    if (SYSTEM_VERSION >= 8.0) {
        chatView.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [chatView setBroadcastModel:model];
    [self presentViewController:chatView animated:NO completion:nil];
}

#pragma mark -
- (void)postOptWithContent:(id)content
               contentType:(PostContentType)ctype
                  postType:(PostViewType)ptype
                completion:(void (^)(BOOL, NSError *))completion
{
    [self postOptWithContent:content contentType:ctype postType:ptype extension:nil completion:completion];
}

- (void)postOptWithContent:(id)content
               contentType:(PostContentType)ctype
                  postType:(PostViewType)ptype
                 extension:(NSDictionary*)extension
                completion:(void(^)(BOOL succeed, NSError* error))completion
{
    if (ptype != PostViewType_Plaza) {
        return;
    }
    
    [[SCStateService shareInstance] setSelectedStateTag:_msgTag];
    _filterButton.selected = NO;
    [_filterButton setNeedUpdateContent];
    [_filterView removeFromSuperview];
    self.filterView = nil;
    
    if (ctype == PostContentType_Text) {
        [self postTextBroadcast:content];
    }else if (ctype == PostContentType_IMG){
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:extension];
        [dic setObject:@(_msgTag) forKey:@"msgTag"];
        
        UIImage* imageToPost = (UIImage*)content;
        [self addPhotoUploadTask:imageToPost withExtension:dic];
    }
    completion(YES,nil);
//    self.postOptComletionCallback = completion;    
}

- (void)forceToUpdatePlazaSillyMessage
{
    static BOOL isForceUpdating = NO;
    if (isForceUpdating) {
        return;
    }
    isForceUpdating = YES;

    [UmLogEngine logEventWithFilterAutoly:EventBrowse];
    [[SillyService shareInstance] fetchNearbySillyBroacast:[[SCStateService shareInstance] selectedFilter] msgTag:[[SCStateService shareInstance] selectedMsgTag] comletion:^(id json, JSONModelError *err) {
        PlazaViewController* tmpself = (PlazaViewController*)_weakSelf;
        NSArray* broacasts = nil;
        if (err == nil) {
            SillyBroacastResponseModel* response = [[SillyBroacastResponseModel alloc] initWithDictionary:json error:&err];
            if (response && response.statusCode && [response.statusCode integerValue] == 0) {
                broacasts = response.broacastArray;
                DPTrace("拉取广播数据成功，共计: %zd个",[broacasts count]);
                
                [tmpself.broadcastArray removeAllObjects];
                @try {
                    if ([broacasts count]) {
                        [tmpself.broadcastArray addObjectsFromArray:broacasts];
                    }
                }
                @catch (NSException *exception) {
                    DPTrace(@"数据添加产生Exception : %@",[exception description]);
                }
                @finally {
                    [tmpself.metroView setMaxRow:[response.lineLen integerValue]];
                    [tmpself.metroView setDatasource:tmpself.broadcastArray];
                }
            }else{
                DPTrace("拉取广播数据失败");
                [tmpself.metroView refreshDone];
            }
        }else{
            DPTrace("拉取广播数据请求失败")
        }
        isForceUpdating = NO;
        [tmpself.metroView refreshDone];
    }];
}

#pragma mark - 地理位置处理

- (void)willUserLocationStartUpdate:(NSNotification*)notification
{

}

- (void)didUserLocationStopUpdate:(NSNotification*)notification
{

}

- (void)didUserLocationUpdateFailed:(NSNotification*)notification
{

}

- (void)didUserLocationEndUpdate:(NSNotification*)notification
{

}

- (void)didGeoReverseResultUpdate:(NSNotification*)notification
{
    DPTrace("GEO检索完成: %@",[[DPLbsServerEngine shareInstance] city]);
    
    if([notification.object boolValue]){
        [self forceToUpdatePlazaSillyMessage];
    }
}

- (void)didSelectItemWithDatasource:(NSDictionary *)datasource
{
    _msgTag = [[datasource objectForKey:@"fid"] unsignedIntegerValue];
    _wording4Tag = [datasource objectForKey:@"title"];
    
    [self openPostViewController];
    [self removeStateSelectedViewWithAnimate:NO];
}

@end
