//
//  UIImageAdditions.m
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UIImageAdditions.h"

@implementation UIImage (biubiu)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [self imageWithColor:color size:CGSizeMake(4.0, 4.0)];
}

+ (UIImage*)resizeImageWithColor:(UIColor *)color
{
    UIColor *bgColor = color;
    if(!bgColor)  //默认
        bgColor = [UIColor colorWithRed:229.0/255.0 green:230.0/255.0 blue:231.0/255.0 alpha:1];
    
    UIImage *_selectedImg = [UIImage imageWithColor:bgColor];
    CGFloat leftCap = floorf(_selectedImg.size.height/2);
    CGFloat topCap = floorf(_selectedImg.size.height/2);
    UIEdgeInsets capInset = UIEdgeInsetsMake(leftCap,topCap, _selectedImg.size.height - topCap - 1, _selectedImg.size.width -leftCap - 1);
    UIImage *_stretchSelectedImg = [_selectedImg resizableImageWithCapInsets:capInset];
    return _stretchSelectedImg;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img;
    }
}

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    
    [text drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


+(UIImage*) drawTextView:(UITextView*) textView
             inImage:(UIImage*)  image
{
    return [self drawTextView:textView inImage:image scaleNumber:image.size.width/SCREEN_WIDTH];
}


+(UIImage*) drawTextView:(UITextView*)textView
                 inImage:(UIImage*)image
             scaleNumber:(CGFloat)number
{
    if(nil == textView || [textView.text length] == NO){
        return image;
    }
    
    NSString* text = textView.text;
    CGPoint point = CGPointMake(textView.origin.x * number, textView.origin.y * number);
    UIFont *font = [UIFont fontWithName:textView.font.fontName size:textView.font.pointSize * number];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    
    CGRect rect = CGRectMake(point.x, point.y, textView.width * number, textView.height*number);
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.alignment = textView.textAlignment;
    
    [text drawInRect:CGRectIntegral(rect)
      withAttributes:@{NSFontAttributeName:font,
                       NSParagraphStyleAttributeName:textStyle,NSForegroundColorAttributeName:textView.textColor}];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(UIImage*) drawTextView:(UITextView*)textView
                 inImage:(UIImage*)image
               orignRect:(CGRect)orignRect
{
    if(nil == textView || [textView.text length] == NO){
        return image;
    }
    CGFloat xScale = image.size.width/orignRect.size.width;
    CGFloat yScale = image.size.height/orignRect.size.height;
    
    NSString* text = textView.text;
    CGPoint point = CGPointMake(textView.origin.x * xScale, textView.origin.y * yScale);
    UIFont *font = [UIFont fontWithName:textView.font.fontName size:textView.font.pointSize * MAX(xScale, yScale)];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    
    CGRect rect = CGRectMake(point.x, point.y, textView.width * xScale, textView.height*yScale);
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.alignment = textView.textAlignment;
    [text drawInRect:CGRectIntegral(rect)
      withAttributes:@{NSFontAttributeName:font,
                       NSParagraphStyleAttributeName:textStyle,NSForegroundColorAttributeName:textView.textColor}];
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)subImageInRect:(CGRect)rect image:(UIImage*)image
{
    CGImageRef imageRef = image.CGImage;
    
    CGRect tar_rect = CGRectMake(rect.origin.x, rect.origin.y ,rect.size.width, rect.size.height);
    
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, tar_rect);
    
    UIImage *imageRect = [[UIImage alloc] initWithCGImage:imageRefRect];
    
    return imageRect;
}

@end
