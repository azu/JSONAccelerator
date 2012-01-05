//
//  HTTPOptionsWindowController.h
//  JSONModeler
//
//  Created by Sean Hickey on 12/29/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HTTPOptionsWindowController : NSWindowController


@property (weak) IBOutlet NSMatrix *httpMethodRadioButtons;
@property HTTPMethod httpMethod;

@property (strong) IBOutlet NSArrayController *headerArrayController;

@property (weak) IBOutlet NSTextField *headerKeyField;
@property (weak) IBOutlet NSTextField *headerValueField;
@property (weak) IBOutlet NSTableView *headerTableView;

@property (weak) IBOutlet NSTableColumn *headerTableKeyColumn;

/* This button exists purely as a graphic element. It has no functionality */
@property (weak) IBOutlet NSButtonCell *dummyButton;

- (IBAction)addHeaderClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;

- (IBAction)plusClicked:(id)sender;
- (IBAction)minusClicked:(id)sender;

@end
