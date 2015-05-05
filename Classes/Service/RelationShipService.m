//
//  RelationShipService.m
//  sillyChat
//
//  Created by haowenliang on 15/4/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "RelationShipService.h"
#import "DPLbsServerEngine.h"
#import "NSKeyedUnarchiverAdditions.h"
#import "SillyBroacastModel.h"
#import "SillyService.h"
#import "SillyResponseModel.h"
#import "SillyRelationshipModel.h"


NSString* const RelationShipsDidUpdate = @"_RelationShipsDidUpdate_";
NSString* const RelationShipsDidReload = @"_RelationShipsDidReload_";

@interface RelationShipService ()
{
    BOOL _hasUnhandleMessage;
}
@property (nonatomic, strong) NSMutableDictionary* unreadRecords;
@property (nonatomic, strong) NSDate* reloadTimeStamp;
@property (nonatomic, strong) NSMutableArray* linkOperations;
@property (nonatomic, strong) NSMutableDictionary* linkRelations;

@end

@implementation RelationShipService

+ (instancetype)shareInstance
{
    static RelationShipService* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[RelationShipService alloc] init];
    });
    return s_instance;
}

#pragma mark -
- (SillyBroacastModel *)getBroadcastOf:(NSString *)dvcId titleId:(NSNumber *)titleId
{
    for (SillyRelationshipModel* model in _relationShips) {
        if ([model.broadcastModel.dvcId isEqualToString:dvcId]) {
            if ([model.broadcastModel.titleId unsignedIntegerValue] == [titleId unsignedIntegerValue]) {
                return model.broadcastModel;
            }
        }
    }
    [self reloadRelationShips:0];
    return nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        _unreadRecords = [[NSMutableDictionary alloc] initWithCapacity:1];
        //get unread records from cache
        
        _linkRelations = [[NSMutableDictionary alloc] initWithCapacity:1];
        _relationShips = [[NSMutableArray alloc] initWithCapacity:1];
        _linkOperations = [[NSMutableArray alloc] initWithCapacity:1];
        
        NSDictionary* dict = [RelationShipService getDeviceRelationships];
        if ([dict count]) {
            [_linkRelations addEntriesFromDictionary:dict];
        }
        
        [self reloadRelationShips:@(0)];
    }
    return self;
}

- (void)reloadRelationShipsWithSequence
{
    BOOL needToUpdate = NO;
    NSDate* date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSinceDate:_reloadTimeStamp];
    if (abs(timeInterval) > 60*60) {//每隔一个小时，需要更新一次关系链
        needToUpdate = YES;
    }
    if (needToUpdate == NO) {
        return;
    }
    [self reloadRelationShips:@0];
}

- (NSInteger)unreadMessageCountOfChat:(NSString*)chatkey
{
    NSNumber* value = [_unreadRecords objectForKey:chatkey];
    return [value integerValue];
}

- (void)clearAllUnreadRecord
{
    [_unreadRecords removeAllObjects];
}

- (void)removeUnreadCountOfChat:(NSString*)chatkey
{
    [_unreadRecords removeObjectForKey:chatkey];
}

- (void)addUnreadCountOfChat:(NSString*)chatkey
{
    _hasUnhandleMessage = YES;
    
    NSNumber* value = [_unreadRecords objectForKey:chatkey];
    NSInteger count = MAX(0, [value integerValue]);
    [_unreadRecords setObject:@(count+1) forKey:chatkey];
}

- (BOOL)needToRelinkToDevice:(NSString*)dvc andSortId:(NSNumber*)sortid
{
    return YES;
    //这里需要注意，dvcId是对方的id
//    NSString* key = [NSString stringWithFormat:@"%@%@",dvc,sortid];
//    BOOL cache = [[self.linkRelations objectForKey:key] boolValue];
//    
//    if (cache == NO && [_linkOperations containsObject:key]) {
//        DPTrace("已有该请求");
//        return NO;
//    }
//    return !cache;
}

- (void)linkDeviceWithBroadcast:(SillyBroacastModel*)broadcast
{
    if ([self needToRelinkToDevice:broadcast.dvcId andSortId:broadcast.sortId]) {
        __block NSString* key = [NSString stringWithFormat:@"%@%@",broadcast.dvcId,broadcast.sortId];
        [_linkOperations addObject:key];
        __weak RelationShipService* weakSelf = self;
        [[SillyService shareInstance] markRelationshipToDeviceWithBroadCast:broadcast.sortId toDevice:broadcast.dvcId comletion:^(id json, JSONModelError *err) {
            [weakSelf.linkOperations removeObject:key];
            
            if (err == nil) {
                SillyResponseModel* model = [[SillyResponseModel alloc] initWithDictionary:json error:&err];
                if ((model && model.statusCode) || nil == err) {
                    if([model.statusCode integerValue] == 0){
                        DPTrace("链接关系链成功");
                        [weakSelf.linkRelations setObject:@(YES) forKey:key];
                        [RelationShipService saveDeviceRelationships:weakSelf.linkRelations];
                        
                        [weakSelf updateRelationShips];
                        return;
                    }else{
                        DPTrace("链接关系链失败： %@",model);
                    }
                }
            }
            DPTrace("链接关系链失败...各种失败");
        }];
    }
}

