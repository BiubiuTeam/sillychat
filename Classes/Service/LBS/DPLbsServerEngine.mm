//
//  DPLbsServerEngine.m
//  biubiu
//
//  Created by haowenliang on 15/3/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPLbsServerEngine.h"
#import "NSKeyedUnarchiverAdditions.h"
#import "NSObject+Encoder.h"

NSString* const DPLocationDidEndUpdate = @"_DPLocationDidEndUpdate_";
NSString* const DPLocationWillStartUpdate = @"_DPLocationWillStartUpdate_";
NSString* const DPLocationDidStopUpdate = @"_DPLocationDidStopUpdate_";
NSString* const DPLocationDidFailedUpdate = @"_DPLocationDidFailedUpdate_";
NSString* const DPLocationGetReverseGeoCodeResult = @"_DPLocationGetReverseGeoCodeResult_";

@implementation BBLocationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentStatus = NSNotFound;
        [self setDelegate:self];
    }
    return self;
}

- (void) requestAuthorization
{
    //ios8.0以上需要如下判断才能授权
    if([self respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self requestWhenInUseAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    DPTrace("Change authorization status: %zd to status: %zd",_currentStatus, status);
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            //首次请求地理位置
            DPTrace("kCLAuthorizationStatusNotDetermined");
            [self requestAuthorization];
        }break;
        case kCLAuthorizationStatusAuthorized:
            //case kCLAuthorizationStatusAuthorizedAlways:
        {
            DPTrace("kCLAuthorizationStatusAuthorized");
        }break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            DPTrace("kCLAuthorizationStatusAuthorizedWhenInUse");
        }break;
        case kCLAuthorizationStatusDenied:{
            DPTrace("kCLAuthorizationStatusDenied");
        }break;
        case kCLAuthorizationStatusRestricted:{
            DPTrace("kCLAuthorizationStatusRestricted");
        }break;
        default:
            break;
    }
    [self postAuthorizationStatusChanged:status];
    _currentStatus = status;
}

- (void)postAuthorizationStatusChanged:(CLAuthorizationStatus)status
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInteger:status] forKey:@"toStatus"];
    [dict setObject:[NSNumber numberWithInteger:_currentStatus] forKey:@"fromStatus"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"_ChangeLocationAuthorizationStatus_" object:nil userInfo:dict];
}

@end


@interface DPLbsServerEngine ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _searcher;
    NSMutableArray* _locationManagerList;
    
    BOOL _isUpdatingLocation;
}

/*暂时仅作权限状态转换通知使用*/
@property (nonatomic, strong) BBLocationManager* bblocationMgr;

@property (nonatomic, strong) BMKGeoCodeSearch* searcher;
@end

@implementation DPLbsServerEngine

+ (instancetype)shareInstance
{
    static DPLbsServerEngine* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[DPLbsServerEngine alloc] init];
    });
    return s_instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _bblocationMgr = [[BBLocationManager alloc] init];
        
        _isUpdatingLocation = NO;
        self.userLocation = [DPLbsServerEngine getCacheUserLocation];
        self.geoCodeResult = [DPLbsServerEngine getCacheGeoPoiResult];
        
        //设置定位精确度，默认：kCLLocationAccuracyBest
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        //指定最小距离更新(米)，默认：kCLDistanceFilterNone
        [BMKLocationService setLocationDistanceFilter:1000.f];
        
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
        
//        //启动LocationService
//        [self forceToUpdateLocation];
    }
    return self;
}

- (BMKGeoCodeSearch *)searcher
{
    if (nil == _searcher) {
        _searcher = [[BMKGeoCodeSearch alloc]init];
        _searcher.delegate = self;
    }
    return _searcher;
}

- (void)forceToUpdateLocation
{
    [self forceToUpdateLocationWithCacheTime:2*60];
}

- (void)forceToUpdateLocationWithCacheTime:(NSInteger)timestamp
{
//    [_bblocationMgr requestAuthorization];
#if TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidEndUpdate object:@(NO)];
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationGetReverseGeoCodeResult object:@(NO)];
#else
    if (_isUpdatingLocation) {
        DPTrace("地理位置正在更新");
        return;
    }
    if (_userLocation == nil || fabs([[NSDate date] timeIntervalSinceDate:_userLocation.location.timestamp]) > timestamp){
        DPTrace("地理位置需要更新");
        //启动LocationService
        [_locService startUserLocationService];
        _isUpdatingLocation = YES;
    }else{
        _isUpdatingLocation = NO;
        DPTrace("地理位置不需要更新");
        [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidEndUpdate object:@(NO)];
        [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationGetReverseGeoCodeResult object:@(NO)];
    }
#endif
}

- (int)latitude
{
#if TARGET_IPHONE_SIMULATOR
    return 22546793;
#else
    int lat = 0;
    if (_userLocation) {
        lat = _userLocation.location.coordinate.latitude * 1000000;
    }
    return lat;
#endif
}

- (int)longitude
{
#if TARGET_IPHONE_SIMULATOR
    return 113945447;
#else
    int lon = 0;
    if (_userLocation) {
        lon = _userLocation.location.coordinate.longitude * 1000000;
    }
    return lon;
#endif
}

