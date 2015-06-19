//
//  UserTermsView.m
//  sillyChat
//
//  Created by haowenliang on 15/6/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UserTermsView.h"

static NSString* termsLine;

@interface UserTermsView ()

@property (nonatomic, strong) UIWebView* termsView;

@property (nonatomic, strong) UIButton* iKnowButton;
@end

@implementation UserTermsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        [self addSubview:self.termsView];
        [self addSubview:self.iKnowButton];
        
        [self showUp];
    }
    return self;
}

- (UIWebView *)termsView
{
    if (nil == _termsView) {
        _termsView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _termsView.backgroundColor = [UIColor clearColor];
        
        _termsView.size = CGSizeMake(_size_S(290), _size_S(290));
        UIScrollView* scroll = (UIScrollView*) [_termsView findSubview:@"UIScrollView" resursion:YES];
        [scroll setShowsHorizontalScrollIndicator:NO];
        
        _termsView.layer.cornerRadius = _size_S(4);
        _termsView.layer.masksToBounds = YES;
        _termsView.layer.borderWidth = 1;
        _termsView.layer.borderColor = APPLIGHTCOLOR.CGColor;
    }
    return _termsView;
}

- (void)showUp
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"reference/protocol/protocol" withExtension:@"html"];
    NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [_termsView loadHTMLString:html baseURL:baseURL];
}

- (UIButton *)iKnowButton
{
    if (_iKnowButton == nil) {
        _iKnowButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _iKnowButton.backgroundColor = APPLICATIONCOLOR;
        
        [_iKnowButton setTitle:@"我知道了" forState:UIControlStateNormal];
        
        _iKnowButton.layer.borderWidth = 1;
        _iKnowButton.layer.borderColor = [UIColor whiteColor].CGColor;
        
        [_iKnowButton setTitleColor:APPBLACKCOLOR forState:UIControlStateNormal];
        [_iKnowButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        [_iKnowButton addTarget:self  action:@selector(didClickIKnowBtn) forControlEvents:UIControlEventTouchUpInside];
        
        [_iKnowButton sizeToFit];
        _iKnowButton.width += _size_S(16);
        _iKnowButton.height += _size_S(4);
        
        _iKnowButton.layer.cornerRadius = _iKnowButton.height/2;
        _iKnowButton.layer.masksToBounds = YES;
    }
    return _iKnowButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _termsView.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT - _size_S(240))/2);
    
    _iKnowButton.centerX = SCREEN_WIDTH/2;
    _iKnowButton.top = _termsView.bottom + _size_S(20);
}

- (void)didClickIKnowBtn
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    [UserTermsView updateShowUpTerms:YES];
}

+ (BOOL)hasEverShowUpTerms
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"UserTermsShown"];
}

+ (void)updateShowUpTerms:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:@"UserTermsShown"];
}

@end
