//
//  UIImageView+AsyncImage.m
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UIImageView+AsyncImage.h"
#import "DPAsyncImageLoader.h"

@implementation UIImageView (AsyncImage)

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
