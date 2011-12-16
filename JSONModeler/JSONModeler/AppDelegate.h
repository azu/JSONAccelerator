//
//  NILAppDelegate.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MainWindowController* myWindowController;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)downloadJSON:(id)sender;
- (IBAction) saveButtonPressed: (id) sender;
- (IBAction)openPreferences:(id)sender;

@end
