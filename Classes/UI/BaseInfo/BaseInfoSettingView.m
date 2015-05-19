//
//  BaseInfoSettingView.m
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BaseInfoSettingView.h"
#import "EMAccountService.h"
#import "SillyService.h"

@interface ProfileButton : UIButton
@property (nonatomic, assign) BOOL alignTop;
@property (nonatomic, strong) UILabel* messageLabel;
@end

@implementation ProfileButton

- (UILabel *)messageLabel
{
    if(nil == _messageLabel){
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _messageLabel.layer.borderWidth = _size_S(5);
        
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        
        _messageLabel.font = [UIFont boldSystemFontOfSize:24];
        _messageLabel.layer.cornerRadius = 4;
        _messageLabel.layer.masksToBounds = YES;
    }
    return _messageLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _alignTop = YES;
        [self addSubview:self.messageLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _messageLabel.width = self.width - 2*_size_S(36);
    _messageLabel.height = _size_S(250);
    _messageLabel.centerX = self.width/2;
    if (_alignTop) {
        _messageLabel.top = (self.height - _messageLabel.height)/3;
    }else{
        _messageLabel.top = 2*(self.height - _messageLabel.height)/3;
    }
}

- (void)setMessageText:(NSString*)text
{
    _messageLabel.text = text;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        UIColor* color = _alignTop?RGBACOLOR(0x61, 0xa1, 0xf8, 1):RGBACOLOR(0xf8, 0x61, 0x61, 1);
        _messageLabel.textColor = color;
        _messageLabel.layer.borderColor = color.CGColor;
    }else{
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}
@end

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
@interface SillyDragImageView : UIImageView
{
    CGPoint _lastLocation;
}
@property (nonatomic, assign) SEL dragDownSelector;
@property (nonatomic, assign) SEL dragStartSelector;
@property (nonatomic, assign) SEL dragEndSelector;

@property (nonatomic, strong) UILabel* sillyLabel;
@end

@implementation SillyDragImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.sillyLabel];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPan:)];
        [self addGestureRecognizer:panRecognizer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _sillyLabel.centerX = self.width/2;
    _sillyLabel.centerY = self.height/2;
}

- (UILabel *)sillyLabel
{
    if (nil == _sillyLabel) {
        _sillyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sillyLabel.backgroundColor = [UIColor clearColor];
        _sillyLabel.font = [UIFont boldSystemFontOfSize:2*FONT_SIZE_MIDDLE];
        _sillyLabel.textColor = [UIColor whiteColor];
        _sillyLabel.text = @"无聊";
        [_sillyLabel sizeToFit];
    }
    return _sillyLabel;
}

- (void) detectPan:(UIPanGestureRecognizer *) uiPanGestureRecognizer
{
    if (uiPanGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _lastLocation = self.center;
//        if(self.isAnimating){
//            [self stopAnimating];
//        }
        if(_dragStartSelector){
            [[self nextResponder] performSelectorInBackground:_dragStartSelector withObject:nil];
        }
    }else if (uiPanGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [uiPanGestureRecognizer translationInView:self.superview];
        self.center = CGPointMake(_lastLocation.x ,
                                  _lastLocation.y + MAX(0,translation.y));
        
        if (self.bottom > self.superview.height) {
            [uiPanGestureRecognizer removeTarget:self action:@selector(detectPan:)];
            if(_dragDownSelector){
                [[self nextResponder] performSelectorInBackground:_dragDownSelector withObject:nil];
            }
        }
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            // Offset for gesture location.
            self.center = _lastLocation;
//            self.transform = CGAffineTransformMakeScale(0.99, 0.99);
//            self.highlighted = NO;
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
//            self.transform = CGAffineTransformMakeScale(1/0.99, 1/0.99);
            if (!self.isAnimating) {
                [self startAnimating];
            }
        }];
        if(_dragEndSelector){
            [[self nextResponder] performSelectorInBackground:_dragEndSelector withObject:nil];
        }
    }
}

@end

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
@interface BaseInfoSettingView ()
{
    NSUInteger _userConfig;
}
@property (nonatomic, strong) SillyDragImageView* roundButton;
@property (nonatomic, strong) UIButton* leftButton;
@property (nonatomic, strong) UIButton* rightButton;

@property (nonatomic, strong) ProfileButton* studentButton;
@property (nonatomic, strong) ProfileButton* employeeButton;

@property (nonatomic, strong) UIImageView* runningDot;
@property (nonatomic, strong) UILabel* msgLabel;
@end

