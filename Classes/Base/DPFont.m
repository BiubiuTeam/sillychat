//
//  UIFontAdditions.m
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPFont.h"
#define FONT_NONE_CHANGED (0)
@implementation DPFont

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize
{
#if FONT_NONE_CHANGED
    return [super systemFontOfSize:fontSize];
#else
    CGFloat nFontSize = _size_F(fontSize);
    return [super systemFontOfSize:nFontSize];
#endif
}

+ (UIFont*)boldSystemFontOfSize:(CGFloat)fontSize
{
#if FONT_NONE_CHANGED
    return [super boldSystemFontOfSize:fontSize];
#else
    CGFloat nFontSize = _size_F(fontSize);
    return [super boldSystemFontOfSize:nFontSize];
#endif
}

+ (UIFont *)italicSystemFontOfSize:(CGFloat)fontSize
{
#if FONT_NONE_CHANGED
    return [super italicSystemFontOfSize:fontSize];
#else
    CGFloat nFontSize = _size_F(fontSize);
    return [super italicSystemFontOfSize:nFontSize];
#endif
}

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
#if FONT_NONE_CHANGED
    return [super fontWithName:fontName size:fontSize];
#else
    CGFloat nFontSize = _size_F(fontSize);
    return [super fontWithName:fontName size:nFontSize];
#endif
}

@end
