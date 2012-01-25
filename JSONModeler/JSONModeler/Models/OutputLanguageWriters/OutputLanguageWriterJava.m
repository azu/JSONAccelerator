//
//  OutputLanguageWriterJava.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 1/19/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "OutputLanguageWriterJava.h"
#import "ClassBaseObject.h"
#import "NSString+Nerdery.h"

@interface OutputLanguageWriterJava ()

- (NSString *) Java_ImplementationFileForClassObject:(ClassBaseObject *)classObject;

@end

@implementation OutputLanguageWriterJava
//@synthesize classObject = _classObject;

#pragma mark - File Writing Methods

- (BOOL)writeClassObjects:(NSDictionary *)classObjectsDict toURL:(NSURL *)url options:(NSDictionary *)options generatedError:(BOOL *)generatedErrorFlag
{
    BOOL filesHaveHadError = NO;
    BOOL filesHaveBeenWritten = NO;
    
    NSArray *files = [classObjectsDict allValues];
    
    /* Determine package name */
    NSString *packageName;
    if (nil != [options objectForKey:kJavaWritingOptionPackageName]) {
        packageName = [options objectForKey:kJavaWritingOptionPackageName];
    }
    else {
        /* Default value */
        packageName = @"com.MYCOMPANY.MYPROJECT.model";
    }
    
    for(ClassBaseObject *base in files) {
        // This section is to guard against people going through and renaming the class
        // to something that has already been named.
        // This will check the class name and keep appending an additional number until something has been found
        if([[base className] isEqualToString:@"InternalBaseClass"]) {
            NSString *newBaseClassName;
            if (nil != [options objectForKey:kJavaWritingOptionBaseClassName]) {
                newBaseClassName = [options objectForKey:kJavaWritingOptionBaseClassName];
            }
            else {
                newBaseClassName = @"BaseClass";
            }
            BOOL hasUniqueFileNameBeenFound = NO;
            NSUInteger classCheckInteger = 2;
            while (hasUniqueFileNameBeenFound == NO) {
                hasUniqueFileNameBeenFound = YES;
                for(ClassBaseObject *collisionBaseObject in files) {
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
        
        /* Write the .java file to disk */
        NSError *error;
        NSString *outputString = [self Java_ImplementationFileForClassObject:base];
        NSString *filename = [NSString stringWithFormat:@"%@.java", base.className];
        
        /* Define the package name in each file */
        outputString = [outputString stringByReplacingOccurrencesOfString:@"{PACKAGENAME}" withString:packageName];
        
        [outputString writeToURL:[url URLByAppendingPathComponent:filename]
                     atomically:YES
                       encoding:NSUTF8StringEncoding 
                          error:&error];
        if(error) {
            DLog(@"%@", [error localizedDescription]);
            filesHaveHadError = YES;
        } else {
            filesHaveBeenWritten = YES;
        }
    }
    
    /* Return the error flag (by reference) */
    generatedErrorFlag = &filesHaveHadError;
    
    
    return filesHaveBeenWritten;
}

- (NSDictionary *) getOutputFilesForClassObject:(ClassBaseObject *)classObject
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[self Java_ImplementationFileForClassObject:classObject] forKey:[NSString stringWithFormat:@"%@.java", classObject.className]];
    
    return [NSDictionary dictionaryWithDictionary:dict];
    
}

- (NSString *) Java_ImplementationFileForClassObject:(ClassBaseObject *)classObject
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *interfaceTemplate = [mainBundle pathForResource:@"JavaTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:classObject.className];
    
    // Flag if class has an ArrayList type property (used for generating the import block)
    BOOL containsArrayList = NO;
    
    // Public Properties
    NSString *propertiesString = @"";
    for(ClassPropertiesObject *property in [classObject.properties allValues]) {
        
        propertiesString = [propertiesString stringByAppendingString:[self propertyForProperty:property]];
        if (property.type == PropertyTypeArray) {
            containsArrayList = YES;
        }
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{PROPERTIES}" withString:propertiesString];
    
    // Import Block
    if (containsArrayList) {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{IMPORTBLOCK}" withString:@"import java.util.ArrayList;"];
    }
    else {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{IMPORTBLOCK}" withString:@""];
    }
    
    // Constructor arguments
    NSString *constructorArgs = @"";
    for (ClassPropertiesObject *property in [classObject.properties allValues]) {
        //Append a comma if not the first argument added to the string
        if ( ![constructorArgs isEqualToString:@""] ) {
            constructorArgs = [constructorArgs stringByAppendingString:@", "];
        }
        
        constructorArgs = [constructorArgs stringByAppendingString:[NSString stringWithFormat:@"%@ %@", [self typeStringForProperty:property], property.name]];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CONSTRUCTOR_ARGS}" withString:constructorArgs];
    
    
    // Setters strings   
    NSString *settersString = @"";
    for(ClassPropertiesObject *property in [classObject.properties allValues]) {
        
        settersString = [settersString stringByAppendingString:[self setterForProperty:property]];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERS}" withString:settersString];    
    
    NSString *rawObject = @"rawObject";
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{OBJECTNAME}" withString:rawObject];
    
    
    // Getter/Setter Methods
    NSString *getterSetterMethodsString = @"";
    for (ClassPropertiesObject *property in [classObject.properties allValues]) {
        getterSetterMethodsString = [getterSetterMethodsString stringByAppendingString:[self getterForProperty:property]];
        getterSetterMethodsString = [getterSetterMethodsString stringByAppendingString:[self setterMethodForProperty:property]];
    }
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{GETTER_SETTER_METHODS}" withString:getterSetterMethodsString];
    
    return templateString;
}

#pragma mark - Property Writing Methods

- (NSString *)propertyForProperty:(ClassPropertiesObject *) property
{
    NSString *returnString = [NSString stringWithFormat:@"private %@ %@;\n    ", [self typeStringForProperty:property], property.name];
    
    return returnString;
}

- (NSString *)setterForProperty:(ClassPropertiesObject *)  property
{
    NSString *setterString = @"";
    setterString = [setterString stringByAppendingFormat:@"        this.%@ = %@;\n", property.name, property.name];
    return setterString;
}

- (NSString *)getterForProperty:(ClassPropertiesObject *) property
{
    NSString *getterMethod = [NSString stringWithFormat:@"    public %@ get%@() {\n        return this.%@;\n    }\n\n", [self typeStringForProperty:property], [property.name capitalizeFirstCharacter], property.name];
    return getterMethod;
}

- (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *)  property
{
    return [NSArray array];
}

- (NSString *)typeStringForProperty:(ClassPropertiesObject *)  property
{
    switch (property.type) {
        case PropertyTypeString:
            return @"String";
            break;
        case PropertyTypeArray: {
            
            //Special case, switch over the collection type
            switch (property.collectionType) {
                case PropertyTypeClass:
                    return [NSString stringWithFormat:@"ArrayList<%@>", property.collectionTypeString];
                    break;
                case PropertyTypeString:
                    return @"ArrayList<String>";
                    break;
                case PropertyTypeInt:
                    return @"ArrayList<int>";
                    break;
                case PropertyTypeBool:
                    return @"ArrayList<boolean>";
                    break;
                case PropertyTypeDouble:
                    return @"ArrayList<double>";
                    break;
                default:
                    break;
            }
            
            break;
        }
        case PropertyTypeDictionary:
            return @"Dictionary";
            break;
        case PropertyTypeInt:
            return @"int";
            break;
        case PropertyTypeBool:
            return @"boolean";
            break;
        case PropertyTypeDouble:
            return @"double";
            break;
        case PropertyTypeClass:
            return property.referenceClass.className;
            break;
        case PropertyTypeOther:
            return property.otherType;
            break;
            
        default:
            break;
    }
    return @"";
}

#pragma mark - Java specific implementation details

- (NSString *)setterMethodForProperty:(ClassPropertiesObject *)  property
{
    NSString *setterMethod = [NSString stringWithFormat:@"    public void set%@(%@ %@) {\n        this.%@ = %@;\n    }\n\n", [property.name capitalizeFirstCharacter], [self typeStringForProperty:property], property.name, property.name, property.name];
    return setterMethod;
}



@end
