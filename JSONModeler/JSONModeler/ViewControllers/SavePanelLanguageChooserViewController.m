//
//  SavePanelLanguageChooserViewController.m
//  JSONModeler
//
//  Created by Sean Hickey on 12/29/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "SavePanelLanguageChooserViewController.h"

@implementation SavePanelLanguageChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.buildForARC = YES;
    }
    
    return self;
}

-(void)awakeFromNib {
    self.outputLanguageLabel.stringValue = NSLocalizedString(@"Output Language", "In the save portion, the label to choose what language");
    self.packageNameLabel.stringValue = NSLocalizedString(@"Package Name", "In the save portion, the label to choose what the package is");
    self.baseClassLabel.stringValue = NSLocalizedString(@"Base Class", "In the save portion, the prompt to specify what the base class is");
    self.buildForArcButton.title = NSLocalizedString(@"Use Automatic Reference Counting", "In the save portion, for objective C, determine whether or not to use ARC");
    self.classPrefixLabel.stringValue = NSLocalizedString(@"Class Prefix", "The letters to prepend to the file");
    
    self.javaPanel.hidden = YES;
    self.objectiveCPanel.hidden = NO;

    [self.languageDropDown selectItemAtIndex:2];
    [self.languageDropDown selectItemAtIndex:0];
    
    self.languageDropDown.nextKeyView = self.baseClassField;
    self.baseClassField.nextKeyView = self.classPrefixField;
    
}

- (IBAction)languagePopUpChanged:(id)sender {
    if (_languageDropDownIndex == 1) {
        self.javaPanel.hidden = NO;
        self.objectiveCPanel.hidden = YES;

        self.packageNameLabel.hidden = NO;
        self.packageNameField.hidden = NO;
        self.buildForArcButton.hidden = YES;
        self.baseClassField.nextKeyView = self.packageNameField;
    }
    else if (_languageDropDownIndex == 0) {
        self.javaPanel.hidden = YES;
        self.objectiveCPanel.hidden = NO;
        self.baseClassField.nextKeyView = self.classPrefixField;
    }
    else {
        self.javaPanel.hidden = YES;
        self.objectiveCPanel.hidden = YES;
    }
}

-(OutputLanguage)chosenLanguage {
    if (_languageDropDownIndex == 0) {
        return OutputLanguageObjectiveC;
    }
    else if (_languageDropDownIndex == 1) {
        return OutputLanguageJava;
    }
    else if (_languageDropDownIndex == 2) {
        return OutputLanguageCoreDataObjectiveC;
    }
    else if (_languageDropDownIndex == 3) {
        return OutputLanguageDjangoPython;
    }
    else if (_languageDropDownIndex == 4) {
        return OutputLanguagePython;
    }
    else {
        return -1;
    }
}
@end
