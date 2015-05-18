//
//  SillyMediaDevice.m
//  sillyChat
//
//  Created by haowenliang on 15/5/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyMediaDevice.h"

@implementation SillyMediaDevice


+ (void)isCameraAvailable
{
    // 先判断是否访问限制：“通用-访问控制-相机”
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 如果相机能用，则再判断是否隐私限制：“设置-隐私-相机”
        [self deviceHasMediaPrivilege:AVMediaTypeVideo shouldRequestAccessForMedia:YES completion:^(NSInteger authorizationStatus, BOOL granted) {
            if (authorizationStatus != 0 && granted == NO) {
                // 弹出授权提示框
                [self showMediaAuthorizedAlert:NSLocalizedString(@"无法使用相机", @"")
                                       content:NSLocalizedString(@"请在iPhone的\"设置-隐私-相机\"中允许访问相机。",@"")];
            }
        }];
    } else {
        // 弹出提示框打开相机
        [self showMediaAuthorizedAlert:NSLocalizedString(@"无法使用相机",@"")
                               content:NSLocalizedString(@"请在iPhone的\"设置-通用-访问限制-相机\"中允许访问相机。",@"")];
    }
}

+ (void)deviceHasMediaPrivilege:(NSString*)mediaType shouldRequestAccessForMedia:(BOOL)bRequest completion:(void (^)(NSInteger authorizationStatus, BOOL granted))completion
{
    if (SYSTEM_VERSION < 7.0) {
        completion(3, YES);
        return;
    }
    
    //AVAuthorizationStatus
    NSInteger status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (status == 3) {
        //有授权
        completion(status, YES);
    } else if (status == 1 || status == 2) {
        //无权限
        completion(status, NO);
        return;
    } else if (status == 0) {
        // 没检测
        if (bRequest == YES) {
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                
                dispatch_async(dispatch_get_main_queue(), ^() {
                    
                    completion(status, granted);
                });
            }];
        } else {
            completion(status, YES);
        }
    }
}

+ (void)showMediaAuthorizedAlert:(NSString*)title content:(NSString*)content
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:content
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定",@"")
                                              otherButtonTitles:nil];
        [alert show];
    });
}


@end
