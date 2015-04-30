//
//  SillyStringMapping.h
//  sillyChat
//
//  Created by haowenliang on 15/4/13.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SillyStringMapping : NSObject

+ (instancetype)shareInstance;

- (NSString*)getMappingStringFromString:(NSString*)fromString;

- (BOOL)mappingString:(NSString*)fromString toString:(NSString*)toString;

@end
