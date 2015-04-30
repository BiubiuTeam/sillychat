//
//  DPAudioUploader.h
//  sillyChat
//
//  Created by haowenliang on 15/4/11.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPBaseUploader.h"

@interface DPAudioUploader : DPBaseUploader
{
    NSURLRequest* request;
}
@property (nonatomic, strong) NSString* localPath;

- (void)createRequestWithLocalPath:(NSString *)localPath;
- (void)createRequestWithData:(NSData*)audio;
@end
