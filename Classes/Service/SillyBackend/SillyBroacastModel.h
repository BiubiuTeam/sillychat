//
//  SillyBroacastModel.h
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "JSONModel+Encoder.h"

#import "ServiceConstants.h"

@protocol SillyBroacastModel
@end

@interface SillyBroacastModel : JSONModel

@property (nonatomic, strong) NSNumber* sortId;
@property (nonatomic, strong) NSNumber<Optional>* titleId; /*等价sortid*/

@property (nonatomic, strong) NSString* dvcId;
@property (nonatomic, strong) NSNumber* userConfig;

@property (nonatomic, strong) NSString* titleCont;

@property (nonatomic, strong) NSNumber* titleType;//1文字，2语音，3图片，4表情
@property (nonatomic, strong) NSNumber* pubTime;

@property (nonatomic, strong) NSDictionary<Optional>* extension;//字典数据，字符串格式
@property (nonatomic, strong) NSNumber* blockLen; //数据长度，UI展示用
@end


////////////////////////////

@interface SillyBroacastResponseModel : JSONModel

@property (nonatomic, strong) NSNumber* statusCode;
@property (nonatomic, strong) NSString<Optional>* statusInfo;

@property (nonatomic, strong) NSString<Optional>* city;
@property (nonatomic, strong) NSNumber<Optional>* lineLen; //行长度（每行分成几份）
@property (nonatomic, strong) NSNumber<Optional>* lineNum; //行数（有几行）
@property (nonatomic, strong) NSArray<SillyBroacastModel,Optional,ConvertOnDemand>* broacastArray;

@end