//
//  PlazaPhotoBrowser.h
//  sillyChat
//
//  Created by haowenliang on 15/4/9.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlazaPhotoBrowser : NSObject
/**
 *	@brief	浏览图像
 *
 *	@param 	oldImageView 	图像所在的imageView
 */
+ (void)showImage:(UIImageView*)avatarImageView;
+ (void)hideImage:(BOOL)animation;
+ (void)showImage:(UIImageView *)ImageView relativeFrame:(CGRect)frame;
@end
