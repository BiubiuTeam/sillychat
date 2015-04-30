//
//  SillyRelationshipModel.h
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "JSONModel+Encoder.h"
@class SillyBroacastModel;

@protocol SillyRelationshipModel
@end

@interface SillyRelationshipModel : JSONModel

@property (nonatomic, strong) NSNumber* sortId;
@property (nonatomic, strong) NSNumber* titleId;/*关系链对应的广播id*/

@property (nonatomic, strong) NSString* dvcId;
@property (nonatomic, strong) NSNumber* userConfig;
@property (nonatomic, strong) NSString* city;//建立关系城市

@property (nonatomic, strong) NSNumber* latitude;
@property (nonatomic, strong) NSNumber* longitude;

@property (nonatomic, strong) NSString* titleCont;

@property (nonatomic, strong) NSNumber* titleType;//1文字，2语音，3图片，4表情
@property (nonatomic, strong) NSNumber* pubTime;

//本地标志
@property (nonatomic, strong) NSNumber<Ignore>* localTemp;
@property (nonatomic, strong) SillyBroacastModel<Ignore>* broadcastModel;

@property (nonatomic, strong) NSNumber<Ignore>* hasUnreadMessage;
+ (instancetype)newRelationShipModelWithBroadcast:(SillyBroacastModel*)broadcast;
@end


////////////////////////////

@interface SillyRelationshipResponseModel : JSONModel

@property (nonatomic, strong) NSNumber* statusCode;
@property (nonatomic, strong) NSString<Optional>* statusInfo;

@property (nonatomic, strong) NSArray<SillyRelationshipModel,Optional,ConvertOnDemand>* relationships;

@end