//
//  CheckImageViewController.h
//  sillyChat
//
//  Created by haowenliang on 15/5/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BaseViewController.h"
#import "BroadcastBaseView.h"
#import "BroadcastContentView.h"

@interface CheckImageViewController : BaseViewController<BroadcastBaseViewProtocol>

@property (nonatomic, strong) SillyBroacastModel* broadcastModel;
@property (nonatomic, strong) BroadcastBaseView* broadcastView;
@property (nonatomic, strong) BroadcastContentView* contentView;

@property (nonatomic, strong) UIView* containerView;

@property (nonatomic, assign) CGRect originFrame;

@end
