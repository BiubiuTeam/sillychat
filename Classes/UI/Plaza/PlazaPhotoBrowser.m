//
//  PlazaPhotoBrowser.m
//  sillyChat
//
//  Created by haowenliang on 15/4/9.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaPhotoBrowser.h"

#define IMAGE_OFR _size_S(80)

@interface PlazaPhotoBrowser ()

@property (nonatomic, strong) UILabel* messageLabel;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, assign) CGRect originFrame;

@end

@implementation PlazaPhotoBrowser

- (instancetype)init
{
    if (self = [super init]) {
        _originFrame = CGRectMake((SCREEN_WIDTH - IMAGE_OFR)/2, (SCREEN_HEIGHT - IMAGE_OFR)/2, IMAGE_OFR, IMAGE_OFR);
    }
    return self;
}

- (void)hideBrowserWithAnimate:(BOOL)animation
{
    if (animation == NO) {
        [_imageView removeFromSuperview];
        [_messageLabel removeFromSuperview];
        [_backgroundView removeFromSuperview];
        self.imageView = nil;
        self.messageLabel = nil;
        self.backgroundView = nil;
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _imageView.frame = _originFrame;
            _backgroundView.alpha = .1;
            _messageLabel.alpha = .1;
        } completion:^(BOOL finished) {
            if (finished) {
                [_imageView removeFromSuperview];
                [_backgroundView removeFromSuperview];
                [_messageLabel removeFromSuperview];
                self.messageLabel = nil;
                self.imageView = nil;
                self.backgroundView = nil;
            }
        }];
    }
    _originFrame = CGRectMake((SCREEN_WIDTH - IMAGE_OFR)/2, (SCREEN_HEIGHT - IMAGE_OFR)/2, IMAGE_OFR, IMAGE_OFR);
}

- (void)dealloc
{
    DPTrace("图片大图浏览器销毁");
    
    [_backgroundView removeFromSuperview];
    [_imageView removeFromSuperview];
    self.imageView = nil;
}

- (UILabel *)messageLabel
{
    if (nil == _messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(_size_S(16), SCREEN_HEIGHT - _size_S(80), SCREEN_WIDTH - _size_S(16)*2, _size_S(80))];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LARGE];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.numberOfLines = 0;
//        _messageLabel.text = @"我只是一个莫名其妙的孩子，有着一个不错的名字";
    }
    return _messageLabel;
}

- (void)showImage:(UIImage *)image
{
    self.imageView.frame = _originFrame;
    _imageView.image = image;
    
    self.backgroundView.alpha = 0.3;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_backgroundView];
    
    if (_imageView.superview != _backgroundView) {
        [_imageView removeFromSuperview];
        [_backgroundView addSubview:_imageView];
    }
    
    if (self.messageLabel.superview != _backgroundView) {
        [_messageLabel removeFromSuperview];
        [_backgroundView addSubview:_messageLabel];
    }
    _messageLabel.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 1;
        _messageLabel.alpha = 1;
        _imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
    } completion:^(BOOL finished) {
        if(finished){
            DPTrace("图片大小：%@",NSStringFromCGRect(_imageView.frame));
        }
    }];
}

- (void)showImage:(UIImage*)image fromFrame:(CGRect)frame
{
    self.originFrame = frame;
    [self showImage:image];
}

- (void)showImage:(UIImage*)image fromFrame:(CGRect)frame message:(NSString*)message
{
    self.originFrame = frame;
    self.messageLabel.text = message;
    [self showImage:image];
}

- (UIImageView *)imageView
{
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (UIView *)backgroundView
{
    if (nil == _backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return _backgroundView;
}

+ (instancetype)shareInstance
{
    static PlazaPhotoBrowser* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[PlazaPhotoBrowser alloc] init];
    });
    return s_instance;
}

@end
