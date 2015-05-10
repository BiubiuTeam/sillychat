//
//  CPKenburnsView+AsyncImage.m
//  sillyChat
//
//  Created by haowenliang on 15/3/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "CPKenburnsView+AsyncImage.h"
#import "DPAsyncImageLoader.h"
#import "UIImage+Helper.h"

@implementation CPKenburnsView (AsyncImage)

- (void)setImageURL:(NSURL *)imageURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DPAsyncImageLoader sharedLoader] loadImageWithURL:imageURL target:self action:@selector(setImage:)];
    });
}

- (NSURL *)imageURL
{
    return [[DPAsyncImageLoader sharedLoader] URLForTarget:self action:@selector(setImage:)];
}

@end


@implementation DPKenburnsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
#if !REMOVE_ANIMOTION
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartMotion) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optActionWhenReceiveNotification:) name:@"KenburnsImageViewStateSet" object:nil];
#endif
    }
    return self;
}
#if !REMOVE_ANIMOTION
- (void)optActionWhenReceiveNotification:(NSNotification*)notification
{
    NSNumber* bvalue = notification.object;
    [self setState:([bvalue boolValue])?CPKenburnsImageViewStateAnimating:CPKenburnsImageViewStatePausing];
}
#endif

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
