//
//  MainViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GenerateFilesButton;

@interface MainWindowController : NSWindowController

@property (weak) IBOutlet NSButton *getDataButton;
@property (unsafe_unretained) IBOutlet NSTextView *JSONTextView;
@property (weak) IBOutlet NSProgressIndicator *progressView;
@property (weak) IBOutlet NSButton *optionsButton;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (strong) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSView *fetchDataFromURLView;
@property (weak) IBOutlet NSButton *switchToDataLoadButton;
@property (weak) IBOutlet NSView *getDataView;
@property (weak) IBOutlet NSView *validDataStructureView;
@property (weak) IBOutlet GenerateFilesButton *genFilesView;

- (IBAction)optionsButtonPressed:(id)sender;
- (IBAction)generateFilesPressed:(id)sender;
- (IBAction)switchToDataLoadView:(id)sender;
- (IBAction)cancelDataLoad:(id)sender;



@end
