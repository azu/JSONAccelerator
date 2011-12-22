//
//  ClassBaseObject.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassBaseObject : NSObject <NSCoding>

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *baseClass;
@property (nonatomic, retain) NSMutableDictionary *properties;

- (NSDictionary *)outputStringsWithType:(OutputLanguage)type;

@end
