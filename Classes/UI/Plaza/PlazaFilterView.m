//
//  PlazaFilterView.m
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "PlazaFilterView.h"
#import "SCStateService.h"

@interface PlazaFilterView ()
@property (nonatomic, strong) NSMutableDictionary* markedIndexPath;
@end

@implementation PlazaFilterView

#pragma mark -
- (void)dealloc
{
    
}

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = _size_S(6*48+100);
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = APPLICATIONCOLOR;
        [self addSubview:self.collectionView];
    }
    return self;
}

- (NSMutableDictionary *)markedIndexPath
{
    if (nil == _markedIndexPath) {
        _markedIndexPath = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return _markedIndexPath;
}

- (void)selectPosition:(NSIndexPath*)indexPath
{
    NSIndexPath* oldPosition = nil;
    NSArray* filters = [[[SCStateService shareInstance] filterDatasource] objectForKey:[NSString stringWithFormat:@"section%zd",indexPath.section]];
    
    NSMutableDictionary* select = [[NSMutableDictionary alloc] initWithDictionary:filters[indexPath.row]];
    if ([[select objectForKey:@"isSelected"] boolValue]) {
        //老位置，不做操作
        return;
    }
    NSMutableArray* mutFilter = [NSMutableArray arrayWithArray:filters];
    for (NSDictionary* dict in filters) {
        NSInteger row = [filters indexOfObject:dict];
        if (row == indexPath.row) {
            continue;
        }
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            oldPosition = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
            
            NSMutableDictionary* oldSelect = [[NSMutableDictionary alloc] initWithDictionary:dict];
            [oldSelect setValue:@(NO) forKey:@"isSelected"];
            [mutFilter replaceObjectAtIndex:row withObject:oldSelect];
            break;
        }
    }
    [select setValue:@(YES) forKey:@"isSelected"];
    [mutFilter replaceObjectAtIndex:indexPath.row withObject:select];
    
    [[[SCStateService shareInstance] filterDatasource] setValue:mutFilter forKey:[NSString stringWithFormat:@"section%zd",indexPath.section]];
    if (oldPosition) {
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath,oldPosition]];
    }else{
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PlazaStateCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark -datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return MAX([[[SCStateService shareInstance] filterDatasource] count],1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray* array = [[[SCStateService shareInstance] filterDatasource] objectForKey:[NSString stringWithFormat:@"section%zd",section]];
    return [array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlazaStateCell" forIndexPath:indexPath];
    
    UILabel* label = (id)[cell viewWithTag:0x4321];
    if(!label){
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 0x4321;
        label.layer.borderWidth = 2;
        label.layer.cornerRadius = 4;
        label.layer.masksToBounds = YES;
        label.backgroundColor = [UIColor clearColor];
        [cell addSubview:label];
    }
    NSArray* array = [[[SCStateService shareInstance] filterDatasource] objectForKey:[NSString stringWithFormat:@"section%zd",indexPath.section]];
    NSDictionary* dict = array[indexPath.row];
    label.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"title"]];
    
    BOOL isMark = [[dict objectForKey:@"isSelected"] boolValue];
    if (isMark) {
        label.textColor = [UIColor blackColor];
        label.layer.borderColor = [UIColor blackColor].CGColor;
    }else{
        label.textColor = [UIColor whiteColor];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    label.frame = cell.bounds;
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_size_S(102), _size_S(38));
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat leftw = (self.width - _size_S(102)*3)/3;
    return UIEdgeInsetsMake(_size_S(5), leftw/2, _size_S(5), leftw/2);
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
    [self selectPosition:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - collection view header
-(CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = {self.width, _size_S(50)};
    if(section == 0)
    {
        size.height = 0;
    }
    return size;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader)
    {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview = headerView;
    }
    
    UILabel* label = (id)[reusableview viewWithTag:0x123];
    if(!label){
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentLeft;
        label.tag = 0x123;
        label.font = [UIFont boldSystemFontOfSize:FONT_SIZE_LARGE];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [reusableview addSubview:label];
    }
    
    NSArray* array = @[@"想看到的地点",@"想看到的状态",@"想看到的用户"];
    label.text = [NSString stringWithFormat:@"%@", array[indexPath.section]];
    [label sizeToFit];
    
    CGFloat leftw = (self.width - _size_S(102)*3)/3;
    label.left = leftw/2;
    label.centerY = reusableview.height/2;
    
    return reusableview;
}

@end
