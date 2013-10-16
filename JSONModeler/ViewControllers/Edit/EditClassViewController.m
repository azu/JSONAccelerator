//
//  EditClassViewController.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 12/1/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "EditClassViewController.h"

@implementation EditClassViewController
@synthesize classObject = _classObject;
@synthesize superclassField = _superclassField;
@synthesize classNameField = _classNameField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
