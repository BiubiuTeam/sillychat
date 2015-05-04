//
//  TagImageView.m
//  sillyChat
//
//  Created by haowenliang on 15/3/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "TagImageView.h"
#import "CPKenburnsView.h"
#import "CPKenburnsView+AsyncImage.h"
#import "PlazaPhotoBrowser.h"

#import "UmLogEngine.h"

@interface TagImageView ()
{
    DPKenburnsView *_kenbunrsView;
}

@end

@implementation TagImageView

- (void)dealloc
{
    _kenbunrsView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame viewType:(BroacastType)viewType
{
    frame.size.width = TAG_IMAGE_WIDTH;
    if (self = [super initWithFrame:frame viewType:viewType]) {
        _kenbunrsView = [[DPKenburnsView alloc] initWithFrame:self.bounds];
        [self addSubview:_kenbunrsView];
        _kenbunrsView.backgroundColor = [UIColor clearColor];
        self.viewType = BroacastType_Image;
        _kenbunrsView.image = [UIImage imageWithColor:RGBACOLOR(0xe9, 0xc6, 0x00, 1) size:_kenbunrsView.size];
        _kenbunrsView.userInteractionEnabled = NO;
        _kenbunrsView.exclusiveTouch = NO;
        
        //long press to show whole image
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showWholeImage:)];
        longPress.minimumPressDuration = .5f;
        [self addGestureRecognizer:longPress];
        
        [self sendSubviewToBack:_kenbunrsView];
    }
    return self;
}

- (void)setImageContent:(id)content
{
    if ([content isKindOfClass:[UIImage class]]) {
        _kenbunrsView.image = (UIImage*)content;
    }else if([content isKindOfClass:[NSString class]]){
        //需要去下载
        _kenbunrsView.imageURL = [NSURL URLWithString:content];
    }
}

- (CGRect)absoluteFrame
{
    return [_kenbunrsView convertRect:_kenbunrsView.bounds toView:[UIApplication sharedApplication].keyWindow];
}

- (void)showWholeImage:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            [UmLogEngine logEvent:EventStartChat attribute:@{@"ViewType":@"LongPress"}];
            CGRect frame = [_kenbunrsView convertRect:_kenbunrsView.bounds toView:[UIApplication sharedApplication].keyWindow];
            [[PlazaPhotoBrowser shareInstance] showImage:_kenbunrsView.image fromFrame:frame];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    _kenbunrsView.frame = self.bounds;
}
@end
