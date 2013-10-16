//
//  ChooseLanguageViewController.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "ChooseLanguageViewController.h"

@implementation ChooseLanguageViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)typeChosen:(id)sender
{
    if([self.delegate conformsToProtocol:@protocol(MasterControllerDelegate)]) {
        [self.delegate moveToNextViewController];
    }
}

@end
