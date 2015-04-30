//
//  BiuDevice.mm
//  BiuBiu
//
//  Created by haowenliang on 14/12/3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#include "BiuDevice.h"
#include <sys/sysctl.h>
#include <sys/socket.h> // Per msqr
#include <net/if.h>
#include <net/if_dl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <LocalAuthentication/LAContext.h>

#define FULL_CPU_USAGE  100.0f
#define BUSY_THREHOLD   40.0f

#pragma mark -- CPU
float get_cpu_usage(float threhold)
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS)
    {
        return FULL_CPU_USAGE;
    }
    
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS)
    {
        return FULL_CPU_USAGE;
    }
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS)
        {
            return FULL_CPU_USAGE;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE))
        {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
        if (tot_cpu >= threhold)
        {
            // 如果当前已经大于threhold，直接返回
            return tot_cpu;
        }
    }
    
    return tot_cpu;
}

bool is_cpu_busy()
{
    return get_cpu_usage(80) >= 80;
}

#pragma mark ---
double dp_getSystemVersion()
{
    static double s_SystemVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
    return s_SystemVersion;
}

//判断是否完整安装越狱插件
bool dp_isFullJailBrokenPatch()
{
    //7.0 只针对7.x的用户做这个检查，因为到目前为止只有7.x系统才有自动重连下载的逻辑
    if ((SYSTEM_VERSION >= 7.0) && (SYSTEM_VERSION) < 8.0)
    {
        NSString * ppsyncPatchPath = @"bin/ppsync.dylib";
        if ([[NSFileManager defaultManager] fileExistsAtPath:ppsyncPatchPath])
        {
            DPTrace("越狱安装了appsync7.x补丁");
            return YES;
        }
        else
        {
            DPTrace("越狱没有安装了appsync7.x补丁");
            return NO;
        }
    }

    return YES;
}

bool dp_isDeviceJailBroken()
{
    
    static BOOL qZoneJailBroken = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cydiaPath = @"/Applications/Cydia.app";
        NSString *aptPath = @"/private/var/lib/apt/";
        if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
            qZoneJailBroken = YES;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
            qZoneJailBroken = YES;
        }
    });
    
    NSURL* url = [NSURL URLWithString:@"cydia://package/com.example.package"];
    BOOL dpJailBroken = [[UIApplication sharedApplication] canOpenURL:url];
    
    return qZoneJailBroken || dpJailBroken;
}

bool dp_isLowPerformanceDevice()
{
    static bool s_isLowPerformanceDevice = ([[DPDevice defaultDevice] ifDeviceLow4S] || [[DPDevice defaultDevice] ifDeviceTouchLow]);
    return s_isLowPerformanceDevice;
}

bool dp_isSupportBackgroundRefresh()
{
    if (dp_getSystemVersion() < 7.0){
        return false;
    }
    if ([UIApplication sharedApplication].backgroundRefreshStatus == UIBackgroundRefreshStatusAvailable){
        return true;
    }
    return false;
}

#pragma mark - DPDevice
@implementation DPDevice

+ (DPDevice *)defaultDevice
{
    static DPDevice* defaultDevice = nil;
    static dispatch_once_t defaultOnce;
    dispatch_once(&defaultOnce, ^{
        defaultDevice = [[DPDevice alloc] init];
    });
    return defaultDevice;
}

#pragma -mark 判断设备性能是否较低
- (BOOL)isLowPerformanceDevice
{
    DeviceType devType = [self deviceVersion];
    if (devType == DeviceiPhone1G ||
        devType == DeviceiPhone3G ||
        devType == DeviceiPhone3GS ||
        devType == DeviceiPhone4 ||
        devType == DeviceiPhone4S ||
        devType == DeviceiPodTouch1G ||
        devType == DeviceiPodTouch2G ||
        devType == DeviceiPodTouch2G ||
        devType == DeviceiPodTouch3G ||
        devType == DeviceiPodTouch4G ||
        devType == DeviceiPad1) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)ifDeviceTouchLow
{
    /**
     DeviceiPhone1G,
     DeviceiPhone3G,
     DeviceiPhone3GS,
     DeviceiPhone4,
     */
    DeviceType typeD = [self deviceVersion];
    if(DeviceiPodTouch1G == typeD ||
       DeviceiPodTouch2G == typeD ||
       DeviceiPodTouch3G == typeD ||
       DeviceiPodTouch4G == typeD)
        return TRUE;
    
    return FALSE;
}

