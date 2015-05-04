//
//  SillyRelationshipModel.h
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "JSONModel+Encoder.h"
#import "SillyBroacastModel.h"

@protocol SillyRelationshipModel
@end

@interface SillyRelationshipModel : JSONModel

@property (nonatomic, strong) NSNumber* sortId;
@property (nonatomic, strong) SillyBroacastModel<Optional,ConvertOnDemand>* broadcastModel;

//本地标志
@property (nonatomic, strong) NSNumber<Ignore>* localTemp;
@property (nonatomic, strong) NSNumber<Ignore>* hasUnreadMessage;

+ (instancetype)newRelationShipModelWithBroadcast:(SillyBroacastModel*)broadcast;
@end


////////////////////////////

@interface SillyRelationshipResponseModel : JSONModel

@property (nonatomic, strong) NSNumber* statusCode;
@property (nonatomic, strong) NSString<Optional>* statusInfo;

@property (nonatomic, strong) NSArray<SillyRelationshipModel,Optional,ConvertOnDemand>* relationships;

@end