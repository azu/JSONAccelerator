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
+ (NSString *)propertyForProperty:(ClassPropertiesObject *) property;
+ (NSString *)setterForProperty:(ClassPropertiesObject *) property;
+ (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *) property;
+ (NSString *)typeStringForProperty:(ClassPropertiesObject *) property;
+ (NSString *)getterForProperty:(ClassPropertiesObject *)property;

@end
