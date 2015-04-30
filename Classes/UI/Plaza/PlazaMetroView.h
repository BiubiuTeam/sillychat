//
//  PlazaMetroView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RFQuiltLayout.h"

#define TAG_VERTICAL_MARGIN (15)
#define TAG_HORICAL_MARGIN (26)

@protocol PlazaMetroProtocol <NSObject>

@optional
- (void)didClickBroacastView:(UIView*)bview datasource:(id)broacast;
- (void)didClickBroacast:(id)broacast onFrame:(CGRect)absoluteFrame;

- (void)startUpdatePlazaSource;

@end

@interface PlazaMetroView : UIView<UICollectionViewDataSource,UICollectionViewDelegate,RFQuiltLayoutDelegate>

@property (nonatomic, assign) NSUInteger maxRow;/*default is 3*/
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, assign) id<PlazaMetroProtocol> delegate;

@property (nonatomic, strong) NSMutableArray* datasource;
- (void)reloadData;

- (void)refreshDone;

@end
