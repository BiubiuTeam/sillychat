//
//  SillyEmojView.h
//  sillyChat
//
//  Created by haowenliang on 15/3/17.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SillyEmojiViewDelegate;

@interface SillyEmojView : UIView
{
    BOOL _withFunctionButton;
}

@property (nonatomic, assign) id<SillyEmojiViewDelegate> delegate;
- (void)showAnimationEmoji:(NSString*)emoji;

@end

@protocol SillyEmojiViewDelegate <NSObject>

-(void)emojiView:(SillyEmojView *)emojiView didSelectEmoji:(NSString *)emoji;
@optional
-(void)emojiView:(SillyEmojView *)emojiView didPressDeleteButton:(UIButton *)deletebutton;

@optional
- (void)emojiViewDidTapTopAccessoryView:(SillyEmojView *)emojiView;

-(void)emojiView:(SillyEmojView *)emojiView didPressFunctionButton:(UIButton *)fucBtn;
@end

@interface SillyDeleteButton : UIButton

@end