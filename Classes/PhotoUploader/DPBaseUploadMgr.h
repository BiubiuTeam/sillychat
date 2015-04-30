//
//  DPBaseUploadMgr.h
//  ImageCGIUploadDemo
//
//  Created by haowenliang on 14-8-31.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPBaseUploader.h"

@class DPBaseUploadMgr;

@protocol DPBaseUploadMgrProtocol <NSObject>
@optional
- (void)taskUploadMgrOnStartUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task;
- (void)taskUploadMgrUploadTaskProcess:(DPBaseUploadMgr *)manager task:(DPBaseUploader*)task process:(CGFloat)process;
- (void)taskUploadMgrOnFinishUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task info:(NSDictionary*)info;
- (void)taskUploadMgrOnCancelUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task;

@end


@interface DPBaseUploadMgr : NSObject
{
    NSMutableArray* _uploadQueue;       //  上传队列
    int32_t _conCurrentUploading;
}

@property(nonatomic,assign) id<DPBaseUploadMgrProtocol> delegate;
@property(nonatomic,retain) NSMutableArray* uploadQueue;
@property(nonatomic,assign) int32_t conCurrentUploading;

/*单例模式*/
+ (DPBaseUploadMgr*)shareInstance;
/*添加上传任务*/
- (NSInteger)addTaskWithPhotoTask:(DPBaseUploader*)task;
/*取消所有任务*/
- (void)cancelAllTask;
/*取消所有任务，标志错误码*/
- (void)cancelAllTaskWithError:(UploadErrorCode)error;
/*获取当前上传任务数*/
- (NSInteger)getUploadTaskCount;
/*取消countLeft后面的任务*/
- (void)cancelRestTask:(NSInteger)countLeft;
/*获取所有任务的上传结果数据*/
- (NSArray*)getAllTaskResultInformation;
/*获取第index个上传任务*/
- (DPBaseUploader* )getUploaderAtIndex:(NSInteger)index;
/*根据任务索引获取任务*/
- (DPBaseUploader* )findUploaderByTag:(NSInteger)tag;
/*根据任务索引取消任务*/
- (void)cancelTaskbyTag:(NSInteger)tag;
/*取消任务集合*/
- (void)cancelTaskbyIndexSet:(NSIndexSet *)indexSet;
/*判断任务队列是否完成上传*/
- (BOOL)isAllTaskFinishUpload;

@end
