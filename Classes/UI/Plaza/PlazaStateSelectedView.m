//
//  PlazaStateSelectedView.m
//  sillyChat
//
//  Created by haowenliang on 15/4/21.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaStateSelectedView.h"
#import "SCStateService.h"

#define StateImageRadius _size_S(70)

@interface PlazaStateCell : UICollectionViewCell

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* imageView;

@end

@implementation PlazaStateCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (UIImageView *)imageView
{
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, StateImageRadius, StateImageRadius)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.centerX = _imageView.centerX = self.width/2;
    _titleLabel.bottom = self.height;
}

- (void)setDatasource:(NSDictionary*)dict
{
    [self.titleLabel setText:[dict objectForKey:@"title"]];
    [_titleLabel sizeToFit];
    
    NSString* imageName = [dict objectForKey:@"image"];
    [_imageView setImage:LOAD_ICON_USE_POOL_CACHE(imageName)];
    
    [self setNeedsLayout];
}

@end

#define MSG_COLLECTION_INSET _size_S(10)
//////////////////////////////////////////
//////////////////////////////////////////
@interface PlazaStateSelectedView ()
{
    UIView* _maskView;
}
@property (nonatomic, strong) UILabel* messageLabel;
@property (nonatomic ,strong) NSArray* stateArray;
@end

@implementation PlazaStateSelectedView

#pragma mark -
- (void)showInView:(UIView*)superview
{
    [superview addSubview:self];
    self.top = SCREEN_HEIGHT;
    self.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.top = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissWithAnimation:(BOOL)animation
{
    if (animation == NO) {
        [self removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.top = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = APPLIGHTCOLOR;
        _maskView.alpha = 0.9;
        [self addSubview:_maskView];
        
        [self addSubview:self.messageLabel];
        [self addSubview:self.collectionView];
        
        [self sendSubviewToBack:_maskView];
    }
    return self;
}

- (UILabel *)messageLabel
{
    if (nil == _messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.font = [DPFont boldSystemFontOfSize:FONT_SIZE_LARGE+6];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        
        _messageLabel.text = @"你此刻的状态是？";
        [_messageLabel sizeToFit];
    }
    return _messageLabel;
}

- (NSArray *)stateArray
{
    if (nil == _stateArray) {
        _stateArray = [[[SCStateService shareInstance] stateStillList] copy];
    }
    return _stateArray;
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        [_collectionView registerClass:[PlazaStateCell class] forCellWithReuseIdentifier:@"PlazaStateCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _maskView.frame = self.bounds;
    
    CGFloat height = _messageLabel.height + 3*(_size_S(96) + 10) + MSG_COLLECTION_INSET;
    
    _messageLabel.centerX = self.width/2;
    _messageLabel.top = (self.height - ALL_BUBBLE_BOTTOM2 - SMALL_BUBBLE_RADIUS - height)/2;
    _collectionView.top = _messageLabel.bottom + MSG_COLLECTION_INSET;
}

#pragma mark -datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.stateArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlazaStateCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PlazaStateCell" forIndexPath:indexPath];
    
    NSDictionary* dict = [_stateArray objectAtIndex:indexPath.row];
    [cell setDatasource:dict];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout   
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_size_S(86), _size_S(96));
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat leftw = (self.width - _size_S(86)*3)/3;
    return UIEdgeInsetsMake(5, leftw/2, 5, leftw/2);
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
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectItemWithDatasource:)]) {
        [_delegate didSelectItemWithDatasource:[_stateArray objectAtIndex:indexPath.row]];
    }
//    [self dismissWithAnimation:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
@end
