//
//  ClassBaseObject.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"

@interface ClassBaseObject ()

- (NSString *) ObjC_HeaderFile;
- (NSString *) ObjC_ImplementationFile;

- (NSString *) Java_ImplementationFile;

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

- (NSDictionary *)outputStringsWithType:(OutputType)type 
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(type == OutputTypeObjectiveC) {
        [dict setObject:[self ObjC_HeaderFile] forKey:[NSString stringWithFormat:@"%@.h", _className]];
        [dict setObject:[self ObjC_ImplementationFile] forKey:[NSString stringWithFormat:@"%@.m", _className]];        
    } else if (type == OutputTypeJava) {
        [dict setObject:[self Java_ImplementationFile] forKey:[NSString stringWithFormat:@"%@.java", _className]];
    }
    
    return dict;
}

- (NSString *) ObjC_HeaderFile
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *interfaceTemplate = [mainBundle pathForResource:@"InterfaceTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];

    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:_className];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DATE}" withString:[dateFormatter stringFromDate:currentDate]];
        
    // First we need to find if there are any class properties, if so do the @Class business
    NSString *forwardDeclarationString = @"";
        
    for(ClassPropertiesObject *property in [_properties allValues]) {
        if([property isClass]) {
            if([forwardDeclarationString isEqualToString:@""]) {
                forwardDeclarationString = [NSString stringWithFormat:@"@class %@", [[property name] capitalizedString]]; 
            } else {
                forwardDeclarationString = [forwardDeclarationString stringByAppendingFormat:@", %@", [[property name] capitalizedString]];
            }
        }
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{FORWARD_DECLARATION}" withString:forwardDeclarationString];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{BASEOBJECT}" withString:_baseClass];
    
    NSString *propertyString = @"";
    for(ClassPropertiesObject *property in [_properties allValues]) {
        propertyString = [propertyString stringByAppendingFormat:@"%@\n", property];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{PROPERTIES}" withString:propertyString];
    
    return templateString;
}

- (NSString *) ObjC_ImplementationFile
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *implementationTemplate = [mainBundle pathForResource:@"ImplementationTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:implementationTemplate encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:_className];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DATE}" withString:[dateFormatter stringFromDate:currentDate]];
    
    NSString *sythesizeString = @"";
    for(ClassPropertiesObject *property in [_properties allValues]) {
        sythesizeString = [sythesizeString stringByAppendingFormat:@"@synthesize %@ = _%@;\n", property.name, property.name];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SYNTHESIZE_BLOCK}" withString:sythesizeString];
    
    NSString *settersString = @"";
    for(ClassPropertiesObject *property in [_properties allValues]) {
        if([property isClass]) {
            //[FlickrPhotoCollectionPhotoset instanceFromDictionary:[aDictionary objectForKey:@"photoset"]];
            settersString = [settersString stringByAppendingFormat:@"    self.%@ = [%@ instanceFromDictionary:[dict objectForKey:@\"%@\"]];\n", [property.name capitalizedString], property.name, property.jsonName];
        } else {
            settersString = [settersString stringByAppendingFormat:@"    self.%@ = [dict objectForKey:@\"%@\"];\n", property.name, property.jsonName];
        }
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERS}" withString:settersString];
    
    return templateString;
}

- (NSString *) Java_ImplementationFile
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *interfaceTemplate = [mainBundle pathForResource:@"JavaTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:_className];
    
    return templateString;
}

@end
