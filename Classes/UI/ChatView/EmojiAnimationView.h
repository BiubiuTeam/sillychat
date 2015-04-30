//
//  EmojiAnimationView.h
//  sillyChat
//
//  Created by haowenliang on 15/3/18.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiAnimationView : UIImageView
{
    CADisplayLink* _link;
}
@property (nonatomic) BOOL LeftOrientation;

- (void)startAnimation;
+ (void)showEmoji:(NSString*)emoji aboveView:(UIView*)superView yPosition:(CGFloat)position leftOrientation:(BOOL)toleft;

@end
