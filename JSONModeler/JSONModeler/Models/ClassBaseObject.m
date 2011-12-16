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

- (NSDictionary *)outputStringsWithType:(OutputLanguage)type 
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(type == OutputLanguageObjectiveC) {
        [dict setObject:[self ObjC_HeaderFile] forKey:[NSString stringWithFormat:@"%@.h", _className]];
        [dict setObject:[self ObjC_ImplementationFile] forKey:[NSString stringWithFormat:@"%@.m", _className]];        
    } else if (type == OutputLanguageJava) {
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
                forwardDeclarationString = [NSString stringWithFormat:@"@class %@", [[property referenceClass] className]]; 
            } else {
                forwardDeclarationString = [forwardDeclarationString stringByAppendingFormat:@", %@", [[property referenceClass] className]];
            }
        }
    }
    
    if([forwardDeclarationString isEqualToString:@""] == NO) {
        forwardDeclarationString = [forwardDeclarationString stringByAppendingString:@";"];        
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
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    

    // IMPORTS
    NSMutableArray *importArray = [NSMutableArray array];
    NSString *importString = @"";
    for(ClassPropertiesObject *property in [_properties allValues]) {
        if([property isClass]) {
            [importArray addObject:[[property referenceClass] className]];
        }
        // Check References
        NSArray *referenceArray = [property setterReferenceClassesForLanguage:OutputLanguageObjectiveC];
        for(NSString *referenceString in referenceArray) {
            if(![importArray containsObject:referenceString]) {
                [importArray addObject:referenceString];
            }
        }
    }
            
    for(NSString *referenceImport in importArray) {
        importString = [importString stringByAppendingFormat:@"#import \"%@.h\"\n", referenceImport];
    }
    
    
    // SYNTHESIZE
    NSString *sythesizeString = @"";
    for(ClassPropertiesObject *property in [_properties allValues]) {
        sythesizeString = [sythesizeString stringByAppendingFormat:@"@synthesize %@ = _%@;\n", property.name, property.name];
    }
    
    // SETTERS
    NSString *settersString = @"";
    for(ClassPropertiesObject *property in [_properties allValues]) {
        settersString = [settersString stringByAppendingString:[property setterForLanguage:OutputLanguageObjectiveC]];
    }
    
    // DEALLOC SECTION
    NSString *deallocString = @"";
    
    /* Add dealloc method only if not building for ARC */
    if( ![[[NSUserDefaultsController sharedUserDefaultsController] defaults] boolForKey:@"buildForARC"] ) {
        deallocString = @"\n- (void)dealloc\n{\n";
        for(ClassPropertiesObject *property in [_properties allValues]) {
            if([property type] != PropertyTypeInt && [property type] != PropertyTypeDouble){
                deallocString = [deallocString stringByAppendingString:[NSString stringWithFormat:@"    [_%@ release];\n", property.name]];
            }
        }
        deallocString = [deallocString stringByAppendingString:@"    [super dealloc];\n}\n"];
    } 
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:_className];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DATE}" withString:[dateFormatter stringFromDate:currentDate]];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{IMPORT_BLOCK}" withString:importString];    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SYNTHESIZE_BLOCK}" withString:sythesizeString];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERS}" withString:settersString];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DEALLOC}" withString:deallocString];
    
    return templateString;
}

- (NSString *) Java_ImplementationFile
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *interfaceTemplate = [mainBundle pathForResource:@"JavaTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:_className];
    
    // Public Properties
    NSString *propertiesString = @"";
    for(ClassPropertiesObject *property in [_properties allValues]) {
        propertiesString = [propertiesString stringByAppendingString:[property propertyForLanguage:OutputLanguageJava]];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{PROPERTIES}" withString:propertiesString];
    
    
    // Setters    
    NSString *settersString = @"";
    for(ClassPropertiesObject *property in [_properties allValues]) {
        settersString = [settersString stringByAppendingString:[property setterForLanguage:OutputLanguageJava]];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERS}" withString:settersString];    
    
    NSString *rawObject = @"rawObject";
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{OBJECTNAME}" withString:rawObject];
    
    return templateString;
}

@end
