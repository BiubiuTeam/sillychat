//
//  BroadcastBaseView.m
//  sillyChat
//
//  Created by haowenliang on 15/4/10.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BroadcastBaseView.h"
#import "NSDate+Category.h"
#import "SCStateService.h"

#define BBV_HOR_INSET _size_S(8)
#define BBV_VER_INSET _size_S(18)

#define BBV_HOR_MARGIN _size_S(20)
#define BBV_VER_MARGIN _size_S(15)

#define BBV_STATE_RADIUS _size_S(20)
#define BBV_PRO_WIDTH _size_S(40)
#define BBV_PRO_HEIGHT _size_S(18)

#define BBV_STU_COLOR RGBACOLOR(0x7e, 0xd3, 0x21, 1)
#define BBV_EMP_COLOR RGBACOLOR(0x4a, 0x90, 0xe2, 1)

#define BBV_PROGRESS_HEIGHT (15)
#define BBV_PROGRESS_MARGIN (17)

@interface BroadcastBaseView ()

@property (nonatomic, strong) UIButton* rightButton;
@property (nonatomic, strong) UIButton* leftButton;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* profileLabel;
@property (nonatomic, strong) CALayer* stateIconLayer;

@end

@implementation BroadcastBaseView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = [BroadcastBaseView defaultHeight];
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = APPBLACKCOLOR;
        
        [self.layer addSublayer:self.timerLayer];
        [_timerLayer addSublayer:self.progressLayer];
        [self addSubview:self.textLabel];
        
        [self addSubview:self.leftButton];
        [self addSubview:self.rightButton];
        [self addSubview:self.titleLabel];
        [self addSubview:self.profileLabel];
        [self.layer addSublayer:self.stateIconLayer];
        
        [self addBottomBorderLayer];
        [self centerTopSubviews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = [BroadcastBaseView defaultHeight];
    [super setFrame:frame];
}

- (void)centerTopSubviews
{
    CGFloat centerY = STATUSBAR_HEIGHT + BBV_VER_MARGIN + BBV_STATE_RADIUS/2;
    
    _leftButton.centerY = _rightButton.centerY = _titleLabel.centerY = _profileLabel.centerY = centerY;
    _titleLabel.left = self.width/2 + BBV_HOR_INSET/2;
    _profileLabel.right = self.width/2 - BBV_HOR_INSET/2;
    
    CGRect siFrame = _stateIconLayer.frame;
    siFrame.origin.y = centerY - siFrame.size.height/2;
    siFrame.origin.x = _profileLabel.left - BBV_HOR_INSET - BBV_STATE_RADIUS;
    _stateIconLayer.frame = siFrame;
    
    _leftButton.left = BBV_HOR_MARGIN;
    _rightButton.right = self.width - BBV_HOR_MARGIN;
}

#pragma mark - getter
- (CALayer *)timerLayer
{
    if (nil == _timerLayer) {
        _timerLayer = [CALayer layer];
        _timerLayer.frame = CGRectMake(BBV_PROGRESS_MARGIN, self.height - BBV_PROGRESS_HEIGHT - BBV_VER_MARGIN, self.width - 2*BBV_PROGRESS_MARGIN, BBV_PROGRESS_HEIGHT);
        
        _timerLayer.backgroundColor = RGBACOLOR(0x47, 0x46, 0x3e, 1).CGColor;
        _timerLayer.cornerRadius = _size_S(3);
        _timerLayer.borderColor = RGBACOLOR(0x00, 0x00, 0x00, 1).CGColor;
        _timerLayer.borderWidth = _size_S(1);
    }
    return _timerLayer;
}

- (CALayer *)progressLayer
{
    if (nil == _progressLayer) {
        _progressLayer = [CALayer layer];
        _progressLayer.frame = CGRectMake(0, 0, abs(_timerLayer.frame.size.width), _timerLayer.frame.size.height);
        
        _progressLayer.backgroundColor = RGBACOLOR(0xdf, 0xbf, 0x17, 1).CGColor;
        _progressLayer.cornerRadius = _timerLayer.cornerRadius;
        _progressLayer.borderColor = _timerLayer.borderColor;
        _progressLayer.borderWidth = _timerLayer.borderWidth;
    }
    return _progressLayer;
}

- (UILabel *)textLabel
{
    if (nil == _textLabel) {
        CGRect frame = self.timerLayer.frame;
        frame.size.width = frame.size.width - _size_S(3);
        _textLabel = [[UILabel alloc] initWithFrame:frame];
        [_textLabel setFont:[DPFont boldSystemFontOfSize:FONT_SIZE_SMALL-2]];
        [_textLabel setBackgroundColor:[UIColor clearColor]];
        [_textLabel setTextAlignment:NSTextAlignmentRight];
        [_textLabel setTextColor:[UIColor whiteColor]];
    }
    return _textLabel;
}

