//
//  OutputLanguageWriterObjectiveC.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 1/19/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "OutputLanguageWriterObjectiveC.h"
#import "ClassBaseObject.h"
#import "NSString+Nerdery.h"

#ifndef COMMAND_LINE
    #import <AddressBook/AddressBook.h>
#endif


@interface OutputLanguageWriterObjectiveC ()

@property (nonatomic, assign) BOOL buildForARC;

- (NSString *) ObjC_HeaderFileForClassObject:(ClassBaseObject *)classObject;
- (NSString *) ObjC_ImplementationFileForClassObject:(ClassBaseObject *)classObject;
- (NSString *)processHeaderForString:(NSString *)unprocessedString;

@end

@implementation OutputLanguageWriterObjectiveC
//@synthesize classObject = _classObject;

#pragma mark - File Writing Methods

- (BOOL)writeClassObjects:(NSDictionary *)classObjectsDict toURL:(NSURL *)url options:(NSDictionary *)options generatedError:(BOOL *)generatedErrorFlag
{
    BOOL filesHaveHadError = NO;
    BOOL filesHaveBeenWritten = NO;
    
    NSArray *files = [classObjectsDict allValues];
    
    /* Determine whether or not to build for ARC */
    if (nil != options[kObjectiveCWritingOptionUseARC]) {
        self.buildForARC = [options[kObjectiveCWritingOptionUseARC] boolValue];
    }
    else {
        /* Default to not building for ARC */
        self.buildForARC = NO;
    }
    
    for (ClassBaseObject *base in files) {
        NSString *newBaseClassName = base.className;
        
        // This section is to guard against people going through and renaming the class
        // to something that has already been named.
        // This will check the class name and keep appending an additional number until something has been found
        
        if ([[base className] isEqualToString:@"InternalBaseClass"]) {
            
            if (nil != options[kObjectiveCWritingOptionBaseClassName]) {
                newBaseClassName = options[kObjectiveCWritingOptionBaseClassName];
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
                    newBaseClassName = [NSString stringWithFormat:@"%@%li", newBaseClassName, classCheckInteger];
                    classCheckInteger++;
                }
            }
        }
        
        if (nil != options[kObjectiveCWritingOptionClassPrefix]) {
            newBaseClassName = [NSString stringWithFormat:@"%@%@", options[kObjectiveCWritingOptionClassPrefix], newBaseClassName ];
        }
        
        [base setClassName:newBaseClassName];
    }
    
    for(ClassBaseObject *base in files) {    
        /* Write the h file to disk */
        NSError * hFileError;
        NSString *outputHFile = [self ObjC_HeaderFileForClassObject:base];
        NSString *hFilename = [NSString stringWithFormat:@"%@.h", base.className];
#ifndef COMMAND_LINE
        [outputHFile writeToURL:[url URLByAppendingPathComponent:hFilename]
                      atomically:YES
                        encoding:NSUTF8StringEncoding 
                           error:&hFileError];
#else
        [outputHFile writeToFile:[[url URLByAppendingPathComponent:hFilename] absoluteString]
                      atomically:YES
                        encoding:NSUTF8StringEncoding
                           error:&hFileError];
#endif
        if(hFileError) {
            DLog(@"%@", [hFileError localizedDescription]);
            filesHaveHadError = YES;
        } else {
            filesHaveBeenWritten = YES;
        }
        
        /* Write the m file to disk */
        NSError * mFileError;
        NSString *outputMFile = [self ObjC_ImplementationFileForClassObject:base];
        NSString *mFilename = [NSString stringWithFormat:@"%@.m", base.className];
        
#ifndef COMMAND_LINE
        [outputMFile writeToURL:[url URLByAppendingPathComponent:mFilename]
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:&mFileError];
#else
        [outputMFile writeToFile:[[url URLByAppendingPathComponent:mFilename] absoluteString]
                      atomically:YES
                        encoding:NSUTF8StringEncoding
                           error:&mFileError];

#endif
        if(mFileError) {
            DLog(@"%@", [mFileError localizedDescription]);
            filesHaveHadError = YES;
        } else {
            filesHaveBeenWritten = YES;
        }
    }

