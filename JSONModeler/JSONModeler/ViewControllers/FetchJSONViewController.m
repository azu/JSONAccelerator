//
//  FetchJSONViewController.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "FetchJSONViewController.h"

@implementation FetchJSONViewController
@synthesize modeler = _modeler;
@synthesize urlTextField = _urlTextField;
@synthesize urlTextFieldCell = _urlTextFieldCell;
@synthesize getDataButton = _getDataButton;
@synthesize JSONTextView = _JSONTextView;
@synthesize progressView = _progressView;
@synthesize chooseLanguageButton = _chooseLanguageButton;

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
}



- (IBAction)getUrlPressed:(id)sender 
{
    [self.modeler addObserver:self forKeyPath:@"parseComplete" options:NSKeyValueObservingOptionNew context:NULL];
    [_modeler loadJSONWithURL:[_urlTextField stringValue]];
}

- (IBAction)chooseLanguagePressed:(id)sender {
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(_modeler.parseComplete) {
        [self.chooseLanguageButton setEnabled:YES];
    }
}

@end
