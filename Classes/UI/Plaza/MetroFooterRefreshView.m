//
//  MetroFooterRefreshView.m
//  sillyChat
//
//  Created by haowenliang on 15/4/23.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "MetroFooterRefreshView.h"

#define SMILE_FACE_RADIUS (27)
#define SMILE_FACE_LEFT _size_S(10)
#define SMILE_FACE_INSET _size_S(4)

#define REFRESH_WIDTH _size_S(80)
#define REFRESH_DRAG_WIDTH _size_S(60)

static NSString* RefreshMessage = @"松\n手\n换\n一\n批";
static NSString* LoadingMessage = @"正\n在\n加\n载";

@interface MetroFooterRefreshView ()
- (void)setState:(MetroPullRefreshState)aState;

@property (nonatomic, strong) CADisplayLink* link;
@end

@implementation MetroFooterRefreshView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];

        _smileFaceArray = [NSMutableArray new];
        UIImage* whiteSmile = LOAD_ICON_USE_POOL_CACHE(@"silly_smile_face_normal.png");
        for (NSInteger index = 0; index < 4; index++) {
            CALayer* layer = [CALayer layer];
            layer.frame = CGRectMake(SMILE_FACE_LEFT, 0, SMILE_FACE_RADIUS, SMILE_FACE_RADIUS);
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.contents = (id)whiteSmile.CGImage;
            
            [_smileFaceArray addObject:layer];
            [self.layer addSublayer:layer];
        }
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width - (SMILE_FACE_INSET*2+SMILE_FACE_RADIUS), 0)];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = RGBACOLOR(0x4A, 0x90, 0xe2, 0.5);
        _messageLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        _messageLabel.text = RefreshMessage;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        [_messageLabel sizeToFit];
        [self addSubview:_messageLabel];
        
        [self setState:MetroPullRefreshNormal];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = SMILE_FACE_RADIUS* 4+ SMILE_FACE_INSET*3;
    CGFloat top = (self.height - height)/2;
    CGRect frame = CGRectZero;
    for (NSInteger index = 0; index < 4; index++) {
        CALayer* layer = [_smileFaceArray objectAtIndex:index];
        frame = layer.frame;
        frame.origin.y = top;
        top = top + SMILE_FACE_INSET + SMILE_FACE_RADIUS;
        layer.frame = frame;
    }
    _messageLabel.left = CGRectGetMaxX(frame)+_size_S(10);
    _messageLabel.centerY = self.height/2;
}

- (void)adjustPosition
{
    CGPoint center = CGPointMake(MAX(_scrollView.width, _scrollView.contentSize.width) + self.width/2, _scrollView.height/2);
    self.center = center;
}

- (id)initWithScrollView:(UIScrollView* )scrollView
{
    CGSize size = scrollView.frame.size;
    size = CGSizeMake(size.height, REFRESH_WIDTH);
    
    CGPoint center = CGPointMake(scrollView.contentSize.width+size.width/2, size.height/2);
    if (self = [self initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        _scrollView = scrollView;
        
        self.center = center;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [scrollView addSubview:self];
    }
    return self;
}


#pragma mark -
#pragma mark Setters

- (void)setState:(MetroPullRefreshState)aState{
    switch (aState) {
        case MetroPullRefreshPulling:{
            [self stopAnimation];
            _messageLabel.text = RefreshMessage;
        } break;
        case MetroPullRefreshNormal:{
            if (_state == MetroPullRefreshPulling) {
    
            }
            [self stopAnimation];
            _messageLabel.text = RefreshMessage;
        }break;
        case MetroPullRefreshLoading:
        {
            [self startAnimation];
            _messageLabel.text = LoadingMessage;
        } break;
        default:
            break;
    }
    _state = aState;
}


#pragma mark - ScrollView Methods
- (void)MetroRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    if (_state == MetroPullRefreshLoading) {
        CGFloat offset = MAX(scrollView.frame.size.width+scrollView.contentOffset.x-scrollView.contentSize.width, 0);
        offset = MIN(offset, REFRESH_WIDTH);
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, offset);
    } else if (scrollView.isDragging) {
        BOOL _loading = NO;
        
        if ([_delegate respondsToSelector:@selector(MetroRefreshTableHeaderDataSourceIsLoading:)]) {
            _loading = [_delegate MetroRefreshTableHeaderDataSourceIsLoading:self];
        }
        
        BOOL pullingCondition = NO;
        BOOL normalCondition = NO;

        CGFloat x = scrollView.contentOffset.x+scrollView.frame.size.width;
        pullingCondition = ((x < (scrollView.contentSize.width+REFRESH_DRAG_WIDTH)) && (x > scrollView.contentSize.width));
        normalCondition = (x > (scrollView.contentSize.width+REFRESH_DRAG_WIDTH));

        if (_state == MetroPullRefreshPulling && pullingCondition && !_loading) {
            [self setState:MetroPullRefreshNormal];
        } else if (_state == MetroPullRefreshNormal && normalCondition && !_loading) {
            [self setState:MetroPullRefreshPulling];
        }
        
        if (scrollView.contentInset.top != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
        
    }
    
}

- (void)MetroRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    BOOL _loading = NO;
    if ([_delegate respondsToSelector:@selector(MetroRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [_delegate MetroRefreshTableHeaderDataSourceIsLoading:self];
    }
    
    BOOL condition = NO;
    UIEdgeInsets insets = UIEdgeInsetsZero;

    CGFloat x = scrollView.contentOffset.x+scrollView.frame.size.width-scrollView.contentSize.width;
    condition = (x > REFRESH_DRAG_WIDTH);
    insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, self.width);

    if (condition && !_loading) {
        if ([_delegate respondsToSelector:@selector(MetroRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate MetroRefreshTableHeaderDidTriggerRefresh:self];
        }
        
        /* Set NO paging Disable */
        _pagingEnabled = scrollView.pagingEnabled;
        scrollView.pagingEnabled = NO;

        [self setState:MetroPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = insets;
        [UIView commitAnimations];
    }
}

- (void)MetroRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    scrollView.pagingEnabled = _pagingEnabled;
    
    [self setState:MetroPullRefreshNormal];
}

#pragma mark - animation

- (CADisplayLink *)link
{
    if (nil == _link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        _link.frameInterval = 15;
    }
    return _link;
}

static NSInteger lightIndex = 0;
- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    lightIndex = lightIndex%_smileFaceArray.count;
    for (NSInteger index = 0; index < 4; index++) {
        CALayer* layer = _smileFaceArray[index];
        if (lightIndex == index) {
            layer.contents = (id)LOAD_ICON_USE_POOL_CACHE(@"silly_smile_face_lighted.png").CGImage;
        }else{
            layer.contents = (id)LOAD_ICON_USE_POOL_CACHE(@"silly_smile_face_normal.png").CGImage;
        }
    }
    lightIndex++;
}

- (void)startAnimation
{
    lightIndex = 0;
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
    for (CALayer* layer in _smileFaceArray) {
        layer.contents = (id)LOAD_ICON_USE_POOL_CACHE(@"silly_smile_face_normal.png").CGImage;
    }
    
    if (_link) {
        [_link invalidate];
        self.link = nil;
    }
}

#pragma mark Dealloc
- (void)dealloc {
    [self stopAnimation];
    _delegate=nil;
}

@end
