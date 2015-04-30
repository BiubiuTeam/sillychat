//
//  NSKeyedUnarchiver+ExceptionCatch.m
//  biubiu
//
//  Created by haowenliang on 14-6-15.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "NSKeyedUnarchiverAdditions.h"

@implementation NSKeyedUnarchiver (ExceptionCatch)

+ (id)unarchiveObjectWithDataNoException:(NSData *)data
{
    id retData = nil;
	@try {
		retData = [self unarchiveObjectWithData:data];
	}
	@catch (NSException * e) {
		NSString *err = [e reason];
		if (err != nil) {
		}else {
        }
        // 要是有异常，就要返回nil指针
        retData = nil;
	}
    @catch (...) {
        // 要是有异常，就要返回nil指针
        retData = nil;
    }
	return retData;
}

+ (id)unarchiveObjectWithFileNoException:(NSString *)path
{
	id retData = nil;
	@try {
        if (path == nil)
            return nil;
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (isFileExist) {
            //耗时13％
            retData = [self unarchiveObjectWithFile:path];
            if (retData == nil) {
            }
        }
        else {}
	}
	@catch (NSException * e) {
		NSString *err = [e reason];
		if (path != nil && err != nil){
		} else if (path != nil) {
		} else if (err != nil) {
		}else { }
        
        // 要是有异常，就要返回nil指针
        retData = nil;
        // 要不要把文件删了。。。
	}
    @catch (...) {
        // 要是有异常，就要返回nil指针
        retData = nil;
        // 要不要把文件删了。。。
    }
	return retData;
}


@end