- (NSString*)city
{
#if TARGET_IPHONE_SIMULATOR
    return @"深圳市";
#else
    if (_geoCodeResult) {
        BMKAddressComponent* componet = _geoCodeResult.addressDetail;
        return componet.city;
    }
    return nil;
#endif
}

- (NSString*)provinceAndCity
{
    if (_geoCodeResult) {
        NSMutableString* string = [[NSMutableString alloc] init];
        BMKAddressComponent* componet = _geoCodeResult.addressDetail;
        if ([componet.province length]) {
            [string appendString:componet.province];
        }
        if ([componet.city length]) {
            [string appendString:@"."];
            [string appendString:componet.city];
        }
        return string;
    }
    return nil;
}

- (BMKPoiInfo*)getPoiInfoAtIndex:(NSInteger)index
{
    NSArray* poiList = _geoCodeResult.poiList;
    NSInteger count = [poiList count];
//    if (index >= count) {
//        [self reverseGeoCode];
//    }
    if (count) {
        index = index%count;
        return [poiList objectAtIndex:index];
    }
    return nil;
}

- (NSString*)getUserLocationName:(NSInteger)index
{
    NSArray* poiList = _geoCodeResult.poiList;
    NSInteger count = [poiList count];
    if (count) {
        index = index%count;
        BMKPoiInfo* info = [poiList objectAtIndex:index];
        if (info && [info.name length]) {
            return info.name;
        }
    }
    return _geoCodeResult.address;
}

- (CLLocationCoordinate2D)getLoactionCoordinate2DAtIndex:(NSInteger)index
{
    NSArray* poiList = _geoCodeResult.poiList;
    NSInteger count = [poiList count];
    if (count) {
        index = index%count;
        BMKPoiInfo* info = [poiList objectAtIndex:index];
        if (info && [info.name length]) {
            return info.pt;
        }
    }
    return _geoCodeResult.location;
}

#pragma mark- switch授权和打开的开关
//系统定位服务是否打开
-(BOOL) isLocationServerviceEnabled
{
    BOOL locationsvEnabled = [CLLocationManager locationServicesEnabled];
    return locationsvEnabled;
}

//手Q是否授权
-(BOOL) isAuthorized
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (SYSTEM_VERSION >= 8.0)
    {
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            return YES;
        }
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if(status == kCLAuthorizationStatusAuthorized)
#pragma clang diagnostic pop
        {
            return YES;
        }
    }
    
    return NO;
}

//是否打开且授权
-(BOOL) isEnabledAndAuthorize
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    if ([self isLocationServerviceEnabled] && [self isAuthorized])
    {
        return YES;
    }
    else
    {
        return NO;
    }
#endif
}

#pragma mark -
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationWillStartUpdate object:nil];
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    _isUpdatingLocation = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidStopUpdate object:nil];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    DPTrace(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (userLocation) {
        self.userLocation = userLocation;
        [DPLbsServerEngine saveUserLocation:_userLocation];
    }
    _isUpdatingLocation = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidEndUpdate object:@(YES)];
    
    [self reverseGeoCode];
}

- (void)reverseGeoCode
{
    //检索用户POI
    CLLocationCoordinate2D pt = _userLocation.location.coordinate;
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag){
        DPTrace(@"*****eo检索发送成功");
    }else{
        DPTrace(@"*****eo检索发送失败");
        [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationGetReverseGeoCodeResult object:@(NO)];
        _isUpdatingLocation = NO;
    }
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    _isUpdatingLocation = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidFailedUpdate object:nil];
}

#pragma mark - 
//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if(result){
        self.geoCodeResult = result;
        [DPLbsServerEngine saveGeoPoiResult:_geoCodeResult];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationGetReverseGeoCodeResult object:@(YES)];
    _isUpdatingLocation = NO;
}

#pragma mark - cache Lbs

#define LBSWITHOUTCACHE (1)

+ (BOOL)saveUserLocation:(id)object
{
#if LBSWITHOUTCACHE
    return NO;
#else
    if (!object) {
        return NO;
    }
    NSString* filePath = [self sillyChatCacheFilePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/userLocation",filePath];
    return [NSKeyedArchiver archiveRootObject:object toFile:fileName];
#endif
}

+ (BOOL)saveGeoPoiResult:(id)object
{
#if LBSWITHOUTCACHE
    return NO;
#else
    if (!object) {
        return NO;
    }
    NSString* filePath = [self sillyChatCacheFilePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/geoPoiResult",filePath];
    return [NSKeyedArchiver archiveRootObject:object toFile:fileName];
#endif
}

+ (id)getCacheUserLocation
{
#if LBSWITHOUTCACHE
    return nil;
#else
    NSString* filePath = [self sillyChatCacheFilePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/userLocation",filePath];
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFileNoException:fileName];
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return object;
#endif
}

+ (id)getCacheGeoPoiResult
{
#if LBSWITHOUTCACHE
    return nil;
#else
    NSString* filePath = [self sillyChatCacheFilePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/geoPoiResult",filePath];
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFileNoException:fileName];
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return object;
#endif
}

+ (NSString*)sillyChatCacheFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* doc = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/contents", doc];
    DPTrace("\nCacheFilePath: %@\n",path);
    return path;
}
@end
