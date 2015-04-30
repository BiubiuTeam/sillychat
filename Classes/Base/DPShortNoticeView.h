//
//  DPShortNoticeView.h
//  Longan
//
//  Created by haowenliang on 14-6-20.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ShortNotificationTipsViewTag    10000

@interface DPShortNoticeView : UIView
@property (nonatomic, retain) NSString* title;

- (void)showView;
- (void)hideView;
+ (void)showTips:(NSString*)tipsStr atRootView:(UIView*)rootView;

@end
