//
//  CoreDataModelGenerator.m
//  JSONModeler
//
//  Created by Sean Hickey on 1/24/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "CoreDataModelGenerator.h"
#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"

#import "NSString+Nerdery.h"

@interface CoreDataModelGenerator () {
@private
    
}

- (NSXMLElement *)modelRootElement;
- (NSXMLElement *)entityElementForClassBaseObject:(ClassBaseObject *)classBaseObject;
- (NSXMLElement *)attributeElementForClassPropertiesObject:(ClassPropertiesObject *)classPropertiesObject;
- (NSXMLElement *)relationshipElementForClassPropertiesObject:(ClassPropertiesObject *)classPropertiesObject forEntityNamed:(NSString *)entityName;
- (NSXMLElement *)UIElementsElementForModel:(NSXMLElement *)model;
- (NSArray *)computeInverseRelationshipsForModel:(NSXMLElement *)model;

@end

@implementation CoreDataModelGenerator

- (NSXMLDocument *)coreDataModelXMLDocumentFromClassObjects:(NSDictionary *)dictionary
{
    NSXMLElement *rootElement = [self modelRootElement];
    
    
    NSArray *classObjects = [dictionary allValues];
    for (ClassBaseObject *classObject in classObjects) {
        
        NSXMLElement *entity = [self entityElementForClassBaseObject:classObject];
        
        NSArray *properties = [[classObject properties] allValues];
        for (ClassPropertiesObject *property in properties) {
            
            PropertyType type = property.type;
            
            NSXMLElement *childElement;
            if (type == PropertyTypeString || type == PropertyTypeInt || type == PropertyTypeDouble || type == PropertyTypeBool || type == PropertyTypeOther) {
                childElement = [self attributeElementForClassPropertiesObject:property];
            }
            else if (type == PropertyTypeArray || type == PropertyTypeDictionary || type == PropertyTypeClass || type == PropertyTypeOther) {
                childElement = [self relationshipElementForClassPropertiesObject:property forEntityNamed:[[entity attributeForName:@"name"] stringValue]];
            }
            
            [entity addChild:childElement];
        }
        
        [rootElement addChild:entity];
    }
    
    NSArray *inverseRelationships = [self computeInverseRelationshipsForModel:rootElement];
    NSArray *entities = [rootElement elementsForName:@"entity"];
    for (NSXMLElement *inverse in inverseRelationships) {
        NSString *entityNeedingInverseName = [[[inverse attributeForName:@"inverseName"] stringValue] objectiveCClassString];
        for (NSXMLElement *entity in entities) {
            if ([[[entity attributeForName:@"name"] stringValue] isEqualToString:entityNeedingInverseName]) {
                [entity addChild:inverse];
            }
        }
    }
    
    NSXMLElement *uiInfo = [self UIElementsElementForModel:rootElement];
    [rootElement addChild:uiInfo];
    
    NSXMLDocument *modelDoc = [[NSXMLDocument alloc] initWithRootElement:rootElement];
    
    return modelDoc;
}

- (NSXMLElement *)modelRootElement
{
    return [[NSXMLElement alloc] initWithName:@"model"];
}

