//
//  DPAudioUploader.m
//  sillyChat
//
//  Created by haowenliang on 15/4/11.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPAudioUploader.h"
static NSThread *gsHttpThread = nil;

@implementation DPAudioUploader

- (id)init
{
    if (self = [super init]) {
        self.httpThread = [DPAudioUploader httpThread];
        self.uploadState = UPLOAD_STATE_WAITING;
        self.contentType = UploadContentType_Audio;
    }
    return self;
}

- (NSURLRequest *)getUploadTaskRequest
{
    return request;
}


- (void)createRequestWithLocalPath:(NSString *)localPath
{
    if (!localPath.length)
        return;
    NSString* url = @"http://183.131.76.109/upload.php";
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"post url : %@",url);
    self.localPath = localPath;
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:localPath];
    request = [DPAudioUploader createPOSTRequest:url content:data timeout:300];
}

- (void)createRequestWithData:(NSData *)audio
{
    if (!audio)
        return;
    NSString* url = @"http://183.131.76.109/upload.php";
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"post url : %@",url);
    request = [DPAudioUploader createPOSTRequest:url content:audio timeout:300];
}

+ (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

+ (NSURLRequest*)createPOSTRequest:(NSString*)url content:(NSData*)content timeout:(NSTimeInterval)timeout
{
    if(!url.length)
        return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [self generateBoundaryString];
    // set content type
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // create body
    NSMutableData *httpBody = [NSMutableData data];
    // add image data
    NSString* fieldName = @"file";
    NSString* filename = [NSString stringWithFormat:@"%zd.amr",rand()];
    filename = [filename stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *mimetype  = @"audio/amr";
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:content];
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[NSString stringWithFormat:@"%zd", httpBody.length] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = httpBody;
    
    return request;
}

+ (id)httpThread {
    @synchronized(self){
        if (nil == gsHttpThread) {
            gsHttpThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(httpThreadProc)
                                                     object:nil];
            [gsHttpThread setName:@"AudioTransferThread"];
            
            [gsHttpThread start];
        }
    }
    
    return gsHttpThread;
}

+ (void)httpThreadProc {
    @autoreleasepool {
        [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow]
                                         target:self
                                       selector:@selector(donothingatall:)
                                       userInfo:nil
                                        repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    }
}

+ (void)donothingatall:(id)sender
{
    
}

+ (void)stopHttpThread {
    if (gsHttpThread) {
        if (![gsHttpThread isCancelled]) {
            [gsHttpThread cancel];
        }
        gsHttpThread = nil;
    }
}


@end
