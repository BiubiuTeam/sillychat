//
//  UIImageAdditions.h
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (biubiu)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage*)resizeImageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point;

+ (UIImage*) drawTextView:(UITextView*) textView inImage:(UIImage*)image;
+ (UIImage*)subImageInRect:(CGRect)rect image:(UIImage*)image;
+ (UIImage*) drawTextView:(UITextView*)textView
                 inImage:(UIImage*)image
               orignRect:(CGRect)orignRect;

@end
