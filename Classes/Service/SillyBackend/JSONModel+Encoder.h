//
//  JSONModel+Encoder.h
//  biubiu
//
//  Created by haowenliang on 15/2/8.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "JSONModel.h"

@interface JSONModel (Encoder)

-(void)encodeWithCoder:(NSCoder *)encoder;
-(id)initWithCoder:(NSCoder *)decoder;

@end