@implementation BaseInfoSettingView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.roundButton];
        [self addSubview:self.runningDot];
        [_roundButton startAnimating];
        [_runningDot startAnimating];
        _userConfig = 0;
        [self addSubview:self.msgLabel];
    }
    return self;
}

- (UIImageView *)runningDot
{
    if (nil == _runningDot) {
        _runningDot = [[UIImageView alloc] initWithFrame:CGRectZero];
        _runningDot.frame = CGRectMake(0, 0, 24, 58);
        _runningDot.backgroundColor = [UIColor clearColor];
        _runningDot.image = LOAD_ICON_USE_POOL_CACHE(@"regist/silly_arrow0.png");
        
        _runningDot.animationImages = @[LOAD_ICON_USE_POOL_CACHE(@"regist/silly_arrow1.png"),LOAD_ICON_USE_POOL_CACHE(@"regist/silly_arrow2.png"),LOAD_ICON_USE_POOL_CACHE(@"regist/silly_arrow3.png"),LOAD_ICON_USE_POOL_CACHE(@"regist/silly_arrow4.png")];
        _runningDot.animationDuration = 1;
        _runningDot.animationRepeatCount = 0;
    }
    return _runningDot;
}

- (UILabel *)msgLabel
{
    if (nil == _msgLabel) {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LARGE];
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.text = @"下滑开启";
        [_msgLabel sizeToFit];
    }
    return _msgLabel;
}

