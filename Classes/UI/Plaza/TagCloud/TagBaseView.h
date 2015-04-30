//
//  TagBaseView.h
//  sillyChat
//
//  Created by haowenliang on 15/3/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceConstants.h"

#define TAG_VIEW_DEFAULT_HEIGHT (32)

#define HOR_MARGIN (13)
#define HOR_INSET (9)
#define VER_INSET (13)

#define TAG_IMAGE_WIDTH (SCREEN_WIDTH/2 - 3*9)

#define TAG_VOICE_MINWIDTH (64)
#define TAG_VOICE_MAXWIDTH (SCREEN_WIDTH/2 - 3*9)

#define TAG_TEXT_MINWIDTH (32)
#define TAG_TEXT_MAXWIDTH (SCREEN_WIDTH/2 - 3*9)


@interface TagBaseView : UIView
{
    BOOL _didScale;
}
@property (nonatomic, assign) BroacastType viewType;
@property (nonatomic, assign) BOOL didTaged;

@property (nonatomic, strong) NSObject* datasource;

@property (nonatomic, strong) NSString* targetOrigin;

@property (nonatomic, assign) CGRect absoluteFrame;

- (instancetype)initWithFrame:(CGRect)frame viewType:(BroacastType)viewType;

- (void)setupUiControls;

- (void)setViewContent:(id)content;

- (NSComparisonResult)compareWithWidth:(TagBaseView*)otherView;
@end
