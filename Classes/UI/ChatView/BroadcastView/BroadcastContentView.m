//
//  BroadcastContentView.m
//  sillyChat
//
//  Created by haowenliang on 15/4/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BroadcastContentView.h"
#import "SillyBroacastModel.h"
#import "DPAsyncImageLoader.h"

#import "PostViewController.h"

@interface BroadcastContentView ()
@property (nonatomic, strong) UILabel* msgLabel;
@property (nonatomic, strong) NSString* titleContent;
@end

@implementation BroadcastContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size = CGSizeMake(BCV_RADIUS, BCV_RADIUS);
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        self.titleContent = nil;
        self.backgroundColor = APPLIGHTCOLOR;
    
        [[self imageView] setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:self.msgLabel];
        [self setLargeState:NO];
    }
    return self;
}

- (UILabel *)msgLabel
{
    if (nil == _msgLabel) {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEFAUTL_TEXTVIEW_WIDTH, 0)];
        _msgLabel.backgroundColor = [UIColor clearColor];
        [_msgLabel setTextAlignment:NSTextAlignmentCenter];
        [_msgLabel setTextColor:TEXTVIEW_TINT_COLOR];
        [_msgLabel setFont:TEXTVIEW_FONT];
        [_msgLabel setNumberOfLines:0];
    }
    return _msgLabel;
}

- (void)setLargeState:(BOOL)largeState
{
    _largeState = largeState;
    _msgLabel.hidden = !largeState;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _msgLabel.centerX = self.width/2;
    _msgLabel.height = self.height;
    [self bringSubviewToFront:_msgLabel];
}

- (void)setContentViewWithDatasource:(SillyBroacastModel*)model
{
    if ([model.titleType integerValue] == BroacastType_Text) {
        [self setTitle:model.titleCont forState:UIControlStateNormal];
    }else if ([model.titleType integerValue] == BroacastType_Image){
        NSDictionary* dic = model.extension;
        [self setImageURL:[NSURL URLWithString:model.titleCont]];
        self.msgLabel.text = [dic objectForKey:@"Text"];
        [self setLargeState:NO];
    }
}

- (void)setWebImage:(UIImage*)image
{
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
    [self setImage:image forState:UIControlStateSelected];
}

- (void)setImageURL:(NSURL *)imageURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DPAsyncImageLoader sharedLoader] loadImageWithURL:imageURL target:self action:@selector(setWebImage:)];
    });
}

- (NSURL *)imageURL
{
    return [[DPAsyncImageLoader sharedLoader] URLForTarget:self action:@selector(setWebImage:)];
}

- (void)dealloc
{
    DPTrace("\n--------------私聊图片销毁完成--------------");
}
@end