#ifndef COMMAND_LINE
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *dataModelsTemplate = [mainBundle pathForResource:@"DataModelsTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:dataModelsTemplate
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];

    // Now for the data models
    for(ClassBaseObject *base in files) {
        NSString *importString = [NSString stringWithFormat:@"#import \"%@.h\"\r", base.className];
        templateString = [templateString stringByAppendingString:importString];
    }
    
    templateString = [self processHeaderForString:templateString];
    
    NSError *dataModelFileError = nil;
    [templateString writeToURL:[url URLByAppendingPathComponent:@"DataModels.h"]
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&dataModelFileError];
    
    if(dataModelFileError) {
        DLog(@"%@", [dataModelFileError localizedDescription]);
        filesHaveHadError = YES;
    }
#endif
    
    /* Return the error flag (by reference) */
    *generatedErrorFlag = filesHaveHadError;
    
    
    return filesHaveBeenWritten;
}

- (NSDictionary *) getOutputFilesForClassObject:(ClassBaseObject *)classObject
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Defaults to not use ARC. This should probably be updated at some point.
    dict[[NSString stringWithFormat:@"%@.h", classObject.className]] = [self ObjC_HeaderFileForClassObject:classObject];
    dict[[NSString stringWithFormat:@"%@.m", classObject.className]] = [self ObjC_ImplementationFileForClassObject:classObject];
    
    return [NSDictionary dictionaryWithDictionary:dict];

}

