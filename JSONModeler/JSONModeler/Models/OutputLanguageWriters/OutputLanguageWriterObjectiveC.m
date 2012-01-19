//
//  OutputLanguageWriterObjectiveC.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 1/19/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "OutputLanguageWriterObjectiveC.h"
#import "ClassBaseObject.h"

@implementation OutputLanguageWriterObjectiveC

+ (NSString *)propertyForProperty:(ClassPropertiesObject *) property
{
    NSString *returnString = @"@property (";
    if(property.isAtomic == NO) {
        returnString = [returnString stringByAppendingString:@"nonatomic, "];
    }
    
    if(property.isReadWrite == NO) {
        returnString = [returnString stringByAppendingString:@"readonly, "];
    }
    
    switch (property.semantics) {
        case SetterSemanticStrong:
            returnString = [returnString stringByAppendingString:@"strong"];
            break;
        case SetterSemanticWeak:
            returnString = [returnString stringByAppendingString:@"weak"];
            break;
        case SetterSemanticAssign:
            returnString = [returnString stringByAppendingString:@"assign"];
            break;
        case SetterSemanticRetain:
            returnString = [returnString stringByAppendingString:@"retain"];
            break;
        case SetterSemanticCopy:
            returnString = [returnString stringByAppendingString:@"copy"];
            break;
        default:
            break;
    }
    
    returnString = [returnString stringByAppendingFormat:@") %@ %@%@;", [self typeStringForProperty:property], (property.semantics != SetterSemanticAssign) ? @"*" : @"" , property.name];
    
    return returnString;

}

+ (NSString *)setterForProperty:(ClassPropertiesObject *)  property
{
    NSString *setterString = @"";
    if(property.isClass && (property.type == PropertyTypeDictionary || property.type == PropertyTypeClass)) {
#warning Need to do testing to make sure the set object is of type of dictionary
        setterString = [setterString stringByAppendingFormat:@"    self.%@ = [%@ initWithDictionary:[dict objectForKey:@\"%@\"]];\n", property.name, property.referenceClass.className, property.jsonName];
    } else if(property.type == PropertyTypeArray && property.referenceClass != nil) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        NSString *interfaceTemplate = [mainBundle pathForResource:@"ArraySetterTemplate" ofType:@"txt"];
        NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{JSONNAME}" withString:property.jsonName];
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERNAME}" withString:property.name];
        setterString = [templateString stringByReplacingOccurrencesOfString:@"{REFERENCE_CLASS}" withString:property.referenceClass.className];
        
    } else {
        setterString = [setterString stringByAppendingString:[NSString stringWithFormat:@"    self.%@ = ", property.name]];
        if([property type] == PropertyTypeInt) {
            setterString = [setterString stringByAppendingFormat:@"[[dict objectForKey:@\"%@\"] intValue];\n", property.jsonName];
        } else if([property type] == PropertyTypeDouble) {
            setterString = [setterString stringByAppendingFormat:@"[[dict objectForKey:@\"%@\"] doubleValue];\n", property.jsonName]; 
        } else if([property type] == PropertyTypeBool) {
            setterString = [setterString stringByAppendingFormat:@"[[dict objectForKey:@\"%@\"] boolValue];\n", property.jsonName]; 
        } else {
            setterString = [setterString stringByAppendingFormat:@"[dict objectForKey:@\"%@\"];\n", property.jsonName];
        }
    }
    return setterString;
}

+ (NSString *)getterForProperty:(ClassPropertiesObject *) property
{
    return @"";
}

+ (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *)  property
{
    NSMutableArray *array = [NSMutableArray array];

    if(property.referenceClass != nil) {
        [array addObject:property.referenceClass.className];
    }

    return [NSArray arrayWithArray:array];

}

+ (NSString *)typeStringForProperty:(ClassPropertiesObject *)  property
{
    switch (property.type) {
        case PropertyTypeString:
            return @"NSString";
            break;
        case PropertyTypeArray:
            return @"NSArray";
            break;
        case PropertyTypeDictionary:
            return @"NSDictionary";
            break;
        case PropertyTypeInt:
            return @"NSInteger";
            break;
        case PropertyTypeBool:
            return @"BOOL";
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
}


@end
