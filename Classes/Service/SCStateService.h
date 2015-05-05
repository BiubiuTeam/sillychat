//
//  SCStateService.h
//  sillyChat
//
//  Created by haowenliang on 15/5/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCStateService : NSObject

+ (instancetype)shareInstance;

- (NSMutableDictionary*)filterDatasource;
- (NSUInteger)selectedMsgTag;
//最低位0全部，1本地
//第二第三位，00全部，01男，10女
- (NSUInteger)selectedFilter;
- (NSString*)filterMessage;
- (void)setSelectedStateTag:(NSUInteger)fid;
- (NSString*)selectedMsgWording;

/*发表选择状态*/
- (NSArray*)stateStillList;
- (NSDictionary*)getStateInfoOfId:(NSUInteger)stateId;
@end
