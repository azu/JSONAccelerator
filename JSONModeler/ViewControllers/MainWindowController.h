//
//  MainViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GenerateFilesButton, InvalidDataButton, JSONTextView;

@interface MainWindowController : NSWindowController

@property (weak) IBOutlet NSButton *getDataButton;
@property (unsafe_unretained) IBOutlet JSONTextView *JSONTextView;
@property (weak) IBOutlet NSProgressIndicator *progressView;
@property (weak) IBOutlet NSButton *optionsButton;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (strong) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSView *fetchDataFromURLView;
@property (weak) IBOutlet NSButton *switchToDataLoadButton;
@property (weak) IBOutlet NSView *getDataView;
@property (weak) IBOutlet NSView *validDataStructureView;
@property (weak) IBOutlet GenerateFilesButton *genFilesView;
@property (weak) IBOutlet InvalidDataButton *invalidDataView;
@property (weak) IBOutlet NSView *errorMessageView;
@property (weak) IBOutlet NSTextField *errorMessageTitle;
@property (weak) IBOutlet NSTextField *errorMessageDescription;
@property (weak) IBOutlet NSButton *errorCloseButton;
@property (weak) IBOutlet NSTextFieldCell *instuctionsTextField;
@property (weak) IBOutlet NSTextFieldCell *validDataStructureField;


- (BOOL)verifyJSONString;
- (IBAction)optionsButtonPressed:(id)sender;
- (IBAction)generateFilesPressed:(id)sender;
- (IBAction)switchToDataLoadView:(id)sender;
- (IBAction)cancelDataLoad:(id)sender;
- (IBAction)closeAlertPressed:(id)sender;



@end
