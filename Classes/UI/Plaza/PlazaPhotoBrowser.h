//
//  PlazaPhotoBrowser.h
//  sillyChat
//
//  Created by haowenliang on 15/4/9.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlazaPhotoBrowser : NSObject

+ (instancetype)shareInstance;
- (void)showImage:(UIImage *)image;
- (void)showImage:(UIImage*)image fromFrame:(CGRect)frame;
- (void)hideBrowserWithAnimate:(BOOL)animation;

@end
