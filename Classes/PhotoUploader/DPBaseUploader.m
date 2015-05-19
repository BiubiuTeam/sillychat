//
//  DPBaseUploader.m
//  ImageCGIUploadDemo
//
//  Created by haowenliang on 14-8-28.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

//#if ! __has_feature(objc_arc)
//#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
//#endif

#import "DPBaseUploader.h"

#define DPDefaultHttpGetTimeOut (30) //get 请求超时30s
#define DPDefaultHttpPostTimeOut (300) //post 请求超时5min
#define DPDefaultRetryTimes (1) //请求重试机制，重试次数

@interface DPBaseUploader ()
{
    NSTimer *_httpPostTimer;
    NSURLConnection *_connection;
    int _uPostCount; //统计重试次数
    BOOL _isTaskFinished;
}

@property (nonatomic, retain) NSTimer* httpPostTimer;
@property (nonatomic, retain) NSURLConnection* connection;

@end

@implementation DPBaseUploader

- (id)init
{
    self = [super init];
    if (self) {
        _contentType = UploadContentType_File;
        _resultType = UploadResultType_Dictionary;
        _isTaskFinished = NO;
        self.taskTag = (NSUInteger)self;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelRetryHttpPost];
    self.resultInfo = nil;
    self.delegate = nil;
    if (self.httpPostTimer && [self.httpPostTimer isValid]) {
        [self.httpPostTimer invalidate];
    }
    self.httpPostTimer = nil;
    if (self.connection) {
        [self.connection cancel];
        self.connection = nil;
    }
    self.httpThread = nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (id)initWithDelegate:(id)delegate withThread:(NSThread *)httpThread
{
    self = [self init];
    if (self) {
        
    }
    return self;
}

- (BOOL)startUpLoad
{
    if(!self.httpThread && _uploadState != UPLOAD_STATE_WAITING)
        return NO;
    _uploadState = UPLOAD_STATE_UPLOADING;
    if ([NSThread currentThread] != self.httpThread)
    {
        [self performSelector:@selector(doRunloop)
                     onThread:self.httpThread
                   withObject:nil
                waitUntilDone:NO];
        return YES;
    }
    return NO;
}

- (void)cancelUpLoadWithError:(UploadErrorCode)error
{
    _uploadState = UPLOAD_STATE_CANCEL;
    _uploadError = error;
    _isTaskFinished = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCancelUploadTask:)])
    {
        id <DPBaseUploaderProtocol>del = self.delegate;
        dispatch_async(dispatch_get_main_queue(), ^{
            [del onCancelUploadTask:self];
        });
    }
    [self stop];
}

- (BOOL)canStartUpload
{
    return (_uploadState == UPLOAD_STATE_WAITING);
}

- (BOOL)isTaskFinishUpload
{
    return (_uploadState != UPLOAD_STATE_WAITING && _uploadState != UPLOAD_STATE_UPLOADING);
}

- (BOOL)isTaskUploading
{
    return (_uploadState == UPLOAD_STATE_UPLOADING);
}

#pragma mark -----time out-----
- (void)stopHttpPostTimer
{
    if (self.httpPostTimer) {
		if ([self.httpPostTimer isValid]) {
			[self.httpPostTimer invalidate];
		}
	}
    self.httpPostTimer = nil;
}

- (void)startHttpPostTimer
{
    [self stopHttpPostTimer];
    self.httpPostTimer = [NSTimer scheduledTimerWithTimeInterval:DPDefaultHttpPostTimeOut target:self selector:@selector(httpPostTimeOut) userInfo:nil repeats:NO];
}

- (void)httpPostTimeOut
{
    [self onErrorFinish:UploadErrorCodeTimeOut];
}

- (void)onErrorFinish:(UploadErrorCode)errCode
{
    _uploadState = UPLOAD_STATE_FAILED;
    _uploadError = errCode;
    _isTaskFinished = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishUploadTask:info:)])
    {
        id <DPBaseUploaderProtocol>del = self.delegate;
        dispatch_async(dispatch_get_main_queue(), ^{
            [del onFinishUploadTask:self info:nil];
        });
    }
    [self stop];
}

#pragma mark -----
- (void)cancelHttpConnection
{
    [self cancelRetryHttpPost];
    if (self.connection)
    {
        [self.connection cancel];
    }
    self.connection = nil;
}

