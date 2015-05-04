//
//  ChatRoomImageBubbleView.m
//  sillyChat
//
//  Created by haowenliang on 15/4/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatRoomImageBubbleView.h"
#import <UIImageView+WebCache.h>
#import "PlazaPhotoBrowser.h"

@implementation ChatRoomImageBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setTextAlignment:NSTextAlignmentCenter];
        
        //long press to show whole image
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showWholeImage:)];
        longPress.minimumPressDuration = .5f;
        [self addGestureRecognizer:longPress];
    }
    
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize = [_imageView.image size];
    
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, 2 * BUBBLE_VIEW_PADDING + retSize.height);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);

    frame.origin.x = BUBBLE_VIEW_PADDING;

    frame.origin.y = BUBBLE_VIEW_PADDING;
    [self.imageView setFrame:frame];
    
    self.textLabel.width = frame.size.width;
    self.textLabel.centerY = self.height/2;
    [self bringSubviewToFront:self.textLabel];
}

#pragma mark - setter

- (void)setImagePath:(NSString *)path
{
    __weak ChatRoomImageBubbleView* weakSelf = self;
    
    UIImage* place = [UIImage imageWithColor:RGBACOLOR(0x97, 0x97, 0x97, 1) size:CGSizeMake(MAX_SIZE, MAX_SIZE)];
    [self setTextContent:@"图片正在加载\n点击进入聊天"];

    [self.imageView setImageWithURL:[NSURL URLWithString:path] placeholderImage:place completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        CGFloat lastRight = weakSelf.right;
        weakSelf.size = [weakSelf sizeThatFits:CGSizeZero];
        weakSelf.right = lastRight;
        if (image && error ==nil && cacheType != SDImageCacheTypeNone) {
            [weakSelf setTextContent:nil];
        }
    }];
}

#pragma mark - public

- (CGRect)absoluteFrame
{
    CGRect frame = [_imageView convertRect:_imageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    frame.origin.y = frame.origin.y - BUBBLE_VIEW_PADDING/2 - 1;
    return frame;
}

- (void)setTextContent:(NSString *)content
{
    [self.textLabel setText:content];
}

- (void)showWholeImage:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            CGRect frame = [_imageView convertRect:_imageView.bounds toView:[UIApplication sharedApplication].keyWindow];
            [[PlazaPhotoBrowser shareInstance] showImage:_imageView.image fromFrame:frame];
        }break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [[PlazaPhotoBrowser shareInstance] hideBrowserWithAnimate:YES];
        }break;
        default:
            break;
    }
}

@end
