//
//  FetchJSONViewController.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "FetchJSONViewController.h"
#import "JSONFetcher.h"
#import "NoodleLineNumberView.h"
#import "ClassBaseObject.h"

@interface FetchJSONViewController() {
@private
    NoodleLineNumberView *lineNumberView;
}

- (BOOL) verifyJSONString;
- (void) generateFiles;

@end

@implementation FetchJSONViewController
@synthesize modeler = _modeler;
@synthesize urlTextField = _urlTextField;
@synthesize urlTextFieldCell = _urlTextFieldCell;
@synthesize getDataButton = _getDataButton;
@synthesize JSONTextView = _JSONTextView;
@synthesize progressView = _progressView;
@synthesize chooseLanguageButton = _chooseLanguageButton;
@synthesize generateFilesButton = _generateFilesButton;
@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

// -------------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// load the default image from our bundle
    [self.urlTextFieldCell setPlaceholderString:NSLocalizedString(@"Enter URL...", nil)];
    [self.chooseLanguageButton setEnabled:NO];
    [self.JSONTextView setRichText:NO];
    [self.JSONTextView setFont:[NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]]];
    
    
//    [self.scrollView setVerticalRulerView:[[NoodleLineNumberView alloc] initWithScrollView:self.scrollView]];
//    [self.scrollView setHasHorizontalRuler:NO];
//    [self.scrollView setHasVerticalRuler:YES];
//    [self.scrollView setRulersVisible:YES];
    
#ifdef DEBUG
    [self.urlTextFieldCell setStringValue:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=fm34txf3v6vu9jph5fdqt529"];
#endif
}



- (IBAction)getUrlPressed:(id)sender 
{
    if (nil == [_urlTextField stringValue] || [[_urlTextField stringValue] isEqualToString:@""]) {
        return;
    }
    [self.modeler addObserver:self forKeyPath:@"parseComplete" options:NSKeyValueObservingOptionNew context:NULL];
    JSONFetcher *fetcher = [[JSONFetcher alloc] init];
    [fetcher downloadJSONFromLocation:[_urlTextField stringValue] withSuccess:^(id object) {
        NSString *parsedString  = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        [self.JSONTextView setString:[parsedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    } 
    andFailure:^(NSHTTPURLResponse *response, NSError *error) {
        if(response == nil) {
            NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"An Error Occurred", nil)
                                                 defaultButton:NSLocalizedString(@"Dismiss", @"")
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"%@", [error localizedDescription]];
            [testAlert runModal];
        }
    }];

}

- (IBAction)chooseLanguagePressed:(id)sender 
{
    if([self verifyJSONString]) {
        [self.modeler loadJSONWithString:[self.JSONTextView string]];
        [self generateFiles];
//        if([self.delegate conformsToProtocol:@protocol(MasterControllerDelegate)]) {
//            [self.modeler loadJSONWithString:[self.JSONTextView string]];
//            [self.delegate moveToNextViewController];
//        }
    }
}

- (IBAction)verifyPressed:(id)sender
{
    [self verifyJSONString];
}

- (BOOL)verifyJSONString
{
    NSError *error = nil;    
    NSData *data = [[self.JSONTextView string] dataUsingEncoding:NSUTF8StringEncoding];
    // Just for testing
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if(error) {
        NSDictionary *dict = [error userInfo];
        NSString *informativeText = [[dict allValues] objectAtIndex:0];
        if([informativeText isEqualToString:@"No value."]) {
            informativeText = NSLocalizedString(@"There is no content to parse.", nil);
        } else if ([informativeText isEqualToString:@"JSON text did not start with array or object and option to allow fragments not set."]) {
            informativeText = NSLocalizedString(@"JSON text did not start with array or object.", nil);
        }
        NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"An error occurred while verifying the JSON", nil)
                                             defaultButton:NSLocalizedString(@"Dismiss", @"")
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@", informativeText];
        [testAlert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:nil contextInfo:nil]; 
        return NO;
    } else {
        [self.chooseLanguageButton setEnabled:YES];
        id output = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        [self.JSONTextView setString:outputString];
        return YES;
    }
    return YES;
}

- (IBAction)animateButtonPressed:(id)sender 
{
    NSShadow *shadow = [[NSShadow alloc] init];
        
    [shadow setShadowOffset:NSMakeSize(3, -3)];
    [shadow setShadowBlurRadius:4.0];
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.75]];
    // Begin a grouping of animation target value settings.
    [NSAnimationContext beginGrouping];
    
    // Request a default animation duration of 0.5 seconds.
    [[NSAnimationContext currentContext] setDuration:2.5];
    
    [[(NSButton *)sender animator] setFrameOrigin:NSMakePoint(100, 100)];
    // End the grouping of animation target value settings, causing the animations in the grouping to be started simultaneously.
    [NSAnimationContext endGrouping];

}

- (void)generateFiles
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setCanCreateDirectories:YES];
    [panel setResolvesAliases:YES];
    [panel setPrompt:NSLocalizedString(@"Choose", nil)];
    
    OutputLanguage language = OutputLanguageObjectiveC;
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {        
        if (result == NSOKButton)
        {
            BOOL filesHaveBeenWritten = NO;
            BOOL filesHaveHadError = NO;
            if(self.modeler) {
                NSError *error = nil;
                NSURL *selectedDirectory = [panel URL];
                NSArray *files = [[self.modeler parsedDictionary] allValues];
                for(ClassBaseObject *base in files) {
                    NSDictionary *outputDictionary = [base outputStringsWithType:language];
                    NSArray *keysArray = [outputDictionary allKeys];
                    NSString *outputString = nil;
                    for(NSString *key in keysArray) {
                        error = nil;
                        outputString = [outputDictionary objectForKey:key];
                        [outputString writeToURL:[selectedDirectory URLByAppendingPathComponent:key]
                                      atomically:NO
                                        encoding:NSUTF8StringEncoding 
                                           error:&error];
                        if(error) {
                            DLog(@"%@", [error localizedDescription]);
                            filesHaveHadError = YES;
                        } else {
                            filesHaveBeenWritten = YES;
                        }
                    }
                }
            }
            NSString *statusString = @"";
            if(filesHaveBeenWritten) {
                statusString = NSLocalizedString(@"Your files have successfully been generated.", @"");
                if(filesHaveHadError) {
                    statusString = [statusString stringByAppendingString:NSLocalizedString(@" However, there was an error writing one or more of the files", @"")];
                }
            } else {
                statusString = NSLocalizedString(@"An error has occurred and no files have been generated.", @"");
            }
            NSAlert *statusAlert = [NSAlert alertWithMessageText:NSLocalizedString((filesHaveBeenWritten) ? @"Success!" : @"How about that - nothing happened", nil)
                                                 defaultButton:NSLocalizedString(@"Dismiss", @"")
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"%@", statusString];
            [statusAlert runModal];
        }
    }];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(_modeler.parseComplete) {
        
        [self.chooseLanguageButton setEnabled:YES];
    }
}

@end
