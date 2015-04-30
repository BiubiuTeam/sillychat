//
//  PlazaMetroView.m
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaMetroView.h"
#import "MetroCollectionViewCell.h"
#import "SillyBroacastModel.h"
#import "MetroFooterRefreshView.h"
#import "TagBaseView.h"

static CGFloat MetroInset = 5;
#define ROWHEIGHT _size_S(115)

@interface PlazaMetroView ()<MetroRefreshViewDelegate>
{
    BOOL _reloading;
}
@property (nonatomic, strong) MetroFooterRefreshView* refreshView;
@end

@implementation PlazaMetroView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.maxRow = 3;
    }
    return self;
}

- (void)setMaxRow:(NSUInteger)maxRow
{
    _maxRow = maxRow;
    _collectionView.height = self.height = 2*_maxRow* MetroInset + _maxRow*ROWHEIGHT;
    [self updateMetroBaseWidth:_maxRow];
}

- (void)reloadData
{
    [_collectionView setContentOffset:CGPointZero animated:NO];
    
    [_collectionView performBatchUpdates:^{
        [_collectionView reloadSections:[[NSIndexSet alloc] initWithIndex:0]];
    } completion:^(BOOL finished) {
        if (finished) {
            [_refreshView adjustPosition];
        }
    }];
}

- (void)setDatasource:(NSMutableArray *)datasource
{
    _datasource = datasource;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (MetroFooterRefreshView *)refreshView
{
    if (nil == _refreshView) {
        _refreshView = [[MetroFooterRefreshView alloc] initWithScrollView:_collectionView];
        _refreshView.delegate = self;
    }
    return _refreshView;
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        RFQuiltLayout *flowLayout= [[RFQuiltLayout alloc] init];
        flowLayout.delegate = self;
        flowLayout.direction = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        
        [_collectionView registerClass:[MetroCollectionViewCell class] forCellWithReuseIdentifier:@"MetroCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [self.refreshView adjustPosition];
        //下面方法是可以实现页面没有填满也可以横向换页
        _collectionView.alwaysBounceHorizontal = YES;
    }
    return _collectionView;
}

- (void)updateMetroBaseWidth:(NSInteger)maxRow
{
    CGFloat leftW = self.width - MetroInset*(maxRow + 1);
    NSInteger bwidth = abs(leftW/maxRow);
    
    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.blockPixels = CGSizeMake(bwidth, ROWHEIGHT);
}

#pragma mark -datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_datasource count];
}

- (MetroCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MetroCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MetroCell" forIndexPath:indexPath];
    
    if (indexPath.row < _datasource.count) {
        [cell updateMetroWithData:_datasource[indexPath.row]];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.transform = CGAffineTransformMakeScale(1.1, 1.1);
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.transform = CGAffineTransformMakeScale(1, 1);
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didClickBroacast:onFrame:)]) {
        TagBaseView* base = (TagBaseView*)[cell findSubview:@"TagBaseView" resursion:YES];
        CGRect absoluteFrame = base.absoluteFrame;
         absoluteFrame.origin.y = absoluteFrame.origin.y - self.top + TAG_VERTICAL_MARGIN;
        [_delegate didClickBroacast:_datasource[indexPath.row] onFrame:absoluteFrame];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _datasource.count) {
        return CGSizeMake(1, 1);
    }
    
    SillyBroacastModel* model = _datasource[indexPath.row];
    return CGSizeMake(MIN(_maxRow,[model.blockLen integerValue]), 1);
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(MetroInset/2, MetroInset, MetroInset/2, MetroInset);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshView MetroRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshView MetroRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -MetroRefreshViewDelegate
- (void)refreshDone
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshDone) object:nil];
    
    _reloading = NO;
    _collectionView.scrollEnabled = YES;
    [_refreshView MetroRefreshScrollViewDataSourceDidFinishedLoading:_collectionView];
}

- (void)MetroRefreshTableHeaderDidTriggerRefresh:(MetroFooterRefreshView *)view
{
    [self performSelector:@selector(noticeDelegateToUpdateSource) withObject:nil afterDelay:0.5];
    
    _collectionView.scrollEnabled = NO;
    [self performSelector:@selector(refreshDone) withObject:nil afterDelay:10.0f];
}

- (BOOL)MetroRefreshTableHeaderDataSourceIsLoading:(MetroFooterRefreshView *)view
{
    return _reloading;
}

- (void)noticeDelegateToUpdateSource
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(noticeDelegateToUpdateSource) object:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(startUpdatePlazaSource)]) {
        [_delegate startUpdatePlazaSource];
    }
}
@end
