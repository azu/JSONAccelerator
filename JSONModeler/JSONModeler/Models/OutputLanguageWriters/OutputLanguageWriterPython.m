//
//  OutputLanguageWriterPython.m
//  JSONModeler
//
//  Created by Sean Hickey on 1/26/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "OutputLanguageWriterPython.h"
#import "ClassBaseObject.h"

#import "NSString+Nerdery.h"

#define kPythonPropertyPrefix @"        "

@interface OutputLanguageWriterPython () {
@private
    
}

- (NSString *)pythonFileForClassObjects:(NSArray *)classObjects;

@end

@implementation OutputLanguageWriterPython

-(BOOL)writeClassObjects:(NSDictionary *)classObjectsDict toURL:(NSURL *)url options:(NSDictionary *)options generatedError:(BOOL *)generatedErrorFlag
{
    
    BOOL filesHaveHadError = NO;
    BOOL filesHaveBeenWritten = NO;
    
    NSArray *classObjects = [classObjectsDict allValues];
    for (ClassBaseObject *base in classObjects) {
        if([[base className] isEqualToString:@"InternalBaseClass"]) {
            NSString *newBaseClassName;
            if (nil != [options objectForKey:kPythonWritingOptionBaseClassName]) {
                newBaseClassName = [options objectForKey:kPythonWritingOptionBaseClassName];
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
                    newBaseClassName = [NSString stringWithFormat:@"%@%li", newBaseClassName, classCheckInteger];
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
    /*
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
                // Add a one-to-one relationship to the child class
                if (nil == [pythonClasses objectForKey:[property.name uppercaseCamelcaseString]]) {
                    NSMutableDictionary *childClass = [[NSMutableDictionary alloc] init];
                    [pythonClasses setObject:childClass forKey:[property.name uppercaseCamelcaseString]];
                }
                NSMutableDictionary *childClass = [pythonClasses objectForKey:[property.name uppercaseCamelcaseString]];
                [childClass setObject:classObject.className forKey:[NSString stringWithFormat:@"oneToOne%@", classObject.className]];
            }
            else if (type == PropertyTypeArray) {
                // Add a many-to-one relationship to the child class
                if (nil == [pythonClasses objectForKey:[property.name uppercaseCamelcaseString]]) {
                    NSMutableDictionary *childClass = [[NSMutableDictionary alloc] init];
                    [pythonClasses setObject:childClass forKey:[property.name uppercaseCamelcaseString]];
                }
                NSMutableDictionary *childClass = [pythonClasses objectForKey:[property.name uppercaseCamelcaseString]];
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
    */
    
    NSMutableString *fileString = [NSMutableString stringWithString:@""];
    
    for (ClassBaseObject *classObject in classObjects) {
        
        [fileString appendFormat:@"\nclass %@(object):\n\n    def __init__(self):\n", classObject.className];
        [fileString appendFormat:@"%@\"\"\"\n", kPythonPropertyPrefix];
        NSString *formatString = @"%@: attribute %@ : %@\n";
        
        
        for (ClassPropertiesObject *property in [[classObject properties] allValues]) {
            PropertyType type = property.type;
            if (type == PropertyTypeString) {
                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property.name underscoreDelimitedString], @"string"];
            }
            else if (type == PropertyTypeInt) {
                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property.name underscoreDelimitedString], @"int"];
            }
            else if (type == PropertyTypeDouble) {
                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property.name underscoreDelimitedString], @"float"];
            }
            else if (type == PropertyTypeBool) {
                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property.name underscoreDelimitedString], @"bool"];
            }
            else if (type == PropertyTypeClass) {
                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property.name underscoreDelimitedString], [property.referenceClass.className uppercaseCamelcaseString]];
                // Add a one-to-one relationship to the child class
//                if (nil == [pythonClasses objectForKey:[property.name uppercaseCamelcaseString]]) {
//                    NSMutableDictionary *childClass = [[NSMutableDictionary alloc] init];
//                    [pythonClasses setObject:childClass forKey:[property.name uppercaseCamelcaseString]];
//                }
//                NSMutableDictionary *childClass = [pythonClasses objectForKey:[property.name uppercaseCamelcaseString]];
//                [childClass setObject:classObject.className forKey:[NSString stringWithFormat:@"oneToOne%@", classObject.className]];
            }
            else if (type == PropertyTypeArray) {
                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property.name underscoreDelimitedString], @"array"];
                // Add a many-to-one relationship to the child class
