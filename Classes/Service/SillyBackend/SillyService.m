//
//  SillyService.m
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyService.h"

#import "SvUDIDTools.h"
#import "NSStringAdditions.h"
#import "NSDictionaryAdditions.h"

#import "DPLbsServerEngine.h"
#import "NSString+Emoji.h"

@interface SillyService ()

@property (nonatomic, strong) NSMutableData* respData;
@property (nonatomic, strong) NSURLConnection* urlconnection;
@end

@implementation SillyService

+ (instancetype)shareInstance
{
    static SillyService* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[SillyService alloc] init];
    });
    return s_instance;
}

#pragma mark -normal request
/**
 *  用户注册
 *
 */
- (void)registSillyUserWithInformation:(NSUInteger)userConfig
                            completion:(JSONObjectBlock)completion

{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x1001] forKey:@"cmd"];
    [body setObject:@(userConfig) forKey:@"userConfig"];
    [body setObject:[[UIDevice currentDevice] name] forKey:@"dvcInfo"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}

/**
 *  用户信息查询
 */
- (void)fetchSillyUserInformation:(NSString*)identifier
                        comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x1002] forKey:@"cmd"];
    if (identifier.length) {
        [body setObject:identifier forKey:@"dvcId"];
    }
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}

/**
 *  搜索广场的广播信息
 *  type : 1 上推拉取更久的信息   2 下拉刷出最新的数据
 */
- (void)fetchNearbySillyBroacast:(NSInteger)type
                   startPosition:(NSInteger)position
                       comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2001] forKey:@"cmd"];
    [body setObject:@(type) forKey:@"IdType"];
    [body setObject:@(position) forKey:@"lastId"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}

/**
 *  搜索广场的广播信息
 *  filter: 最低位0全部，1本地,第二第三位，00全部，01男，10女
 *  msgTag: 信息标签
 */
- (void)fetchNearbySillyBroacast:(NSUInteger)filter
                          msgTag:(NSUInteger)msgTag
                       comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2001] forKey:@"cmd"];
    [body setObject:@(msgTag) forKey:@"msgTag"];
    [body setObject:@(filter) forKey:@"filter"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}

/**
 *  发布广播消息
 */
- (void)sendBroacastToPlaza:(BroacastType)titleType
               titleContent:(NSString*)content
                  comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2002] forKey:@"cmd"];
    [body setObject:@(titleType) forKey:@"titleType"];
    [body setObject:@(3) forKey:@"msgTag"];
    
    [body setObject:[content stringByReplacingEmojiUnicodeWithCheatCodes] forKey:@"titleCont"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}

- (void)sendBroacastToPlaza:(BroacastType)titleType
               titleContent:(NSString*)content
                     msgTag:(NSUInteger)msgTag
                  extension:(NSDictionary*)extension
                  comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2002] forKey:@"cmd"];
    [body setObject:@(titleType) forKey:@"titleType"];
    [body setObject:@(msgTag) forKey:@"msgTag"];
    [body setObject:[content stringByReplacingEmojiUnicodeWithCheatCodes] forKey:@"titleCont"];
    
    if([extension count]){
        [body setObject:extension forKey:@"extension"];
    }
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}
/**
 *  正反向关系链写入
 *
 */
- (void)markRelationshipToDevice:(NSString*)toDevice
                        linkType:(BroacastType)titleType
                    titleContent:(NSString*)content
                       comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2003] forKey:@"cmd"];
    [body setObject:@(titleType) forKey:@"titleType"];
    [body setObject:[content stringByReplacingEmojiUnicodeWithCheatCodes] forKey:@"titleCont"];
    [body setObject:toDevice forKey:@"toDvcId"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}

- (void)markRelationshipToDeviceWithBroadCast:(NSNumber*)titleId
                                     toDevice:(NSString *)toDevice
                                    comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2003] forKey:@"cmd"];
    [body setObject:toDevice forKey:@"toDvcId"];
    [body setObject:titleId forKey:@"titleId"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}
/**
 *  关系链查询
 *
 */
- (void)fetchSillyUserRelationships:(NSInteger)type
                      startPosition:(NSInteger)position
                          comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2004] forKey:@"cmd"];
    [body setObject:@(type) forKey:@"IdType"];
    [body setObject:@(position) forKey:@"lastId"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}


/**
 *  拉取随机文案
 */
- (void)fetchRandomMessage:(BroacastType)preType
                 comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2005] forKey:@"cmd"];
    [body setObject:@(preType) forKey:@"preTitleType"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}

- (void)reportContentOptWithId:(NSUInteger)contId
                   contentType:(ReportType)contType
                        reason:(ReportReasonType)reason
                    reasonCont:(NSString*)reasonCont
                     comletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x5001] forKey:@"cmd"];
    
    [body setObject:@(contType) forKey:@"contType"];
    [body setObject:@(reason) forKey:@"reason"];
    if (reasonCont.length) {
        [body setObject:reasonCont forKey:@"reasonCont"];
    }
    [body setObject:@(contId) forKey:@"contId"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if(completion){
            completion(json,err);
        }
    }];
}
#pragma mark -private methods

- (void)postRequestWithBody:(NSString*)bodyString
                 completion:(JSONObjectBlock)completeBlock
{
    [JSONHTTPClient setTimeoutInSeconds:15];
    [JSONHTTPClient postJSONFromURLWithString:SillChat_CGI bodyString:bodyString completion:^(id json, JSONModelError *err) {
        if (completeBlock) {
            completeBlock(json, err);
        }
    }];
}

- (void)postRequestWithBodyDictionary:(NSDictionary*)bodyDict
                           completion:(JSONObjectBlock)completeBlock
{
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:bodyDict];
    //自动填充：device identifier , latitude, logitude , city
    if(![body objectForKey:@"dvcId"]){
        [body setObject:[SillyService sillyDeviceIdentifier] forKey:@"dvcId"];
    }
    CLLocationCoordinate2D locationCorrrdinate = [[DPLbsServerEngine shareInstance] userLocation].location.coordinate;
    if (CLLocationCoordinate2DIsValid(locationCorrrdinate)) {
        [body setObject:@(abs(locationCorrrdinate.latitude*1000000)) forKey:@"latitude"];
        [body setObject:@(abs(locationCorrrdinate.longitude*1000000)) forKey:@"longitude"];
    }
    if([[[DPLbsServerEngine shareInstance] city] length]){
        [body setObject:[[DPLbsServerEngine shareInstance] city] forKey:@"city"];
    }
    
    //填充appVersion, platform
    [body setObject:@"iOS" forKey:@"platform"];
    [body setObject:[SillyService appVersion] forKey:@"appVersion"];
    
    //转换字符串
    NSString* jsonString = [body jsonStringWithPrettyPrint:NO];
    DPTrace("%@命令请求",[NSString hexValue:[bodyDict objectForKey:@"cmd"]]);
    DPTrace("\n请求body：\n%@\n",jsonString);
    [self postRequestWithBody:jsonString completion:completeBlock];
}

+ (NSString*)sillyDeviceIdentifier
{
    NSString* udidStr = [SvUDIDTools UDID];
    return [NSString stringWithFormat:@"sillychat-%@",udidStr];
}

+ (NSString*)appVersion
{
    static NSString *version = nil;
    if (!version.length) {
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    
    return version;
}

@end
