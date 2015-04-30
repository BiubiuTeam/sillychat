//
//  MetroCollectionViewCell.h
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SillyBroacastModel;
@interface MetroCollectionViewCell : UICollectionViewCell

- (void)updateMetroWithData:(SillyBroacastModel*)datasource;
@end
