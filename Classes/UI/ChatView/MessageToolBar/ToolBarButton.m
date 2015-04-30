//
//  ToolBarButton.m
//  sillyChat
//
//  Created by haowenliang on 15/4/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ToolBarButton.h"

@implementation ToolBarButton

- (void)setHighlightImg:(UIImage *)highlightImg
{
    _highlightImg = highlightImg;
    
    [self setImage:_highlightImg forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
//    if (selected) {
//        [self setImage:LOAD_ICON_USE_POOL_CACHE(@"toolbar/silly_tools_keyboard_pressed.png") forState:UIControlStateHighlighted];
//    }else{
////        [self setImage:_highlightImg forState:UIControlStateHighlighted];
//    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];

}

@end
