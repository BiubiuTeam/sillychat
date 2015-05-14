//
//  PostViewController.h
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BaseViewController.h"
#import "Camera View/CameraSessionView.h"

#define KeyBoardHeight (216)
#define DEFAUTL_TEXTVIEW_WIDTH (300)

#define TEXTVIEW_FONT [UIFont fontWithName:@"STHeitiSC-Medium" size:FONT_SIZE_LARGE]
#define TEXTVIEW_TINT_COLOR ([UIColor whiteColor])

typedef NS_ENUM(NSUInteger, PostContentType) {
    PostContentType_Text = 0,
    PostContentType_IMG = 1,
};

typedef NS_ENUM(NSUInteger, PostViewType) {
    PostViewType_Plaza = 0,
    PostViewType_Chat = 1,
};

#define MARGIN_CR _size_S(15)
#define MARGIN_LG _size_S(27)

@protocol PostViewControllerDelegate <NSObject>

- (void)postOptWithContent:(id)content
               contentType:(PostContentType)ctype
                  postType:(PostViewType)ptype
                completion:(void(^)(BOOL succeed, NSError* error))completion;

- (void)postOptWithContent:(id)content
               contentType:(PostContentType)ctype
                  postType:(PostViewType)ptype
                 extension:(NSDictionary*)extension
                completion:(void(^)(BOOL succeed, NSError* error))completion;

@optional
- (void)didClickEmojButtonType:(PostViewType)ptype;

@end

@interface PostViewController : BaseViewController
{
    UIImageView* _captureView;//主要是在照相模式下，绘制成图片
    UIButton* _randomPostButton; //随机Post按钮
    UIView* _containerView;
    PostViewType _viewType;
}

@property (nonatomic) CameraType launchCameraType;

@property (nonatomic, strong) UIView* containerView; //承载所有的视图控件
@property (nonatomic, assign) id<PostViewControllerDelegate> delegate;

- (instancetype)initWithViewType:(PostViewType)type;
- (void)updateBottomControlPositionWithKeybordRect:(CGRect)keyboardRect;

@end

