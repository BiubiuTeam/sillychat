//
//  DPDeviceHelper.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPDeviceHelper : NSObject

+ (NSString*) cacheFolderSize;
+ (BOOL)biubiuUpdateAppStoreVersion;

+ (void) installAppNewVersionFromPGY;
+ (void) openDetailsOfAppFromPGY;

@end
