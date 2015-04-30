//
//  DPDeviceHelper.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPDeviceHelper.h"
#import "NSDictionaryAdditions.h"

static NSString* appKeyAtPuGongYing = @"";
static NSString* currentWebVersion = @"";

@implementation DPDeviceHelper

#pragma mark -----------helper----------------
+ (NSString*) cacheFolderSize
{
    NSFileManager  *_manager = [NSFileManager defaultManager];
    NSArray *_cachePaths =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                NSUserDomainMask, YES);
    NSString  *_cacheDirectory = [_cachePaths objectAtIndex:0];
    NSArray  *_cacheFileList;
    NSEnumerator *_cacheEnumerator;
    NSString *_cacheFilePath;
    
    unsigned long long int _cacheFolderSize = 0;
    _cacheFileList = [_manager subpathsAtPath:_cacheDirectory];
    _cacheEnumerator = [_cacheFileList objectEnumerator];
    while (_cacheFilePath = [_cacheEnumerator nextObject])
    {
//        if ([_manager respondsToSelector:@selector(fileAttributesAtPath:traverseLink:)]) {
//            NSDictionary *_cacheFileAttributes = [_manager fileAttributesAtPath: [_cacheDirectory stringByAppendingPathComponent:_cacheFilePath] traverseLink:YES];
//            _cacheFolderSize += [_cacheFileAttributes fileSize];
//        } else
        {
            NSError *error = nil;
            NSDictionary *_cacheFileAttributes = [_manager attributesOfItemAtPath:[_cacheDirectory stringByAppendingPathComponent:_cacheFilePath] error:&error];
            if (_cacheFileAttributes) {
                _cacheFolderSize += [_cacheFileAttributes fileSize];
            } else {
                // handle error found in 'error'
            }
        }
    }
    // 单位是字节
    return [self stringFromFileSize:_cacheFolderSize];
}

+ (NSString *)stringFromFileSize:(unsigned long long int)theSize
{
    float floatSize = theSize;
    if (theSize<1023)
        return([NSString stringWithFormat:@"%llu bytes",theSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
    floatSize = floatSize / 1024;
    
    return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

+ (void)emptyCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray *file = [fileManage subpathsAtPath:documentsDirectory];
    NSError* error = nil;
    for (NSString* tmp in file) {
        BOOL success = [fileManage removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, tmp] error:&error];
        if (!success || error) {
            DPTrace("删除失败：%@",[error description]);
        }
    }
}

+ (void)checkForAppUpdate
{
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/lookup?id=966457609"];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [req setHTTPMethod:@"GET"];
    
    void(^requestBackHandler)(NSURLResponse *,NSData *,NSError *)=^(NSURLResponse *response,NSData *data,NSError *connectionError)
    {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;

        if (200==httpResponse.statusCode)
        {
            if ([data length]) {
                NSError* error = nil;
                NSDictionary *responeDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                
                if (nil == error) {
                    NSArray *configData = [responeDict valueForKey:@"results"];
                    NSString* version = @"";
                    for (id config in configData)
                    {
                        version = [config valueForKey:@"version"];
                    }
                    // app版本
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                    //Check your version with the version in app store
                    if ([version length] && ![version isEqualToString:app_Version])
                    {
                        DPTrace("appstore 最新版本号：%@",version);
                        NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
                        [accountDefaults setObject:version forKey:@"SVR_VERSION"];
                        [accountDefaults synchronize];
                        
                        //post notification
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_VERSION_UPDATE" object:nil userInfo:@{@"VNOTIFICATION_VERSION":version}];
                    }else{
                        DPTrace("no update version");
                    }
                }else{
                    DPTrace("%@",[error description]);
                }
            }
        }
        else if (304==httpResponse.statusCode)
        {
            DPTrace("no update");
        }
        else
        {
            DPTrace("connectionError:%@",[connectionError description]);
        }
    };
    // avaiable in iOS 5.0 or later
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:requestBackHandler];
}

+ (BOOL)biubiuUpdateAppStoreVersion
{

    //local app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *localVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
#if TO_APPSTORE
    //svr 版本
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    NSString* newVersion = [accountDefaults objectForKey:@"SVR_VERSION"];
    
    if ([newVersion length] && ![newVersion isEqualToString:localVersion])
    {
        DPTrace("appstore 最新版本号：%@",newVersion);
        return YES;
    }else{
        DPTrace("no update version, & send a request to check for update");
        [DPDeviceHelper checkForAppAtPGYUpdate];
    }
#else
    if ([currentWebVersion length] && ![currentWebVersion isEqualToString:localVersion])
    {
        DPTrace("appstore 最新版本号：%@",currentWebVersion);
        [DPDeviceHelper checkForAppAtPGYUpdate];
        return YES;
    }else{
        DPTrace("no update version, & send a request to check for update");
        [DPDeviceHelper checkForAppAtPGYUpdate];
    }
#endif
    return NO;
}

