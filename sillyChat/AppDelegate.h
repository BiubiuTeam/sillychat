//
//  AppDelegate.h
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>
{
    EMConnectionState _connectionState;
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@property (strong, nonatomic) UIWindow *window;
- (void)changeToPlazaViewControllerWithDatasource:(NSArray*)datasource;

@end

