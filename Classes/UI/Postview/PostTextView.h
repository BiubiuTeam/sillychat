//
//  PostTextView.h
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTextView : UITextView

@property (nonatomic, assign) NSUInteger maxCount;
@property (nonatomic, assign) NSUInteger minCount;
@property (nonatomic, assign) NSUInteger inputCount;

@property (nonatomic, assign) CGFloat defaultCenterY;
@property (nonatomic, assign) CGFloat defaultWidth;

//引用计数label
@property (nonatomic, weak) UILabel* countLabel;

- (void)dpTextDidChanged:(NSNotification*)notification;
@end