- (UIButton *)leftButton
{
    if (_leftButton == nil) {
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width/2, self.height)];
        _leftButton.backgroundColor = RGBACOLOR(0xff, 0xde, 0x32, 1);
        
        [_leftButton addTarget:self action:@selector(selectMale) forControlEvents:UIControlEventTouchUpInside];
        
        [_leftButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_gendar_male_normal.png") forState:UIControlStateNormal];
        [_leftButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_gendar_male_press.png") forState:UIControlStateHighlighted];
        [_leftButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_gendar_male_press.png") forState:UIControlStateSelected];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (_rightButton == nil) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width/2, 0, self.width/2, self.height)];
        _rightButton.backgroundColor = [UIColor clearColor];
        
        [_rightButton addTarget:self action:@selector(selectFemale) forControlEvents:UIControlEventTouchUpInside];
        
        [_rightButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_gendar_female_normal.png") forState:UIControlStateNormal];
        [_rightButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_gendar_female_press.png") forState:UIControlStateHighlighted];
        [_rightButton setImage:LOAD_ICON_USE_POOL_CACHE(@"silly_gendar_female_press.png") forState:UIControlStateSelected];
    }
    return _rightButton;
}

- (ProfileButton *)studentButton
{
    if (_studentButton == nil) {
        _studentButton = [[ProfileButton alloc] initWithFrame:CGRectMake(0, 0, self.width/2, self.height)];
        _studentButton.backgroundColor = RGBACOLOR(0xff, 0xde, 0x32, 1);
        
        [_studentButton addTarget:self action:@selector(toBeAStudent) forControlEvents:UIControlEventTouchUpInside];
        
        [_studentButton setMessageText:@"我\n还\n是\n学\n生"];
    }
    return _studentButton;
}

- (ProfileButton *)employeeButton
{
    if (_employeeButton == nil) {
        _employeeButton = [[ProfileButton alloc] initWithFrame:CGRectMake(self.width/2, 0, self.width/2, self.height)];
        _employeeButton.backgroundColor = [UIColor clearColor];
        _employeeButton.alignTop = NO;
        [_employeeButton addTarget:self action:@selector(toBeAnEmployee) forControlEvents:UIControlEventTouchUpInside];
        
        [_employeeButton setMessageText:@"我\n已\n经\n工\n作"];
    }
    return _employeeButton;
}

- (SillyDragImageView *)roundButton
{
    if (nil == _roundButton) {
        _roundButton = [[SillyDragImageView alloc] initWithFrame:CGRectMake(0, 0, BIG_BUBBLE_RADIUS, BIG_BUBBLE_RADIUS)];
        _roundButton.backgroundColor = [UIColor clearColor];
        _roundButton.image = LOAD_ICON_USE_POOL_CACHE(@"regist/silly_regist_dark.png");
        _roundButton.animationImages = @[LOAD_ICON_USE_POOL_CACHE(@"regist/silly_regist_dark.png"),LOAD_ICON_USE_POOL_CACHE(@"regist/silly_regist_light.png")];
        _roundButton.animationDuration = 2;
        _roundButton.animationRepeatCount = 0;
        _roundButton.userInteractionEnabled = YES;
        
        _roundButton.dragDownSelector = @selector(dragDownButton);
        _roundButton.dragStartSelector = @selector(dragBegin);
        _roundButton.dragEndSelector = @selector(dragEnd);
    }
    return _roundButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _msgLabel.centerX = _runningDot.centerX = _roundButton.centerX = self.width/2;
    
    _roundButton.bottom = self.height - 96;
    _runningDot.top = _roundButton.bottom + 6;
    
    _msgLabel.bottom = SCREEN_HEIGHT - _msgLabel.height/2;
}

- (void)removeRoundbuttonWithAnimate:(BOOL)animation
{
    if (NO == animation) {
        [_roundButton removeFromSuperview];
        self.roundButton = nil;
        [_runningDot removeFromSuperview];
        self.runningDot = nil;
        return;
    }
}

#pragma mark - button selectors
- (void)dragBegin
{
    [self.runningDot stopAnimating];
}

- (void)dragEnd
{
    [self.runningDot startAnimating];
}

- (void)dragDownButton
{
    [self removeRoundbuttonWithAnimate:NO];
    [_studentButton removeFromSuperview];
    [_employeeButton removeFromSuperview];
    
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
    
    _msgLabel.text = @"选择你的性别";
    [_msgLabel sizeToFit];
    [self bringSubviewToFront:_msgLabel];
    
    _leftButton.bottom = 0;
    _rightButton.top = _rightButton.height;
    [UIView animateWithDuration:0.3 animations:^{
        _leftButton.bottom = _leftButton.height;
        _rightButton.top = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)selectMale
{
    [[EMAccountService shareInstance] setAccountGendar:0];
    _userConfig += 0;
    [self comeToSelectProfile];
}

- (void)selectFemale
{
    [[EMAccountService shareInstance] setAccountGendar:1];
    _userConfig += 1;
    [self comeToSelectProfile];
}

- (void)removeInfoView
{
    self.alpha = 0.7;
    [UIView animateWithDuration:0.3 animations:^{
        _studentButton.top = _studentButton.height;
        _employeeButton.bottom = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [_studentButton removeFromSuperview];
        [_employeeButton removeFromSuperview];
        self.studentButton = nil;
        self.employeeButton = nil;
        [self removeFromSuperview];
    }];
}

#pragma mark - 选择职业
- (void)comeToSelectProfile
{
    [self addSubview:self.studentButton];
    [self addSubview:self.employeeButton];
    
    _msgLabel.text = @"选择你的职业";
    [_msgLabel sizeToFit];
    [self bringSubviewToFront:_msgLabel];
    
    _studentButton.bottom = 0;
    _studentButton.top = _studentButton.height;
    [UIView animateWithDuration:0.3 animations:^{
        _leftButton.top = _leftButton.height;
        _rightButton.bottom = 0;
        
        _studentButton.bottom = _studentButton.height;
        _employeeButton.top = 0;
    } completion:^(BOOL finished) {
        [_leftButton removeFromSuperview];
        [_rightButton removeFromSuperview];
        self.leftButton = nil;
        self.rightButton = nil;
    }];
}

- (void)toBeAStudent
{
    _userConfig += 0;
    [self registOperation:_userConfig];
}

- (void)toBeAnEmployee
{
    _userConfig += 2;
    [self registOperation:_userConfig];
}

#pragma mark -
- (void)registOperation:(NSUInteger)userConfig
{
    __weak BaseInfoSettingView* weakSelf = self;
    [[SillyService shareInstance] registSillyUserWithInformation:userConfig completion:^(id json, JSONModelError *err) {
        DPTrace("注册流程回调");
        if (err == nil) {
            SillyResponseModel* response = [[SillyResponseModel alloc] initWithDictionary:json error:&err];
            if (err == nil) {
                DPTrace(@"结果：%@",response);
                if ([response.statusCode integerValue] != 0) {
                    DPTrace("注册失败，可能是帐户冲突");
                    [[EMAccountService shareInstance] updateSettingAccountInfo:YES];
                    [weakSelf removeInfoView];
                }else{
                    DPTrace("注册成功");
                    [[EMAccountService shareInstance] updateSettingAccountInfo:YES];
                    [weakSelf removeInfoView];
                }
            }else{
                DPTrace(@"转换失败：%@",[err description]);
                [weakSelf showErroTips];
                [weakSelf dragDownButton];
            }
        }else{
            DPTrace("注册失败");
            [weakSelf showErroTips];
            [[EMAccountService shareInstance] updateSettingAccountInfo:NO];
            [weakSelf dragDownButton];
        }
    }];
}

- (void)showErroTips
{
    DPTrace(@"注册失败，请重新尝试");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"注册失败，请重新尝试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}
@end
