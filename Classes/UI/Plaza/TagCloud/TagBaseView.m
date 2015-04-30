//
//  TagBaseView.m
//  sillyChat
//
//  Created by haowenliang on 15/3/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "TagBaseView.h"

@interface TagBaseView ()

@end

@implementation TagBaseView

- (instancetype)initWithFrame:(CGRect)frame viewType:(BroacastType)viewType
{
    frame.size.height = TAG_VIEW_DEFAULT_HEIGHT;
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        self.viewType = viewType;
        [self setupUiControls];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = TAG_VIEW_DEFAULT_HEIGHT;
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        self.viewType = BroacastType_Text;
        [self setupUiControls];
    }
    return self;
}

- (void)setupUiControls
{
    _didScale = NO;
//    [self addTarget:self action:@selector(didTouchUpInsideTag:) forControlEvents:UIControlEventTouchUpInside];
}
//
//- (void)didTouchUpInsideTag:(UIButton*)sender
//{
//    NSLog(@"%@",_datasource);
//}

- (void)setViewType:(BroacastType)viewType
{
    _viewType = viewType;
    switch (_viewType) {
        case BroacastType_Text:{
            self.backgroundColor = APPLIGHTCOLOR;
        }break;
        case BroacastType_Voice:{
            self.backgroundColor = RGBACOLOR(0x31, 0xd0, 0x5a, 1);
        }break;
        default:{
            self.backgroundColor = APPLIGHTCOLOR;
        }break;
    }
}

- (void)setViewContent:(id)content
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

/////////////////////////////////////////////////
- (NSComparisonResult)compareWithWidth:(TagBaseView*)otherView
{
    if(self.width > otherView.width){
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

@end
