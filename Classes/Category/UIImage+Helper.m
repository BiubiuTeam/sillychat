//
//  UIImage+Helper.m
//  sillyChat
//
//  Created by haowenliang on 15/4/26.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helper)

+ (UIImage *)fixOrientation:(UIImage *)srcImg
{
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage*)image:(UIImage*)image scaleToFitSize:(CGSize)fitSize
{
    float shortSide = fitSize.width >= fitSize.height ? fitSize.height : fitSize.width;
    float longSide = fitSize.width >= fitSize.height ? fitSize.width : fitSize.height;
    CGSize size = [self fitImage:image withMaxShortSide:shortSide];
    size = [self fitSize:size withMaxLongSide:longSide];
    
    UIImage* scaledImage = nil;
    
    if (image.imageOrientation == UIImageOrientationUp &&
        CGSizeEqualToSize(size, image.size))
    {
        scaledImage = image;
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return scaledImage;
}

+ (UIImage*)image:(UIImage*)image scaleToFitSizeWithMaxLongSide:(CGFloat)longSideLength
{
    UIImage* scaledImage = nil;
    CGSize size = [self fitImage:image withMaxLongSide:longSideLength];
    
    if (image.imageOrientation == UIImageOrientationUp &&
        CGSizeEqualToSize(size, image.size))
    {
        scaledImage = image;
    }
    else
    {
#if 1
        UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
        
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
#else
        CGContextRef mainViewContentContext;
        CGColorSpaceRef colorSpace;
        
        colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // create a bitmap graphics context the size of the image
        mainViewContentContext = CGBitmapContextCreate (NULL, size.width, size.height, 8,0, colorSpace, kCGImageAlphaPremultipliedLast);
        
        // free the rgb colorspace
        CGColorSpaceRelease(colorSpace);
        
        if (mainViewContentContext==NULL)
        {
            DPTrace("roundCornerImageWithMaxShortSide, mainViewContentContext is nil!");
            return nil;
        }
        
        CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, size.width, size.height), image.CGImage);
        CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
        CGContextRelease(mainViewContentContext);
        
        // convert the finished reflection image to a UIImage
        scaledImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
        
        // image is retained by the property setting above, so we can
        // release the original
        CGImageRelease(mainViewContentBitmapContext);
#endif
    }
    
    return scaledImage;
}

+ (CGSize)fitImage:(UIImage*)image withMaxShortSide:(CGFloat)shortSideLength
{
    return [self fitSize:image.size withMaxShortSide:shortSideLength];
}

+ (CGSize)fitImage:(UIImage*)image withMaxLongSide:(CGFloat)longSideLength
{
    return [self fitSize:image.size withMaxLongSide:longSideLength];
}

+ (CGSize)fitSize:(CGSize)thisSize withMaxShortSide:(CGFloat)shortSideLength
{
    CGSize size = thisSize;
    
    float hv = size.width/size.height;
    if (hv > 1.0f)
    {
        if (size.height > shortSideLength)
        {
            float v = shortSideLength / size.height;
            size.width *= v;
            size.height = shortSideLength;
        }
    }
    else
    {
        if (size.width > shortSideLength)
        {
            float v = shortSideLength / size.width;
            size.height *= v;
            size.width = shortSideLength;
        }
    }
    
    return size;
}

+ (CGSize)fitSize:(CGSize)thisSize withMaxLongSide:(CGFloat)longSideLength
{
    CGSize size = thisSize;
    
    float hv = size.width/size.height;
    if (hv > 1.0f)
    {
        if (size.width > longSideLength)
        {
            float v = longSideLength / size.width;
            size.height *= v;
            size.width = longSideLength;
        }
    }
    else
    {
        if (size.height > longSideLength)
        {
            float v = longSideLength / size.height;
            size.width *= v;
            size.height = longSideLength;
        }
    }
    
    return size;
}


@end
