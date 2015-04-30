//
//  UIImage+Helper.h
//  sillyChat
//
//  Created by haowenliang on 15/4/26.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

+ (UIImage *)fixOrientation:(UIImage *)srcImg;

+ (UIImage*)image:(UIImage*)image scaleToFitSize:(CGSize)fitSize;
+ (UIImage*)image:(UIImage*)image scaleToFitSizeWithMaxLongSide:(CGFloat)longSideLength;
@end
