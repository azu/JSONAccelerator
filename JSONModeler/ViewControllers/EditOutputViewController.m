//
//  EditOutputViewController.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "EditOutputViewController.h"
#import "ClassPropertiesTableViewHelper.h"
#import "ClassNameTableViewHelper.h"
#import "ClassBaseObject.h"

@implementation EditOutputViewController
@synthesize delegate = _delegate;
@synthesize modeler = _modeler;
@synthesize classNameHelper = _classNameHelper;
@synthesize classPropertyHelper = _classPropertyHelper;
@synthesize classTableView = _classTableView;
@synthesize propertiesTableView = _propertiesTableView;
@synthesize editClassWindow = _editClassWindow;
@synthesize editPropertyWindow = _editPropertyWindow;
@synthesize editClassVC = _editClassVC;
@synthesize editPropertyVC = _editPropertyVC;
@synthesize editClassButton = _editClassButton;
@synthesize editPropertyButton = _editPropertyButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    self.classNameHelper.modeler = self.modeler;
    self.classNameHelper.delegate = self;
    
    self.classPropertyHelper.modeler = self.modeler;
    self.classPropertyHelper.delegate = self;
    
    _editClassWindow.contentView = _editClassVC.view;
    _editPropertyWindow.contentView = _editPropertyVC.view;
}

- (IBAction)generateFilesPressed:(id)sender
{
    if([self.delegate conformsToProtocol:@protocol(MasterControllerDelegate)]) {
        [self.delegate moveToNextViewController];
    }
}

- (IBAction)editClassPressed:(id)sender
{
    NSPopover *myPopover = [[NSPopover alloc] init];
    
    myPopover.contentViewController = self.editClassVC;
    
    NSArray *keysArray = [[self.modeler parsedDictionary ] allKeys];
    ClassBaseObject *object = (ClassBaseObject *)[[self.modeler parsedDictionary] objectForKey:[keysArray objectAtIndex:self.classTableView.selectedRow]];
    
    self.editClassVC.classObject = object;
    
    [[self.editClassVC superclassField] setStringValue:object.baseClass];
    [[self.editClassVC classNameField] setStringValue:object.className];
    
    
    // AppKit will close the popover when the user interacts with a user interface element outside the popover.
    // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
    myPopover.behavior = NSPopoverBehaviorTransient;
    
    // so we can be notified when the popover appears or closes
    myPopover.delegate = self;
    
    NSButton *targetButton = (NSButton *)sender;
    
    // configure the preferred position of the popover
    NSRectEdge prefEdge =NSMinYEdge;
    
    [myPopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:prefEdge];
}

- (IBAction)editPropertyPressed:(id)sender
{
    NSPopover *myPopover = [[NSPopover alloc] init];
    
    myPopover.contentViewController = self.editPropertyVC;
    
    
    // AppKit will close the popover when the user interacts with a user interface element outside the popover.
    // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
    myPopover.behavior = NSPopoverBehaviorTransient;
    
    // so we can be notified when the popover appears or closes
    myPopover.delegate = self;
    
    NSButton *targetButton = (NSButton *)sender;
    
    // configure the preferred position of the popover
    NSRectEdge prefEdge =NSMinYEdge;
    
    [myPopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:prefEdge];
}

- (void)tableDidChangeSelection: (NSTableView *)tableView
{
    if(tableView == self.classTableView) {
        if([self.classTableView selectedRow] != -1) {
            [_editClassButton setEnabled:YES];
            NSArray *keysArray = [[self.modeler parsedDictionary ] allKeys];
            ClassBaseObject *object = (ClassBaseObject *)[[self.modeler parsedDictionary] objectForKey:[keysArray objectAtIndex:[self.classTableView selectedRow]]];
            [self.classPropertyHelper setProperties:object.properties];
            [self.propertiesTableView reloadData];
        } else {
            [_editClassButton setEnabled:NO];
            [_editPropertyButton setEnabled:NO];
        }
    }
    if(tableView == self.propertiesTableView) {
        
    }

}

@end
