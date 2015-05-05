//
//  PostTextView.h
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTextView : UITextView
{
    NSString    *_defaultPlaceholder;
    NSString    *_editingPlaceholder;
    BOOL        _isPlaceholderDisplayed;
    //记录_editingPlaceholder是否显示的标记（textview在frame没变化的时候输入和增加位子的时候不会调用drawRect，需要通过textViewDidchange里去判断）
    BOOL        _isEditing;
}

@property(nonatomic, strong)        NSString    *defaultPlaceholder;   // default is nil. string is drawn 70% gray
@property(nonatomic, strong)        NSString    *editingPlaceholder;   // default is nil. string is drawn 70% gray
@property(nonatomic, assign)        BOOL        isEditing;        // 是否正在编辑

@property (nonatomic, assign) NSUInteger maxCount;
@property (nonatomic, assign) NSUInteger minCount;
@property (nonatomic, assign) NSUInteger inputCount;

@property (nonatomic, assign) CGFloat defaultCenterY;
@property (nonatomic, assign) CGFloat defaultWidth;

//引用计数label
@property (nonatomic, weak) UILabel* countLabel;

- (void)dpTextDidChanged:(NSNotification*)notification;
@end

@protocol PostAccessoryViewProtocol <NSObject>
@optional
- (void)getRandomPost;
- (void)endTextViewEditting;

@end

@interface PostTextViewAccessoryView : UIView
{
    UIView* _bgView;
    UIView* _sepLine;
}
@property (nonatomic, assign) id<PostAccessoryViewProtocol> delegate;

@property (nonatomic, strong) UILabel* countLabel;
@property (nonatomic, strong) UIButton* shuffleButton;
@property (nonatomic, strong) UIButton* closeButton;

@property (nonatomic, weak) UITextView* weakTextView; //引用TextView
@end