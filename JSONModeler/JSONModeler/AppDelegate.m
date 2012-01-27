//
//  NILAppDelegate.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONModeler.h"
#import "ClassBaseObject.h"
#import "MainWindowController.h"
#import "MASPreferencesWindowController.h"
#import "JRFeedbackController.h"
#import <ObjectiveMetrics/ObjectiveMetrics.h>

@interface AppDelegate () {
    
    MASPreferencesWindowController *_preferencesWindowController;
    
}

@end


@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[DMTracker defaultTracker] startApp];
    _preferencesWindowController = nil;
    
}

-(BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return YES;
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    
    if ([[filename pathExtension] isEqualToString:@"json"]) {
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename] display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {}];
        return YES;
    }
    
    return NO;
    
}

- (IBAction)openPreferences:(id)sender 
{
    
}

- (IBAction)feedbackMenuSelected:(id)sender
{
    [JRFeedbackController showFeedback];
}

@end
