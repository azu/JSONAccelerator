//
//  MainViewController.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController {
    IBOutlet NSView*	myTargetView;				// the host view
	NSViewController*	myCurrentViewController;	// the current view controller
}

@property (weak) IBOutlet NSPathControl *currentPlacementPathBar;

- (NSViewController*)viewController;

@end
