//
//  ChatInputViewController.m
//  sillyChat
//
//  Created by haowenliang on 15/3/17.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ChatInputViewController.h"

@interface ChatInputViewController ()
@property (nonatomic, strong) UIButton* emojButton; //表情按钮
@end

@implementation ChatInputViewController

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.containerView addSubview:self.emojButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)emojButton
{
    if (nil == _emojButton) {
        UIImage* emoj = LOAD_ICON_USE_POOL_CACHE(@"private/silly_chatview_emoji.png");
        _emojButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, emoj.size.width, emoj.size.height)];
        _emojButton.backgroundColor = [UIColor clearColor];
        [_emojButton addTarget:self action:@selector(openEmojInputView) forControlEvents:UIControlEventTouchUpInside];
        
        [_emojButton setImage:emoj forState:UIControlStateNormal];
        [_emojButton setImage:LOAD_ICON_USE_POOL_CACHE(@"private/silly_chatview_emoji_pressed.png") forState:UIControlStateSelected];
        [_emojButton setImage:LOAD_ICON_USE_POOL_CACHE(@"private/silly_chatview_emoji_pressed.png") forState:UIControlStateHighlighted];
        
        _emojButton.right = _containerView.width - MARGIN_LG;
        _emojButton.bottom = _containerView.height - MARGIN_CR;
    }
    return _emojButton;
}

- (void)openEmojInputView
{
    if (_emojButton.selected) {
        return;
    }
    _emojButton.selected = YES;
    [_containerView removeFromSuperview];
    [_containerView resignAllFirstResponder];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickEmojButtonType:)]) {
        [self.delegate didClickEmojButtonType:_viewType];
    }
    
    _emojButton.selected = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)updateBottomControlPositionWithKeybordRect:(CGRect)keyboardRect
{
    [super updateBottomControlPositionWithKeybordRect:keyboardRect];
    _emojButton.bottom = _containerView.height - MARGIN_CR;
}

@end
