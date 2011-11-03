//
//  NILAppDelegate.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONModeler.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)downloadJSON:(id)sender {
    // http://developer.rottentomatoes.com/docs/json/v10/Top_Rentals
    // http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=fm34txf3v6vu9jph5fdqt529
    JSONModeler *modeler = [[JSONModeler alloc] init];
    [modeler loadJSONWithURL:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=fm34txf3v6vu9jph5fdqt529"];
}

- (IBAction) saveButtonPressed: (id) sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setResolvesAliases:YES];
    [panel setPrompt:NSLocalizedString(@"Choose", nil)];
    
    [panel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {        
        if (result == NSOKButton)
        {
            NSString *wert = @"wert";
            NSError *error = nil;
            NSURL *selectedDirectory = [panel URL];
            selectedDirectory = [selectedDirectory URLByAppendingPathComponent:@"wert.txt"];
            
            [wert writeToURL:selectedDirectory atomically:NO encoding:NSUTF8StringEncoding error:&error];
        }
    }];
    
}

@end
