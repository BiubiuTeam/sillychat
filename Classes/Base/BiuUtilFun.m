//
//  BiuUtilFun.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//


#import "BiuUtilFun.h"
#import <CommonCrypto/CommonDigest.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <netinet/in.h>
#import <arpa/inet.h>

#import <Accelerate/Accelerate.h>

static const void* DPRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void DPReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray* DPCreateNonRetainingArray() {
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.retain = DPRetainNoOp;
    callbacks.release = DPReleaseNoOp;
    return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

static const char kTCHexCharTable[] = "0123456789ABCDEF";

@implementation DPUtilFun

+ (NSString *)HexStrFromBuff:(const char *)pcBuf length:(int)nBufLen
{
    NSString *hexStr = nil;
    if (!pcBuf || nBufLen <= 0)
    {
        return hexStr;
    }
    
    char *cstrHex = malloc(nBufLen * 2 + 1);
    if (cstrHex)
    {
        int nData = 0;
        char *pcHex = cstrHex;
        for (int i = 0; i < nBufLen; ++i)
        {
            nData = (pcBuf[i] & 0x0ff);
            (*pcHex) = kTCHexCharTable[(nData & 0x0f0) >> 4];
            ++pcHex;
            (*pcHex) = kTCHexCharTable[nData & 0x0f];
            ++pcHex;
        }
        (*pcHex) = '\0';
        
        hexStr = [NSString stringWithUTF8String:cstrHex];
        free(cstrHex);
    }
    
    return hexStr;
}

//从字符串中取字节数组
+(NSData*)HexStrToBuff:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1 = 0;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2 = 0;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

+ (NSString *)MD5Hash:(NSString *)plaintext
{
    if (0 == plaintext.length)
    {
        return nil;
    }
    
    NSData *plainData = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([plainData bytes], (CC_LONG)[plainData length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

//关于Invoke的获取返回值的通用方法
+ (id)returnValueOfInvoke:(NSInvocation*)invoke
{
    if (!invoke) {
        return nil;
    }
    const char *returnType  = invoke.methodSignature.methodReturnType;
    id          returnValue = nil;
    
    if( !strcmp(returnType, @encode(void))) {
        return nil;
    }
    
    if( !strcmp(returnType, @encode(id)) ){
        [invoke getReturnValue:&returnValue];
        return returnValue;
    }
    
    NSUInteger  length      = [invoke.methodSignature methodReturnLength];
    void        *retvBuffer = (void *)malloc(length);
    
    memset(retvBuffer, 0, length);
    [invoke getReturnValue:retvBuffer];
    
    if(0 == strcmp(returnType, @encode(BOOL))) {
        returnValue = [NSNumber numberWithBool:*((BOOL*)retvBuffer)];
    }
    else if(0 == strcmp(returnType, @encode(unsigned int))) {
        returnValue = [NSNumber numberWithUnsignedInt:*((unsigned int*)retvBuffer)];
    }
    else if(0 == strcmp(returnType, @encode(long long))) {
        returnValue = [NSNumber numberWithLongLong:*((long long*)retvBuffer)];
    }
    else if(0 == strcmp(returnType, @encode(double))) {
        returnValue = [NSNumber numberWithDouble:*((double*)retvBuffer)];
    }
    else if(0 == strcmp(returnType, @encode(NSInteger))) {
        returnValue = [NSNumber numberWithInteger:*((NSInteger*)retvBuffer)];
    }
    else {
        returnValue = [NSValue valueWithBytes:retvBuffer objCType:returnType];
    }
    
    free(retvBuffer);
    return returnValue;
}

@end


@implementation NSString(HexHelper)

-(NSData*)HexStrToBuff
{
    if (self.length <= 0)
    {
        return nil;
    }
    return [DPUtilFun HexStrToBuff:self];
}

@end
