//
//  PlazaFilterButton.m
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaFilterButton.h"
#import "PlazaFilterView.h"

@interface PlazaFilterButton ()
@property (nonatomic, strong) UIImageView* eyeImgView;
@property (nonatomic, strong) UILabel* filterLabel;
@property (nonatomic, strong) UIImageView* arrowImgView;
@end

@implementation PlazaFilterButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.eyeImgView];
        [self addSubview:self.filterLabel];
        [self addSubview:self.arrowImgView];
        [self setNeedUpdateContent];
    }
    return self;
}

- (UIImageView *)eyeImgView
{
    if (nil == _eyeImgView) {
        _eyeImgView = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"filter_eye_black.png")];
        _eyeImgView.backgroundColor = [UIColor clearColor];
        _eyeImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _eyeImgView;
}

- (UILabel *)filterLabel
{
    if (nil == _filterLabel) {
        _filterLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _filterLabel.backgroundColor = [UIColor clearColor];
        _filterLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        _filterLabel.textAlignment = NSTextAlignmentCenter;
        _filterLabel.textColor = [UIColor blackColor];
    }
    return _filterLabel;
}

- (UIImageView *)arrowImgView
{
    if (nil == _arrowImgView) {
        _arrowImgView = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_down.png")];
        _arrowImgView.backgroundColor = [UIColor clearColor];
        _arrowImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _arrowImgView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _arrowImgView.centerY = _filterLabel.centerY = _eyeImgView.centerY = self.height/2;
    
    _eyeImgView.left = _size_S(12);
    _filterLabel.left = _eyeImgView.right + _size_S(10);
    _arrowImgView.left = _filterLabel.right + _size_S(10);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted || self.selected) {
        _filterLabel.textColor = [UIColor whiteColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_up.png");
        _eyeImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_eye_white.png");
    }else{
        _filterLabel.textColor = [UIColor blackColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_down.png");
        _eyeImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_eye_black.png");
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        _filterLabel.textColor = [UIColor whiteColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_up.png");
        _eyeImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_eye_white.png");
    }else{
        _filterLabel.textColor = [UIColor blackColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_down.png");
        _eyeImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_eye_black.png");
    }
}

- (void)setFilterLabelContent:(NSString*)content
{
    _filterLabel.text = content;
    [_filterLabel sizeToFit];
    
    self.width = _size_S(12)+_size_S(10)*2 + _eyeImgView.width + _arrowImgView.width + _filterLabel.width;
}

- (BOOL)setNeedUpdateContent
{
    NSString* lastMsg = _filterLabel.text;
    [self setFilterLabelContent:[PlazaFilterView filterMessage]];
    NSString* newMsg = _filterLabel.text;
    return ![lastMsg isEqualToString:newMsg];
}

@end
