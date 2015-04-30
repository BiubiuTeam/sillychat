//
//  TagVoiceView.h
//  sillyChat
//
//  Created by haowenliang on 15/3/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "TagBaseView.h"

@interface TagVoiceView : TagBaseView
{
    UIImageView *_animationImageView; // 动画的ImageView
    UILabel *_timeLabel; // 时间label
}

@property (nonatomic, assign) BOOL animation;
-(void)startAudioAnimation;
-(void)stopAudioAnimation;

@end
