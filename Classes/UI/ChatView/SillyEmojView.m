//
//  SillyEmojView.m
//  sillyChat
//
//  Created by haowenliang on 15/3/17.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyEmojView.h"
#import "EmojiConstants.h"
#import "EmojiItem.h"
#import "SillyEmojiMgr.h"
#import "EmojiAnimationView.h"

@interface SillyEmojView()<UIScrollViewDelegate,EmojiItemProtocol>
{
    NSUInteger _numberOfPage;
    
    CGRect _boardFrame;
}

@property (nonatomic, strong) NSArray *emojis;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end


@implementation SillyEmojView

- (instancetype)initWithFrame:(CGRect)frame withFunction:(BOOL)function
{
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = EmojiViewHeight;
    if (self = [super initWithFrame:frame]) {
        _withFunctionButton = function;
        [self setup];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = EmojiViewHeight;
    if (self = [super initWithFrame:frame]) {
        _withFunctionButton = NO;
        [self setup];
    }
    return self;
}

- (void)addTopBorderLayer
{
    // Add a bottomBorder.
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 0, self.width, .5f);
    bottomBorder.backgroundColor = RGBACOLOR(0x97, 0x97, 0x97, .75).CGColor;
    [self.layer addSublayer:bottomBorder];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    [self addTopBorderLayer];
    _boardFrame = self.bounds;
    _boardFrame.origin.y = .5;
    _boardFrame.size.height -= .5;
    
    [self addFaceEmojAndSubControls];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetect:)];
    [self addGestureRecognizer:panGesture];
}

- (void)addFaceEmojAndSubControls
{
    // init emojis
    self.emojis = [SillyEmojiMgr emojiArray];
    
    NSInteger rowNum = EmojiHorNumber;
    NSInteger colNum = EmojiVerNumber;
    _numberOfPage = ceil((float)[self.emojis count] / (float)(rowNum * colNum));
    
    [self addSubview:self.scrollView];
    // add emojis
    NSInteger row = 0;
    NSInteger column = 0;
    NSInteger page = 0;
    NSInteger emojiPointer = 0;
    
    NSInteger totalCount = [self.emojis count];
    if (_withFunctionButton) {
        totalCount = totalCount + _numberOfPage - 1;
    }
    
    for (int i = 0; i < totalCount; i++) {
        // Pagination
        if (i % (rowNum * colNum) == 0) {
            page ++;    // Increase the number of pages
            row = 0;    // the number of lines is 0
            column = 0; // the number of columns is 0
        }else if (i % colNum == 0) {
            // NewLine
            row += 1;   // Increase the number of lines
            column = 0; // The number of columns is 0
        }
        
        CGRect currentRect = CGRectMake(((page-1) * _boardFrame.size.width) + (column * (EmojiWidth + EmojiHorInset)) + EmojiHorMargin,
                                        row * (EmojiHeight+EmojiVerInset) + EmojiVerMargin,
                                        EmojiWidth,
                                        EmojiHeight);
        
        if (_withFunctionButton && row == (rowNum - 1) && column == (colNum - 1)) {
            // last position of page, add delete button
            SillyDeleteButton *deleteButton = [SillyDeleteButton buttonWithType:UIButtonTypeCustom];
            [deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            deleteButton.frame = currentRect;
            deleteButton.tintColor = [UIColor blackColor];
            [_scrollView addSubview:deleteButton];
        }else{
            NSString *emoji = self.emojis[emojiPointer++];
            // init Emoji Button
            EmojiItem *emojiButton = [[EmojiItem alloc] initWithFrame:currentRect];
            emojiButton.delegate = self;
            [emojiButton setEmojiName:emoji];
            [_scrollView addSubview:emojiButton];
        }
        column++;
    }
    
    [self addSubview:self.pageControl];
}

- (UIScrollView *)scrollView
{
    if (nil == _scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:_boardFrame];
        _scrollView.backgroundColor = APPBLACKCOLOR;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_boardFrame) * _numberOfPage, CGRectGetHeight(_boardFrame));
    }
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if (nil == _pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPage = 0;
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.numberOfPages = _numberOfPage;
        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:_numberOfPage];
        _pageControl.frame = CGRectMake(CGRectGetMidX(_boardFrame) - (pageControlSize.width / 2),
                                        CGRectGetHeight(self.bounds) - pageControlSize.height + 5,
                                        pageControlSize.width,
                                        pageControlSize.height);
        [_pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
        
        _pageControl.currentPageIndicatorTintColor = RGBACOLOR(0xff, 0xde, 0x32, 1);
        _pageControl.pageIndicatorTintColor = RGBACOLOR(0x78, 0x77, 0x72, 1);
    }
    return _pageControl;
}

#pragma mark -

- (void)panDetect:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
    }
}

#pragma mark -

- (void)pageControlTouched:(UIPageControl *)sender {
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
    [self.scrollView scrollRectToVisible:bounds animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage == newPageNumber) {
        return;
    }
    self.pageControl.currentPage = newPageNumber;
}

- (void)emojiButtonPressed:(NSString *)emojiContent
{
    // Callback
    if ([self.delegate respondsToSelector:@selector(emojiView:didSelectEmoji:)]) {
        [self.delegate emojiView:self didSelectEmoji:emojiContent];
    }
}

- (void)deleteButtonPressed:(UIButton *)button{
    // Add a simple scale animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.toValue = @0.9;
    animation.duration = 0.1;
    animation.autoreverses = YES;
    [button.layer addAnimation:animation forKey:nil];
    
    // Callback
    if ([self.delegate respondsToSelector:@selector(emojiView:didPressDeleteButton:)]) {
        [self.delegate emojiView:self didPressDeleteButton:button];
    }
}

- (void)showAnimationEmoji:(NSString*)emoji
{
    [EmojiAnimationView showEmoji:emoji aboveView:self.superview yPosition:0 leftOrientation:NO];
}

@end


@implementation SillyDeleteButton

-(void)drawRect:(CGRect)rect{
    
    // Rectangle Drawing
    UIBezierPath* rectanglePath = UIBezierPath.bezierPath;
    [rectanglePath moveToPoint: CGPointMake(5, 25.05)];
    [rectanglePath addLineToPoint: CGPointMake(20.16, 36)];
    [rectanglePath addLineToPoint: CGPointMake(45.5, 36)];
    [rectanglePath addLineToPoint: CGPointMake(45.5, 13.5)];
    [rectanglePath addLineToPoint: CGPointMake(20.16, 13.5)];
    [rectanglePath addLineToPoint: CGPointMake(5, 25.05)];
    [rectanglePath closePath];
    [self.tintColor setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];

    // Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(26.5, 20)];
    [bezierPath addLineToPoint: CGPointMake(36.5, 29.5)];
    [bezierPath moveToPoint: CGPointMake(36.5, 20)];
    [bezierPath addLineToPoint: CGPointMake(26.5, 29.5)];
    [self.tintColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}

@end