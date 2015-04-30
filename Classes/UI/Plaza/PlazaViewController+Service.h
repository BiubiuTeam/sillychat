//
//  PlazaViewController+Service.h
//  sillyChat
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaViewController.h"

@interface PlazaViewController (Service)

- (void)postTextBroadcast:(NSString*)content;

- (void)postImageBroadcast:(NSString*)picPath withExtension:(NSDictionary*)extension;

- (void)postAudioBroadcast:(NSString*)audioPath withExtension:(NSDictionary*)extension;

@end
