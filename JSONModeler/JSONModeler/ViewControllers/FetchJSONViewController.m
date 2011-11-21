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

@interface FetchJSONViewController() {
@private
    NoodleLineNumberView *lineNumberView;
}

@end

@implementation FetchJSONViewController
@synthesize modeler = _modeler;
@synthesize urlTextField = _urlTextField;
@synthesize urlTextFieldCell = _urlTextFieldCell;
@synthesize getDataButton = _getDataButton;
@synthesize JSONTextView = _JSONTextView;
@synthesize progressView = _progressView;
@synthesize chooseLanguageButton = _chooseLanguageButton;
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
    
    [self.urlTextFieldCell setStringValue:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=fm34txf3v6vu9jph5fdqt529"];
}



- (IBAction)getUrlPressed:(id)sender 
{
    [self.modeler addObserver:self forKeyPath:@"parseComplete" options:NSKeyValueObservingOptionNew context:NULL];
    JSONFetcher *fetcher = [[JSONFetcher alloc] init];
    [fetcher downloadJSONFromLocation:[_urlTextField stringValue] withSuccess:^(id object) {
        NSString *parsedString  = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        [self.JSONTextView setString:[parsedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    } 
    andFailure:^(NSHTTPURLResponse *response, NSError *error) {
        
    }];

}

- (IBAction)chooseLanguagePressed:(id)sender 
{
    
    if([self.delegate conformsToProtocol:@protocol(MasterControllerDelegate)]) {
        [self.modeler loadJSONWithString:[self.JSONTextView string]];
        [self.delegate moveToNextViewController];
    }
}

- (IBAction)verifyPressed:(id)sender
{
    NSError *error = nil;    
    NSData *data = [[self.JSONTextView string] dataUsingEncoding:NSUTF8StringEncoding];
    // Just for testing
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if(error) {
        NSLog(@"Error: %@", [error userInfo] );
    } else {
        [self.chooseLanguageButton setEnabled:YES];
        id output = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        [self.JSONTextView setString:outputString];
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(_modeler.parseComplete) {
        
        [self.chooseLanguageButton setEnabled:YES];
    }
}

@end
