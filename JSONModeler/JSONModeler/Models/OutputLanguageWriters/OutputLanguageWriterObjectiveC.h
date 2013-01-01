//
//  OutputLanguageWriterObjectiveC.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 1/19/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassPropertiesObject.h"
#import "OutputLanguageWriterProtocol.h"
#import "ClassBaseObject.h"

/* Writing options keys for OutputLanguageWriterProtocol methods */
static NSString *const kObjectiveCWritingOptionBaseClassName = @"kObjectiveCWritingOptionBaseClassName";
static NSString *const kObjectiveCWritingOptionUseARC = @"kObjectiveCWritingOptionUseARC";
static NSString *const kObjectiveCWritingOptionClassPrefix = @"kObjectiveCWritingOptionClassPrefix";


@interface OutputLanguageWriterObjectiveC : NSObject <OutputLanguageWriterProtocol>


@end
