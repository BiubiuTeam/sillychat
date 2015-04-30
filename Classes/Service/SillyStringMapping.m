//
//  SillyStringMapping.m
//  sillyChat
//
//  Created by haowenliang on 15/4/13.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SillyStringMapping.h"
#import "NSKeyedUnarchiverAdditions.h"

@interface SillyStringMapping()

@property (nonatomic, strong) NSMutableDictionary* mapFactory;

@end

@implementation SillyStringMapping

+ (instancetype)shareInstance
{
    static SillyStringMapping* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[SillyStringMapping alloc] init];
    });
    return s_instance;
}

+ (NSString*)sillyMappingCacheFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* doc = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/keymapping", doc];
    DPTrace("\nCacheFilePath: %@\n",path);
    return path;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSString* filePath = [SillyStringMapping sillyMappingCacheFilePath];
//        NSString* fileName = [NSString stringWithFormat:@"%@/keyMapping",filePath];
        NSDictionary* object = nil;
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithFileNoException:filePath];
        }
        @catch (NSException *exception) {}
        @finally {}
        
        if ([object count]) {
            [self.mapFactory addEntriesFromDictionary:object];
        }
    }
    return self;
}

- (NSMutableDictionary *)mapFactory
{
    if (nil == _mapFactory) {
        _mapFactory = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return _mapFactory;
}

- (NSString*)getMappingStringFromString:(NSString*)fromString
{
    return [self.mapFactory objectForKey:fromString];
}

- (BOOL)mappingString:(NSString*)fromString toString:(NSString*)toString
{
    if (![toString length] || ![fromString length]) {
        DPTrace("数据出错 net path: %@， local path: %@",fromString, toString);
        return NO;
    }
    [self.mapFactory setObject:toString forKey:fromString];
    
    if ([_mapFactory count]) {
        NSString* filePath = [SillyStringMapping sillyMappingCacheFilePath];
//        NSString* fileName = [NSString stringWithFormat:@"%@/keyMapping",filePath];
        return [NSKeyedArchiver archiveRootObject:_mapFactory toFile:filePath];
    }
    return NO;
}

@end