- (NSString *) ObjC_HeaderFileForClassObject:(ClassBaseObject *)classObject
{
#ifndef COMMAND_LINE
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *interfaceTemplate = [mainBundle pathForResource:@"InterfaceTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];
#else
    NSString *templateString = @"//\n//  {CLASSNAME}.h\n//\n//  Created by __NAME__ on {DATE}\n//  Copyright (c) {COMPANY_NAME}. All rights reserved.\n//\n\n#import <Foundation/Foundation.h>\n\n{FORWARD_DECLARATION}\n\n@interface {CLASSNAME} : {BASEOBJECT} <NSCoding>\n\n{PROPERTIES}\n+ ({CLASSNAME} *)modelObjectWithDictionary:(NSDictionary *)dict;\n- (id)initWithDictionary:(NSDictionary *)dict;\n- (NSDictionary *)dictionaryRepresentation;\n\n@end\n";
#endif
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:classObject.className];
    
    /* Set the date */
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DATE}" withString:[dateFormatter stringFromDate:currentDate]];
    
    templateString = [self processHeaderForString:templateString];
    
    // First we need to find if there are any class properties, if so do the @Class business
    NSString *forwardDeclarationString = @"";
    
    for(ClassPropertiesObject *property in [classObject.properties allValues]) {
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
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{BASEOBJECT}" withString:classObject.baseClass];
    
    NSString *propertyString = @"";
    for(ClassPropertiesObject *property in [classObject.properties allValues]) {
        
        propertyString = [propertyString stringByAppendingFormat:@"%@\n", [self propertyForProperty:property]];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{PROPERTIES}" withString:propertyString];
    
    return templateString;
}

- (NSString *) ObjC_ImplementationFileForClassObject:(ClassBaseObject *)classObject
{
#ifndef COMMAND_LINE
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *implementationTemplate = [mainBundle pathForResource:@"ImplementationTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:implementationTemplate encoding:NSUTF8StringEncoding error:nil];
#else
    NSString *templateString = @"//\n//  {CLASSNAME}.m\n//\n//  Created by __NAME__ on {DATE}\n//  Copyright (c) {COMPANY_NAME}. All rights reserved.\n//\n\n#import \"{CLASSNAME}.h\"\n{IMPORT_BLOCK}\n\n@interface {CLASSNAME} ()\n\n- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;\n\n@end\n\n@implementation {CLASSNAME}\n\n{SYNTHESIZE_BLOCK}\n\n+ ({CLASSNAME} *)modelObjectWithDictionary:(NSDictionary *)dict\n{\n    {CLASSNAME} *instance = {CLASSNAME_INIT};\n    return instance;\n}\n\n- (id)initWithDictionary:(NSDictionary *)dict\n{\n    self = [super init];\n    \n    // This check serves to make sure that a non-NSDictionary object\n    // passed into the model class doesn't break the parsing.\n    if(self && [dict isKindOfClass:[NSDictionary class]]) {\n{SETTERS}\n    }\n    \n    return self;\n    \n}\n\n- (NSDictionary *)dictionaryRepresentation\n{\n    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];\n{DICTIONARY_REPRESENTATION}\n    return [NSDictionary dictionaryWithDictionary:mutableDict];\n}\n\n- (NSString *)description \n{\n    return [NSString stringWithFormat:@\"%@\", [self dictionaryRepresentation]];\n}\n\n#pragma mark - Helper Method\n- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict\n{\n    id object = [dict objectForKey:aKey];\n    return [object isEqual:[NSNull null]] ? nil : object;\n}\n\n\n#pragma mark - NSCoding Methods\n\n- (id)initWithCoder:(NSCoder *)aDecoder\n{\n    self = [super init];\n{INITWITHCODER}\n    return self;\n}\n\n- (void)encodeWithCoder:(NSCoder *)aCoder\n{\n{ENCODEWITHCODER}\n}\n\n{DEALLOC}\n@end\n";
#endif
    
    // Need to check for ARC to tell whether or not to use autorelease or not
    if(self.buildForARC) {
        // Uses ARC
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME_INIT}" withString:@"[[{CLASSNAME} alloc] initWithDictionary:dict]"];
    } else {
        // Doesn't use ARC
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME_INIT}" withString:@"[[[{CLASSNAME} alloc] initWithDictionary:dict] autorelease]"];
    }
    
    
    // IMPORTS
    NSMutableArray *importArray = [NSMutableArray array];
    NSString *importString = @"";
    for(ClassPropertiesObject *property in [classObject.properties allValues]) {
        if([property isClass]) {
            [importArray addObject:[[property referenceClass] className]];
        }
        
        // Check References
        NSArray *referenceArray = [self setterReferenceClassesForProperty:property];
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
    for(ClassPropertiesObject *property in [classObject.properties allValues]) {
        NSString *camelCased = [property.name lowercaseCamelcaseString];
        sythesizeString = [sythesizeString stringByAppendingFormat:@"@synthesize %@ = _%@;\n", camelCased, camelCased];
    }
    
    // SETTERS
    NSString *settersString = @"";
    for(ClassPropertiesObject *property in [classObject.properties allValues]) {
        settersString = [settersString stringByAppendingString:[self setterForProperty:property]];
    }
    
    //dictionaryRepresentation
    NSString *dictionaryRepresentation = @"";
    for(ClassPropertiesObject *property in [classObject.properties allValues]) {
        dictionaryRepresentation = [dictionaryRepresentation stringByAppendingString:[self dictionaryRepresentationfromProperty:property]];
    }
    
    // NSCODING SECTION
    NSString *initWithCoderString = @"";
    for (ClassPropertiesObject *property in [classObject.properties allValues]) {
        switch (property.type) {
            case PropertyTypeInt:
                initWithCoderString = [initWithCoderString stringByAppendingString:[NSString stringWithFormat:@"\n    self.%@ = [aDecoder decodeIntegerForKey:@\"%@\"];", [property.name lowercaseCamelcaseString], property.name]];
                break;
            case PropertyTypeDouble:
                initWithCoderString = [initWithCoderString stringByAppendingString:[NSString stringWithFormat:@"\n    self.%@ = [aDecoder decodeDoubleForKey:@\"%@\"];", [property.name lowercaseCamelcaseString], property.name]];
                break;
            case PropertyTypeBool:
                initWithCoderString = [initWithCoderString stringByAppendingString:[NSString stringWithFormat:@"\n    self.%@ = [aDecoder decodeBoolForKey:@\"%@\"];", [property.name lowercaseCamelcaseString], property.name]];
                break;
            default:
                initWithCoderString = [initWithCoderString stringByAppendingString:[NSString stringWithFormat:@"\n    self.%@ = [aDecoder decodeObjectForKey:@\"%@\"];", [property.name lowercaseCamelcaseString], property.name]];
                break;
        }
    }
    
    
    NSString *encodeWithCoderString = @"";
    for (ClassPropertiesObject *property in [classObject.properties allValues]) {
        switch (property.type) {
            case PropertyTypeInt:
                encodeWithCoderString = [encodeWithCoderString stringByAppendingString:[NSString stringWithFormat:@"\n    [aCoder encodeInteger:_%@ forKey:@\"%@\"];", property.name, property.name]];
                break;
            case PropertyTypeDouble:
                encodeWithCoderString = [encodeWithCoderString stringByAppendingString:[NSString stringWithFormat:@"\n    [aCoder encodeDouble:_%@ forKey:@\"%@\"];", property.name, property.name]];
                break;
            case PropertyTypeBool:
                encodeWithCoderString = [encodeWithCoderString stringByAppendingString:[NSString stringWithFormat:@"\n    [aCoder encodeBool:_%@ forKey:@\"%@\"];", property.name, property.name]];
                break;
            default:
                encodeWithCoderString = [encodeWithCoderString stringByAppendingString:[NSString stringWithFormat:@"\n    [aCoder encodeObject:_%@ forKey:@\"%@\"];", property.name, property.name]];
                break;
        }
    }
    
    // DEALLOC SECTION
    NSString *deallocString = @"";
    
    /* Add dealloc method only if not building for ARC */
    if(self.buildForARC == NO) {
        deallocString = @"\n- (void)dealloc\n{\n";
        for(ClassPropertiesObject *property in [classObject.properties allValues]) {
            if([property type] != PropertyTypeInt && [property type] != PropertyTypeDouble && [property type] != PropertyTypeBool){
                deallocString = [deallocString stringByAppendingString:[NSString stringWithFormat:@"    [_%@ release];\n", property.name]];
            }
        }
        deallocString = [deallocString stringByAppendingString:@"    [super dealloc];\n}\n"];
    }
    
    /* Set other template strings */
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:classObject.className];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{IMPORT_BLOCK}" withString:importString];    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SYNTHESIZE_BLOCK}" withString:sythesizeString];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERS}" withString:settersString];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DICTIONARY_REPRESENTATION}" withString:dictionaryRepresentation];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{INITWITHCODER}" withString:initWithCoderString];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{ENCODEWITHCODER}" withString:encodeWithCoderString];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DEALLOC}" withString:deallocString];
    
    templateString = [self processHeaderForString:templateString];
    
    return templateString;
}

