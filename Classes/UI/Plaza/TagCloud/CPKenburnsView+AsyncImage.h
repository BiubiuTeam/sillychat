//
//  CPKenburnsView+AsyncImage.h
//  sillyChat
//
//  Created by haowenliang on 15/3/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "CPKenburnsView.h"
#import "UIImageView+AsyncImage.h"

#define REMOVE_ANIMOTION (0)

@interface CPKenburnsView (AsyncImage)

@property (nonatomic, strong) NSURL *imageURL;

@end

/**
 *  由后台进入前台，重新视图的动画
 */
#if REMOVE_ANIMOTION
@interface DPKenburnsView : UIImageView
#else
@interface DPKenburnsView : CPKenburnsView
#endif

@end