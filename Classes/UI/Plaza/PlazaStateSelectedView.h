//
//  PlazaStateSelectedView.h
//  sillyChat
//
//  Created by haowenliang on 15/4/21.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlazaStateSelectedProtocol <NSObject>
@optional
- (void)didSelectItemWithDatasource:(NSDictionary*)datasource;

@end

@interface PlazaStateSelectedView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, assign) id<PlazaStateSelectedProtocol> delegate;
- (void)dismissWithAnimation:(BOOL)animation;
- (void)showInView:(UIView*)superview;
@end
