//
//  UIScreenEx.cpp
//  baseUI
//
//  Created by odie song on 12-9-13.
//  Copyright (c) 2012年 odie song. All rights reserved.
//

#include "UIScreenEx.h"

#define iPhone6PlusPXWidth (414.0f)
#define iPhone6PXWidth (375.0f)

static int static_statusbarHeight = 0;

int getScreenWidth()
{
    static int s_scrWidth = 0;
    if (s_scrWidth == 0){
        CGRect screenFrame = [UIApplication sharedApplication].keyWindow.bounds;
        s_scrWidth = MIN(screenFrame.size.width, screenFrame.size.height);
    }
    return s_scrWidth;
}

int getScreenHeight()
{
    static int s_scrHeight = 0;
    if (s_scrHeight == 0){
        UIScreen* screen = [UIScreen mainScreen];
        CGRect screenFrame = screen.bounds;
        s_scrHeight = MAX(screenFrame.size.height, screenFrame.size.width);
    }
    return s_scrHeight;
}

int getStatusBarHeight()
{
    if (static_statusbarHeight == 0) {
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        static_statusbarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);
    }
    return static_statusbarHeight;
}

void setStatusBarHeight(int newH)
{
    static_statusbarHeight = newH;
}

CGFloat fitScreenW(CGFloat value)
{
    return value*screenScale();
}

CGFloat fitScreenH(CGFloat value)
{
    return value*screenScale();
}

CGFloat fitScaleScreen(CGFloat value)
{
    return value*screenScale();
}

CGFloat fitScaleFontScreen(CGFloat value)
{
    if (screenScale() >= 1) {
        return value;
    }else{
        return value - 2;
    }
}

CGFloat screenScale()
{
    return (CGFloat)getScreenWidth()/iPhone6PXWidth;
}


//@implementation UIScreen (extention_scale)
//
//+ (CGFloat)adjustWidth:(CGFloat)value {
//    return _size_W(value);
//}
//
//+ (CGFloat)adjustHeight:(CGFloat)value {
//    return _size_H(value);
//}
//
//+ (CGFloat)adjustSize:(CGFloat)value {
//    return _size_S(value);
//}
//
//+ (CGFloat)adjustFont:(CGFloat)value
//{
//    return _size_F(value);
//}
//
//@end

