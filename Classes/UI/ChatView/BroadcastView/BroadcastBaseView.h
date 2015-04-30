//
//  BroadcastBaseView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/10.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SillyBroacastModel.h"

#define BCV_HOR_MARGIN (17)
#define BCV_MARGIN_TOP (42)

#define BCV_PROGRESS_MARGIN_TOP (9)
#define BCV_PROGRESS_MARGIN_BOTTOM (13)
#define BCV_PROGRESS_HEIGHT (15)

@protocol BroadcastBaseViewProtocol <NSObject>

@optional
- (void)didClickLeftButton;
- (void)didClickRightButton;

@end

@interface BroadcastBaseView : UIView

@property (nonatomic, strong) CALayer* timerLayer;
@property (nonatomic, strong) CALayer* progressLayer;
@property (nonatomic, strong) UILabel* textLabel;


@property (nonatomic, assign) id<BroadcastBaseViewProtocol> delegate;

- (void)setBroadcastModel:(SillyBroacastModel*)broadcast;

@end
