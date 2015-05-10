//
//  PlazaFilterButton.h
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EyeType) {
    EyeType_Black = 0,
    EyeType_White = 1,
    EyeType_Succeed = 2,
    EyeType_Failed = 3,
    
    EyeType_Custom = 4,
};

@interface PlazaFilterButton : UIButton
@property (nonatomic, strong) UIImage* uploadImage;
@property (nonatomic) NSInteger uploaderTag;//上传对象关联的tag

@property (nonatomic) float progress;

- (void)setEyeType:(EyeType)type;
- (void)resetEyeType;

- (BOOL)setNeedUpdateContent;
@end
