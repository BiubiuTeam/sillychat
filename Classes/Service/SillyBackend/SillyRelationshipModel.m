//
//  SillyRelationshipModel.m
//  sillyChat
//
//  Created by haowenliang on 15/3/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyRelationshipModel.h"
#import "NSString+Emoji.h"
#import "SillyBroacastModel.h"
#import "RelationShipService.h"
@implementation SillyRelationshipModel

- (NSString *)titleCont
{
    return [_titleCont stringByReplacingEmojiCheatCodesWithUnicode];
}

- (SillyBroacastModel*)broadcastModel
{
    if (_broadcastModel == nil) {
        _broadcastModel = [[SillyBroacastModel alloc] init];
        _broadcastModel.titleCont = self.titleCont;
        _broadcastModel.titleType = self.titleType;
        _broadcastModel.dvcId = self.dvcId;
        _broadcastModel.pubTime = self.pubTime;
        _broadcastModel.sortId = self.titleId;
    }
    return _broadcastModel;
}

- (NSNumber<Ignore> *)hasUnreadMessage
{
    NSString* from = self.dvcId;
    NSString* titleid = [NSString stringWithFormat:@"%@",self.titleId];
    NSInteger count = [[RelationShipService shareInstance] unreadMessageCountOfChat:[NSString stringWithFormat:@"%@%@",from,titleid]];
    if (count > 0) {
        return @YES;
    }
    return @NO;
}

+ (instancetype)newRelationShipModelWithBroadcast:(SillyBroacastModel*)broadcast
{
    SillyRelationshipModel* relation = [[SillyRelationshipModel alloc] init];
    relation.broadcastModel = broadcast;
    return relation;
}
@end


@implementation SillyRelationshipResponseModel


+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"statusCode": @"statusCode",
                                                       @"statusInfo":@"statusInfo",
                                                       @"returnData.contData": @"relationships"
                                                       }];
}


@end