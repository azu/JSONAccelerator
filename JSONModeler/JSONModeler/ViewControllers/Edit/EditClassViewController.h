//
//  EditClassViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 12/1/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ClassBaseObject;

@interface EditClassViewController : NSViewController

@property (retain) ClassBaseObject *classObject;
@property (weak) IBOutlet NSTextField *superclassField;
@property (weak) IBOutlet NSTextField *classNameField;

@end
