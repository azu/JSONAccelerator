//
//  HTTPOptionsWindowController.h
//  JSONModeler
//
//  Created by Sean Hickey on 12/29/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ModelerDocument;

@protocol HTTPOptionsWindowControllerDelegate <NSObject>

- (void)getDataButtonPressed;

@end

@interface HTTPOptionsWindowController : NSViewController <NSPopoverDelegate>

@property (strong) id<HTTPOptionsWindowControllerDelegate>popoverOwnerDelegate;
@property (weak) IBOutlet NSMatrix *httpMethodRadioButtons;
@property HTTPMethod httpMethod;
@property (weak) NSPopover *popover;

@property (strong) IBOutlet NSArrayController *headerArrayController;

@property (weak) ModelerDocument *document;

@property (weak) IBOutlet NSTextField *headerKeyField;
@property (weak) IBOutlet NSTextField *headerValueField;
@property (weak) IBOutlet NSTableView *headerTableView;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSTextFieldCell *urlTextFieldCell;
@property (weak) IBOutlet NSButton *generateDataButton;

@property (weak) IBOutlet NSTableColumn *headerTableKeyColumn;
@property (weak) IBOutlet NSTableColumn *headerTableValueColumn;

/* This button exists purely as a graphic element. It has no functionality */
@property (weak) IBOutlet NSButtonCell *dummyButton;

/* Other Localizable UI Elements */
@property (weak) IBOutlet NSBox *methodBox;
@property (weak) IBOutlet NSBox *headersBox;
@property (weak) IBOutlet NSTextField *keyLabel;
@property (weak) IBOutlet NSTextField *valueLabel;
@property (weak) IBOutlet NSButton *addButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil document:(ModelerDocument *)doc;

- (IBAction)addHeaderClicked:(id)sender;

- (IBAction)plusClicked:(id)sender;
- (IBAction)minusClicked:(id)sender;
- (IBAction)fetchDataPress:(id)sender;

@end
