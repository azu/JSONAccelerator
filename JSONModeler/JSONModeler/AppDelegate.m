//
//  NILAppDelegate.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONModeler.h"
#import "ClassBaseObject.h"
#import "MainWindowController.h"

@interface AppDelegate ()

@property (strong) JSONModeler *modeler;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize modeler = _modeler;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    if (myWindowController == NULL)
		myWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
	
	[myWindowController showWindow:self];
    
}

- (IBAction)downloadJSON:(id)sender {
    // http://developer.rottentomatoes.com/docs/json/v10/Top_Rentals
    // http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=fm34txf3v6vu9jph5fdqt529
    self.modeler = [[JSONModeler alloc] init];
    [self.modeler loadJSONWithURL:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=fm34txf3v6vu9jph5fdqt529"];
}

- (IBAction) saveButtonPressed: (id) sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setCanCreateDirectories:YES];
    [panel setResolvesAliases:YES];
    [panel setPrompt:NSLocalizedString(@"Choose", nil)];
    
    [panel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {        
        if (result == NSOKButton)
        {
            if(self.modeler) {
                NSError *error = nil;
                NSURL *selectedDirectory = [panel URL];
                NSArray *files = [[self.modeler parsedDictionary] allValues];
                for(ClassBaseObject *base in files) {
                    [[base headerStringWithHeader:@""] writeToURL:[selectedDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", base.className]]
                                                       atomically:NO
                                                         encoding:NSUTF8StringEncoding error:&error];
                    
                    [[base implementationStringWithHeader:@""] writeToURL:[selectedDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", base.className]]
                                                       atomically:NO
                                                         encoding:NSUTF8StringEncoding error:&error];
                }
            } 
        }
    }];
    
}

@end