- (NSString *)processHeaderForString:(NSString *)unprocessedString
{
    NSString *templateString = [unprocessedString copy];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    /* Set the name and company values in the template from the current logged in user's address book information */
#ifndef COMMAND_LINE
    ABAddressBook *addressBook = [ABAddressBook sharedAddressBook];
    ABPerson *me = [addressBook me];
    NSString *meFirstName = [me valueForProperty:kABFirstNameProperty];
    NSString *meLastName = [me valueForProperty:kABLastNameProperty];
    NSString *meCompany = [me valueForProperty:kABOrganizationProperty];
#else
    NSString *meFirstName = @"";
    NSString *meLastName = @"";
    NSString *meCompany = @"";
#endif
    
    if(meFirstName == nil) {
        meFirstName = @"";
    }
    
    if(meLastName == nil) {
        meLastName = @"";
    }
    
    if(meCompany == nil) {
        meCompany = @"__MyCompanyName__";
    }

    templateString = [templateString stringByReplacingOccurrencesOfString:@"__NAME__" withString:[NSString stringWithFormat:@"%@ %@", meFirstName, meLastName]];
    
    NSString *companyReplacement = [NSString stringWithFormat:@"%@ %@", [currentDate descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:nil] , meCompany];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{COMPANY_NAME}"
                                                               withString:companyReplacement];
    
    /* Set other template strings */
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DATE}"
                                                               withString:[dateFormatter stringFromDate:currentDate]];
    return templateString;
}

#pragma mark - Reserved Words Callbacks

- (NSSet *)reservedWords
{
    return [NSSet setWithObjects:@"__autoreleasing", @"__block", @"__strong", @"__unsafe_unretained", @"__weak", @"_Bool", @"_Complex", @"_Imaginery", @"@catch", @"@class", @"@dynamic", @"@end", @"@finally", @"@implementation", @"@interface", @"@private", @"@property", @"@protected", @"@protocol", @"@public", @"@selector", @"@synthesize", @"@throw", @"@try", @"assign", @"atomic", @"auto", @"autoreleasing", @"block", @"BOOL", @"break", @"bycopy", @"byref", @"case", @"catch", @"char", @"class", @"Class", @"const", @"continue", @"default", @"description", @"do", @"double", @"dynamic", @"else", @"end", @"enum", @"extern", @"finally", @"float", @"for", @"goto", @"id", @"if", @"IMP", @"implementation", @"in", @"inline", @"inout", @"int", @"interface", @"long", @"nil", @"NO", @"nonatomic", @"NULL", @"oneway", @"out", @"private", @"property", @"protected", @"protocol", @"Protocol", @"public", @"register", @"restrict", @"retain", @"return", @"SEL", @"selector", @"self", @"short", @"signed", @"sizeof", @"static", @"strong", @"struct", @"super", @"switch", @"synthesize", @"throw", @"try", @"typedef", @"union", @"unretained", @"unsafe", @"unsigned", @"void", @"volatile", @"weak", @"while", @"YES", nil];
}

