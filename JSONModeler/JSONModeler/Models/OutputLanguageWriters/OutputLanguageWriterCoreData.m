//
//  OutputLanguageWriterCoreData.m
//  JSONModeler
//
//  Created by Sean Hickey on 1/24/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "OutputLanguageWriterCoreData.h"

#import "CoreDataModelGenerator.h"
#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"
#import "NSString+Nerdery.h"
#import <AddressBook/AddressBook.h>

@interface OutputLanguageWriterCoreData () {
@private

}
- (NSString *)headerFileForEntityElement:(NSXMLElement *)entity;
- (NSString *)implementationFileForEntityElement:(NSXMLElement *)entity;

@end


@implementation OutputLanguageWriterCoreData

- (BOOL)writeClassObjects:(NSDictionary *)classObjectsDict toURL:(NSURL *)url options:(NSDictionary *)options generatedError:(BOOL *)generatedErrorFlag
{
    BOOL filesHaveBeenWritten = NO;
    BOOL filesHaveHadError = NO;
    
    NSMutableArray *classObjects = [[classObjectsDict allValues] mutableCopy];
    
    for (ClassBaseObject *base in classObjects) {
        if([[base className] isEqualToString:@"InternalBaseClass"]) {
            NSString *newBaseClassName;
            if (nil != [options objectForKey:kCoreDataWritingOptionBaseClassName]) {
                newBaseClassName = [options objectForKey:kCoreDataWritingOptionBaseClassName];
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
    
    NSArray *classObjectsCopy = [NSArray arrayWithArray:classObjects];  //Create an immutable copy so we can iterate over it while we mutate the original
    for (ClassBaseObject *classObject in classObjectsCopy) {
        NSArray *properties = [[classObject properties] allValues];
        for (ClassPropertiesObject *property in properties) {
            if (property.type == PropertyTypeArray && property.collectionType != PropertyTypeClass) {
                /* If some class has a to-many property that doesn't contain a custom class (e.g., an array of ints or an array of strings) we need to create a new object to wrap those values */
                ClassBaseObject *newObject = [[ClassBaseObject alloc] init];
                newObject.className = [property.name objectiveCClassString];
                
                ClassPropertiesObject *newProperty = [[ClassPropertiesObject alloc] init];
                newProperty.name = property.name;
                newProperty.type = property.collectionType;
                
                [newObject.properties setObject:newProperty forKey:newProperty.name];
                
                [classObjects addObject:newObject];
            }
        }
    }
    
    CoreDataModelGenerator *coreDataGenerator = [[CoreDataModelGenerator alloc] init];
    NSXMLDocument *doc = [coreDataGenerator coreDataModelXMLDocumentFromClassObjects:classObjects];
    
    NSMutableDictionary *outputDict = [[NSMutableDictionary alloc] init];
    NSArray *entities = [[doc rootElement] elementsForName:@"entity"];
    for (NSXMLElement *entity in entities) {
        NSString *hFile = [self headerFileForEntityElement:entity];
        NSString *mFile = [self implementationFileForEntityElement:entity];
        
        [outputDict setObject:hFile forKey:[NSString stringWithFormat:@"%@.h", [[entity attributeForName:@"name"] stringValue]]];
        [outputDict setObject:mFile forKey:[NSString stringWithFormat:@"%@.m", [[entity attributeForName:@"name"] stringValue]]];
        
    }
    
    for (NSString *filename in outputDict) {
        NSError *error;
        [[outputDict objectForKey:filename] writeToURL:[url URLByAppendingPathComponent:filename] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DLog(@"%@", [error localizedDescription]);
            filesHaveHadError = YES;
        }
        else {
            filesHaveBeenWritten = YES;
        }
    }
    
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createDirectoryAtURL:[[url URLByAppendingPathComponent:@"Model.xcdatamodeld"] URLByAppendingPathComponent:@"Model.xcdatamodel"] withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSError *error;
    [[doc XMLDataWithOptions:NSXMLNodePrettyPrint] writeToURL:[[[url URLByAppendingPathComponent:@"Model.xcdatamodeld"] URLByAppendingPathComponent:@"Model.xcdatamodel"] URLByAppendingPathComponent:@"contents"]  options:NSDataWritingAtomic error:&error];
    if (error) {
        DLog(@"%@", [error localizedDescription]);
        filesHaveHadError = YES;
    }
    else {
        filesHaveBeenWritten = YES;
    }
    
    /* Return the error flag by reference */
    *generatedErrorFlag = filesHaveHadError;
    
    
    return filesHaveBeenWritten;
    
    
}

- (NSDictionary *)getOutputFilesForClassObject:(ClassBaseObject *)classObject
{
    return [NSDictionary dictionary];
}


- (NSString *)propertyForProperty:(ClassPropertiesObject *)property
{
    return @"";
}

- (NSString *)setterForProperty:(ClassPropertiesObject *)property
{
    return @"";
}

- (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *)property
{
    return [NSArray array];
}

- (NSString *)typeStringForProperty:(ClassPropertiesObject *)property
{
    return @"";
}

- (NSString *)getterForProperty:(ClassPropertiesObject *)property
{
    return @"";
}

#pragma mark - File Contents Generation Methods

- (NSString *)headerFileForEntityElement:(NSXMLElement *)entity
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *interfaceTemplatePath = [mainBundle pathForResource:@"CoreDataInterfaceTemplate" ofType:@"txt"];
    
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplatePath encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}"withString:[[entity attributeForName:@"name"] stringValue]];
    
    /* Set the date */
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DATE}" withString:[dateFormatter stringFromDate:currentDate]];
    
    /* Set the name and company values in the template from the current logged in user's address book information */
    ABAddressBook *addressBook = [ABAddressBook sharedAddressBook];
    ABPerson *me = [addressBook me];
    NSString *meFirstName = [me valueForProperty:kABFirstNameProperty];
    NSString *meLastName = [me valueForProperty:kABLastNameProperty];
    NSString *meCompany = [me valueForProperty:kABOrganizationProperty];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{NAME}" withString:[NSString stringWithFormat:@"%@ %@", meFirstName, meLastName]];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{COMPANY_NAME}" withString:[NSString stringWithFormat:@"%@ %@", [currentDate descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:nil] , meCompany]];
    
    /* Set the forward declaration string. We need an @class declaration for each relationship */
    NSArray *relationshipElements = [entity elementsForName:@"relationship"];
    
    NSString *forwardDeclarationString = @"";
    for (NSXMLElement *relationship in relationshipElements) {
        if ([forwardDeclarationString isEqualToString:@""]) {
            forwardDeclarationString = [NSString stringWithFormat:@"@class %@", [[relationship attributeForName:@"destinationEntity"] stringValue]];
        }
        else {
            forwardDeclarationString = [forwardDeclarationString stringByAppendingFormat:@", %@", [[relationship attributeForName:@"destinationEntity"] stringValue]];
        }
    }
    
    if([forwardDeclarationString isEqualToString:@""] == NO) {
        forwardDeclarationString = [forwardDeclarationString stringByAppendingString:@";"];        
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{FORWARD_DECLARATION}" withString:forwardDeclarationString];
    
    /* Add the properties declarations */
    NSString *propertiesString = @"";
    
    NSArray *attributes = [entity elementsForName:@"attribute"];
    for (NSXMLElement *attribute in attributes) {
        /* Attribute properties are either NSStrings or NSNumbers based on our parsing */
        if ([[[attribute attributeForName:@"attributeType"] stringValue] isEqualToString:@"String"]) {
            propertiesString = [propertiesString stringByAppendingFormat:@"@property (nonatomic, retain) NSString *%@\n", [[attribute attributeForName:@"name"] stringValue]];
        }
        else {
            propertiesString = [propertiesString stringByAppendingFormat:@"@property (nonatomic, retain) NSNumber *%@\n", [[attribute attributeForName:@"name"] stringValue]];
        }
    }
    
    NSArray *relationships = [entity elementsForName:@"relationship"];
    NSMutableArray *toManyRelationships = [[NSMutableArray alloc] init];    // Keep track of to-many relationships for generating accessors methods below
    for (NSXMLElement *relationship in relationships) {
        /* To-many relationship are NSSets, otherwise the class name */
        if ([[[relationship attributeForName:@"toMany"] stringValue] isEqualToString:@"YES"]) {
            propertiesString = [propertiesString stringByAppendingFormat:@"@property (nonatomic, retain) NSSet *%@\n", [[relationship attributeForName:@"name"] stringValue]];
            [toManyRelationships addObject:relationship];
        }
        else {
            propertiesString = [propertiesString stringByAppendingFormat:@"@property (nonatomic, retain) %@ *%@\n", [[relationship attributeForName:@"destinationEntity"] stringValue], [[relationship attributeForName:@"name"] stringValue]];
        }
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{PROPERTIES}" withString:propertiesString];
    
    /* If there are any to-many relationships, add the accessors in a category */
    NSString *accessorsString = @"";
    
    if ([toManyRelationships count] != 0) {
        accessorsString = [NSString stringWithFormat:@"@interface %@ (JSONModelerGeneratedAccessors)\n\n", [[entity attributeForName:@"name"] stringValue]];
        for (NSXMLElement *relationship in toManyRelationships) {
            NSString *templatePath = [mainBundle pathForResource:@"CoreDataAccessorsTemplate" ofType:@"txt"];
            
            NSString *accessorsTemplate = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
            accessorsTemplate = [accessorsTemplate stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:[[relationship attributeForName:@"destinationEntity"] stringValue]];
            accessorsString = [accessorsString stringByAppendingFormat:@"%@\n\n", accessorsTemplate];
        }
        accessorsString = [accessorsString stringByAppendingString:@"@end"];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{GENERATEDACCESSORS_CATEGORY}" withString:accessorsString];
    
    return templateString;
}

- (NSString *)implementationFileForEntityElement:(NSXMLElement *)entity
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *interfaceTemplatePath = [mainBundle pathForResource:@"CoreDataImplementationTemplate" ofType:@"txt"];
    
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplatePath encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}"withString:[[entity attributeForName:@"name"] stringValue]];
    
    /* Set the date */
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DATE}" withString:[dateFormatter stringFromDate:currentDate]];
    
    /* Set the name and company values in the template from the current logged in user's address book information */
    ABAddressBook *addressBook = [ABAddressBook sharedAddressBook];
    ABPerson *me = [addressBook me];
    NSString *meFirstName = [me valueForProperty:kABFirstNameProperty];
    NSString *meLastName = [me valueForProperty:kABLastNameProperty];
    NSString *meCompany = [me valueForProperty:kABOrganizationProperty];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{NAME}" withString:[NSString stringWithFormat:@"%@ %@", meFirstName, meLastName]];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{COMPANY_NAME}" withString:[NSString stringWithFormat:@"%@ %@", [currentDate descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:nil] , meCompany]];
    
    /* Add the import directives */
    NSString *importString = @"";
    
    NSArray *relationships = [entity elementsForName:@"relationship"];
    for (NSXMLElement *relationship in relationships) {
        importString = [importString stringByAppendingFormat:@"#import \"%@.h\"\n", [[relationship attributeForName:@"destinationEntity"] stringValue]];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{IMPORT_BLOCK}" withString:importString];
    
    /* Add the @dynamic declarations */
    NSString *dynamicBlockString = @"";
    
    NSArray *attributes = [entity elementsForName:@"attribute"];
    for (NSXMLElement *attribute in attributes) {
        dynamicBlockString = [dynamicBlockString stringByAppendingFormat:@"@dynamic %@;\n", [[attribute attributeForName:@"name"] stringValue]];
    }
    for (NSXMLElement *relationship in relationships) {
        dynamicBlockString = [dynamicBlockString stringByAppendingFormat:@"@dynamic %@;\n", [[relationship attributeForName:@"name"] stringValue]];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{DYNAMIC_BLOCK}" withString:dynamicBlockString];
    
    
    return templateString;
    
}

@end
