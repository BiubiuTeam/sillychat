//
//  SillyUserModel.h
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "JSONModel+Encoder.h"

@interface SillyUserModel : JSONModel

@property (nonatomic, strong) NSNumber* statusCode;
@property (nonatomic, strong) NSString<Optional>* statusInfo;

@property (nonatomic, strong) NSNumber* userConfig;

@property (nonatomic, strong) NSString* city;

@property (nonatomic, strong) NSNumber* latitude;

@property (nonatomic, strong) NSNumber* longitude;

@end
