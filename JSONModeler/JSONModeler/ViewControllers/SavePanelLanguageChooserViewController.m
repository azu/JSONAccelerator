//
//  SavePanelLanguageChooserViewController.m
//  JSONModeler
//
//  Created by Sean Hickey on 12/29/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "SavePanelLanguageChooserViewController.h"

@implementation SavePanelLanguageChooserViewController
@synthesize languageDropDownIndex = _languageDropDownIndex;
@synthesize packageName = _packageName;
@synthesize baseClassName = _baseClassName;

@synthesize languageDropDown = _languageDropDown;
@synthesize outputLanguageLabel = _outputLanguageLabel;
@synthesize packageNameLabel = _packageNameLabel;
@synthesize packageNameField = _packageNameField;
@synthesize baseClassLabel = _baseClassLabel;
@synthesize baseClassField = _baseClassField;
@synthesize buildForArcButton = _buildForArcButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)awakeFromNib {
    self.outputLanguageLabel.stringValue = NSLocalizedString(@"Output Language", "In the save portion, the label to choose what language");
    self.packageNameLabel.stringValue = NSLocalizedString(@"Package Name", "In the save portion, the label to choose what the package is");
    self.baseClassLabel.stringValue = NSLocalizedString(@"Base Class", "In the save portion, the prompt to specify what the base class is");
    self.buildForArcButton.title = NSLocalizedString(@"Use Automatic Reference Counting", "In the save portion, for objective C, determine whether or not to use ARC");
    self.packageNameLabel.hidden = YES;
    self.packageNameField.hidden = YES;
    self.buildForArcButton.hidden = NO;
}

- (IBAction)languagePopUpChanged:(id)sender {
    if (_languageDropDownIndex == 1) {
        self.packageNameLabel.hidden = NO;
        self.packageNameField.hidden = NO;
        self.buildForArcButton.hidden = YES;
    }
    else {
        self.packageNameLabel.hidden = YES;
        self.packageNameField.hidden = YES;
        self.buildForArcButton.hidden = NO;
    }
}

-(OutputLanguage)chosenLanguage {
    if (_languageDropDownIndex == 0) {
        return OutputLanguageObjectiveC;
    }
    else if (_languageDropDownIndex == 1) {
        return OutputLanguageJava;
    }
    else {
        return -1;
    }
}
@end
