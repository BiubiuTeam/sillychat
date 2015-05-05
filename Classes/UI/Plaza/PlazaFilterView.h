//
//  PlazaFilterView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlazaFilterViewProtocol <NSObject>

@end

@interface PlazaFilterView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, assign) id<PlazaFilterViewProtocol> delegate;

@end
