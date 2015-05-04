//
//  SillyService.h
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONAPI.h"

#import "ServiceConstants.h"
#import "SillyBroacastModel.h"
#import "SillyUserModel.h"
#import "SillyRelationshipModel.h"
#import "SillyResponseModel.h"
#import "SillyRandomMsgModel.h"

//举报类型：针对广播内容、针对用户
typedef NS_ENUM(NSUInteger, ReportType) {
    ReportType_Cont = 1,
    ReportType_User = 2,
};

//举报原因：广播内容、聊天骚扰
typedef NS_ENUM(NSUInteger, ReportReasonType) {
    ReportReasonType_Content = 0,
    ReportReasonType_Chat = 1,
};

//与后台的请求交互
/**
 case 0x1001:$res = execCmd_1001();break; //用户注册
 case 0x1002:$res = execCmd_1002();break; //用户信息查询
	
 case 0x2001:$res = execCmd_2001();break; //搜索附近无聊信息
 case 0x2002:$res = execCmd_2002();break; //无聊消息发布
 case 0x2003:$res = execCmd_2003();break; //正反向关系链写入
 case 0x2004:$res = execCmd_2004();break; //关系链查询
 case 0x2005:$res = execCmd_2005();break; //预设消息拉取
 case 0x5001:$res = execCmd_5001();break; //举报
 */
#define SillChat_CGI (@"http://183.131.76.109/cgi_wl/user_svc.php")

@interface SillyService : NSObject

+ (instancetype)shareInstance;

/**
 *  用户注册
 *
 */
- (void)registSillyUserWithInformation:(NSUInteger)userConfig
                            completion:(JSONObjectBlock)completion;


/**
 *  用户信息查询
 */
- (void)fetchSillyUserInformation:(NSString*)indentifier
                        comletion:(JSONObjectBlock)completion;

/**
 *  搜索广场的广播信息
 *  type : 1 上推拉取更久的信息   2 下拉刷出最新的数据
 */
- (void)fetchNearbySillyBroacast:(NSInteger)type
                   startPosition:(NSInteger)position
                       comletion:(JSONObjectBlock)completion SC_DEPRECATED_IOS(1.0,1.0,@"use fetchNearbySillyBroacast:msgTag:comletion:");
/**
 *  搜索广场的广播信息
 *  filter: 最低位0全部，1本地,第二第三位，00全部，01男，10女
 *  msgTag: 信息标签
 */
- (void)fetchNearbySillyBroacast:(NSUInteger)filter
                          msgTag:(NSUInteger)msgTag
                       comletion:(JSONObjectBlock)completion;
/**
 *  发布广播消息
 */
- (void)sendBroacastToPlaza:(BroacastType)titleType
               titleContent:(NSString*)content
                  comletion:(JSONObjectBlock)completion SC_DEPRECATED_IOS(1.0,1.0,@"use sendBroacastToPlaza:titleContent:msgTag:extension:comletion:");

- (void)sendBroacastToPlaza:(BroacastType)titleType
               titleContent:(NSString*)content
                     msgTag:(NSUInteger)msgTag
                  extension:(NSDictionary*)extension
                  comletion:(JSONObjectBlock)completion;

/**
 *  正反向关系链写入
 *
 */
- (void)markRelationshipToDevice:(NSString*)toDevice
                        linkType:(BroacastType)titleType
                    titleContent:(NSString*)content
                       comletion:(JSONObjectBlock)completion SC_DEPRECATED_IOS(1.0,1.0,@"use markRelationshipToDeviceWithBroadCast:toDevice:comletion:");

- (void)markRelationshipToDeviceWithBroadCast:(NSNumber*)titleId
                                     toDevice:(NSString*)toDevice
                                    comletion:(JSONObjectBlock)completion;

/**
 *  关系链查询
 *
 */
- (void)fetchSillyUserRelationships:(NSInteger)type
                      startPosition:(NSInteger)position
                          comletion:(JSONObjectBlock)completion;


/**
 *  拉取随机文案
 */
- (void)fetchRandomMessage:(BroacastType)preType
                 comletion:(JSONObjectBlock)completion;

/**
 *  举报 ,用户暂时没做逻辑(2无效)
 */
- (void)reportContentOptWithId:(NSUInteger)contId //对应的Id
                   contentType:(ReportType)contType  //举报内容类型  1举报某个title  2举报某个用户
                        reason:(ReportReasonType)reason //举报原因
                    reasonCont:(NSString*)reasonCont //举报原因的描述
                     comletion:(JSONObjectBlock)completion;
@end
