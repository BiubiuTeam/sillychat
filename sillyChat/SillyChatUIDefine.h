//
//  SillyChatUIDefine.h
//  sillyChat
//
//  Created by haowenliang on 15/3/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#ifndef sillyChat_SillyChatUIDefine_h
#define sillyChat_SillyChatUIDefine_h

#define PROGRAM_STYPE (0)

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define LOAD_ICON_USE_POOL_CACHE(x) [UIImage imageNamed:[NSString stringWithFormat:@"reference/%@",x]]

#if !PROGRAM_STYPE
#define APPLICATIONCOLOR RGBACOLOR(0xff,0xde,0x32,1)
#define APPLIGHTCOLOR RGBACOLOR(0xe9, 0xce, 0x32, 1)
#else
#define APPLICATIONCOLOR RGBACOLOR(0x39, 0x38, 0x32, 1)
#define APPLIGHTCOLOR RGBACOLOR(0x23, 0x28, 0x32, 1)
#endif


#define APPBLACKCOLOR RGBACOLOR(0x39, 0x38, 0x32, 1)

#define FONT_SIZE_LARGE (18)
#define FONT_SIZE_MIDDLE (16)
#define FONT_SIZE_SMALL (14)

#endif