- (CALayer *)stateIconLayer
{
    if (nil == _stateIconLayer) {
        _stateIconLayer = [CALayer layer];
        _stateIconLayer.frame = CGRectMake(0, 0, BBV_STATE_RADIUS, BBV_STATE_RADIUS);
        _stateIconLayer.backgroundColor = [UIColor clearColor].CGColor;
        _stateIconLayer.contents = (id)LOAD_ICON_USE_POOL_CACHE(@"state/silly_small_boring.png").CGImage;
    }
    return _stateIconLayer;
}

- (UILabel *)profileLabel
{
    if (nil == _profileLabel) {
        _profileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BBV_PRO_WIDTH, BBV_PRO_HEIGHT)];
        _profileLabel.backgroundColor = BBV_STU_COLOR;
        _profileLabel.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL-2];
        _profileLabel.textColor = [UIColor whiteColor];
        _profileLabel.text = @"学生";
        _profileLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _profileLabel;
}

- (UILabel *)titleLabel
{
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = @"对方在某处";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UIButton *)leftButton
{
    if (nil == _leftButton) {
        _leftButton =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 30)];
        [_leftButton addTarget:self action:@selector(didClickLeftButton) forControlEvents:UIControlEventTouchUpInside];
        _leftButton.titleLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateHighlighted];
        [_leftButton setTitle:@"返回" forState:UIControlStateNormal];
        [_leftButton sizeToFit];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (nil == _rightButton) {
        _rightButton =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 30)];
        [_rightButton addTarget:self action:@selector(didClickRightButton) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.titleLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateHighlighted];
        
        [_rightButton setTitle:@"举报" forState:UIControlStateNormal];
        [_rightButton sizeToFit];
    }
    return _rightButton;
}

#pragma mark -opt
- (void)didClickRightButton
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickRightButton)]) {
        [_delegate didClickRightButton];
    }
}

- (void)didClickLeftButton
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickLeftButton)]) {
        [_delegate didClickLeftButton];
    }
}
#pragma mark -

- (void)updateProcess:(NSTimeInterval)timeInterval
{
    NSDate* pubDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSTimeInterval passed = [pubDate timeIntervalSinceNow];
    NSTimeInterval left = 24*60*60 - abs(passed);
    
    int hour = abs(left/(60*60))%24;
    int min = abs(left/60)%60;
    NSString* desc = [NSString stringWithFormat:@"%02zd小时%02zd分后会话销毁",hour,min];
    [_textLabel setText:desc];
    
    CGRect frame = _progressLayer.frame;
    frame.size.width = ((hour+1) * _timerLayer.frame.size.width)/24;
    _progressLayer.frame = frame;
}

- (void)setBroadcastModel:(SillyBroacastModel*)broadcast
{
    if(broadcast){
        //用户的状态、地理位置、身份
        [self updateProcess:[broadcast.pubTime doubleValue]];
        NSUInteger useConf = [[broadcast userConfig] unsignedIntegerValue];
        useConf = useConf>>1;
        BOOL student = useConf%2 == 0;
        _profileLabel.text = student?@"学生":@"在职";
        _profileLabel.backgroundColor = student?BBV_STU_COLOR:BBV_EMP_COLOR;
        
        NSString* city = [broadcast city];
        if ([city length]) {
            _titleLabel.text = [NSString stringWithFormat:@"对方在%@",city];
            [_titleLabel sizeToFit];
            [self centerTopSubviews];
        }
        
        NSNumber* msgTag = [broadcast msgTag];
        NSDictionary* dict = [[SCStateService shareInstance] getStateInfoOfId:[msgTag unsignedIntegerValue]];
        NSString* imgName = [dict objectForKey:@"image"];
        if (imgName.length) {
            _stateIconLayer.contents = (id)LOAD_ICON_USE_POOL_CACHE(imgName).CGImage;
        }
    }
}

+ (CGFloat)defaultHeight
{
    return STATUSBAR_HEIGHT + BBV_VER_MARGIN*2 + BBV_VER_INSET + BBV_STATE_RADIUS + BBV_PROGRESS_HEIGHT;
}

- (void)dealloc
{
    DPTrace("\n--------------私聊信息详情销毁完成--------------");
}

//haowen, 05-13 底部分割线
- (void)addBottomBorderLayer
{
    // Add a bottomBorder.
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.height - .5, self.width, .5f);
    bottomBorder.backgroundColor = RGBACOLOR(0x97, 0x97, 0x97, .75).CGColor;
    [self.layer addSublayer:bottomBorder];
}

@end
