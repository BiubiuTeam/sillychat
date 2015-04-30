//
//  DPSlideInteractor.h
//  sillyChat
//
//  Created by haowenliang on 15/4/8.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPSlideInteractor : NSObject<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign) float duration;

+ (instancetype)shareInstance;
@end
