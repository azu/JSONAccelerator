//
//  ClassPropertiesObject.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SetterSemanticStrong = 0,
    SetterSemanticWeak,
    SetterSemanticCopy,
    SetterSemanticAssign,
    SetterSemanticRetain
} SetterSemantics;

@interface ClassPropertiesObject : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *jsonName;
@property (nonatomic, copy) NSString *type;

@property (assign) BOOL isClass;
@property (assign) BOOL isAtomic;
@property (assign) BOOL isReadWrite;
@property (assign) SetterSemantics semantics;

- (NSString *)setterForType:(OutputType) type;

@end
