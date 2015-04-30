//
//  DPPhotoUploader.m
//  ImageCGIUploadDemo
//
//  Created by haowenliang on 14-8-28.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPPhotoUploader.h"
static NSThread *gsHttpThread = nil;

@implementation DPPhotoUploader

- (id)init
{
    if (self = [super init]) {
        self.httpThread = [DPPhotoUploader httpThread];
        self.uploadState = UPLOAD_STATE_WAITING;
        self.contentType = UploadContentType_Image;
    }
    return self;
}

- (NSURLRequest *)getUploadTaskRequest
{
    return request;
}

- (void)createRequestWithImage:(UIImage*)uploadImage
{
    if (!uploadImage)
        return;
    NSString* url = @"http://183.131.76.109/upload.php";
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"post url : %@",url);
    self.uploadContent = uploadImage;
    request = [DPPhotoUploader createPOSTRequest:url content:UIImageJPEGRepresentation(uploadImage, 0.8) timeout:300];
}

//+ (NSString*)urlWithParam:(NSDictionary*)diction
//{
//    NSString* host = [diction objectForKey:@"url"];
//    if (host == nil) {
//        return nil;
//    }
//    NSMutableString* url = [[NSMutableString alloc] initWithString:host];
//    [url appendString:@"?"];
//    
//    NSDictionary* paramDic = [diction objectForKey:@"params"];
//    
//    for (id key in [paramDic allKeys]) {
//        NSLog(@"key:%@ , Value:%@",key,[paramDic objectForKey:key]);
//        [url appendString:[NSString stringWithFormat:@"%@=%@&",key,[paramDic objectForKey:key]]];
//    }
//    return [url substringToIndex:[url length]-1];
//}
//
//+ (NSString *)base64difyImage:(UIImage *)image
//{
//    float systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
//    BOOL isIOS7 = (systemVersion >= 7);
//    NSData *imageData           = UIImageJPEGRepresentation(image, 0.8); //获取图片数据
//    NSString *encodedImageData  = isIOS7 ? [imageData base64EncodedStringWithOptions:0] : [imageData base64Encoding]; //base64
//    return encodedImageData;
//}

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
    NSString* filename = [NSString stringWithFormat:@"%zd.png",rand()];
    filename = [filename stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *mimetype  = @"image/png";
    
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
            [gsHttpThread setName:@"PhotoTransferThread"];
            
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
