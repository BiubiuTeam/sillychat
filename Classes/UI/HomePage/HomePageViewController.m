//
//  HomePageViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "HomePageViewController.h"
#import "EMAnimationButton.h"
#import "DPLbsServerEngine.h"
#import "SillyService.h"

#import "AppDelegate.h"
#import "EMAccountService.h"

#import "BaseInfoSettingView.h"

#define SILLY_IMG_TOP (188)
#define SILLY_IMG_DOT_TOP (25)
#define SILLY_IMG_INSET (3)
#define SILLY_DOT_NUMBER (4)
@interface HomePageViewController ()
{
    BOOL _searchOptHolding;
    
    NSUInteger _dotPosition;
}
@property (nonatomic, retain) BaseInfoSettingView* baseInfoView;

@property (nonatomic, strong) UIImageView* sillyImgView;
@property (nonatomic, strong) NSMutableArray* dotImgViews;

@property (nonatomic, strong) EMAnimationButton* roundButton;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUserLocationEndUpdate:) name:DPLocationDidEndUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGeoReverseResultUpdate:) name:DPLocationGetReverseGeoCodeResult object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLocationFailedUpdate:) name:DPLocationDidFailedUpdate object:nil];
    
    _searchOptHolding = NO;
    [self addSubControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self needsShowUpInfoSettingView];
//    if (showUp == NO && [[DPLbsServerEngine shareInstance] isEnabledAndAuthorize] == NO) {
//        [self showLocationDisableMessage];
//    }
}

- (BOOL)needsShowUpInfoSettingView
{
    [_baseInfoView removeFromSuperview];
    self.baseInfoView = nil;
    if ([[EMAccountService shareInstance] hasSettingAccountInfo]) {
        return NO;
    }
    _baseInfoView = [[BaseInfoSettingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_baseInfoView];
    [self.view bringSubviewToFront:_baseInfoView];
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:nil object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:nil object:nil];
    [_roundButton stopAnimation];
    self.roundButton = nil;
    self.sillyImgView = nil;
    self.dotImgViews = nil;
}

#pragma mark - 添加视图元素
- (void)addSubControls
{
    [self.view addSubview:self.sillyImgView];
    [self makeDotsImageView];
    _dotPosition = 0;
    [self.view addSubview:self.roundButton];
    
    [self performSelector:@selector(lightingUpDots) withObject:nil afterDelay:0.3];
}

- (UIImageView *)sillyImgView
{
    if (nil == _sillyImgView) {
        _sillyImgView = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"silly_message.png")];
        _sillyImgView.backgroundColor = [UIColor clearColor];
        _sillyImgView.contentMode = UIViewContentModeScaleAspectFit;
        _sillyImgView.top = SILLY_IMG_TOP;
    }
    return _sillyImgView;
}

- (void)lightingUpDots
{
    _dotPosition = _dotPosition%(SILLY_DOT_NUMBER+1);
    for (NSInteger i = 0; i < _dotPosition; i++) {
        UIView* view = [_dotImgViews objectAtIndex:i];
        view.alpha = 1;
    }
    for (NSInteger j = _dotPosition; j < SILLY_DOT_NUMBER; j++) {
        UIView* view = [_dotImgViews objectAtIndex:j];
        view.alpha = 0;
    }
    _dotPosition++;
    
    [self performSelector:@selector(lightingUpDots) withObject:nil afterDelay:0.3];
}

- (void)makeDotsImageView
{
    self.dotImgViews = [NSMutableArray array];
    float dotsWidth = _sillyImgView.width;
    for (NSInteger i = 0; i < SILLY_DOT_NUMBER; i++) {
        NSString* name = [NSString stringWithFormat:@"silly_message_dot%zd.png",i];
        UIImage* tmp = LOAD_ICON_USE_POOL_CACHE(name);
        dotsWidth += tmp.size.width;
        
        UIImageView* tmpView = [[UIImageView alloc] initWithImage:tmp];
        tmpView.backgroundColor = [UIColor clearColor];
        tmpView.contentMode = UIViewContentModeScaleAspectFit;
        tmpView.top = SILLY_IMG_TOP + SILLY_IMG_DOT_TOP;
        tmpView.alpha = 0;
        [self.view addSubview:tmpView];
        [_dotImgViews addObject:tmpView];
        
        dotsWidth += SILLY_IMG_INSET;
    }
    _sillyImgView.left = (self.view.width - dotsWidth)/2;
    float xPosition = _sillyImgView.right + SILLY_IMG_INSET;
    for (UIImageView* imgView in _dotImgViews) {
        imgView.left = xPosition;
        xPosition = imgView.right + SILLY_IMG_INSET;
    }
}

