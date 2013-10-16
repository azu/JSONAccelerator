//
//  ModelerDocument.h
//  JSONModeler
//
//  Created by Sean Hickey on 12/21/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSONModeler.h"

@class MainWindowController;

@interface ModelerDocument : NSDocument

@property HTTPMethod httpMethod;
@property (strong) NSArray *httpHeaders;
@property (strong) JSONModeler *modeler;

@end
