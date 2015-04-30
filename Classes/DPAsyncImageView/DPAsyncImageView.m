//
//  DPAsyncImageView.m
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPAsyncImageView.h"
#import "DPAsyncImageLoader.h"
#import "UIImageView+AsyncImage.h"

#import <SDWebImage/SDImageCache.h>

@interface DPAsyncImageView ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation DPAsyncImageView


- (void)setUp
{
    self.showActivityIndicator = (self.image == nil);
    self.activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.crossfadeDuration = 0.4;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL
{
    __weak DPAsyncImageView* weakSelf = self;
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:[imageURL absoluteString] done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image)
        {
            weakSelf.image = image;
            return;
        }
        super.imageURL = imageURL;
        if (weakSelf.showActivityIndicator && !weakSelf.image && imageURL)
        {
            if (weakSelf.activityView == nil)
            {
                weakSelf.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:weakSelf.activityIndicatorStyle];
                weakSelf.activityView.hidesWhenStopped = YES;
                weakSelf.activityView.center = CGPointMake(weakSelf.bounds.size.width / 2.0f, weakSelf.bounds.size.height / 2.0f);
                weakSelf.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                [weakSelf addSubview:weakSelf.activityView];
            }
            [weakSelf.activityView startAnimating];
        }
    }];
}

- (void)setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
    _activityIndicatorStyle = style;
    [self.activityView removeFromSuperview];
    self.activityView = nil;
}

- (void)setImage:(UIImage *)image
{
    if (image != self.image && self.crossfadeDuration)
    {
        //jump through a few hoops to avoid QuartzCore framework dependency
        CAAnimation *animation = [NSClassFromString(@"CATransition") animation];
        [animation setValue:@"kCATransitionFade" forKey:@"type"];
        animation.duration = self.crossfadeDuration;
        [self.layer addAnimation:animation forKey:nil];
    }
    super.image = image;
    [self.activityView stopAnimating];
}

- (void)dealloc
{
    [[DPAsyncImageLoader sharedLoader] cancelLoadingURL:self.imageURL target:self];
}

@end
