//
//  PlazaViewController+Audio.h
//  sillyChat
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaViewController.h"

@interface PlazaViewController (Audio)

-(void)longPressGestureOpt:(UILongPressGestureRecognizer *)longGer;

- (void)asyncPlayAudioWithPath:(NSString*)path;
- (void)stopVoicePlay;
@end
