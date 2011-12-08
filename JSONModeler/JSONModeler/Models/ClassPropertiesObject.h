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
    PropertyTypeClass,
    PropertyTypeOther
} PropertyType;

@interface ClassPropertiesObject : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *jsonName;
@property (nonatomic, assign) PropertyType type;
@property (nonatomic, copy) NSString *otherType;

@property (weak) ClassBaseObject *referenceClass;

@property (assign) BOOL isClass;
@property (assign) BOOL isAtomic;
@property (assign) BOOL isReadWrite;
@property (assign) SetterSemantics semantics;

- (NSString *)propertyForLanguage:(OutputLanguage) language;
- (NSString *)setterForLanguage:(OutputLanguage) language;
- (NSArray *)setterReferenceClassesForLanguage:(OutputLanguage) language;
- (NSString *)typeStringForLanguage:(OutputLanguage) language;

@end