- (NSString *)dictionaryRepresentationfromProperty:(ClassPropertiesObject *)property
{
    // Arrays are another bag of tricks 
    if(property.type == PropertyTypeArray) {
#ifndef COMMAND_LINE
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        NSString *implementationTemplate = [mainBundle pathForResource:@"DictionaryRepresentationArrayTemplate" ofType:@"txt"];
        NSString *templateString = [[NSString alloc] initWithContentsOfFile:implementationTemplate encoding:NSUTF8StringEncoding error:nil];
#else
        NSString *templateString = @"NSMutableArray *tempArrayFor{ARRAY_GETTER_NAME} = [NSMutableArray array];\n    for (NSObject *subArrayObject in self.{ARRAY_GETTER_NAME_LOWERCASE}) {\n        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {\n            // This class is a model object\n            [tempArrayFor{ARRAY_GETTER_NAME} addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];\n        } else {\n            // Generic object\n            [tempArrayFor{ARRAY_GETTER_NAME} addObject:subArrayObject];\n        }\n    }\n    [mutableDict setValue:[NSArray arrayWithArray:tempArrayFor{ARRAY_GETTER_NAME}] forKey:@\"%@\"];\n";
#endif
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{ARRAY_GETTER_NAME}" withString:[property.name uppercaseCamelcaseString]];
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{ARRAY_GETTER_NAME_LOWERCASE}" withString:[property.name lowercaseCamelcaseString]];
        return [NSString stringWithFormat:templateString, property.jsonName];
    }

    
    NSString *dictionaryRepresentation = @"";
    NSString *formatString = @"    [mutableDict setValue:%@ forKey:@\"%@\"];\n";
    NSString *value;
    NSString *key = [NSString stringWithFormat:@"%@", property.jsonName];
    
    
    
    switch (property.type) {
        case PropertyTypeString:
        case PropertyTypeDictionary:
        case PropertyTypeOther: 
            value = [NSString stringWithFormat:@"self.%@", [property.name lowercaseCamelcaseString]];
            break;
        case PropertyTypeClass:
            value = [NSString stringWithFormat:@"[self.%@ dictionaryRepresentation]", [property.name lowercaseCamelcaseString]];
            break;

        case PropertyTypeInt:
            value = [NSString stringWithFormat:@"[NSNumber numberWithInt:self.%@]", [property.name lowercaseCamelcaseString]];
            break;
        case PropertyTypeBool:
            value = [NSString stringWithFormat:@"[NSNumber numberWithBool:self.%@]", [property.name lowercaseCamelcaseString]];
            break;
        case PropertyTypeDouble:
            value = [NSString stringWithFormat:@"[NSNumber numberWithDouble:self.%@]", [property.name lowercaseCamelcaseString]];
            break;
        case PropertyTypeArray:
            NSAssert(NO, @"This shouldn't happen");
            break;
            
    }
    dictionaryRepresentation = [NSString stringWithFormat:formatString, value, key];
    
    
    return dictionaryRepresentation;
}