+ (void)NewAppKey
{
    NSURL *url = [NSURL URLWithString:@"http://www.pgyer.com/apiv1/app/getAppKeyByShortcut"];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [req setHTTPMethod:@"POST"];
    
    NSString *str = @"shortcut=FSUM&_api_key=b0b245a8c2287c5839e1f3ffec0144b7";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:data];
    
    void(^requestBackHandler)(NSURLResponse *,NSData *,NSError *)=^(NSURLResponse *response,NSData *data,NSError *connectionError)
    {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
        if (200==httpResponse.statusCode)
        {
            if ([data length]) {
                NSError* error = nil;
                NSDictionary *responeDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if (nil == error) {
                    DPTrace("PGYER: %@", responeDict);
                    NSDictionary* subDict = responeDict[@"data"];
                    if ([subDict count]) {
                        NSString* appKey = subDict[@"appKey"];
                        if ([appKey length]) {
                            appKeyAtPuGongYing = appKey;
                        }
                    }
                }else{
                    DPTrace("%@",[error description]);
                }
            }
        }
        else if (304==httpResponse.statusCode){
            DPTrace("no update");
        }else{
            DPTrace("connectionError:%@",[connectionError description]);
        }
        
        [self checkForAppAtPGYUpdateWith:appKeyAtPuGongYing];
    };
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:requestBackHandler];
}

+ (void)checkForAppAtPGYUpdateWith:(NSString*)appKey
{
    NSURL *url = [NSURL URLWithString:@"http://www.pgyer.com/apiv1/app/view"];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [req setHTTPMethod:@"POST"];
    NSString *str = [NSString stringWithFormat:@"aKey=%@&_api_key=b0b245a8c2287c5839e1f3ffec0144b7",appKey];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:data];
    
    void(^requestBackHandler)(NSURLResponse *,NSData *,NSError *)=^(NSURLResponse *response,NSData *data,NSError *connectionError)
    {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
        if (200==httpResponse.statusCode)
        {
            if ([data length]) {
                NSError* error = nil;
                NSDictionary *responeDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if (nil == error) {
                    DPTrace("PGYER: %@", responeDict);
                    NSDictionary* subDict = responeDict[@"data"];
                    if ([subDict count]) {
                        NSString* svrVersion = subDict[@"appVersion"];
                        // app版本
                        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                        //Check your version with the version in app store
                        if ([svrVersion length] && ![svrVersion isEqualToString:app_Version])
                        {
                            NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
                            [accountDefaults setObject:svrVersion forKey:@"SVR_VERSION"];
                            [accountDefaults synchronize];
                            
                            currentWebVersion = svrVersion;
                            //post notification
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_VERSION_UPDATE" object:nil userInfo:@{@"VNOTIFICATION_VERSION":svrVersion}];
                        }
                    }

                }else{
                    DPTrace("%@",[error description]);
                }
            }
        }
        else if (304==httpResponse.statusCode)
        {
            DPTrace("no update");
        }
        else
        {
            DPTrace("connectionError:%@",[connectionError description]);
        }
    };
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:requestBackHandler];
}

static NSDate* date = nil;
+ (void)checkForAppAtPGYUpdate
{
    if (date == nil || abs([date timeIntervalSinceDate:[NSDate date]]) > 3*60) {
        date = [NSDate date];
#if TO_APPSTORE
        [DPDeviceHelper checkForAppUpdate];
#else
        [self NewAppKey];
#endif
    }
}

+ (void) installAppNewVersionFromPGY
{
    if ([appKeyAtPuGongYing length]) {
        //尝试直接可以安装
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.pgyer.com/apiv1/app/install?aKey=%@&_api_key=b0b245a8c2287c5839e1f3ffec0144b7",appKeyAtPuGongYing]];
        [[UIApplication sharedApplication] openURL:url];
    }else{
        [self openDetailsOfAppFromPGY];
    }
}

+ (void) openDetailsOfAppFromPGY
{
    //直接打开安装页面
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.pgyer.com/FSUM"]];
}
@end
