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
            if (nil != options[kPythonWritingOptionBaseClassName]) {
                newBaseClassName = options[kPythonWritingOptionBaseClassName];
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
            }
            else if (type == PropertyTypeArray) {
                [fileString appendFormat:formatString, kPythonPropertyPrefix, [property.name underscoreDelimitedString], @"array"];
            }
        }
        
        [fileString appendFormat:@"%@\"\"\"\n", kPythonPropertyPrefix];
        
        for (ClassPropertiesObject *property in [[classObject properties] allValues]) {
            /* If it's a simple type, define the database column type */
            [fileString appendFormat:@"%@self.%@ = None\n", kPythonPropertyPrefix, [property.name underscoreDelimitedString]];
        }
        
        [fileString appendString:@"\n"];
        
        
    }
    
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
        components[i] = [(NSString *)components[i] capitalizeFirstCharacter];
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
