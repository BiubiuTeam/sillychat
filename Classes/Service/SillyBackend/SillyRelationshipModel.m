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

- (NSNumber<Ignore> *)hasUnreadMessage
{
    NSString* from = [self.broadcastModel dvcId];
    NSString* titleid = [NSString stringWithFormat:@"%@",[self.broadcastModel titleId]];
    NSInteger count = [[RelationShipService shareInstance] unreadMessageCountOfChat:[NSString stringWithFormat:@"%@%@",from,titleid]];
    if (count > 0) {
        return @YES;
    }
    return @NO;
}

+ (instancetype)newRelationShipModelWithBroadcast:(SillyBroacastModel*)broadcast
{
    SillyRelationshipModel* relation = [[SillyRelationshipModel alloc] init];
    relation.broadcastModel = (SillyBroacastModel<Optional,ConvertOnDemand>*)broadcast;
    return relation;
}

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"sortId": @"sortId",
                                                       @"titleInfo":@"broadcastModel"
                                                       }];
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