- (NSString *)classNameForObject:(ClassBaseObject *)classObject fromReservedWord:(NSString *)reservedWord
{
    NSString *className = [[reservedWord stringByAppendingString:@"Class"] capitalizeFirstCharacter];
    NSRange startsWithNumeral = [[className substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
    if ( !(startsWithNumeral.location == NSNotFound && startsWithNumeral.length == 0) ) {
        className = [@"Num" stringByAppendingString:className];
    }
    
    return className;
}

- (NSString *)propertyNameForObject:(ClassPropertiesObject *)propertyObject inClass:(ClassBaseObject *)classObject fromReservedWord:(NSString *)reservedWord
{
    /* Special cases */
    if([reservedWord isEqualToString:@"id"]) {
        return [[classObject.className stringByAppendingString:@"Identifier"] uncapitalizeFirstCharacter];
    } else if ([reservedWord isEqualToString:@"description"]) {
        return [[classObject.className stringByAppendingString:@"Description"] uncapitalizeFirstCharacter];
    } else if ([reservedWord isEqualToString:@"self"]) {
        return [[classObject.className stringByAppendingString:@"Self"] uncapitalizeFirstCharacter];
    }
    
    /* General case */
    NSString *propertyName = [[reservedWord stringByAppendingString:@"Property"] uncapitalizeFirstCharacter];
    NSRange startsWithNumeral = [[propertyName substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
    if ( !(startsWithNumeral.location == NSNotFound && startsWithNumeral.length == 0) ) {
        propertyName = [@"num" stringByAppendingString:propertyName];
    }
    return [propertyName uncapitalizeFirstCharacter];
}

#pragma mark - Property Writing Methods

- (NSString *)propertyForProperty:(ClassPropertiesObject *) property
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
            if (self.buildForARC) {
                returnString = [returnString stringByAppendingString:@"strong"];
            } else {
                returnString = [returnString stringByAppendingString:@"retain"];
            }
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

- (NSString *)setterForProperty:(ClassPropertiesObject *)  property
{
    NSString *setterString = @"";
    if(property.isClass && (property.type == PropertyTypeDictionary || property.type == PropertyTypeClass)) {
        setterString = [setterString stringByAppendingFormat:@"            self.%@ = [%@ modelObjectWithDictionary:[dict objectForKey:@\"%@\"]];\n", property.name, property.referenceClass.className, property.jsonName];
    } else if(property.type == PropertyTypeArray && property.referenceClass != nil) {
#ifndef COMMAND_LINE
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        NSString *interfaceTemplate = [mainBundle pathForResource:@"ArraySetterTemplate" ofType:@"txt"];
        NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];
#else 
        NSString *templateString = @"    NSObject *received{REFERENCE_CLASS} = [dict objectForKey:@\"{JSONNAME}\"];\n    NSMutableArray *parsed{REFERENCE_CLASS} = [NSMutableArray array];\n    if ([received{REFERENCE_CLASS} isKindOfClass:[NSArray class]]) {\n        for (NSDictionary *item in (NSArray *)received{REFERENCE_CLASS}) {\n            if ([item isKindOfClass:[NSDictionary class]]) {\n                [parsed{REFERENCE_CLASS} addObject:[{REFERENCE_CLASS} modelObjectWithDictionary:item]];\n            }\n       }\n    } else if ([received{REFERENCE_CLASS} isKindOfClass:[NSDictionary class]]) {\n       [parsed{REFERENCE_CLASS} addObject:[{REFERENCE_CLASS} modelObjectWithDictionary:(NSDictionary *)received{REFERENCE_CLASS}]];\n    }\n\n    self.{SETTERNAME} = [NSArray arrayWithArray:parsed{REFERENCE_CLASS}];\n";
#endif
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{JSONNAME}" withString:property.jsonName];
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERNAME}" withString:property.name];
        setterString = [templateString stringByReplacingOccurrencesOfString:@"{REFERENCE_CLASS}" withString:property.referenceClass.className];
        
    } else {
        setterString = [setterString stringByAppendingString:[NSString stringWithFormat:@"            self.%@ = ", [property.name lowercaseCamelcaseString]]];
        if([property type] == PropertyTypeInt) {
            setterString = [setterString stringByAppendingFormat:@"[[dict objectForKey:@\"%@\"] intValue];\n", property.jsonName];
        } else if([property type] == PropertyTypeDouble) {
            setterString = [setterString stringByAppendingFormat:@"[[dict objectForKey:@\"%@\"] doubleValue];\n", property.jsonName]; 
        } else if([property type] == PropertyTypeBool) {
            setterString = [setterString stringByAppendingFormat:@"[[dict objectForKey:@\"%@\"] boolValue];\n", property.jsonName]; 
        } else {
            // It's a normal class type
            setterString = [setterString stringByAppendingFormat:@"[self objectOrNilForKey:@\"%@\" fromDictionary:dict];\n", property.jsonName];
        }
    }
    return setterString;
}

- (NSString *)getterForProperty:(ClassPropertiesObject *) property
{
    return @"";
}

- (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *)  property
{
    NSMutableArray *array = [NSMutableArray array];

    if(property.referenceClass != nil) {
        [array addObject:property.referenceClass.className];
    }

    return [NSArray arrayWithArray:array];

}

- (NSString *)typeStringForProperty:(ClassPropertiesObject *)  property
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
            return @"id";
            break;
            
        default:
            break;
    }
}


@end
