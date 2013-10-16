//
//  GenerateFilesViewController.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "GenerateFilesViewController.h"
#import "ClassBaseObject.h"

@implementation GenerateFilesViewController
@synthesize delegate = _delegate;
@synthesize modeler = _modeler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) awakeFromNib
{
    NSArray *files = [[self.modeler parsedDictionary] allValues];
    for(ClassBaseObject *base in files) {
        NSButton *button = [[NSButton alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 100, 20))];
        
        [self.view addSubview:button];
        
    }
}

- (IBAction) saveButtonPressed: (id) sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setCanCreateDirectories:YES];
    [panel setResolvesAliases:YES];
    [panel setPrompt:NSLocalizedString(@"Choose", nil)];
    
    OutputLanguage language;
    if([sender tag] == 0) {
        language = OutputLanguageObjectiveC;
    } else {
        language = OutputLanguageJava;
    }
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {        
        if (result == NSOKButton)
        {
            if(self.modeler) {
                NSError *error = nil;
                NSURL *selectedDirectory = [panel URL];
                NSArray *files = [[self.modeler parsedDictionary] allValues];
                for(ClassBaseObject *base in files) {
                    NSDictionary *outputDictionary = [base outputStringsWithType:language];
                    NSArray *keysArray = [outputDictionary allKeys];
                    NSString *outputString = nil;
                    for(NSString *key in keysArray) {
                        outputString = [outputDictionary objectForKey:key];
                        [outputString writeToURL:[selectedDirectory URLByAppendingPathComponent:key]
                                      atomically:NO
                                        encoding:NSUTF8StringEncoding 
                                           error:&error];
                    }                    
                }
            } 
        }
    }];
    
}

@end
