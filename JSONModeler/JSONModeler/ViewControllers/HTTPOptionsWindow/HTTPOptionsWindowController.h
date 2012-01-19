//
//  HTTPOptionsWindowController.h
//  JSONModeler
//
//  Created by Sean Hickey on 12/29/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ModelerDocument;

@interface HTTPOptionsWindowController : NSViewController <NSPopoverDelegate>


@property (weak) IBOutlet NSMatrix *httpMethodRadioButtons;
@property HTTPMethod httpMethod;
@property (weak) NSPopover *popover;

@property (strong) IBOutlet NSArrayController *headerArrayController;

@property (weak) ModelerDocument *document;

@property (weak) IBOutlet NSTextField *headerKeyField;
@property (weak) IBOutlet NSTextField *headerValueField;
@property (weak) IBOutlet NSTableView *headerTableView;

@property (weak) IBOutlet NSTableColumn *headerTableKeyColumn;

/* This button exists purely as a graphic element. It has no functionality */
@property (weak) IBOutlet NSButtonCell *dummyButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil document:(ModelerDocument *)doc;

- (IBAction)addHeaderClicked:(id)sender;

- (IBAction)plusClicked:(id)sender;
- (IBAction)minusClicked:(id)sender;

@end
