//
//  BaseViewController.h
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
    __weak BaseViewController* _weakSelf;
    UIColor* _mainVCtrColor;
}
@property (nonatomic, weak) BaseViewController* weakSelf;

@end
