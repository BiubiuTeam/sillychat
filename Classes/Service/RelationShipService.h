//
//  RelationShipService.h
//  sillyChat
//
//  Created by haowenliang on 15/4/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const RelationShipsDidUpdate;
extern NSString* const RelationShipsDidReload;
extern NSString* const RelationShipsUnReadMessageDidUpdate;

@class SillyBroacastModel;

@interface RelationShipService : NSObject

@property (nonatomic, assign) BOOL hasUnhandleMessage;

@property (nonatomic, strong, readonly) NSMutableArray* relationShips;
+ (instancetype)shareInstance;
- (void)linkDeviceWithBroadcast:(SillyBroacastModel*)broadcast;
- (void)reloadRelationShips:(NSNumber*)lastId;
- (void)updateRelationShips;

- (BOOL)removeRelationShipWithTitleId:(NSDictionary*)ext;

- (void)addUnreadCountOfChat:(NSString*)chatkey;
- (NSInteger)unreadMessageCountOfChat:(NSString*)chatkey;
- (void)removeUnreadCountOfChat:(NSString*)chatkey;


- (void)reloadRelationShipsWithSequence;

- (SillyBroacastModel*)getBroadcastOf:(NSString*)dvcId titleId:(NSNumber*)titleId;
@end