- (NSXMLElement *)entityElementForClassBaseObject:(ClassBaseObject *)classBaseObject
{
    NSXMLElement *entity = [[NSXMLElement alloc] initWithName:@"entity"];
    
    NSXMLNode *nameAttribute = [NSXMLNode attributeWithName:@"name" stringValue:classBaseObject.className];
    NSXMLNode *syncableAttribute = [NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"];
    
    [entity addAttribute:nameAttribute];
    [entity addAttribute:syncableAttribute];
    
    return entity;
}

- (NSXMLElement *)attributeElementForClassPropertiesObject:(ClassPropertiesObject *)classPropertiesObject
{
    /* Check to make sure we can actually create an attribute of this type */
    PropertyType type = classPropertiesObject.type;
    if (type == PropertyTypeArray || type == PropertyTypeDictionary || type == PropertyTypeClass || type == PropertyTypeOther) {
        NSLog(@"Error: %@ does not have a valid attribute type", classPropertiesObject);
        return nil;
    }
    
    /* Create the element */
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"attribute"];
    
    /* Assign its name */
    NSXMLNode *nameAttribute = [NSXMLNode attributeWithName:@"name" stringValue:classPropertiesObject.name];
    [element addAttribute:nameAttribute];
    
    /* Make it optional */
    NSXMLNode *optionalAttribute = [NSXMLNode attributeWithName:@"optional" stringValue:@"YES"];
    [element addAttribute:optionalAttribute];
    
    /* Determine the backing type for the attribute */
    NSString *attributeType = nil;
    if (type == PropertyTypeString) {
        attributeType = @"String";
    }
    else if (type == PropertyTypeInt) {
        attributeType = @"Integer 32";
    }
    else if (type == PropertyTypeDouble) {
        attributeType = @"Double";
    }
    else if (type == PropertyTypeBool) {
        attributeType = @"Boolean";
    }
    else {
        NSLog(@"Error: %@ does not have a valid attribute type", classPropertiesObject);
        return nil;
    }
    
    /* Create the attribute type */
    NSXMLNode *typeAttribute = [NSXMLNode attributeWithName:@"attributeType" stringValue:attributeType];
    [element addAttribute:typeAttribute];
    
    /* If the type was a numerical type, give it a default value */
    if (type == PropertyTypeInt) {
        NSXMLNode *defaultValue = [NSXMLNode attributeWithName:@"defaultValueString" stringValue:@"0"];
        [element addAttribute:defaultValue];
    }
    else if (type == PropertyTypeDouble) {
        NSXMLNode *defaultValue = [NSXMLNode attributeWithName:@"defaultValueString" stringValue:@"0.0"];
        [element addAttribute:defaultValue];
    }
    
    /* Add the syncable attribute */
    NSXMLNode *syncable = [NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"];
    [element addAttribute:syncable];
    
    return element;
    
}

- (NSXMLElement *)relationshipElementForClassPropertiesObject:(ClassPropertiesObject *)classPropertiesObject forEntityNamed:(NSString *)entityName
{
    NSLog(@"%@", [classPropertiesObject description]);
    /* Check to make sure we can actually create a relationship */
    PropertyType type = classPropertiesObject.type;
    if (type == PropertyTypeString || type == PropertyTypeInt || type == PropertyTypeDouble || type == PropertyTypeBool || type == PropertyTypeOther) {
        NSLog(@"Error: %@ does not have a valid attribute type", classPropertiesObject);
        return nil;
    }
    
    /* Create the element */
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"relationship"];
    
    /* Give it a name */
    NSXMLNode *nameAttribute = [NSXMLNode attributeWithName:@"name" stringValue:classPropertiesObject.name];
    [element addAttribute:nameAttribute];
    
    /* Make it optional */
    NSXMLNode *optionalAttribute = [NSXMLNode attributeWithName:@"optional" stringValue:@"YES"];
    [element addAttribute:optionalAttribute];
    
    /* If this represents an array, make it a to-many relationship */
    if (type == PropertyTypeArray) {    //To-many relationship
        NSXMLNode *toManyAttribute = [NSXMLNode attributeWithName:@"toMany" stringValue:@"YES"];
        [element addAttribute:toManyAttribute];
    }
    
    /* Set the deletion rule */
    NSXMLNode *deletionAttribute = [NSXMLNode attributeWithName:@"deletionRule" stringValue:@"Nullify"];
    [element addAttribute:deletionAttribute];
    
    /* Set the destination entity */
    NSXMLNode *destinationAttribute = [NSXMLNode attributeWithName:@"destinationEntity" stringValue:[classPropertiesObject.name objectiveCClassString]];
    [element addAttribute:destinationAttribute];
    
    /* Set the inverse relationship */
    NSXMLNode *inverseAttribute = [NSXMLNode attributeWithName:@"inverseName" stringValue:[entityName objectiveCPropertyString]];
    [element addAttribute:inverseAttribute];
    
    /* Set the inverse entity name */
    NSXMLNode *inverseEntityAttribute = [NSXMLNode attributeWithName:@"inverseEntity" stringValue:[classPropertiesObject.name objectiveCClassString]];
    [element addAttribute:inverseEntityAttribute];
    
    /* Add the syncable attribute */
    NSXMLNode *syncable = [NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"];
    [element addAttribute:syncable];
    
    return element;
}

- (NSXMLElement *)UIElementsElementForModel:(NSXMLElement *)model
{
    NSXMLElement *elementsNode = [[NSXMLElement alloc] initWithName:@"elements"];
    
    NSArray *entities = [model elementsForName:@"entity"];
    
    int i = 0;
    for (NSXMLElement *entity in entities) {
        NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"element"];
        
        NSXMLNode *nameAttribute = [NSXMLNode attributeWithName:@"name" stringValue:[[entity attributeForName:@"name"] stringValue]];
        [element addAttribute:nameAttribute];
        
        NSXMLNode *positionXAttribute = [NSXMLNode attributeWithName:@"positionX" stringValue:[NSString stringWithFormat:@"%i", i * 200]];
        [element addAttribute:positionXAttribute];
        
        NSXMLNode *positionYAttribute = [NSXMLNode attributeWithName:@"positionY" stringValue:@"0"];
        [element addAttribute:positionYAttribute];
        
        NSXMLNode *widthAttribute = [NSXMLNode attributeWithName:@"width" stringValue:@"135"];
        [element addAttribute:widthAttribute];
        
        NSUInteger countChildren = [entity childCount];
        
        NSXMLNode *heightAttribute = [NSXMLNode attributeWithName:@"height" stringValue:[NSString stringWithFormat:@"%i", ((int)countChildren * 15) + 45]];
        [element addAttribute:heightAttribute];
        
        [elementsNode addChild:element];
        
        ++i;
    }
    
    return elementsNode;
}

