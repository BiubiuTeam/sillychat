//
//  UIColorAdditions.m
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UIColorAdditions.h"

@implementation UIColor (biubiu)

+ (UIColor*)colorWithColorType:(ColorType)type
{
    UIColor* tcolor = [UIColor clearColor];
    switch (type) {
            //导航栏颜色
        case ColorType_NavBar:
            tcolor = RGBACOLOR(0x54, 0xcb, 0xff, 0.85);
            break;
        case ColorType_NavTitle:
            tcolor = RGBACOLOR(0xff, 0xff, 0xff, 1);
            break;
        case ColorType_NavBtnNormal://导航栏颜色
            tcolor = RGBACOLOR(0xff, 0xff, 0xff, 1);
            break;
        case ColorType_NavBtnPressed://导航栏颜色
            tcolor = RGBACOLOR(0xff, 0xff, 0xff, 0.4);
            break;
            
        //附近回复主题颜色
        case ColorType_Green:
            tcolor = RGBACOLOR(0x68, 0xe7, 0xc2, 1);
            break;
        case ColorType_LightGreen:
            tcolor = RGBACOLOR(0x61, 0xda, 0xb7, 1);
            break;
        case ColorType_Pink:
            tcolor = RGBACOLOR(0xfc, 0x91, 0x85, 1);
            break;
        case ColorType_LightPink:
            tcolor = RGBACOLOR(0xf0, 0x85, 0x7a, 1);
            break;
        case ColorType_Yellow:
            tcolor = RGBACOLOR(0xf7, 0xe0, 0x61, 1);
            break;
        case ColorType_LightYellow:
            tcolor = RGBACOLOR(0xe4, 0xcc, 0x4a, 1);
            break;
            
        //文本颜色
        case ColorType_DeepTxt:
            tcolor = RGBACOLOR(0x33, 0x33, 0x33, 1);
            break;
        case ColorType_MediumTxt:
            tcolor = RGBACOLOR(0x66, 0x66, 0x66, 1);
            break;
        case ColorType_LightTxt:
            tcolor = RGBACOLOR(0x99, 0x99, 0x99, 1);
            break;
        case ColorType_WhiteTxt:
            tcolor = RGBACOLOR(0xff, 0xff, 0xff, 1);
            break;
        case ColorType_BlueTxt:
            tcolor = RGBACOLOR(0x54, 0xcb, 0xff, 1);
            break;
            
        //背景颜色
        case ColorType_DeepGray:
            tcolor = RGBACOLOR(0xf0, 0xf3, 0xf5, 1);
            break;
        case ColorType_MediumGray:
            tcolor = RGBACOLOR(0xf6, 0xf9, 0xfb, 1);
            break;
        case ColorType_LightGray:
            tcolor = RGBACOLOR(0xfb, 0xfb, 0xfb, 1);
            break;
        case ColorType_WhiteBg:
            tcolor = RGBACOLOR(0xff, 0xff, 0xff, 1);
            break;
            
        case ColorType_Seperator:
            tcolor = RGBACOLOR(0xde, 0xdf, 0xe0, 1);
            break;
        case ColorType_ContactBg:
            tcolor = RGBACOLOR(0xfa, 0xfa, 0xfa, 1);
            break;
        case ColorType_EmptyViewBg:
            tcolor = RGBACOLOR(0xee, 0xed, 0xf3, 1);
            break;
        case ColorType_MaskColor:
            tcolor = RGBACOLOR(0xf8, 0xf9, 0xfc, 0.5);
            break;
//        case ColorType_:
//            
//            break;
//        case ColorType_:
//            
//            break;
//        case ColorType_:
//            
//            break;
//        case ColorType_:
//            
//            break;
//        case ColorType_:
//            
//            break;
        default:
            break;
    }
    return tcolor;
}

@end