- (void)updateRelationShips
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateRelationShips) object:nil];
    
    __weak RelationShipService* weakSelf = self;
    SillyRelationshipModel* firstModel = [_relationShips firstObject];
    NSUInteger topId = 0;
    if (firstModel) {
        topId = [firstModel.sortId unsignedIntegerValue];
    }
    [[SillyService shareInstance] fetchSillyUserRelationships:2 startPosition:topId comletion:^(id json, JSONModelError *err) {
        if (nil == err) {
            SillyRelationshipResponseModel* response = [[SillyRelationshipResponseModel alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                if (response && response.statusCode) {
                    if ([response.statusCode integerValue] == 0) {
                        DPTrace("请求关系链成功");
                        NSArray* array = response.relationships;
                        if (array.count) {
                            DPTrace("有新数据");
                            [weakSelf performSelector:@selector(insertLatestRelationShips:) withObject:array];
                            [weakSelf performSelector:@selector(updateRelationShips) withObject:nil afterDelay:0.3];
                        }else{
                            DPTrace("请求数据为空");
                            [[NSNotificationCenter defaultCenter] postNotificationName:RelationShipsDidUpdate object:nil];
                        }
                    }else{
                        DPTrace("请求关系链失败 status code :%@",response.statusCode);
                    }
                }else{
                    DPTrace("转换失败");
                }
            }else{
                DPTrace("数据转换失败: %@",json);
            }
        }else{
            DPTrace("连接后台失败");
        }
    }];
}

- (void)reloadRelationShips:(NSNumber*)lastId
{
    __weak RelationShipService* weakSelf = self;
    [[SillyService shareInstance] fetchSillyUserRelationships:1 startPosition:[lastId unsignedIntegerValue] comletion:^(id json, JSONModelError *err) {
        if (nil == err) {
            SillyRelationshipResponseModel* response = [[SillyRelationshipResponseModel alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                if (response && response.statusCode) {
                    if ([response.statusCode integerValue] == 0) {
                        DPTrace("请求关系链成功");
                        NSArray* array = response.relationships;
                        if (array.count) {
                            DPTrace("有新数据");
                            [weakSelf performSelector:@selector(addMoreRelationShips:) withObject:array];
                            SillyRelationshipModel* lastModel = [weakSelf.relationShips lastObject];
                            NSNumber* lastId = @(0);
                            if (lastModel) {
                                lastId = lastModel.sortId;
                            }
                            weakSelf.reloadTimeStamp = [NSDate date];
                            [weakSelf performSelector:@selector(reloadRelationShips:) withObject:lastId afterDelay:0.3];
                        }else{
                            DPTrace("请求数据为空");
                            [[NSNotificationCenter defaultCenter] postNotificationName:RelationShipsDidReload object:nil];
                        }
                    }else{
                        DPTrace("请求关系链失败 status code :%@",response.statusCode);
                    }
                }else{
                    DPTrace("转换失败");
                }
            }else{
                DPTrace("数据转换失败: %@",json);
            }
        }else{
            DPTrace("连接后台失败");
        }
    }];
}

- (void)addMoreRelationShips:(NSArray*)relations
{
    @synchronized(_relationShips){
        NSMutableArray* tmpList = [_relationShips mutableCopy];
        for (SillyRelationshipModel* model in relations) {
            BOOL exsit = NO;
            for (SillyRelationshipModel* tmp in _relationShips) {
                if ([[model.broadcastModel titleId] unsignedIntegerValue] == [[tmp.broadcastModel titleId] unsignedIntegerValue] && [[model.broadcastModel dvcId] isEqualToString:[tmp.broadcastModel dvcId]]) {
                    exsit = YES;
                    break;
                }
            }
            if (exsit == NO) {
                [tmpList addObject:model];
            }
        }
        _relationShips = tmpList;
    }
}

- (void)insertLatestRelationShips:(NSArray *)relations
{
    @synchronized(_relationShips){
        NSMutableArray* tmpList = [_relationShips mutableCopy];
        for (SillyRelationshipModel* model in relations) {
            BOOL exsit = NO;
            NSInteger index = 0;
            for (SillyRelationshipModel* tmp in _relationShips)
            {
                if ([[model.broadcastModel titleId] unsignedIntegerValue] == [[tmp.broadcastModel titleId] unsignedIntegerValue] && [[model.broadcastModel dvcId] isEqualToString:[tmp.broadcastModel dvcId]])
                {
                    index = [_relationShips indexOfObject:tmp];
                    exsit = YES;
                    break;
                }
            }
            
            if (exsit == YES) {
                [tmpList removeObjectAtIndex:index];
            }
            
            [tmpList insertObject:model atIndex:0];
        }
        _relationShips = tmpList;
    }
}
#pragma mark - 本地化

+ (BOOL)saveDeviceRelationships:(id)object
{
    if (!object) {
        return NO;
    }
    NSString* filePath = [DPLbsServerEngine sillyChatCacheFilePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/relationships",filePath];
    return [NSKeyedArchiver archiveRootObject:object toFile:fileName];
}

+ (id)getDeviceRelationships
{
    NSString* filePath = [DPLbsServerEngine sillyChatCacheFilePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/relationships",filePath];
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFileNoException:fileName];
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return object;
}


@end
