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
        [_backgroundView removeFromSuperview];
        self.imageView = nil;
        self.backgroundView = nil;
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _imageView.frame = _originFrame;
            _backgroundView.alpha = .1;
        } completion:^(BOOL finished) {
            if (finished) {
                [_imageView removeFromSuperview];
                [_backgroundView removeFromSuperview];
                
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
    
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 1;
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
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
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
