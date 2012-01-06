//
//  MainViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MasterControllerDelegate.h"

@interface MainWindowController : NSWindowController <MasterControllerDelegate> {
    IBOutlet NSView*	myTargetView;				// the host view
	NSViewController*	myCurrentViewController;	// the current view controller
}

@property (weak) IBOutlet NSPathControl *currentPlacementPathBar;
@property (strong) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSToolbarItem *generateFilesButton;
@property (weak) IBOutlet NSToolbarItem *verifyJSONButton;

- (NSViewController*)viewController;
- (IBAction)generateFilesPressed:(id)sender;
- (IBAction)verifyJSONPressed:(id)sender;

@end
