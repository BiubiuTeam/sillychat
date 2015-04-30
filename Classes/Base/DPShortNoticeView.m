//
//  DPShortNoticeView.m
//  Longan
//
//  Created by haowenliang on 14-6-20.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPShortNoticeView.h"

#define TIPSVIEW_HEIGHT	40
#define TIPSVIEW_SPACE  10
#define TIPSVIEW_MARGIN 10

@implementation DPShortNoticeView

{
    UIImage* _bgImage;
    UIImage* _tipsImg;
}
@synthesize title;

+ (void)showTips:(NSString*)tipsStr atRootView:(UIView*)rootView
{
    if ([rootView findSubview:@"DPShortNoticeView" resursion:YES]) {
        return;
    }
    
    DPShortNoticeView* showView = [[DPShortNoticeView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TIPSVIEW_HEIGHT)];
	showView.title = tipsStr;
    showView.tag = ShortNotificationTipsViewTag;
	[rootView addSubview:showView];
	[showView showView];
}


- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
        _bgImage = LOAD_ICON_USE_POOL_CACHE(@"shortNotice_bg");
        _tipsImg = LOAD_ICON_USE_POOL_CACHE(@"shortNoti_information");
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
    //背景
    _bgImage = [_bgImage stretchableImageWithLeftCapWidth:_bgImage.size.width/2 topCapHeight:_bgImage.size.height/2];
    [_bgImage drawInRect:CGRectMake(TIPSVIEW_MARGIN, 0, SCREEN_WIDTH-TIPSVIEW_MARGIN*2, TIPSVIEW_HEIGHT)];
    
    UIFont* font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
    CGSize titleSize = [self.title sizeWithFont:font];
    int contentWidth = _tipsImg.size.width + TIPSVIEW_SPACE + titleSize.width;
    int contentMaxWidth = SCREEN_WIDTH - TIPSVIEW_MARGIN*4;
    if (contentWidth > contentMaxWidth) {
        contentWidth = contentMaxWidth;
    }
    int cx = (SCREEN_WIDTH - contentWidth)/2;
    int cy = (TIPSVIEW_HEIGHT - _tipsImg.size.height)/2;
    [_tipsImg drawAtPoint:CGPointMake(cx, cy)];
    
    //文字
    cx += _tipsImg.size.width + TIPSVIEW_SPACE;
    cy = (TIPSVIEW_HEIGHT - titleSize.height)/2;
    [[UIColor whiteColor] set];
    [self.title drawAtPoint:CGPointMake(cx, cy) forWidth:(SCREEN_WIDTH - TIPSVIEW_MARGIN*2 - cx) withFont:font lineBreakMode:NSLineBreakByTruncatingTail];
	
}

- (void)showView
{
	self.frame = CGRectMake(0, -TIPSVIEW_HEIGHT, SCREEN_WIDTH, TIPSVIEW_HEIGHT);
    self.alpha = 0.6;
    
	[UIView beginAnimations:@"showFeedUpdateCount" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideView)];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationDelay:0.3];
	
	self.frame = CGRectMake(0, 0, SCREEN_WIDTH, TIPSVIEW_HEIGHT);
    self.alpha = 1.0;
	
	[UIView commitAnimations];
}

- (void)hideView
{
	[UIView beginAnimations:@"hideFeedUpdateCount" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:1.5];
	
	self.frame = CGRectMake(0, -TIPSVIEW_HEIGHT, SCREEN_WIDTH, TIPSVIEW_HEIGHT);
	self.alpha = 0.6;
    
	[UIView commitAnimations];
}

@end
