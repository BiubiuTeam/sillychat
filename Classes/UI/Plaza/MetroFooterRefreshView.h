//
//  MetroFooterRefreshView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/23.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
    MetroPullRefreshPulling = 0,
    MetroPullRefreshNormal,
    MetroPullRefreshLoading,
} MetroPullRefreshState;

@class MetroFooterRefreshView;
@protocol MetroRefreshViewDelegate <NSObject>
- (void)MetroRefreshTableHeaderDidTriggerRefresh:(MetroFooterRefreshView*)view;
- (BOOL)MetroRefreshTableHeaderDataSourceIsLoading:(MetroFooterRefreshView*)view;
@end

@interface MetroFooterRefreshView : UIView
{
    MetroPullRefreshState _state;
    UIScrollView* _scrollView;
    BOOL _pagingEnabled;
    
    NSMutableArray* _smileFaceArray;
    UIActivityIndicatorView *_activityView;
    
    UILabel* _messageLabel;
}

@property(nonatomic,assign) id <MetroRefreshViewDelegate> delegate;

- (id)initWithScrollView:(UIScrollView* )scrollView;
- (void)adjustPosition;

- (void)MetroRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)MetroRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)MetroRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
