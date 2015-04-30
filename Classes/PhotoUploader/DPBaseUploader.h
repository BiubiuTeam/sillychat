//
//  DPBaseUploader.h
//  ImageCGIUploadDemo
//
//  Created by haowenliang on 14-8-28.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    UPLOAD_STATE_NONE = 0,         //没有上传状态
    UPLOAD_STATE_WAITING = 1,      //等待上传
    UPLOAD_STATE_UPLOADING = 2,    //上传中
    UPLOAD_STATE_SUCCEED = 3,      //上传成功
    UPLOAD_STATE_CANCEL = 4,       //上传取消
    UPLOAD_STATE_FAILED = -1,       //上传失败
}UPLOAD_STATE; //图片上传状态

//上传错误码
typedef enum
{
    UploadErrorCodeSuccess = 0,             //成功
    UploadErrorCodeTimeOut = 1,             //超时
    UploadErrorCodeRespError = 2,           //服务器回包错误
    UploadErrorCodeUserCancel = 3,          //用户取消
    UploadErrorCodeError = 4,               //其他错误
}UploadErrorCode;


@class DPBaseUploader;
@protocol DPBaseUploaderProtocol <NSObject>
@optional
/*启动上传任务*/
- (void)onStartUploadTask:(DPBaseUploader*)uploader;
/*上传任务进度回调*/
- (void)onUploadingProcess:(DPBaseUploader*)uploader process:(CGFloat)process;
/*任务结果回调*/
- (void)onFinishUploadTask:(DPBaseUploader*)uploader info:(NSDictionary*)info;
/*任务取消回调*/
- (void)onCancelUploadTask:(DPBaseUploader*)uploader;
@end

typedef NS_ENUM(NSUInteger, UploadResultType) {
    UploadResultType_Dictionary,
    UploadResultType_String,
    UploadResultType_Array,
};

typedef NS_ENUM(NSUInteger, UploadContentType) {
    UploadContentType_File = 0, //普通文件
    UploadContentType_Image = 1, //图片
    UploadContentType_Audio = 2, //音频
    UploadContentType_Video = 3, //视频
};

@interface DPBaseUploader : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic,assign) UploadResultType resultType;
@property (nonatomic,assign) UploadContentType contentType;

@property (nonatomic,assign) NSUInteger taskTag;
@property (nonatomic,assign) id<DPBaseUploaderProtocol> delegate;
@property (nonatomic,assign) UploadErrorCode uploadError;
@property (nonatomic,assign) CGFloat process;
@property (nonatomic,retain) NSDictionary* resultInfo;
@property (nonatomic,assign) UPLOAD_STATE uploadState;
@property (nonatomic, retain) NSThread* httpThread;

@property (nonatomic,strong) NSDictionary* extensionInfo;

- (id)initWithDelegate:(id)delegate withThread:(NSThread*)httpThread;

- (BOOL)startUpLoad;
- (BOOL)canStartUpload;
- (BOOL)isTaskUploading;
- (BOOL)isTaskFinishUpload;

/*取消上传任务*/
- (void)cancelUpLoadWithError:(UploadErrorCode)error;

- (NSURLRequest*)getUploadTaskRequest;
@end