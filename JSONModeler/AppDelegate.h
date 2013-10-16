//
//  NILAppDelegate.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)reflowDocument:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)feedbackMenuSelected:(id)sender;

@end
