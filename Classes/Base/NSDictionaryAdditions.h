//
//  NSDictionaryAdditions.h
//  biubiu
//
//  Created by haowenliang on 15/2/2.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)
- (NSString*)jsonStringWithPrettyPrint:(BOOL) prettyPrint;
- (NSData*)dataWithPrettyPrint:(BOOL) prettyPrint;
@end
