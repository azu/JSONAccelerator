//
//  OutputLanguageWriterPython.h
//  JSONModeler
//
//  Created by Sean Hickey on 1/26/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "OutputLanguageWriterProtocol.h"

static NSString *const kPythonWritingOptionBaseClassName = @"kPythonWritingOptionBaseClassName";

@interface OutputLanguageWriterPython : NSObject <OutputLanguageWriterProtocol>

@end
