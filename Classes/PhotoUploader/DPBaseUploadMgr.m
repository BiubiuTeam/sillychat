//
//  DPBaseUploadMgr.m
//  ImageCGIUploadDemo
//
//  Created by haowenliang on 14-8-31.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBaseUploadMgr.h"

#define MaxUploadTaskNumber (1)

static DPBaseUploadMgr* dInstance = nil;

@interface DPBaseUploadMgr()<DPBaseUploaderProtocol>
{
    BOOL _canStartNext;
    NSMutableDictionary *_fileTmepPathDic;
    NSMutableArray * _uploadReqs;
    NSMutableDictionary* _tagToImageDic;
    
    NSMutableArray *_serverList;
}

@property (nonatomic, retain) NSMutableDictionary* fileTempPathDic;
@property (nonatomic, retain) NSMutableArray* uploadReqs;
@property (nonatomic, retain) NSMutableDictionary* tagToImageDic;

//服务器列表，如果是支持多个服务器上传，轮询，避免某个服务器挂掉
@property (nonatomic, retain) NSMutableArray* serverList;


- (void)excuteNextUpload;
@end


@implementation DPBaseUploadMgr

+ (DPBaseUploadMgr *)shareInstance
{
    if (dInstance == nil) {
        dInstance = [[DPBaseUploadMgr alloc] init];
    }
    return dInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _uploadQueue = [[NSMutableArray alloc]init];
        _uploadReqs = [[NSMutableArray alloc] init];
        _fileTmepPathDic = [[NSMutableDictionary alloc]initWithCapacity:8];
        _tagToImageDic = [[NSMutableDictionary alloc]initWithCapacity:8];
        _canStartNext = YES;
        _conCurrentUploading = 0;
        _delegate = nil;
    }
    
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.uploadQueue = nil;
    self.fileTempPathDic = nil;
    self.uploadReqs = nil;
    self.serverList = nil;
    self.tagToImageDic = nil;

#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark -----Functions-----
- (NSArray *)getAllTaskResultInformation
{
    @synchronized(_uploadQueue){
        if (!_uploadQueue || [_uploadQueue count] < 1) {
            return @[];
        }
        NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:1];
        NSUInteger count = [_uploadQueue count];
        for (NSUInteger i = 0;i<count;i++)
        {
            id obj = [_uploadQueue objectAtIndex:i];
            if ([obj isKindOfClass:[DPBaseUploader class]])
            {
                DPBaseUploader *uptask = (DPBaseUploader *)obj;
                if([uptask isTaskFinishUpload] && [uptask.resultInfo count])
                {
                    [arr addObject:uptask.resultInfo];
                }
            }
        }
#if ! __has_feature(objc_arc)
        return [arr autorelease];
#endif
        return arr;
    }
}

- (NSInteger)getUploadTaskCount
{
    return [_uploadQueue count];
}

