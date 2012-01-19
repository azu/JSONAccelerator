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

@implementation OutputLanguageWriterJava

+ (NSString *)propertyForProperty:(ClassPropertiesObject *) property
{
    NSString *returnString = [NSString stringWithFormat:@"private %@ %@;\n    ", [self typeStringForProperty:property], property.name];
    
    return returnString;
}

+ (NSString *)setterForProperty:(ClassPropertiesObject *)  property
{
    NSString *setterString = @"";
    setterString = [setterString stringByAppendingFormat:@"        this.%@ = %@;\n", property.name, property.name];
    return setterString;
}

+ (NSString *)getterForProperty:(ClassPropertiesObject *) property
{
    NSString *getterMethod = [NSString stringWithFormat:@"    public %@ get%@() {\n        return this.%@;\n    }\n\n", [self typeStringForProperty:property], [property.name capitalizeFirstCharacter], property.name];
    return getterMethod;
}

+ (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *)  property
{
    return [NSArray array];
}

+ (NSString *)typeStringForProperty:(ClassPropertiesObject *)  property
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

+ (NSString *)setterMethodForProperty:(ClassPropertiesObject *)  property
{
    NSString *setterMethod = [NSString stringWithFormat:@"    public void set%@(%@ %@) {\n        this.%@ = %@;\n    }\n\n", [property.name capitalizeFirstCharacter], [self typeStringForProperty:property], property.name, property.name, property.name];
    return setterMethod;
}



@end
