//
//  OutputLanguageWriterCoreData.m
//  JSONModeler
//
//  Created by Sean Hickey on 1/24/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "OutputLanguageWriterCoreData.h"

#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"
#import "NSString+Nerdery.h"

@implementation OutputLanguageWriterCoreData

- (BOOL)writeClassObjects:(NSDictionary *)classObjectsDict toURL:(NSURL *)url options:(NSDictionary *)options generatedError:(BOOL *)generatedErrorFlag
{
    NSMutableArray *classObjects = [[classObjectsDict allValues] mutableCopy];
    
    NSArray *classObjectsCopy = [NSArray arrayWithArray:classObjects];  //Create an immutable copy so we can iterate over it while we mutate the original
    for (ClassBaseObject *classObject in classObjectsCopy) {
        NSArray *properties = [[classObject properties] allValues];
        for (ClassPropertiesObject *property in properties) {
            if (property.type == PropertyTypeArray && property.collectionType != PropertyTypeClass) {
                /* If some class has a to-many property that doesn't contain a custom class (e.g., an array of ints) we need to create a new object to wrap those values */
                ClassBaseObject *newObject = [[ClassBaseObject alloc] init];
                newObject.className = [property.name objectiveCClassString];
                
                ClassPropertiesObject *newProperty = [[ClassPropertiesObject alloc] init];
                newProperty.name = property.name;
                newProperty.type = property.collectionType;
                
                [classObjects addObject:newObject];
                
                NSLog(@"%@", [newObject properties]);
            }
        }
    }
}

@end
