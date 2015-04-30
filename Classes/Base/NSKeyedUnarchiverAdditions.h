//
//  NSKeyedUnarchiver+ExceptionCatch.h
//  biubiu
//
//  Created by haowenliang on 14-6-15.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSKeyedUnarchiver (ExceptionCatch)

+ (id)unarchiveObjectWithDataNoException:(NSData *)data;

+ (id)unarchiveObjectWithFileNoException:(NSString *)path;
@end