- (NSArray *)computeInverseRelationshipsForModel:(NSXMLElement *)model
{
    NSArray *entities = [model elementsForName:@"entity"];
    
    NSMutableArray *newRelationships = [[NSMutableArray alloc] init];
    for (NSXMLElement *entity in entities) {
        NSArray *relationships = [entity elementsForName:@"relationship"];
        for (NSXMLElement *relationship in relationships) {
            
            NSXMLElement *newRelationship = [[NSXMLElement alloc] initWithName:@"relationship"];
            
            NSXMLNode *nameAttribute = [NSXMLNode attributeWithName:@"name" stringValue:[[relationship attributeForName:@"inverseName"] stringValue]];
            [newRelationship addAttribute:nameAttribute];
            
            NSXMLNode *optionalAttribute = [NSXMLNode attributeWithName:@"optional" stringValue:@"YES"];
            [newRelationship addAttribute:optionalAttribute];
            
            NSXMLNode *deletionAttribute = [NSXMLNode attributeWithName:@"deletionRule" stringValue:@"Nullify"];
            [newRelationship addAttribute:deletionAttribute];
            
            /* Set the destination entity */
            NSXMLNode *destinationAttribute = [NSXMLNode attributeWithName:@"destinationEntity" stringValue:[[entity attributeForName:@"name"] stringValue]];
            [newRelationship addAttribute:destinationAttribute];
            
            /* Set the inverse relationship */
            NSXMLNode *inverseAttribute = [NSXMLNode attributeWithName:@"inverseName" stringValue:[[relationship attributeForName:@"name"] stringValue]];
            [newRelationship addAttribute:inverseAttribute];
            
            /* Set the inverse entity name */
            NSXMLNode *inverseEntityAttribute = [NSXMLNode attributeWithName:@"inverseEntity" stringValue:[[entity attributeForName:@"name"] stringValue]];
            [newRelationship addAttribute:inverseEntityAttribute];
            
            /* Add the syncable attribute */
            NSXMLNode *syncable = [NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"];
            [newRelationship addAttribute:syncable];
            
            [newRelationships addObject:newRelationship];
            
        }
    }
    
    return newRelationships;
}

@end






















