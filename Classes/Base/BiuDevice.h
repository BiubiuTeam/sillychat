//
//  BiuDevice.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//


#ifndef BiuBiu___BiuDevice__
#define BiuBiu___BiuDevice__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    double dp_getSystemVersion();
    bool dp_isFullJailBrokenPatch();
    bool dp_isDeviceJailBroken();
    bool dp_isLowPerformanceDevice();
    bool dp_isSupportBackgroundRefresh();
#ifdef __cplusplus
}
#endif

#define SYSTEM_VERSION              dp_getSystemVersion()
#define IS_LOWPERFORMANCE_DEVICE    dp_isLowPerformanceDevice()

typedef enum tagDeviceType {
    DeviceiPhoneNone,
    DeviceiPhoneSimulator,
    
    DeviceiPhone1G,
    DeviceiPhone3G,
    DeviceiPhone3GS,
    DeviceiPhone4,
    DeviceiPhone4S,
    DeviceiPhoneLater,
    
    DeviceiPodTouch1G,
    DeviceiPodTouch2G,
    DeviceiPodTouch3G,
    DeviceiPodTouch4G,
    DeviceiPodTouchLater,
    
    DeviceiPad1,
    DeviceiPad2,
    DeviceiPad3,
    DeviceiPadLater
}DeviceType;

@interface DPDevice : NSObject
{
    DeviceType _deviceType;
}

@property (assign, nonatomic) DeviceType deviceType;

+ (DPDevice *)defaultDevice;

- (DeviceType)deviceVersion;

- (BOOL)ifDeviceTouchLow;
- (BOOL)ifDeviceLow4S;


@end

#endif
