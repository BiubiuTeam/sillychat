//
//  UIColorAdditions.h
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef HEXCOLOR
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]
#endif

#ifndef RGBACOLOR
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#endif

typedef NS_ENUM(NSUInteger, ColorType) {
    ColorType_NavBar,
    ColorType_NavTitle,
    ColorType_NavBtnNormal,
    ColorType_NavBtnPressed,
    
    ColorType_Clear,    //透明色
    //附近回复主题颜色
    ColorType_Green,
    ColorType_LightGreen,
    
    ColorType_Pink,
    ColorType_LightPink,
    
    ColorType_Yellow,
    ColorType_LightYellow,
    
    //文本颜色
    ColorType_DeepTxt,
    ColorType_MediumTxt,
    ColorType_LightTxt,
    ColorType_WhiteTxt,
    ColorType_BlueTxt,
    
    //背景颜色
    ColorType_DeepGray,
    ColorType_MediumGray,
    ColorType_LightGray,
    ColorType_WhiteBg,
    ColorType_ContactBg, //联系我们页面背景色
    ColorType_EmptyViewBg, //空白页面背景色
    ColorType_Seperator,
    
    ColorType_MaskColor, //消息列表已读半透明颜色
};


@interface UIColor (biubiu)

+ (UIColor*)colorWithColorType:(ColorType)type;

@end