//
//  FetchJSONViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSONModeler.h"

@interface FetchJSONViewController : NSViewController

@property (retain) JSONModeler *modeler;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSButton *getDataButton;
@property (unsafe_unretained) IBOutlet NSTextView *JSONTextView;
@property (weak) IBOutlet NSProgressIndicator *progressView;

- (IBAction)getUrlPressed:(id)sender;

@end
