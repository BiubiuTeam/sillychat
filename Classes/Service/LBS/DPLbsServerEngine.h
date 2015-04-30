//
//  DPLbsServerEngine.h
//  biubiu
//
//  Created by haowenliang on 15/3/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"
#import <CoreLocation/CoreLocation.h>

/*
 
 地理位置的更新机制为：（LocationUpdate）刷新地理位置入口，地理位置信息缓存2分钟有效期，超出缓存时间则刷新
 
 调用刷新时机有：
 1，用户下拉刷新附近列表、版块列表 都会调用LocationUpdate
 2，用户进入发表页面、创建版块页面 都会调用LocationUpdate
 3，App从后台进入前台，会调用LocationUpdate
 
 地理位置更新成功后，会触发附近列表、版块列表的刷新
 
 */
extern NSString* const DPLocationDidEndUpdate;
extern NSString* const DPLocationWillStartUpdate;
extern NSString* const DPLocationDidStopUpdate;
extern NSString* const DPLocationDidFailedUpdate;

extern NSString* const DPLocationGetReverseGeoCodeResult;

@interface BBLocationManager : CLLocationManager<CLLocationManagerDelegate>

@property (nonatomic, assign) NSInteger currentStatus;

- (void) requestAuthorization;

@end


@interface DPLbsServerEngine : NSObject

@property (nonatomic, strong) BMKUserLocation *userLocation;
@property (nonatomic, strong) BMKReverseGeoCodeResult* geoCodeResult;

+ (instancetype)shareInstance;

- (int)latitude;
- (int)longitude;
- (BMKPoiInfo*)getPoiInfoAtIndex:(NSInteger)index;

- (NSString*)getUserLocationName:(NSInteger)index;
- (CLLocationCoordinate2D)getLoactionCoordinate2DAtIndex:(NSInteger)index;

- (NSString*)city;
- (NSString*)provinceAndCity;


- (void)forceToUpdateLocation;
- (void)forceToUpdateLocationWithCacheTime:(NSInteger)timestamp;

//系统定位服务是否打开
-(BOOL) isLocationServerviceEnabled;

//手Q是否授权
-(BOOL) isAuthorized;

//是否打开且授权
-(BOOL) isEnabledAndAuthorize;


+ (NSString*)sillyChatCacheFilePath;
@end