- (BOOL)ifDeviceLow4S
{
    DeviceType typeD = [self deviceVersion];
    if(DeviceiPhone1G == typeD ||
       DeviceiPhone3G == typeD ||
       DeviceiPhone3GS == typeD ||
       DeviceiPhone4 == typeD ||
       DeviceiPodTouch1G == typeD ||
       DeviceiPodTouch2G == typeD ||
       DeviceiPodTouch3G == typeD ||
       DeviceiPodTouch4G == typeD )
        return TRUE;
    
    return FALSE;
}

- (DeviceType)deviceVersion
{
    if (_deviceType == DeviceiPhoneNone) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = (char*)malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString* platform = nil;
        if (machine == NULL) {
            platform = @"i386";
        } else {
            platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        }
        free(machine);
        
        if ([platform hasPrefix:@"iPhone"]) {
            if ([platform isEqualToString:@"iPhone1,1"]) {
                _deviceType = DeviceiPhone1G;
            } else if ([platform isEqualToString:@"iPhone1,2"]) {
                _deviceType = DeviceiPhone3G;
            } else if ([platform isEqualToString:@"iPhone2,1"]) {
                _deviceType = DeviceiPhone3GS;
            } else if ([platform rangeOfString:@"iPhone3,"].length > 0) {
                _deviceType = DeviceiPhone4;
            } else if ([platform rangeOfString:@"iPhone4,"].length > 0) {
                _deviceType = DeviceiPhone4S;
            } else {
                _deviceType = DeviceiPhoneLater;
            }
        } else if([platform hasPrefix:@"iPod"]) {
            if ([platform isEqualToString:@"iPod1,1"]) {
                _deviceType = DeviceiPodTouch1G;
            } else if ([platform isEqualToString:@"iPod2,1"]) {
                _deviceType = DeviceiPodTouch2G;
            } else if ([platform isEqualToString:@"iPod3,1"]) {
                _deviceType = DeviceiPodTouch3G;
            } else if ([platform isEqualToString:@"iPod4,1"]) {
                _deviceType = DeviceiPodTouch4G;
            } else {
                _deviceType = DeviceiPodTouchLater;
            }
        } else if ([platform hasPrefix:@"iPad"]) {
            if ([platform isEqualToString:@"iPad1,1"]) {
                _deviceType = DeviceiPad1;
            } else if ([platform isEqualToString:@"iPad2,1"]) {
                _deviceType = DeviceiPad2;
            } else if ([platform isEqualToString:@"iPad2,2"]) {
                _deviceType = DeviceiPad2;
            } else if ([platform hasPrefix:@"iPad3"]) {
                _deviceType = DeviceiPad3;
            } else {
                _deviceType = DeviceiPadLater;
            }
        } else if ([platform isEqualToString:@"i386"]) {
            _deviceType = DeviceiPhoneSimulator;
        } else if ([platform isEqualToString:@"x86_64"]) {
            _deviceType = DeviceiPhoneSimulator;
        }
    }
    
    return _deviceType;
}

- (BOOL)IsDeviceHaveJailBrokend
{
    BOOL jailbroken = NO;
    NSString* cydiaPath = @"/Application/Cydia.app";
    NSString* aptPath = @"/private/lib/apt";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath] || [[NSFileManager defaultManager]fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

- (float)getCurrentDeviceBattery
{
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    return [device batteryLevel] * 100;
}

- (BOOL)IsDeviceOpenTouchID
{
    LAContext *context = [[[LAContext alloc] init] autorelease];
    NSError *error;
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = (char *)malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return outstring;
}

@end