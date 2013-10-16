//
//  OutputLanguageWriterProtocol.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 1/19/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassPropertiesObject.h"

@protocol OutputLanguageWriterProtocol <NSObject>

@required
//@property (retain) ClassBaseObject *classObject;

/**
 * Generates output files and writes class objects to disk.
 *
 * @param classObjects Dictionary where the key is the name of the class to be generated and the value is the `ClassBaseObject` that represents the class.
 * @param url URL to write files to.
 * @param options An arbitrary dictionary of options for the class to use while generating and writing the files. Keys for this dictionary should be defined in the class that conforms to this protocol.
 * @param generatedError Pointer to a BOOL that will indicate whether an error occurred in the process of writing.
 * @return Boolean value indicating whether or not files were written to disk.
 */
- (BOOL)writeClassObjects:(NSDictionary *)classObjectsDict toURL:(NSURL *)url options:(NSDictionary *)options generatedError:(BOOL *)generatedErrorFlag;

/**
 * Should provide a set of `NSString`s where each string is a reserved word in the language. E.g., in Objective-C, this would contain
 * strings like `@interface`, `if`, `YES`, etc.
 *
 * @return Set of reserved words for the language
 */
- (NSSet *)reservedWords;

/**
 * This method is called by the modeler when it attempts to create a class with a name that is a reserved word in the language.
 * It should return the name to be used by the modeler. A common use might be to simply take the reserved word, append a string such
 * as "Class" and return that string to the modeler.
 *
 * @param classObject The `ClassBaseObject` to be named
 * @param reservedWord The default name provided by the json which is also a reserved word in the language
 * @return The string that the modeler will name the class. This will not be furthered checked to make sure it's not a reserved word
 */
- (NSString *)classNameForObject:(ClassBaseObject *)classObject fromReservedWord:(NSString *)reservedWord;

/**
 * This method is called by the modeler when it attempts to create a property with a name that is a reserved word in the language.
 * It should return the name to be used by the modeler. A common use might be to simply take the reserved word, append a string such
 * as "Property" and return that string to the modeler. Alternatively, specific reserved words can return specific values (e.g., in
 * Objective-C, if a property should be named "id", according to the json, this function could return the class name appended with "Identifier".
 *
 * @param propertyObject The `ClassPropertyObject` to be named
 * @param classObject The `ClassBaseObject` that "owns" the property
 * @param reservedWord The default name provided by the json which is also a reserved word in the language
 * @return The string that the modeler will name the property. This will not be furthered checked to make sure it is not a reserved word
 */
- (NSString *)propertyNameForObject:(ClassPropertiesObject *)propertyObject inClass:(ClassBaseObject *)classObject fromReservedWord:(NSString *)reservedWord;

@optional
- (NSDictionary *)getOutputFilesForClassObject:(ClassBaseObject *)classObject;

- (NSString *)propertyForProperty:(ClassPropertiesObject *)property;
- (NSString *)setterForProperty:(ClassPropertiesObject *)property;
- (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *)property;
- (NSString *)typeStringForProperty:(ClassPropertiesObject *)property;
- (NSString *)getterForProperty:(ClassPropertiesObject *)property;

@end
