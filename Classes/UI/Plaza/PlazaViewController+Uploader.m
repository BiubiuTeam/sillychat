//
//  PlazaViewController+Uploader.m
//  sillyChat
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//
#import "PlazaViewController+Uploader.h"
#import "PlazaViewController+Service.h"
#import "DPPhotoUploader.h"
#import "DPAudioUploader.h"
#import <SDWebImage/SDImageCache.h>
#import "SillyVoiceCache.h"
#import "UIImage+Helper.h"
#import "PlazaFilterButton.h"

@implementation PlazaViewController (Uploader)

- (void)addPhotoUploadTask:(UIImage*)photo
{
    [self addPhotoUploadTask:photo withExtension:nil];
}

- (void)addPhotoUploadTask:(UIImage*)photo withExtension:(NSDictionary*)extension
{
    DPPhotoUploader* uploader = [[DPPhotoUploader alloc] init];
    uploader.resultType = UploadResultType_String;
    [uploader createRequestWithImage:photo];
    
    uploader.extensionInfo = extension;
    [[DPBaseUploadMgr shareInstance] addTaskWithPhotoTask:uploader];
    
    _filterButton.uploaderTag = uploader.taskTag;
    [_filterButton setUploadImage:photo];
    [_filterButton setEyeType:EyeType_Custom];
}

- (void)addAudioFileUploadTask:(NSString*)localPath withExtension:(NSDictionary*)extension
{
    DPAudioUploader* uploader = [[DPAudioUploader alloc] init];
    uploader.resultType = UploadResultType_String;
    [uploader createRequestWithLocalPath:localPath];
    uploader.extensionInfo = extension;
    
    [[DPBaseUploadMgr shareInstance] addTaskWithPhotoTask:uploader];
}

#pragma mark - uploader delegate
- (void)taskUploadMgrOnStartUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task
{
    
}

- (void)taskUploadMgrUploadTaskProcess:(DPBaseUploadMgr *)manager task:(DPBaseUploader*)task process:(CGFloat)process
{
    switch (task.contentType) {
        case UploadContentType_File:
        {
            
        } break;
        case UploadContentType_Image:
        {
            NSLog(@"****图片上传进度：%f",process);
            if (_filterButton.uploaderTag == task.taskTag) {
                _filterButton.progress = process;
            }
        } break;
        case UploadContentType_Audio:
        {
            NSLog(@"****音频上传进度：%f",process);
        } break;
        case UploadContentType_Video:
        {
            
        } break;
        default:
            break;
    }
}

- (void)taskUploadMgrOnFinishUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task info:(NSDictionary*)info
{
    switch (task.contentType) {
        case UploadContentType_File:
        {
            
        } break;
        case UploadContentType_Image:
        {
            NSLog(@"*****图片上传结果：%@",info);
            if (info) {
                if (_filterButton.uploaderTag == task.taskTag) {
                    [_filterButton resetEyeType];
                    [_filterButton setEyeType:EyeType_Succeed];
                }
                //上传成功
                NSString* picPath = [info objectForKey:@"return_string"];
                [self postImageBroadcast:picPath withExtension:task.extensionInfo];
                
                //store the image
                DPPhotoUploader* uploader = (DPPhotoUploader*)task;
                [[SDImageCache sharedImageCache] storeImage:[UIImage fixOrientation:uploader.uploadContent] forKey:picPath toDisk:YES];
            }else{
                if (_filterButton.uploaderTag == task.taskTag) {
                    [_filterButton resetEyeType];
                    [_filterButton setEyeType:EyeType_Failed];
                }
                //上传失败了
                if (self.postOptComletionCallback) {
                    self.postOptComletionCallback(NO, nil);
                }
                self.postOptComletionCallback = nil;
            }
        } break;
        case UploadContentType_Audio:
        {
            DPTrace(@"*****音频上传结果：%@",info);
            if (info) {
                //上传成功
                NSString* audioPath = [info objectForKey:@"return_string"];
                [self postAudioBroadcast:audioPath withExtension:task.extensionInfo];
                
                @autoreleasepool {
                    //记录映射对象
                    DPAudioUploader* uptast = (DPAudioUploader*)task;
                    NSString* localPath = uptast.localPath;
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:localPath];
                    [[SillyVoiceCache sharedVoiceCache] storeVoiceData:data forKey:audioPath];
                }
            }else{
                DPTrace("语音上传失败");
            }
        } break;
        case UploadContentType_Video:
        {
            
        } break;
        default:
            break;
    }
}

- (void)taskUploadMgrOnCancelUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task
{
    switch (task.contentType) {
        case UploadContentType_File:
        {
            
        } break;
        case UploadContentType_Image:
        {
            if (_filterButton.uploaderTag == task.taskTag) {
                [_filterButton resetEyeType];
            }
            
            if (self.postOptComletionCallback) {
                self.postOptComletionCallback(NO, nil);
            }
            self.postOptComletionCallback = nil;
        } break;
        case UploadContentType_Audio:
        {
            
        } break;
        case UploadContentType_Video:
        {
            
        } break;
        default:
            break;
    }
}

@end
