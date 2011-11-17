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
#import "TableSelectionChangeDelegate.h"

@class ClassNameTableViewHelper, ClassPropertiesTableViewHelper;

@interface EditOutputViewController : NSViewController <TableSelectionChangeDelegate>

@property (assign) id<MasterControllerDelegate> delegate;
@property (retain) JSONModeler *modeler;
@property (strong) IBOutlet ClassNameTableViewHelper *classNameHelper;
@property (strong) IBOutlet ClassPropertiesTableViewHelper *classPropertyHelper;
@property (weak) IBOutlet NSTableView *classTableView;
@property (weak) IBOutlet NSTableView *propertiesTableView;

- (IBAction)generateFilesPressed:(id)sender;

@end
