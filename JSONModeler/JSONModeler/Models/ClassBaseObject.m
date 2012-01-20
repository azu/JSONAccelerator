//
//  ClassBaseObject.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"
#import "NSString+Nerdery.h"
#import "OutputLanguageWriterObjectiveC.h"
#import "OutputLanguageWriterJava.h"

@interface ClassBaseObject ()

@end

@implementation ClassBaseObject

@synthesize className = _className;
@synthesize baseClass = _baseClass;
@synthesize properties = _properties;

- (id) init
{
    self = [super init];
    if(self) {
        self.properties = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSDictionary *)outputStringsWithType:(OutputLanguage)type 
{
    id<OutputLanguageWriterProtocol> writer = nil;
    
    if(type == OutputLanguageObjectiveC) {
        writer = [OutputLanguageWriterObjectiveC new];
    } else if (type == OutputLanguageJava) {
        writer = [OutputLanguageWriterJava new];
    }
    [writer setClassObject:self];
    
    return [writer getOutputFiles];
}



#pragma mark - NSCoding methods

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    self.className = [aDecoder decodeObjectForKey:@"className"];
    self.baseClass = [aDecoder decodeObjectForKey:@"baseClass"];
    self.properties = [aDecoder decodeObjectForKey:@"properties"];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_className forKey:@"className"];
    [aCoder encodeObject:_baseClass forKey:@"baseClass"];
    [aCoder encodeObject:_properties forKey:@"properties"];    
}

@end
