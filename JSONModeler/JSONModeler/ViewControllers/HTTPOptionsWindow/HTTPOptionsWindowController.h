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


- (IBAction)addHeaderClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;

@end
