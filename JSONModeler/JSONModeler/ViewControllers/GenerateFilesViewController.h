//
//  GenerateFilesViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MasterControllerDelegate.h"
#import "JSONModeler.h"

@interface GenerateFilesViewController : NSViewController

@property (assign) id<MasterControllerDelegate> delegate;
@property (retain) JSONModeler *modeler;

@end
