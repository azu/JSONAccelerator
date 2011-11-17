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
}

- (IBAction)generateFilesPressed:(id)sender
{
    if([self.delegate conformsToProtocol:@protocol(MasterControllerDelegate)]) {
        [self.delegate moveToNextViewController];
    }
}

- (void)tableDidChangeSelection
{
    if([self.classTableView selectedRow] != -1) {
        NSArray *keysArray = [[self.modeler parsedDictionary ] allKeys];
        ClassBaseObject *object = (ClassBaseObject *)[[self.modeler parsedDictionary] objectForKey:[keysArray objectAtIndex:[self.classTableView selectedRow]]];
        [self.classPropertyHelper setProperties:object.properties];
        [self.propertiesTableView reloadData];
    }

}

@end
