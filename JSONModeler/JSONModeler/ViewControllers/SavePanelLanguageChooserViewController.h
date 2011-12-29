//
//  SavePanelLanguageChooserViewController.h
//  JSONModeler
//
//  Created by Sean Hickey on 12/29/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SavePanelLanguageChooserViewController : NSViewController

@property (nonatomic) NSInteger languageDropDownIndex;
@property (strong) NSString *packageName;

@property (weak) IBOutlet NSPopUpButton *languageDropDown;
@property (weak) IBOutlet NSTextField *packageNameLabel;
@property (weak) IBOutlet NSTextField *packageNameField;


- (IBAction)languagePopUpChanged:(id)sender;

- (OutputLanguage)chosenLanguage;
@end
