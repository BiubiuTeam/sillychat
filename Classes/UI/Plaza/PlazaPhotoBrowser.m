//
//  PlazaPhotoBrowser.m
//  sillyChat
//
//  Created by haowenliang on 15/4/9.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaPhotoBrowser.h"

static CGRect oldframe;

static NSUInteger BackgroundViewTag = 0x9801;

@implementation PlazaPhotoBrowser
+ (void)showImage:(UIImageView *)avatarImageView relativeFrame:(CGRect)frame
{
    oldframe = frame;
    [self browserImageView:avatarImageView];
}

+ (void)showImage:(UIImageView *)avatarImageView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:window];
    [self browserImageView:avatarImageView];
}

+ (void)hideImage:(BOOL)animation
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIImageView *imageView = (UIImageView*)[window viewWithTag:BackgroundViewTag];
    if (animation == NO) {
        [imageView removeFromSuperview];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = oldframe;
        } completion:^(BOOL finished) {
            if (finished) {
                [imageView removeFromSuperview];
            }
        }];
    }
}

#pragma mark - private
+ (void)browserImageView:(UIImageView*)avatarImageView
{
    UIImage *image = avatarImageView.image;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:oldframe];
    imageView.image = image;
    imageView.tag = BackgroundViewTag;
    
    [window addSubview:imageView];

    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
    } completion:^(BOOL finished) {
        
    }];
}

@end
