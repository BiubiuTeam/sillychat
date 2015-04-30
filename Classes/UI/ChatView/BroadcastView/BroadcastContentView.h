//
//  BroadcastContentView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BCV_RADIUS _size_S(75)
@class SillyBroacastModel;

@interface BroadcastContentView : UIButton
@property (nonatomic, assign) BOOL largeState;

@property (nonatomic, strong) NSURL *imageURL;

- (void)setContentViewWithDatasource:(SillyBroacastModel*)model;
@end
