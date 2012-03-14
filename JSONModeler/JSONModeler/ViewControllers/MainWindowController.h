//
//  MainViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSTextFieldCell *urlTextFieldCell;
@property (weak) IBOutlet NSButton *getDataButton;
@property (unsafe_unretained) IBOutlet NSTextView *JSONTextView;
@property (weak) IBOutlet NSProgressIndicator *progressView;
@property (weak) IBOutlet NSButton *optionsButton;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (strong) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSToolbarItem *generateFilesButton;
@property (weak) IBOutlet NSToolbarItem *verifyJSONButton;
@property (weak) IBOutlet NSView *fetchDataFromURLView;
@property (weak) IBOutlet NSButton *switchToDataLoadButton;
@property (weak) IBOutlet NSView *getDataView;



- (IBAction)getUrlPressed:(id)sender;
- (void)chooseLanguagePressed:(id)sender;
- (void)verifyPressed:(id)sender;
- (IBAction)optionsButtonPressed:(id)sender;
- (IBAction)generateFilesPressed:(id)sender;
- (IBAction)verifyJSONPressed:(id)sender;
- (IBAction)switchToDataLoadView:(id)sender;



@end
