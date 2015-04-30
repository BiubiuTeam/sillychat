//
//  EMDragButton.h
//  sillyChat
//
//  Created by haowenliang on 15/3/17.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRoundButton.h"

@class EMDragButton;

@protocol EMDragButtonProtocol

@required
- (void)notifyStartLocation:(CGPoint)point withButton:(EMDragButton *)button;
- (void)notifyTheCenterLocation:(CGPoint)point withButton:(EMDragButton *)button;
- (void)notifyLastLocation:(CGPoint)point withButton:(EMDragButton *)button;

@end

@interface EMDragButton : EMRoundButton
{
    CGPoint _beginPoint;
    CGPoint _originCenter;
}

@property (nonatomic) BOOL dragEnable;

@property (nonatomic, assign) id <EMDragButtonProtocol> delegate;

@property (nonatomic) BOOL isAlphaEffect;

@end
