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

@property (nonatomic, strong) NSNumber<Optional>* sortId; /*等价titleid*/
@property (nonatomic, strong) NSNumber<Optional>* titleId; /*等价sortid*/

@property (nonatomic, strong) NSString* dvcId;
@property (nonatomic, strong) NSNumber* userConfig;//%2 0男1女 >1 %2 0学生 1上班
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSString* titleCont;

@property (nonatomic, strong) NSNumber* latitude;
@property (nonatomic, strong) NSNumber* longitude;

@property (nonatomic, strong) NSNumber* titleType;//1文字，2语音，3图片，4表情
@property (nonatomic, strong) NSNumber* pubTime;
@property (nonatomic, strong) NSNumber* msgTag;

@property (nonatomic, strong) NSDictionary<Optional>* extension;//字典数据，字符串格式
@property (nonatomic, strong) NSNumber<Optional>* blockLen; //数据长度，UI展示用

@property (nonatomic, strong) NSNumber<Ignore>* isLocalTmp; //只有在本地创建的时候才会设置为YES
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