//                if (nil == [pythonClasses objectForKey:[property.name uppercaseCamelcaseString]]) {
//                    NSMutableDictionary *childClass = [[NSMutableDictionary alloc] init];
//                    [pythonClasses setObject:childClass forKey:[property.name uppercaseCamelcaseString]];
//                }
//                NSMutableDictionary *childClass = [pythonClasses objectForKey:[property.name uppercaseCamelcaseString]];
//                [childClass setObject:classObject.className forKey:[NSString stringWithFormat:@"manyToOne%@", classObject.className]];
//                if (property.collectionType == PropertyTypeInt) {
//                    [childClass setObject:@"int" forKey:property.name];
//                }
//                else if (property.collectionType == PropertyTypeDouble) {
//                    [childClass setObject:@"double" forKey:property.name];
//                }
//                else if (property.collectionType == PropertyTypeString) {
//                    [childClass setObject:@"string" forKey:property.name];
//                }
//                else if (property.collectionType == PropertyTypeBool) {
//                    [childClass setObject:@"bool" forKey:property.name];
//                }
            }
        }
        
        [fileString appendFormat:@"%@\"\"\"\n", kPythonPropertyPrefix];
        
        for (ClassPropertiesObject *property in [[classObject properties] allValues]) {
            /* If it's a simple type, define the database column type */
            [fileString appendFormat:@"%@self.%@ = None\n", kPythonPropertyPrefix, [property.name underscoreDelimitedString]];
        }
        
        [fileString appendString:@"\n"];
        
        
    }
    
//    for (NSString *className in pythonClasses) {
//        [fileString appendFormat:@"\nclass %@(object):\n\n         def __init__(self):\n", className];
//        [fileString appendFormat:@"%@\"\"\"\n", kPythonPropertyPrefix];
//        
//        NSDictionary *properties = [pythonClasses objectForKey:className];
//        NSString *formatString = @"%@: attribute %@ : %@\n";
//        for (NSString *property in properties) {
//            /* If it's a simple type, define the database column type */
//            NSString *type = [properties objectForKey:property];
//            if ([type isEqualToString:@"string"]) {
//                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property underscoreDelimitedString], @"string"];
//            }
//            else if ([type isEqualToString:@"int"]) {
//                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property underscoreDelimitedString], @"int"];
//            }
//            else if ([type isEqualToString:@"double"]) {
//                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property underscoreDelimitedString], @"float"];
//            }
//            else if ([type isEqualToString:@"bool"]) {
//                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property underscoreDelimitedString], @"bool"];
//            }
//            /* ...otherwise, make a relationship */
//            else {
//                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property underscoreDelimitedString], @"string"];
//                if ([property hasPrefix:@"oneToOne"]) {
//                    [fileString appendFormat:formatString, kPythonPropertyPrefix, [property underscoreDelimitedString], [properties objectForKey:property]];
//                }
//                else if ([property hasPrefix:@"manyToOne"]) {
//                    [fileString appendFormat:formatString, kPythonPropertyPrefix, [property underscoreDelimitedString], @"array"];
//                }
//            }
//        }
//        [fileString appendFormat:@"%@\"\"\"\n", kPythonPropertyPrefix];
//        
//        for (NSString *property in properties) {
//            /* If it's a simple type, define the database column type */
//            [fileString appendFormat:@"%@self.%@ = None\n", kPythonPropertyPrefix, [property underscoreDelimitedString]];
//        }
//        
//        [fileString appendString:@"\n"];
//    }
//    
    return fileString;
    
}

#pragma mark - Reserved Words Methods

- (NSSet *)reservedWords
{
    return [NSSet setWithObjects:@"and", @"assert", @"break", @"class", @"continue", @"def", @"del", @"elif", @"else", @"except", @"exec", @"finally", @"for", @"from", @"global",  @"id", @"if", @"import", @"in", @"is", @"lambda", @"not", @"or", @"pass", @"print", @"raise", @"return", @"self", @"try", @"type", @"while", @"yield", nil];
}

- (NSString *)classNameForObject:(ClassBaseObject *)classObject fromReservedWord:(NSString *)reservedWord
{
    NSString *className = [[reservedWord stringByAppendingString:@"Class"] capitalizeFirstCharacter];
    NSRange startsWithNumeral = [[className substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
    if ( !(startsWithNumeral.location == NSNotFound && startsWithNumeral.length == 0) ) {
        className = [@"Num" stringByAppendingString:className];
    }
    
    NSMutableArray *components = [[className componentsSeparatedByString:@"_"] mutableCopy];
    
    NSInteger numComponents = [components count];
    for (int i = 0; i < numComponents; ++i) {
        [components replaceObjectAtIndex:i withObject:[(NSString *)[components objectAtIndex:i] capitalizeFirstCharacter]];
    }
    return [components componentsJoinedByString:@""];
}

- (NSString *)propertyNameForObject:(ClassPropertiesObject *)propertyObject inClass:(ClassBaseObject *)classObject fromReservedWord:(NSString *)reservedWord
{
    NSString *propertyName = [[reservedWord stringByAppendingString:@"Property"] uncapitalizeFirstCharacter];
    NSRange startsWithNumeral = [[propertyName substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
    if ( !(startsWithNumeral.location == NSNotFound && startsWithNumeral.length == 0) ) {
        propertyName = [@"num" stringByAppendingString:propertyName];
    }
    return [propertyName uncapitalizeFirstCharacter];
}

@end
