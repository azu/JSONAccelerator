//
//  ClassBaseObject.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    OutputTypeObjectiveC = 0,
    OutputTypeJava
} OutputType;

@interface ClassBaseObject : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *baseClass;
@property (nonatomic, retain) NSMutableDictionary *properties;

- (NSDictionary *)outputStringsWithType:(OutputType)type;

@end
