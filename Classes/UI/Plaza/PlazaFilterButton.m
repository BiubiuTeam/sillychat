//
//  PlazaFilterButton.m
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaFilterButton.h"
#import "PlazaFilterView.h"
#import "SCStateService.h"
#import "CircleProgress/CircularProgressView.h"

@interface PlazaFilterButton ()
@property (nonatomic, strong) CircularProgressView* eyeImgView;
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
        self.uploadImage = nil;
        _uploaderTag = 0;
        [self setEyeType:EyeType_Black];
    }
    return self;
}

- (CircularProgressView *)eyeImgView
{
    if (nil == _eyeImgView) {
        _eyeImgView = [[CircularProgressView alloc] initWithFrame:CGRectMake(0, 0, _size_S(25), _size_S(25)) backColor:[UIColor whiteColor] progressColor:RGBACOLOR(0x65, 0x9d, 0xd3, 1) lineWidth:1];
        _eyeImgView.layer.cornerRadius = _eyeImgView.width/2;
        _eyeImgView.layer.masksToBounds = YES;
        _eyeImgView.backgroundColor = [UIColor clearColor];
    }
    return _eyeImgView;
}

- (void)setProgress:(float)progress
{
    [_eyeImgView setProgress:progress];
}

- (void)setEyeType:(EyeType)type
{
    if(_uploadImage){
        type = EyeType_Custom;
    }
    UIImage* eye = nil;
    _eyeImgView.contentMode = UIViewContentModeScaleAspectFit;
    switch (type) {
        case EyeType_Black:
        {
            eye = LOAD_ICON_USE_POOL_CACHE(@"filter_eye_black.png");
        }break;
        case EyeType_White:
        {
            eye = LOAD_ICON_USE_POOL_CACHE(@"filter_eye_white.png");
        }break;
        case EyeType_Succeed:
        {
            eye = LOAD_ICON_USE_POOL_CACHE(@"silly_upload_succeed.png");
            
            [self performSelector:@selector(resetEyeType) withObject:nil afterDelay:1];
        }break;
        case EyeType_Failed:
        {
            eye = LOAD_ICON_USE_POOL_CACHE(@"silly_upload_failed.png");
            
            [self performSelector:@selector(resetEyeType) withObject:nil afterDelay:1];
        }break;
        case EyeType_Custom:
        {
            _eyeImgView.contentMode = UIViewContentModeScaleAspectFill;
            eye = _uploadImage;
        }break;
        default:
            break;
    }
    _eyeImgView.image = eye;
    
    if (type == EyeType_Custom){
        [_eyeImgView setProgressLayerHidden:NO];
    }else{
        [_eyeImgView setProgressLayerHidden:YES];
    }
}

- (void)resetEyeType
{
    self.uploadImage = nil;
    if (self.highlighted || self.selected) {
        _filterLabel.textColor = [UIColor whiteColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_up.png");
        [self setEyeType:EyeType_White];
    }else{
        _filterLabel.textColor = [UIColor blackColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_down.png");
        [self setEyeType:EyeType_Black];
    }
}

- (UILabel *)filterLabel
{
    if (nil == _filterLabel) {
        _filterLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _filterLabel.backgroundColor = [UIColor clearColor];
        _filterLabel.font = [UIFont systemFontOfSize:FONT_SIZE_MIDDLE];
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
        
        [self setEyeType:EyeType_White];
    }else{
        _filterLabel.textColor = [UIColor blackColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_down.png");
        
        [self setEyeType:EyeType_Black];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        _filterLabel.textColor = [UIColor whiteColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_up.png");
        
        [self setEyeType:EyeType_White];
    }else{
        _filterLabel.textColor = [UIColor blackColor];
        _arrowImgView.image = LOAD_ICON_USE_POOL_CACHE(@"filter_arrow_down.png");
        
        [self setEyeType:EyeType_Black];
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
    [self setFilterLabelContent:[[SCStateService shareInstance] filterMessage]];
    NSString* newMsg = _filterLabel.text;
    return ![lastMsg isEqualToString:newMsg];
}

@end
