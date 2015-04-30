//
//  SvUDIDTools.h
//  SvUDID
//
//  Created by  maple on 8/18/13.
//  Copyright (c) 2013 maple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SvUDIDTools : NSObject

/*
 * @brief obtain Unique Device Identity
 */
+ (NSString*)UDID;

/*
 * @brief is the string equal to UDID
 */
+ (BOOL)isEqualToUdid:(NSString*)identifier;

@end
