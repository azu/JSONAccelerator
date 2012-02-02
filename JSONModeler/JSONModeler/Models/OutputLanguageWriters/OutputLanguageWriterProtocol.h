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

@optional
- (NSDictionary *)getOutputFilesForClassObject:(ClassBaseObject *)classObject;

- (NSString *)propertyForProperty:(ClassPropertiesObject *)property;
- (NSString *)setterForProperty:(ClassPropertiesObject *)property;
- (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *)property;
- (NSString *)typeStringForProperty:(ClassPropertiesObject *)property;
- (NSString *)getterForProperty:(ClassPropertiesObject *)property;

@end
