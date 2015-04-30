//
//  UIScreenEx.h
//  baseUI
//
//  Created by odie song on 12-9-13.
//  Copyright (c) 2012年 odie song. All rights reserved.
//
//  参考
#ifndef __baseUI__UIScreenEx__
#define __baseUI__UIScreenEx__

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    int getScreenWidth();
    
    int getScreenHeight();
    
    // 获取状态栏竖边高度
    int getStatusBarHeight();
    
    void setStatusBarHeight(int newH);
    
    CGFloat fitScreenW(CGFloat value);
    CGFloat fitScreenH(CGFloat value);
    CGFloat fitScaleScreen(CGFloat value);
    CGFloat fitScaleFontScreen(CGFloat value);
    CGFloat screenScale();
#ifdef __cplusplus
}
#endif

#define SCREEN_WIDTH            getScreenWidth()
#define SCREEN_HEIGHT           getScreenHeight()

#define SCREEN_WIDTH_2          (SCREEN_WIDTH << 1)
#define SCREEN_HEIGHT_2         (SCREEN_HEIGHT << 1)

/**返回float*/
#define _size_W(value)    fitScreenW(value)
#define _size_H(value)    fitScreenH(value)

#define _size_S(value)    fitScaleScreen(value)
#define _size_F(value)    fitScaleFontScreen(value)

#define _sizeScale        screenScale()


// 这是竖屏的
#define APPLICATION_FRAME_WIDTH       ([UIScreen mainScreen].applicationFrame.size.width)
#define APPLICATION_FRAME_HEIGHT      ([UIScreen mainScreen].applicationFrame.size.height)


#define STATUSBAR_HEIGHT        getStatusBarHeight()
#define APPLICATION_WIDTH       (SCREEN_WIDTH)

#define APPLICATION_HEIGHT      (SCREEN_HEIGHT - STATUSBAR_HEIGHT)

#endif /* defined(__baseUI__UIScreenEx__) */


//@interface UIScreen (extention_scale)
//
//+ (CGFloat)adjustWidth:(CGFloat)value;
//+ (CGFloat)adjustHeight:(CGFloat)value;
//+ (CGFloat)adjustSize:(CGFloat)value;
//+ (CGFloat)adjustFont:(CGFloat)value;
//
//@end
