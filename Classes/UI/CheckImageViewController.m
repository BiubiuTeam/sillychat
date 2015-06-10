//
//  CheckImageViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/5/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "CheckImageViewController.h"
#import "AppDelegate.h"

@interface CheckImageViewController ()
@property (nonatomic, strong) UIView* bottomView;

@property (nonatomic, strong) UILabel* messageLabel;
@property (nonatomic, strong) UIImageView* locationIcon;

@end

@implementation CheckImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.broadcastView];
    [self.view addSubview:self.containerView];
    
    [_containerView addSubview:self.contentView];
    [_containerView addSubview:self.bottomView];
    
    [_bottomView addSubview:self.messageLabel];
    [_bottomView addSubview:self.locationIcon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showUpWithAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //特殊处理会话列表页面，因为从这里回去不会相应viewwillappear
    AppDelegate* delegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [delegate optWhenTopViewControllerPopup];
}

- (void)showUpWithAnimation
{
    self.broadcastView.hidden = YES;
    self.bottomView.hidden = YES;
    
    _contentView.frame = self.originFrame;
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - _broadcastView.height - 36);
    } completion:^(BOOL finished) {
        [self showTopAndBottomWithAnimation];
    }];
}

- (void)showTopAndBottomWithAnimation
{
    _broadcastView.hidden = NO;
    _bottomView.hidden = NO;
    
    CGRect bframe = _broadcastView.frame;
    CGRect tframe = _bottomView.frame;
    _broadcastView.bottom = 0;
    _bottomView.top = _bottomView.superview.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        _broadcastView.frame = bframe;
        _bottomView.frame = tframe;
    }];
}

- (UIView *)bottomView
{
    if (nil == _bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
        _bottomView.backgroundColor = APPBLACKCOLOR;
        _bottomView.bottom = _containerView.height;
        
        // Add a bottomBorder.
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, 0, _bottomView.width, .5f);
        bottomBorder.backgroundColor = RGBACOLOR(0x97, 0x97, 0x97, .75).CGColor;
        [_bottomView.layer addSublayer:bottomBorder];
    }
    return _bottomView;
}

- (UILabel *)messageLabel
{
    if (nil == _messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:FONT_SIZE_MIDDLE];

    }
    return _messageLabel;
}

- (UIImageView *)locationIcon
{
    if (nil == _locationIcon) {
        _locationIcon = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"location_icon.png")];
        _locationIcon.backgroundColor = [UIColor clearColor];
    }
    return _locationIcon;
}

- (BroadcastBaseView *)broadcastView
{
    if (nil == _broadcastView) {
        _broadcastView = [[BroadcastBaseView alloc] initWithFrame:CGRectZero];
        _broadcastView.delegate = self;
        _broadcastView.viewType = BBViewType_Owner;
    }
    return _broadcastView;
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

- (BroadcastContentView *)contentView
{
    if (nil == _contentView) {
        _contentView = [[BroadcastContentView alloc] initWithFrame:CGRectZero];
        [[_contentView imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [_contentView addTarget:self action:@selector(didClickContentView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contentView;
}

- (void)setBottomLocationInfo:(NSString*)message
{
    _messageLabel.text = [NSString stringWithFormat:@"发布于%@",message];
    [_messageLabel sizeToFit];
    
    _messageLabel.centerY = _locationIcon.centerY = _bottomView.height/2;
    
    CGFloat width = _messageLabel.width + _locationIcon.width + 5;
    _locationIcon.left = (_bottomView.width - width)/2;
    _messageLabel.left = _locationIcon.right + 5;
}

- (void)didClickLeftButton
{
    [UIView animateWithDuration:.3 animations:^{
        _broadcastView.bottom = 0;
        _bottomView.top = _bottomView.superview.height;
        _contentView.frame = _originFrame;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)didClickContentView
{
    [self didClickLeftButton];
}

- (void)setBroadcastModel:(SillyBroacastModel *)broadcastModel
{
    _broadcastModel = broadcastModel;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.broadcastView setBroadcastModel:broadcastModel];
        [self.contentView setContentViewWithDatasource:broadcastModel];
        [self setBottomLocationInfo:broadcastModel.city];
    });
}


@end
