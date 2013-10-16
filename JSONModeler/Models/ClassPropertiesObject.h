//
//  ClassPropertiesObject.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ClassBaseObject;

typedef enum {
    SetterSemanticStrong = 0,
    SetterSemanticWeak,
    SetterSemanticCopy,
    SetterSemanticAssign,
    SetterSemanticRetain
} SetterSemantics;

typedef enum {
    PropertyTypeString = 0,
    PropertyTypeArray,
    PropertyTypeDictionary,
    PropertyTypeInt,
    PropertyTypeDouble,
    PropertyTypeBool,
    PropertyTypeClass,
    PropertyTypeOther
} PropertyType;

@interface ClassPropertiesObject : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *jsonName;
@property (nonatomic, assign) PropertyType type;
@property (nonatomic, copy) NSString *otherType;

/* The following 2 properties are used when the instance represents a collection (e.g., ArrayList in java) and needs a secondary class type (e.g. ArrayList<String>) */
@property (nonatomic, assign) PropertyType collectionType;
@property (nonatomic, copy) NSString *collectionTypeString;

@property (weak) ClassBaseObject *referenceClass;

@property (assign) BOOL isClass;
@property (assign) BOOL isAtomic;
@property (assign) BOOL isReadWrite;
@property (assign) SetterSemantics semantics;

@end
