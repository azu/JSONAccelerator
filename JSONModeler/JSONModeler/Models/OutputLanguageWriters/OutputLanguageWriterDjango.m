//
//  OutputLanguageWriterDjango.m
//  JSONModeler
//
//  Created by Sean Hickey on 1/26/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "OutputLanguageWriterDjango.h"
#import "ClassBaseObject.h"

#import "NSString+Nerdery.h"

static NSUInteger kDjangoModelMaxTextLength = 255;

@interface OutputLanguageWriterDjango () {
@private
    
}

- (NSString *)pythonFileForClassObjects:(NSArray *)classObjects;

@end

@implementation OutputLanguageWriterDjango

-(BOOL)writeClassObjects:(NSDictionary *)classObjectsDict toURL:(NSURL *)url options:(NSDictionary *)options generatedError:(BOOL *)generatedErrorFlag
{
    
    BOOL filesHaveHadError = NO;
    BOOL filesHaveBeenWritten = NO;
    
    NSArray *classObjects = [classObjectsDict allValues];
    for (ClassBaseObject *base in classObjects) {
        if([[base className] isEqualToString:@"InternalBaseClass"]) {
            NSString *newBaseClassName;
            if (nil != [options objectForKey:kDjangoWritingOptionBaseClassName]) {
                newBaseClassName = [options objectForKey:kDjangoWritingOptionBaseClassName];
            }
            else {
                newBaseClassName = @"BaseClass";
            }
            BOOL hasUniqueFileNameBeenFound = NO;
            NSUInteger classCheckInteger = 2;
            while (hasUniqueFileNameBeenFound == NO) {
                hasUniqueFileNameBeenFound = YES;
                for(ClassBaseObject *collisionBaseObject in classObjects) {
                    if([[collisionBaseObject className] isEqualToString:newBaseClassName]) {
                        hasUniqueFileNameBeenFound = NO; 
                    }
                }
                if(hasUniqueFileNameBeenFound == NO) {
                    newBaseClassName = [NSString stringWithFormat:@"%@%i", newBaseClassName, classCheckInteger];
                    classCheckInteger++;
                }
            }
            
            [base setClassName:newBaseClassName];
        }
    }
    
    
    NSString *pyFile = [self pythonFileForClassObjects:classObjects];
    
    NSError *error;
    [pyFile writeToURL:[url URLByAppendingPathComponent:@"jsonModel.py"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        filesHaveHadError = YES;
    }
    else {
        filesHaveBeenWritten = YES;
    }
    
    *generatedErrorFlag = filesHaveHadError;
    
    return filesHaveBeenWritten;
    
}

- (NSString *)pythonFileForClassObjects:(NSArray *)classObjects
{
    /* Reconstruct the classes so that relationships are in the child class, not parent */
    NSMutableDictionary *pythonClasses = [[NSMutableDictionary alloc] init];
    
    for (ClassBaseObject *classObject in classObjects) {
        if (nil == [pythonClasses objectForKey:classObject.className]) {
            NSMutableDictionary *pythonClass = [[NSMutableDictionary alloc] init];
            [pythonClasses setObject:pythonClass forKey:classObject.className];
        }
        
        NSMutableDictionary *pythonClass = [pythonClasses objectForKey:classObject.className];
        for (ClassPropertiesObject *property in [[classObject properties] allValues]) {
            PropertyType type = property.type;
            if (type == PropertyTypeString) {
                [pythonClass setObject:@"string" forKey:property.name];
            }
            else if (type == PropertyTypeInt) {
                [pythonClass setObject:@"int" forKey:property.name];
            }
            else if (type == PropertyTypeDouble) {
                [pythonClass setObject:@"double" forKey:property.name];
            }
            else if (type == PropertyTypeBool) {
                [pythonClass setObject:@"bool" forKey:property.name];
            }
            else if (type == PropertyTypeClass) {
                /* Add a one-to-one relationship to the child class */
                if (nil == [pythonClasses objectForKey:[property.name objectiveCClassString]]) {
                    NSMutableDictionary *childClass = [[NSMutableDictionary alloc] init];
                    [pythonClasses setObject:childClass forKey:[property.name objectiveCClassString]];
                }
                NSMutableDictionary *childClass = [pythonClasses objectForKey:[property.name objectiveCClassString]];
                [childClass setObject:classObject.className forKey:[NSString stringWithFormat:@"oneToOne%@", classObject.className]];
            }
            else if (type == PropertyTypeArray) {
                /* Add a many-to-one relationship to the child class */
                if (nil == [pythonClasses objectForKey:[property.name objectiveCClassString]]) {
                    NSMutableDictionary *childClass = [[NSMutableDictionary alloc] init];
                    [pythonClasses setObject:childClass forKey:[property.name objectiveCClassString]];
                }
                NSMutableDictionary *childClass = [pythonClasses objectForKey:[property.name objectiveCClassString]];
                [childClass setObject:classObject.className forKey:[NSString stringWithFormat:@"manyToOne%@", classObject.className]];
                if (property.collectionType == PropertyTypeInt) {
                    [childClass setObject:@"int" forKey:property.name];
                }
                else if (property.collectionType == PropertyTypeDouble) {
                    [childClass setObject:@"double" forKey:property.name];
                }
                else if (property.collectionType == PropertyTypeString) {
                    [childClass setObject:@"string" forKey:property.name];
                }
                else if (property.collectionType == PropertyTypeBool) {
                    [childClass setObject:@"bool" forKey:property.name];
                }
            }
        }
    }
    
    NSMutableString *fileString = [NSMutableString stringWithString:@"from django.db import models\n"];
    
    for (NSString *className in pythonClasses) {
        [fileString appendFormat:@"\nclass %@(models.Model):\n", className];
        NSDictionary *properties = [pythonClasses objectForKey:className];
        for (NSString *property in properties) {
            /* If it's a simple type, define the database column type */
            NSString *type = [properties objectForKey:property];
            if ([type isEqualToString:@"string"]) {
                [fileString appendFormat:@"\t%@ = models.CharField(max_length=%i, blank=True)\n", [property underscoreDelimitedString], kDjangoModelMaxTextLength];
            }
            else if ([type isEqualToString:@"int"]) {
                [fileString appendFormat:@"\t%@ = models.IntegerField(blank=True, null=True)\n", [property underscoreDelimitedString]];
            }
            else if ([type isEqualToString:@"double"]) {
                [fileString appendFormat:@"\t%@ = models.FloatField(blank=True)\n", [property underscoreDelimitedString]];
            }
            else if ([type isEqualToString:@"bool"]) {
                [fileString appendFormat:@"\t%@ = models.BooleanField(blank=True, null=True)\n", [property underscoreDelimitedString]];
            }
            /* ...otherwise, make a relationship */
            else {
                if ([property hasPrefix:@"oneToOne"]) {
                    [fileString appendFormat:@"\t%@ = models.OneToOneField(\"%@\", blank=True)\n", [[properties objectForKey:property] underscoreDelimitedString], [properties objectForKey:property]];
                }
                else if ([property hasPrefix:@"manyToOne"]) {
                    [fileString appendFormat:@"\t%@ = models.ForeignKey(\"%@\", blank=True)\n", [[properties objectForKey:property] underscoreDelimitedString], [properties objectForKey:property]];
                }
                else {
                    NSLog(@"%@ : %@->%@", className, property, [properties objectForKey:property]);
                }
            }
        }
        [fileString appendString:@"\n"];
    }
    
    return fileString;
    
}

@end