- (void)stop
{
    if (NO == [self isThreadAllRightToPerformSelector:@selector(stop)]) {
        return;
    }
    [self stopHttpPostTimer];
    [self cancelHttpConnection];
}

#pragma mark -----retry policy-----
- (void)retryHttpPost
{
    _uploadState = UPLOAD_STATE_WAITING;
    [self performSelector:@selector(doPost) withObject:nil afterDelay:_uPostCount*2];
}

- (void)cancelRetryHttpPost
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doPost) object:nil];
}

- (BOOL)isTaskCanRetry
{
    //网络状态监控
//    NetworkStatus status = [AKNetworkReachability networkStatus];
//    if (NotReachable == status)
//    {
//        return NO;
//    }
    if (_uPostCount < DPDefaultRetryTimes)
    {
        _uPostCount++;
        return YES;
    }
    return NO;
}

#pragma mark -----post task------
- (void)doPost
{
    if (NO == [self isThreadAllRightToPerformSelector:@selector(doPost)]) {
        return;
    }
    @synchronized(self)
    {
        if (self.connection) {
            [self.connection cancel];
        }
        self.connection = nil;
        NSURLRequest* request  =  [self getUploadTaskRequest];
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        [self startHttpPostTimer];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onStartUploadTask:)])
        {
            id <DPBaseUploaderProtocol> del = self.delegate;
            dispatch_async(dispatch_get_main_queue(), ^{
                [del onStartUploadTask:self];
            });
        }
    }
}

- (void)uploadTask
{
    [self performSelector:@selector(doPost) withObject:nil afterDelay:0.2];
}

- (void)doRunloop
{
    if (_isTaskFinished)
        return;
    [self uploadTask];
}

- (NSURLRequest*)getUploadTaskRequest
{
    return nil;
}
#pragma mark -----helper methods------
/*常常我们需要去判断线程*/
- (BOOL)isThreadAllRightToPerformSelector:(SEL)selector
{
    if(!self.httpThread)
        return NO;
    if ([NSThread currentThread] != self.httpThread)
    {
        [self performSelector:selector
                     onThread:self.httpThread
                   withObject:nil
                waitUntilDone:NO];
        
        return NO;
    }
    return YES;
}

#pragma mark -----NSURLConnection Delegate-----
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection != self.connection){
        return;
    }
    @synchronized(self){
        [self stopHttpPostTimer];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection != self.connection){
        return;
    }
    @synchronized(self)
    {
        if (_resultType == UploadResultType_Dictionary) {
            NSError* error = nil;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
            if (error) {
                return [self onErrorFinish:UploadErrorCodeRespError];
            } else{
                _uploadState = UPLOAD_STATE_SUCCEED;
                _isTaskFinished = YES;
                if (result && [result count]) {
                    self.resultInfo = result;
                }
                NSInteger retcode = [[self.resultInfo objectForKey:@"retcode"] integerValue];
                _uploadError = (UploadErrorCode)retcode;
                if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishUploadTask:info:)])
                {
                    id <DPBaseUploaderProtocol>del = self.delegate;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [del onFinishUploadTask:self info:self.resultInfo];
                    });
                }
            }
        }else if (_resultType == UploadResultType_String){
            NSString* isKindOfString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DPTrace(@"%@",isKindOfString);
            self.resultInfo = @{@"return_string": isKindOfString};
            if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishUploadTask:info:)])
            {
                id <DPBaseUploaderProtocol>del = self.delegate;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [del onFinishUploadTask:self info:self.resultInfo];
                });
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (connection != self.connection){
        return;
    }
    
    if(totalBytesWritten >=0 &&
       totalBytesExpectedToWrite >0 &&
       totalBytesWritten <= totalBytesExpectedToWrite)
    {
        CGFloat written = totalBytesWritten;
        CGFloat totalexp = totalBytesExpectedToWrite;
        if(totalexp > 0 && written>=0)
        {
            _process = written/totalexp;;
            _process = MIN(1.0f, _process);

            if (self.delegate && [self.delegate respondsToSelector:@selector(onUploadingProcess:process:)])
            {
                id <DPBaseUploaderProtocol> del = self.delegate;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [del onUploadingProcess:self process:_process];
                });
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (connection != self.connection){
        return;
    }
    @synchronized(self)
    {
        if ([self isTaskCanRetry])
        {
            [self retryHttpPost];
            return;
        }
        [self onErrorFinish:UploadErrorCodeError];
    }
}

@end
