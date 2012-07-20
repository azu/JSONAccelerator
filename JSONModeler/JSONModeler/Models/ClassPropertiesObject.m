//
//  ClassPropertiesObject.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "ClassPropertiesObject.h"
#import "ClassBaseObject.h"
#import "NSString+Nerdery.h"
#import "OutputLanguageWriterObjectiveC.h"

@interface ClassPropertiesObject ()

@end

@implementation ClassPropertiesObject
@synthesize name = _name;
@synthesize jsonName = _mappedName;
@synthesize type = _type;
@synthesize otherType = _otherType;

@synthesize collectionType = _collectionType;
@synthesize collectionTypeString = _collectionTypeString;

@synthesize referenceClass = _referenceClass;

@synthesize isClass = _isClass;
@synthesize isAtomic = _isAtomic;
@synthesize isReadWrite = _isReadWrite;
@synthesize semantics = _semantics;

// Builds the header implementation and is convienient for debugging
- (NSString *) description 
{
    OutputLanguageWriterObjectiveC *writer = [OutputLanguageWriterObjectiveC new];
    return [writer propertyForProperty:self];
}

#pragma mark - NSCoding methods

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.jsonName = [aDecoder decodeObjectForKey:@"jsonName"];
    self.type = [aDecoder decodeIntForKey:@"type"];
    self.otherType = [aDecoder decodeObjectForKey:@"otherType"];
    
    self.collectionType = [aDecoder decodeIntForKey:@"collectionType"];
    self.collectionTypeString = [aDecoder decodeObjectForKey:@"collectionTypeString"];
    
    self.referenceClass = [aDecoder decodeObjectForKey:@"referenceClass"];
    
    self.isClass = [aDecoder decodeBoolForKey:@"isClass"];
    self.isAtomic = [aDecoder decodeBoolForKey:@"isAtomic"];
    self.isReadWrite = [aDecoder decodeBoolForKey:@"isReadWrite"];
    self.semantics = [aDecoder decodeIntForKey:@"semantics"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_mappedName forKey:@"jsonName"];
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeObject:_otherType forKey:@"otherType"];
    
    [aCoder encodeInt:_collectionType forKey:@"collectionType"];
    [aCoder encodeObject:_collectionTypeString forKey:@"collectionTypeString"];
    
    [aCoder encodeObject:_referenceClass forKey:@"referenceClass"];
    
    [aCoder encodeBool:_isClass forKey:@"isClass"];
    [aCoder encodeBool:_isAtomic forKey:@"isAtomic"];
    [aCoder encodeBool:_isReadWrite forKey:@"isReadWrite"];
    [aCoder encodeInt:_semantics forKey:@"semantics"];
    
}

@end
