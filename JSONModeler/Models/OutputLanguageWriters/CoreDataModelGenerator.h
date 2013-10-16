//
//  CoreDataModelGenerator.h
//  JSONModeler
//
//  Created by Sean Hickey on 1/24/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataModelGenerator : NSObject

/**
 * Creates an xml document that can be saved in as a Core Data Model (.xcdatamodel) for use in Xcode.
 *
 * @param dictionary Dictionary of class objects to be included in the data model. Key is the name of an entity to create, value is the `ClassBaseObject` that represents the entity.
 * @return An NSXMLDocument to be wrapped in a .xcdatamodel bundle.
 */
- (NSXMLDocument *)coreDataModelXMLDocumentFromClassObjects:(NSArray *)classObjects;

@end
