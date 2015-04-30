//
//  PlazaViewController+Uploader.h
//  sillyChat
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaViewController.h"

@interface PlazaViewController (Uploader)

- (void)addPhotoUploadTask:(UIImage*)photo;
- (void)addPhotoUploadTask:(UIImage*)photo withExtension:(NSDictionary*)extension;

- (void)addAudioFileUploadTask:(NSString*)localPath withExtension:(NSDictionary*)extension;
@end