- (EMAnimationButton *)roundButton
{
    if (nil == _roundButton) {
        _roundButton = [[EMAnimationButton alloc] initWithFrame:CGRectZero];
        [_roundButton setTitle:@"点我" forState:UIControlStateNormal];
        [_roundButton addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    }
    _roundButton.centerX = self.view.width/2;
    _roundButton.bottom = SCREEN_HEIGHT - ALL_BUBBLE_BOTTOM;
    return _roundButton;
}

#pragma mark - Operation
- (void)clickButton
{
    if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize] == NO) {
        [self showLocationDisableMessage];
        return;
    }
    
    //转换到搜索状态
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(lightingUpDots) object:nil];
    [_sillyImgView removeFromSuperview];
    for (UIView* tmp in _dotImgViews) {
        [tmp removeFromSuperview];
    }
    
    [_roundButton startAnimation];
    [_roundButton setTitle:@"搜索中" forState:UIControlStateNormal];
    
    [self performSelector:@selector(searchSillyMessageOpt) withObject:nil afterDelay:1];
}

- (void)searchSillyMessageOpt
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchSillyMessageOpt) object:nil];
    //return [self openPlazaViewControllerWithData:nil];
    static NSInteger reqCount = 0;
    if (reqCount++ > 5) {
        DPTrace(@"请求失败，请检查你的网络设置");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"请求失败，请检查你的网络设置" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        [_roundButton stopAnimation];
        reqCount = 0;
        return;
    }
    _searchOptHolding = YES;
//    [[DPLbsServerEngine shareInstance] forceToUpdateLocationWithCacheTime:5*60];
    [self searchSillyMessageRequest];
}

- (void)searchSillyMessageRequest
{
    _searchOptHolding = NO;
//    if ([self needsToHoldOnRequest]) {
//        _searchOptHolding = YES;
//        [[DPLbsServerEngine shareInstance] forceToUpdateLocationWithCacheTime:0];
//        return;
//    }
    
    __weak HomePageViewController* weakSelf = self;
    [[SillyService shareInstance] fetchNearbySillyBroacast:0 msgTag:0 comletion:^(id json, JSONModelError *err) {
        NSArray* broacasts = nil;
        if (err == nil) {
            SillyBroacastResponseModel* response = [[SillyBroacastResponseModel alloc] initWithDictionary:json error:&err];
            if (response && response.statusCode) {
                if ([response.statusCode integerValue] == 0) {
                    broacasts = response.broacastArray;
                    DPTrace("拉取广播数据成功，共计：%zd个",[broacasts count]);
                    [weakSelf openPlazaViewControllerWithData:broacasts];
                }else if ([response.statusCode integerValue] == 8){
                    DPTrace(@"你的帐户已经被后台封号");
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"你的帐户已经被后台封号" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alert show];
                    
                    [weakSelf.roundButton stopAnimation];
                }
            }else{
                DPTrace("拉取广播数据失败");
                //防止请求过于频繁
                [weakSelf performSelector:@selector(searchSillyMessageOpt) withObject:nil afterDelay:0.5];
            }
        }else{
            DPTrace("拉取广播数据请求失败");
            //防止请求过于频繁
            [weakSelf performSelector:@selector(searchSillyMessageOpt) withObject:nil afterDelay:0.5];
        }
    }];
}

- (void)openPlazaViewControllerWithData:(NSArray*)broadcasts
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:nil object:nil];
    [_roundButton stopAnimation];
    
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    
    AppDelegate* delegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [delegate changeToPlazaViewControllerWithDatasource:broadcasts];
}

#pragma mark - 地理位置
/**
 *  如果地理位置请求未打开，则无法使用应用
 */
- (BOOL)needsToHoldOnRequest
{
    return [[DPLbsServerEngine shareInstance] city] == nil;
}

- (void)didUserLocationEndUpdate:(NSNotification*)notification
{
//    if (_searchOptHolding) {
//        [self searchSillyMessageRequest];
//    }
}

- (void)didLocationFailedUpdate:(NSNotification*)notification
{
    [_roundButton stopAnimation];
//    if(_searchOptHolding){
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"定位失败，请检查你的当前的网络" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alert show];
//    }
}

- (void)didGeoReverseResultUpdate:(NSNotification*)notification
{
    DPTrace("GEO检索完成: %@",[[DPLbsServerEngine shareInstance] city]);
//    if([notification.object boolValue] || [[[DPLbsServerEngine shareInstance] city] length]){
//        if (_searchOptHolding) {
//            [self searchSillyMessageRequest];
//        }
//    }
}

- (void)showLocationDisableMessage
{
    NSString* navtipstr = @"请在iPhone \"设置-隐私-定位服务\"中打开定位服务，并允许此刻使用";
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"此刻，请先允许定位权限" message:navtipstr delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}
@end
