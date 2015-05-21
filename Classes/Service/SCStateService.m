//
//  SCStateService.m
//  sillyChat
//
//  Created by haowenliang on 15/5/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SCStateService.h"
#import "DPLbsServerEngine.h"

@implementation SCStateService

+ (instancetype)shareInstance
{
    static SCStateService* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[SCStateService alloc] init];
    });
    return s_instance;
}

#pragma mark - Class Method
- (NSMutableDictionary*)filterDatasource
{
    static NSMutableDictionary* _filterDatasource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"FilterList" ofType:@"plist"];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary* dict = [data objectForKey:@"FilterList"];
        _filterDatasource = [[NSMutableDictionary alloc] initWithDictionary:dict];
    });
    return _filterDatasource;
}

//信息标签
- (NSUInteger)selectedMsgTag
{
    NSArray* msgTags = [[self filterDatasource] objectForKey:@"section1"];
    for (NSDictionary* dict in msgTags) {
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            return [[dict objectForKey:@"fid"] unsignedIntegerValue];
        }
    }
    return 0;
}

//信息标签
- (NSString*)selectedMsgWording
{
    NSArray* msgTags = [[self filterDatasource] objectForKey:@"section1"];
    for (NSDictionary* dict in msgTags) {
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            return [dict objectForKey:@"title"];
        }
    }
    return @"all";
}

//最低位0全部，1本地
//第二第三位，00全部，01男，10女
- (NSUInteger)selectedFilter
{
    NSUInteger gendar = 0;
    NSArray* Gendars = [[self filterDatasource] objectForKey:@"section2"];
    for (NSDictionary* dict in Gendars) {
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            gendar = [[dict objectForKey:@"fid"] unsignedIntegerValue];
            break;
        }
    }
    NSUInteger place = 0;
    NSArray* msgTags = [[self filterDatasource] objectForKey:@"section0"];
    for (NSDictionary* dict in msgTags) {
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            place = [[dict objectForKey:@"fid"] unsignedIntegerValue];
            break;
        }
    }
    return gendar + place;
}

- (NSString*)filterMessage
{
    NSMutableString* mutStr = [[NSMutableString alloc] initWithString:@""];
    
    NSArray* Places = [[self filterDatasource] objectForKey:@"section0"];
    for (NSDictionary* dict in Places) {
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            if ([[dict objectForKey:@"fid"] integerValue] == 1) {
                NSString* city = [[DPLbsServerEngine shareInstance] city];
                if (!city.length) {
                    city = @"海外";
                }
                [mutStr appendString:city];
            }else{
                [mutStr appendString:[dict objectForKey:@"title"]];
            }
            break;
        }
    }
    [mutStr appendString:@"."];
    NSArray* msgTags = [[self filterDatasource] objectForKey:@"section1"];
    for (NSDictionary* dict in msgTags) {
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            [mutStr appendString:[dict objectForKey:@"title"]];
            break;
        }
    }
    [mutStr appendString:@"."];
    NSArray* Gendars = [[self filterDatasource] objectForKey:@"section2"];
    for (NSDictionary* dict in Gendars) {
        if ([[dict objectForKey:@"isSelected"] boolValue]){
            [mutStr appendString:[dict objectForKey:@"title"]];
            break;
        }
    }
    return mutStr;
}

- (void)setSelectedStateTag:(NSUInteger)fid
{
    [self setSelectedStateTag:fid inSection:@"section1"];
    [self setSelectedStateTag:0 inSection:@"section0"];
    [self setSelectedStateTag:0 inSection:@"section2"];
}

- (void)setSelectedStateTag:(NSUInteger)fid inSection:(NSString*)section
{
    NSArray* msgTags = [[self filterDatasource] objectForKey:section];
    NSMutableArray* mutFilter = [NSMutableArray arrayWithArray:msgTags];
    for (NSDictionary* dict in msgTags) {
        NSMutableDictionary* mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        if ([[mutDict objectForKey:@"fid"] unsignedIntegerValue] == fid) {
            [mutDict setValue:@(YES) forKey:@"isSelected"];
        }else{
            [mutDict setValue:@(NO) forKey:@"isSelected"];
        }
        
        [mutFilter replaceObjectAtIndex:[msgTags indexOfObject:dict] withObject:mutDict];
    }
    [[self filterDatasource] setObject:mutFilter forKey:section];
}


#pragma mark -
- (NSArray*)stateStillList
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"PropertyList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    return [data objectForKey:@"StateList"];
}

- (NSDictionary*)getStateInfoOfId:(NSUInteger)stateId
{
    NSArray* array = [self stateStillList];
    for (NSDictionary* dict in array) {
        if ([[dict objectForKey:@"fid"] unsignedIntegerValue] == stateId) {
            return dict;
        }
    }
    return nil;
}

@end
