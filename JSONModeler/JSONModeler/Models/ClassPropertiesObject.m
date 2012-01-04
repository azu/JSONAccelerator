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

@interface ClassPropertiesObject ()

- (NSString *) propertyForObjectiveC;
- (NSString *) propertyForJava;
- (NSString *)getterMethodForJava;
- (NSString *)setterMethodForJava;

@end

@implementation ClassPropertiesObject
@synthesize name = _name;
@synthesize jsonName = _mappedName;
@synthesize  type = _type;
@synthesize  otherType = _otherType;

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
    return [self propertyForObjectiveC]; 
}

- (NSString *)propertyForLanguage:(OutputLanguage)language
{
    if(language == OutputLanguageJava) {
        return [self propertyForJava]; 
    } else if (language == OutputLanguageObjectiveC) {
        return [self propertyForObjectiveC];
    }
    return @"";
}

- (NSArray *)setterReferenceClassesForLanguage:(OutputLanguage) language
{
    NSMutableArray *array = [NSMutableArray array];
    if(language == OutputLanguageObjectiveC) {
        // Objective C
        if(self.referenceClass != nil) {
            [array addObject:self.referenceClass.className];
        }
    } else {
        // Java
    }
    return [NSArray arrayWithArray:array];
}

- (NSString *)setterForLanguage:(OutputLanguage) language
{
    NSString *setterString = @"";
    
    if(language == OutputLanguageObjectiveC) {
        if(self.isClass && (self.type == PropertyTypeDictionary || self.type == PropertyTypeClass)) {
#warning Need to do testing to make sure the set object is of type of dictionary
            setterString = [setterString stringByAppendingFormat:@"    self.%@ = [%@ initWithDictionary:[dict objectForKey:@\"%@\"]];\n", self.name, self.referenceClass.className, self.jsonName];
        } else if(self.type == PropertyTypeArray && self.referenceClass != nil) {
            NSBundle *mainBundle = [NSBundle mainBundle];
            
            NSString *interfaceTemplate = [mainBundle pathForResource:@"ArraySetterTemplate" ofType:@"txt"];
            NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];
            templateString = [templateString stringByReplacingOccurrencesOfString:@"{JSONNAME}" withString:self.jsonName];
            templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERNAME}" withString:self.name];
            setterString = [templateString stringByReplacingOccurrencesOfString:@"{REFERENCE_CLASS}" withString:self.referenceClass.className];
            
        } else {
            setterString = [setterString stringByAppendingString:[NSString stringWithFormat:@"    self.%@ = ", self.name]];
            if([self type] == PropertyTypeInt) {
                setterString = [setterString stringByAppendingFormat:@"[[dict objectForKey:@\"%@\"] intValue];\n", self.jsonName];
            } else if([self type] == PropertyTypeDouble) {
                setterString = [setterString stringByAppendingFormat:@"[[dict objectForKey:@\"%@\"] doubleValue];\n", self.jsonName]; 
            } else {
                setterString = [setterString stringByAppendingFormat:@"[dict objectForKey:@\"%@\"];\n", self.jsonName];
            }
        }
    } else if(language == OutputLanguageJava) {
        
        setterString = [setterString stringByAppendingFormat:@"        this.%@ = %@;\n", self.name, self.name];
    }
    
    return setterString;
}

#pragma mark - Properties Section

- (NSString *) propertyForObjectiveC
{
    NSString *returnString = @"@property (";
    if(_isAtomic == NO) {
        returnString = [returnString stringByAppendingString:@"nonatomic, "];
    }
    
    if(_isReadWrite == NO) {
        returnString = [returnString stringByAppendingString:@"readonly, "];
    }
    
    switch (_semantics) {
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
    
    returnString = [returnString stringByAppendingFormat:@") %@ %@%@;", [self typeStringForLanguage:OutputLanguageObjectiveC], (_semantics != SetterSemanticAssign) ? @"*" : @"" , _name];
    
    return returnString;
}

- (NSString *) propertyForJava
{

    NSString *returnString = [NSString stringWithFormat:@"private %@ %@;\n    ", [self typeStringForLanguage:OutputLanguageJava], self.name];
    
    return returnString;
}

- (NSString *)typeStringForLanguage:(OutputLanguage) language
{
    if(language == OutputLanguageObjectiveC) {
        switch (self.type) {
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
            case PropertyTypeDouble:
                return @"double";
                break;
            case PropertyTypeClass:
                return self.referenceClass.className;
                break;
            case PropertyTypeOther:
                return self.otherType;
                break;
                
            default:
                break;
        }
    } else if(language == OutputLanguageJava) {
        switch (self.type) {
            case PropertyTypeString:
                return @"String";
                break;
            case PropertyTypeArray: {
                
                //Special case, switch over the collection type
                switch (self.collectionType) {
                    case PropertyTypeClass:
                        return [NSString stringWithFormat:@"ArrayList<%@>", self.collectionTypeString];
                        break;
                    case PropertyTypeString:
                        return @"ArrayList<String>";
                        break;
                    case PropertyTypeInt:
                        return @"ArrayList<int>";
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
            case PropertyTypeDouble:
                return @"double";
                break;
            case PropertyTypeClass:
                return self.referenceClass.className;
                break;
            case PropertyTypeOther:
                return self.otherType;
                break;
                
            default:
                break;
        }
    }
    return @"";
}

#pragma mark - Getter/Setter Method Generators

- (NSString *)getterMethodForLanguage:(OutputLanguage)language
{
    if (language == OutputLanguageJava) {
        return [self getterMethodForJava];
    }
    else {
        // TODO : update this for other languages
        return nil;
    }
}

-(NSString *)setterMethodForLanguage:(OutputLanguage)language
{
    if (language == OutputLanguageJava) {
        return [self setterMethodForJava];
    }
    else {
        // TODO : update this for other languages
        return nil;
    }
}

- (NSString *)getterMethodForJava
{
    NSString *getterMethod = [NSString stringWithFormat:@"    public %@ get%@() {\n        return this.%@;\n    }\n\n", [self typeStringForLanguage:OutputLanguageJava], [self.name capitalizeFirstCharacter], self.name];
    return getterMethod;
}

- (NSString *)setterMethodForJava
{
    NSString *setterMethod = [NSString stringWithFormat:@"    public void set%@(%@ %@) {\n        this.%@ = %@;\n    }\n\n", [self.name capitalizeFirstCharacter], [self typeStringForLanguage:OutputLanguageJava], self.name, self.name, self.name];
    return setterMethod;
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
