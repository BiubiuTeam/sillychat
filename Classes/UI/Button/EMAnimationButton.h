//
//  EMAnimationButton.h
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "EMRoundButton.h"

@interface EMAnimationButton : EMRoundButton

@property (nonatomic, assign, readonly) BOOL animation;

- (void)startAnimation;
- (void)stopAnimation;

- (void)rotateAnimationLeft:(BOOL)left duration:(CGFloat)duration;

@end
