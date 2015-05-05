//
//  SillyChatUIDefine.h
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#ifndef sillyChat_SillyChatUIDefine_h
#define sillyChat_SillyChatUIDefine_h

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define LOAD_ICON_USE_POOL_CACHE(x) [UIImage imageNamed:[NSString stringWithFormat:@"reference/%@",x]]

#define APPLICATIONCOLOR RGBACOLOR(0xff,0xd6,0x00,1)
#define APPLIGHTCOLOR RGBACOLOR(0xe9, 0xc6, 0x00, 1)

#define APPBLACKCOLOR RGBACOLOR(0x39, 0x38, 0x32, 1)

//对于那个泡泡的一些基本属性
#define EMROUND_RADIUS (99.0)
//水平居中
#define BUBBLE_CENTERX (SCREEN_WIDTH/2)
//距离底部
#define BUBBLE_MARGIN_BOTTOM (SCREEN_HEIGHT - 68)


#define ALL_BUBBLE_BOTTOM (SCREEN_HEIGHT - _size_S(25))
#define ALL_BUBBLE_BOTTOM2 (SCREEN_HEIGHT - _size_S(50))

#endif
