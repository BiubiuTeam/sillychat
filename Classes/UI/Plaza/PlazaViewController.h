//
//  PlazaViewController.h
//  sillyChat
//
//  Created by haowenliang on 15/3/14.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BaseViewController.h"
#import "DPBaseUploadMgr.h"

#import "DXRecordView.h"

#import "EMRoundButton.h"

@class PlazaFilterButton;
@interface PlazaViewController : BaseViewController<DPBaseUploadMgrProtocol>
{
    NSUInteger _curUploadTaskTag;
    DXRecordView* _recordView;
    
    EMRoundButton* _roundButton;
    UIButton* _chatRoomButton;
    NSUInteger _msgTag; //选择发布广播所处的状态
    PlazaFilterButton * _filterButton;
    NSString* _wording4Tag;
}
@property (nonatomic, strong) DXRecordView* recordView;

@property (nonatomic, strong) UIButton* chatRoomButton;
@property (nonatomic, strong) PlazaFilterButton * filterButton;
@property (nonatomic, copy) void (^postOptComletionCallback)(BOOL, NSError *);

- (instancetype)initWithTagsArray:(NSArray*)array;
- (void)forceToUpdatePlazaSillyMessage;

- (void)judgeIfHasUnreadInfo;

@end


@interface UIButton (Blink)
- (void)startAnimation;
- (void)stopAnimation;
@end
