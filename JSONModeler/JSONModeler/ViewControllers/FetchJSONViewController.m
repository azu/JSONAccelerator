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
@synthesize getDataButton = _getDataButton;
@synthesize JSONTextView = _JSONTextView;
@synthesize progressView = _progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)getUrlPressed:(id)sender 
{
    
}

@end
