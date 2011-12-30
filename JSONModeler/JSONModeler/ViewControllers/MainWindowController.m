//
//  MainViewController.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "MainWindowController.h"
#import "JSONModeler.h"
#import "FetchJSONViewController.h"
#import "ChooseLanguageViewController.h"
#import "EditOutputViewController.h"
#import "GenerateFilesViewController.h"
#import "ModelerDocument.h"

@interface MainWindowController ()

@property (strong) JSONModeler *modeler;

- (void)changeViewController:(NSInteger)whichViewTag;

@end

@implementation MainWindowController
@synthesize currentPlacementPathBar;
@synthesize mainWindow;
@synthesize modeler = _modeler;

enum	// view controller choices
{
	kFetchView = 0,
	kChooseView,
	kEditView,
	kGenerateView
};

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
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
    ModelerDocument *document = self.document;
    self.modeler = document.modeler;
	[self changeViewController: kFetchView];
    [self.mainWindow setMinSize:NSMakeSize(500, 300)];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

// -------------------------------------------------------------------------------
//	changeViewController:whichViewTag
//
//	Change the current NSViewController to a new one based on a tag obtained from
//	the NSPopupButton control.
// -------------------------------------------------------------------------------
- (void)changeViewController:(NSInteger)whichViewTag
{
	// we are about to change the current view controller,
	// this prepares our title's value binding to change with it
	[self willChangeValueForKey:@"viewController"];
	
	if ([myCurrentViewController view] != nil)
		[[myCurrentViewController view] removeFromSuperview];	// remove the current view
    	
    NSURL *pathUrl = nil;
    
	switch (whichViewTag)
	{
		case kFetchView:	// swap in the "CustomImageViewController - NSImageView"
		{
			FetchJSONViewController *fetchViewController = [[FetchJSONViewController alloc] initWithNibName:@"FetchJSONViewController" bundle:nil];
            fetchViewController.modeler = self.modeler;
            fetchViewController.document = self.document;
			if (fetchViewController != nil)
			{
				myCurrentViewController = fetchViewController;	// keep track of the current view controller        
                fetchViewController.delegate = self;
			}
            pathUrl = [NSURL URLWithString:@"/Fetch"];
			break;
		}
            
		case kChooseView:	// swap in the "CustomTableViewController - NSTableView"
		{
			ChooseLanguageViewController* chooseViewController =
            [[ChooseLanguageViewController alloc] initWithNibName:@"ChooseLanguageViewController" bundle:nil];
			if (chooseViewController != nil)
			{
				myCurrentViewController = chooseViewController;	// keep track of the current view controller
                chooseViewController.delegate = self;
			}
            
            pathUrl = [NSURL URLWithString:@"/Fetch/Choose"];
            
			break;
		}
            
		case kEditView:	// swap in the "CustomVideoViewController - QTMovieView"
		{
			EditOutputViewController* editViewController = [[EditOutputViewController alloc] initWithNibName:@"EditOutputViewController" bundle:nil];
            editViewController.modeler = self.modeler;
			if (editViewController != nil)
			{
				myCurrentViewController = editViewController;	// keep track of the current view controller
                editViewController.delegate = self;
			}
            
            pathUrl = [NSURL URLWithString:@"/Fetch/Choose/Edit"];
            
			break;
		}
            
		case kGenerateView:	// swap in the "NSViewController - Quartz Composer iSight Camera"
		{
			GenerateFilesViewController* generateViewController =
            [[GenerateFilesViewController alloc] initWithNibName:@"GenerateFilesViewController" bundle:nil];
			if (generateViewController != nil)
			{
				myCurrentViewController = generateViewController;	// keep track of the current view controller
                generateViewController.delegate = self;
			}
            generateViewController.modeler = self.modeler;
            pathUrl = [NSURL URLWithString:@"/Fetch/Choose/Edit/Generate"];
            
			break;
		}
	}
    
    [self.currentPlacementPathBar setURL:pathUrl];
	
	// embed the current view to our host view
	[myTargetView addSubview: [myCurrentViewController view]];
	
	// make sure we automatically resize the controller's view to the current window size
	[[myCurrentViewController view] setFrame: [myTargetView bounds]];
	
	// set the view controller's represented object to the number of subviews in that controller
	// (our NSTextField's value binding will reflect this value)
	// [myCurrentViewController setRepresentedObject: [NSNumber numberWithUnsignedInt: [[[myCurrentViewController view] subviews] count]]];
	
	[self didChangeValueForKey:@"viewController"];	// this will trigger the NSTextField's value binding to change
}

// -------------------------------------------------------------------------------
//	viewController
// -------------------------------------------------------------------------------
- (NSViewController*)viewController
{
	return myCurrentViewController;
}

#pragma mark - MasterControllerDelegate Methods

-(void)moveToNextViewController
{
    if([myCurrentViewController isKindOfClass:[FetchJSONViewController class]]) {
        [self changeViewController: kChooseView];
    } else if ([myCurrentViewController isKindOfClass:[ChooseLanguageViewController class]]) {
        [self changeViewController:kEditView];
    } else if ([myCurrentViewController isKindOfClass:[EditOutputViewController class]]) {
        [self changeViewController:kGenerateView];
    }
}

@end
