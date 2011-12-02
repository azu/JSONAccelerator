//
//  EditOutputViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSONModeler.h"
#import "MasterControllerDelegate.h"
#import "EditClassViewController.h"
#import "EditPropertyViewController.h"
#import "TableSelectionChangeDelegate.h"

@class ClassNameTableViewHelper, ClassPropertiesTableViewHelper;

@interface EditOutputViewController : NSViewController <TableSelectionChangeDelegate, NSPopoverDelegate>

@property (assign) id<MasterControllerDelegate> delegate;
@property (retain) JSONModeler *modeler;
@property (strong) IBOutlet ClassNameTableViewHelper *classNameHelper;
@property (strong) IBOutlet ClassPropertiesTableViewHelper *classPropertyHelper;
@property (weak) IBOutlet NSTableView *classTableView;
@property (weak) IBOutlet NSTableView *propertiesTableView;
@property (strong) IBOutlet NSWindow *editClassWindow;
@property (strong) IBOutlet NSWindow *editPropertyWindow;
@property (strong) IBOutlet EditClassViewController *editClassVC;
@property (strong) IBOutlet EditPropertyViewController *editPropertyVC;
@property (weak) IBOutlet NSButton *editClassButton;
@property (weak) IBOutlet NSButton *editPropertyButton;

- (IBAction)generateFilesPressed:(id)sender;
- (IBAction)editClassPressed:(id)sender;
- (IBAction)editPropertyPressed:(id)sender;

@end
