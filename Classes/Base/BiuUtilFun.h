//
//  BiuUtilFun.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//


#import <Foundation/Foundation.h>

#ifndef UTF8STRING_NOT_NULL
#define UTF8STRING_NOT_NULL(s) (s ? [s UTF8String] : "")
#endif

#ifndef CSTRING_NOT_NULL
#define CSTRING_NOT_NULL(s) (s ? s : "")
#endif

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
#ifdef __cplusplus
extern "C" {
#endif
    NSMutableArray* DPCreateNonRetainingArray();
#ifdef __cplusplus
}
#endif

@interface DPUtilFun : NSObject

+ (NSString *)HexStrFromBuff:(const char *)pcBuf length:(int)nBufLen;
+ (NSData*)HexStrToBuff:(NSString*)string;
+ (NSString *)MD5Hash:(NSString *)plaintext;

+ (id)returnValueOfInvoke:(NSInvocation*)invoke;
@end


@interface NSString(HexHelper)

-(NSData*)HexStrToBuff;
@end