- (BOOL)isAllTaskFinishUpload
{
    NSUInteger count = [_uploadQueue count];
    for (NSUInteger i = 0;i<count;i++)
    {
        id obj = [_uploadQueue objectAtIndex:i];
        if ([obj isKindOfClass:[DPBaseUploader class]])
        {
            DPBaseUploader *uptask = (DPBaseUploader *)obj;
            if(NO == [uptask isTaskFinishUpload])
            {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark ----Add Operations----
- (NSInteger)addTaskWithPhotoTask:(DPBaseUploader*)task
{
    NSInteger ret = 0;
    if (!task) return ret;
    DPBaseUploader *taskTmp = [self findUploaderByTag:task.taskTag];
    if (!taskTmp) {
        task.delegate = self;
        [_uploadQueue addObject:task];
        [self excuteNextUpload];
        ret = task.taskTag;
    }else{
        ret = taskTmp.taskTag;
    }
    return ret;
}

#pragma mark ----Cancel Operations----
- (void)cancelTaskbyTag:(NSInteger)tag
{
    _canStartNext = NO;
    NSArray* tmpDown = [_uploadQueue copy];
    for (id obj in tmpDown)
    {
        if ([obj isKindOfClass:[DPBaseUploader class]])
        {
            DPBaseUploader *task = (DPBaseUploader *)obj;
            if(task.taskTag == tag)
            {
                if([task isTaskUploading])//如果任务正在上传，后面会取消掉
                {
                    if(_conCurrentUploading > 0)
                        _conCurrentUploading -= 1;
                }
                [task cancelUpLoadWithError:UploadErrorCodeUserCancel];
                [_uploadQueue removeObject:obj];
            }
        }
    }
    _canStartNext = YES;
    _RELEASE(tmpDown);
    [self excuteNextUpload];
}

- (void)cancelAllTask
{
    [self cancelAllTaskWithError:UploadErrorCodeUserCancel];
}

- (void)cancelAllTaskWithError:(UploadErrorCode)error
{
    _canStartNext = NO;
    //停掉所有上传
    NSArray* tmpDown = [_uploadQueue copy];
    for (id obj in tmpDown)
    {
        if ([obj isKindOfClass:[DPBaseUploader class]])
        {
            DPBaseUploader *task = (DPBaseUploader *)obj;
            [task cancelUpLoadWithError:error];
        }
    }
    [_uploadQueue removeAllObjects];
    _conCurrentUploading = 0;
    _canStartNext = YES;
    _RELEASE(tmpDown);
}

- (void)cancelTaskbyIndexSet:(NSIndexSet *)indexSet
{
    @synchronized(_uploadQueue){
        NSArray* tmpQueue = [_uploadQueue copy];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            id obj = [tmpQueue objectAtIndex:idx];
            if ([obj isKindOfClass:[DPBaseUploader class]])
            {
                DPBaseUploader *uptask = (DPBaseUploader *)obj;
                [self cancelTaskbyTag:uptask.taskTag];
            }
        }];
        _RELEASE(tmpQueue);
    }
}

- (void)cancelRestTask:(NSInteger)countLeft
{
    NSArray* tmpDown = [_uploadQueue copy];
    if(countLeft > tmpDown.count)
    {
        _RELEASE(tmpDown);
        return;
    }
    for (NSInteger i=0;i<tmpDown.count;i++)
    {
        if(i>=countLeft)
        {
            id obj = [tmpDown objectAtIndex:i];
            if ([obj isKindOfClass:[DPBaseUploader class]])
            {
                DPBaseUploader *task = (DPBaseUploader *)obj;
                [self cancelTaskbyTag:task.taskTag];
            }
            [_uploadQueue removeObject:obj];
        }
    }
    _RELEASE(tmpDown);
}

#pragma mark ----Search Operations----
- (DPBaseUploader *)findUploaderByTag:(NSInteger)tag
{
    for (id obj in _uploadQueue)
    {
        if ([obj isKindOfClass:[DPBaseUploader class]])
        {
            DPBaseUploader *task = (DPBaseUploader *)obj;
            if(task.taskTag == tag)
            {
                return task;
            }
        }
    }
    return nil;
}

- (DPBaseUploader *)getUploaderAtIndex:(NSInteger)index
{
    if (index >= [self getUploadTaskCount]) return nil;
    return [_uploadQueue objectAtIndex:index];
}

#pragma mark ----Excute Operations----
- (void)excuteNextUpload
{
    if (!_canStartNext)
        return;
//    if ([AKNetworkReachability networkStatus] == NotReachable)
//    {
//        return;
//    }
    
    NSUInteger count = [_uploadQueue count];
    for (NSUInteger i = 0;i<count;i++)
    {
        if (_conCurrentUploading >= MaxUploadTaskNumber)
        {
            return;
        }
        id obj = [_uploadQueue objectAtIndex:i];
        if ([obj isKindOfClass:[DPBaseUploader class]])
        {
            DPBaseUploader *uptask = (DPBaseUploader *)obj;
            if([uptask canStartUpload])
            {
                //只有还没有启动的task才能调用start,在start方法中也做了这种判断
                _conCurrentUploading ++;
                [uptask startUpLoad];
            }
        }
    }
}

#pragma mark ----Uploader Delegate----
/*启动上传任务*/
- (void)onStartUploadTask:(DPBaseUploader*)uploader
{
    //上传非本队列中的文件
    if (![_uploadQueue containsObject:uploader])
    {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(taskUploadMgrOnStartUploadTask:task:)]) {
        [_delegate taskUploadMgrOnStartUploadTask:self task:uploader];
    }
}

/*上传任务进度回调*/
- (void)onUploadingProcess:(DPBaseUploader*)uploader process:(CGFloat)process
{
    if (![_uploadQueue containsObject:uploader])
    {
        return;
    }
    if(process > 1.0)
        process = 1.0;
    
    if (_delegate && [_delegate respondsToSelector:@selector(taskUploadMgrUploadTaskProcess:task:process:)]) {
        [_delegate taskUploadMgrUploadTaskProcess:self task:uploader process:process];
    }
}

/*任务结果回调*/
- (void)onFinishUploadTask:(DPBaseUploader*)uploader info:(NSDictionary*)info
{
    if (![_uploadQueue containsObject:uploader])
    {
        return;
    }
    //为了防止_conCurrentUploading变成负数（正常情况下不会有这样的情况）
    if (![uploader canStartUpload] && _conCurrentUploading > 0)
        _conCurrentUploading--;
    
    if (_delegate && [_delegate respondsToSelector:@selector(taskUploadMgrOnFinishUploadTask:task:info:)]) {
        [_delegate taskUploadMgrOnFinishUploadTask:self task:uploader info:info];
    }
    
    [self excuteNextUpload];//开始执行下一个
}

/*任务取消回调*/
- (void)onCancelUploadTask:(DPBaseUploader*)uploader
{
    if (![_uploadQueue containsObject:uploader])
    {
        return;
    }
    //为了防止_conCurrentUploading变成负数（正常情况下不会有这样的情况）
    if (![uploader canStartUpload] && _conCurrentUploading > 0)
        _conCurrentUploading--;
    
    if (_delegate && [_delegate respondsToSelector:@selector(taskUploadMgrOnCancelUploadTask:task:)]) {
        [_delegate taskUploadMgrOnCancelUploadTask:self task:uploader];
    }
    
    [self excuteNextUpload];//开始执行下一个
}

@end
