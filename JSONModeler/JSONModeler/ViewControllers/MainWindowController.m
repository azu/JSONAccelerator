//
//  MainViewController.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/10/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//


#import "MainWindowController.h"
#import <QuartzCore/QuartzCore.h>
#import "JSONModeler.h"
#import "ModelerDocument.h"
#import "JSONFetcher.h"
#import "HTTPOptionsWindowController.h"
#import "MarkerLineNumberView.h"
#import "SavePanelLanguageChooserViewController.h"
#import "GenerateFilesButton.h"

#import "OutputLanguageWriterObjectiveC.h"
#import "OutputLanguageWriterJava.h"
#import "OutputLanguageWriterCoreData.h"
#import "OutputLanguageWriterDjango.h"

#import "CoreDataModelGenerator.h"


@interface MainWindowController ()  <NSTextViewDelegate, NSOpenSavePanelDelegate, HTTPOptionsWindowControllerDelegate, ClickViewDelegate>

@property (strong) JSONModeler *modeler;
@property (strong) HTTPOptionsWindowController *wc;

- (BOOL) verifyJSONString;
- (void) generateFiles;
- (void)getDataButtonPressed;

@end

@implementation MainWindowController  {
@private
    MarkerLineNumberView *_lineNumberView;
    SavePanelLanguageChooserViewController *_languageChooserViewController;
}
@synthesize validDataStructureView = _validDataStructureView;
@synthesize genFilesView = _genFilesView;

@synthesize mainWindow = _mainWindow;
@synthesize fetchDataFromURLView = _fetchDataFromURLView;
@synthesize switchToDataLoadButton = _switchToDataLoadButton;
@synthesize getDataView = _getDataView;
@synthesize modeler = _modeler;
@synthesize getDataButton = _getDataButton;
@synthesize JSONTextView = _JSONTextView;
@synthesize progressView = _progressView;
@synthesize optionsButton = _optionsButton;
@synthesize scrollView = _scrollView;
@synthesize wc = _wc;

#pragma mark - Begin Class Methods
#pragma mark Loading Methods
// -------------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
    ModelerDocument *document = self.document;
    
    self.modeler = document.modeler;
    [self.getDataView setHidden:YES];
    self.wc = [[HTTPOptionsWindowController alloc] initWithNibName:@"HTTPOptionsWindowController" bundle:nil document:self.document];
    self.wc.popoverOwnerDelegate = self;
    
    NSString *genFiles = NSLocalizedString(@"Generate Files", @"In the main screen, this is the button that writes out files");
    [self.mainWindow setMinSize:NSMakeSize(550, 588)];
    [self.genFilesView.textField setStringValue:genFiles];
    self.genFilesView.delegate = self;

    
    NSFont *fixedFont = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
    [self.JSONTextView setFont:fixedFont];

    [self.JSONTextView setNeedsDisplay:YES];
    
    _lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:self.scrollView];
    CGFloat lineNumberColor = 42.0/255.0;
    
    _lineNumberView.backgroundColor = [NSColor colorWithCalibratedRed:lineNumberColor green:lineNumberColor blue:lineNumberColor alpha:1.0f];
    [self.scrollView setVerticalRulerView:_lineNumberView];
    [self.scrollView setHasHorizontalRuler:NO];
    [self.scrollView setHasVerticalRuler:YES];
    [self.scrollView setRulersVisible:YES];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.JSONTextView setTextColor:[NSColor whiteColor]];
    [self.JSONTextView setTextContainerInset:NSMakeSize(2, 4)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:NSControlTextDidChangeNotification object:nil];

    NSError *error = nil;    
    NSData *data = [[self.JSONTextView string] dataUsingEncoding:NSUTF8StringEncoding];
    // Just for testing
    [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error == nil) {
        [self toggleCanGenerateFilesTo:YES];
    } else {
        [self toggleCanGenerateFilesTo:NO];
    }
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark IBActions

- (IBAction)generateFilesPressed:(id)sender {
    if([self verifyJSONString]) {
        [self generateFiles];
    }
}

- (IBAction)switchToDataLoadView:(id)sender
{
    [self optionsButtonPressed:sender];
//    [self.scrollView setHidden:YES];
//    [self.switchToDataLoadButton setHidden:YES];
//    [self.getDataView setHidden:NO];
//    [self.urlTextField becomeFirstResponder];
//    [self.generateFilesButton setEnabled:NO];
}

- (IBAction)cancelDataLoad:(id)sender 
{
    
    [self.scrollView setHidden:NO];
    [self.switchToDataLoadButton setHidden:NO];
    [self.getDataView setHidden:YES];
    
    
    NSError *error = nil;    
    NSData *data = [[self.JSONTextView string] dataUsingEncoding:NSUTF8StringEncoding];
    // Just for testing
    [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error == nil) {
        [self toggleCanGenerateFilesTo:YES];
    } else {
        [self toggleCanGenerateFilesTo:NO];
    }
}

- (void)getDataButtonPressed
{
    if (nil == [self.wc.urlTextField stringValue] || [[self.wc.urlTextField stringValue] isEqualToString:@""]) {
        return;
    }
    
    [self.wc.urlTextField setStringValue:[self.wc.urlTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [self.getDataButton setHidden:YES];
    [self.progressView startAnimation:nil];
    NSString *escapedString = [[self.wc.urlTextField stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    [self.modeler addObserver:self forKeyPath:@"parseComplete" options:NSKeyValueObservingOptionNew context:NULL];
    JSONFetcher *fetcher = [[JSONFetcher alloc] init];
    fetcher.document = self.document;
    
    // ******************************************
    // SUCCESS BLOCK
    // ******************************************    
    void (^successBlock)(id object) = ^(id object) {
        [self.wc.popover close];
        [self.getDataButton setHidden:NO];
        [self.progressView stopAnimation:nil];
        NSString *parsedString  = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;    
        parsedString = [parsedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSData *data = [parsedString dataUsingEncoding:NSUTF8StringEncoding];
        // Just for testing
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if(error == nil) {
            id output = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
            NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
            self.modeler.JSONString = outputString;
            [self toggleCanGenerateFilesTo:YES]; 
        } else {
            self.modeler.JSONString = parsedString;
            [self toggleCanGenerateFilesTo:NO];
        }
    };

    // ******************************************
    // ERROR BLOCK
    // ******************************************    
    void (^errorBlock)(NSHTTPURLResponse *response, NSError *error) = ^(NSHTTPURLResponse *response, NSError *error){
        [self.getDataButton setHidden:NO];
        [self.progressView stopAnimation:nil];
        if(response == nil) {
            NSString *informativeText = [error localizedDescription];
            if(informativeText == nil) {
                informativeText = @"";
            }
            NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"An Error Occurred", @"Title of an alert if there is an error getting content of a url")
                                                 defaultButton:NSLocalizedString(@"Dismiss", @"Button to dismiss an action sheet")
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"%@", informativeText];
            [testAlert runModal];
        }
        else {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"An Error Occurred", @"Title of an alert if there is an error getting content of a url")
                                             defaultButton:NSLocalizedString(@"Dismiss", @"Button to dismiss an action sheet")
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:[NSString stringWithFormat:@"%ld - %@", [response statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]]];
            [alert runModal];
        }
    };
    
    [fetcher downloadJSONFromLocation:escapedString withSuccess: successBlock andFailure:errorBlock ];
    
}

#pragma mark Helper Methods

- (void)textDidChange:(NSNotification *)notification
{
    if ([notification object]== self.JSONTextView) {
        NSError *error = nil;    
        NSData *data = [[self.JSONTextView string] dataUsingEncoding:NSUTF8StringEncoding];
        // Just for testing
        [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            [self toggleCanGenerateFilesTo:NO];
        } else {
            // Show 
            [self toggleCanGenerateFilesTo:YES];
        }
    }
}

- (void)toggleCanGenerateFilesTo:(BOOL)canGenerateFiles {
    if(canGenerateFiles == NO) {
        [self.genFilesView setEnabled:NO];
        [self.validDataStructureView setHidden:YES];
    } else {
        // Show 
        [self.validDataStructureView setHidden:NO];
        [self.genFilesView setEnabled:YES];
    }
}

- (BOOL)verifyJSONString
{
    NSError *error = nil;    
    NSData *data = [[self.JSONTextView string] dataUsingEncoding:NSUTF8StringEncoding];
    // Just for testing
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if(error) {
        NSDictionary *dict = [error userInfo];
        NSString *informativeText = [[dict allValues] objectAtIndex:0];
        if([informativeText isEqualToString:@"No value."]) {
            informativeText = NSLocalizedString(@"There is no content to parse.", @"If there is nothing in the JSON field, state that there is nothing there");
        } else if ([informativeText isEqualToString:@"JSON text did not start with array or object and option to allow fragments not set."]) {
            informativeText = NSLocalizedString(@"JSON text did not start with array or object.", @"Error message to state the JSON didn't start with a {} or []");
        }
        NSAlert *testAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"An error occurred while verifying the JSON", @"The title for the action sheet saying something went wrong")
                                             defaultButton:NSLocalizedString(@"Dismiss", @"Button to dismiss an action sheet")
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@", informativeText];
        [testAlert beginSheetModalForWindow:self.mainWindow modalDelegate:self didEndSelector:nil contextInfo:nil]; 
        return NO;
    } else {
        id output = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        self.modeler.JSONString = outputString;
        return YES;
    }
    return YES;
}

- (IBAction)optionsButtonPressed:(id)sender {
    NSPopover *myPopover = [[NSPopover alloc] init];
    myPopover.appearance = NSPopoverAppearanceMinimal;
    
    self.wc.popover = myPopover;
    myPopover.delegate = self.wc;
    myPopover.contentViewController = self.wc;
    
    // AppKit will close the popover when the user interacts with a user interface element outside the popover.
    // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
    myPopover.behavior = NSPopoverBehaviorSemitransient;
    
    NSButton *targetButton = (NSButton *)sender;
    
    // configure the preferred position of the popover
    NSRectEdge prefEdge =NSMinYEdge;
    
    
    [myPopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:prefEdge];
    
    return;
}

- (void)generateFiles
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setCanCreateDirectories:YES];
    [panel setResolvesAliases:YES];
    [panel setPrompt:NSLocalizedString(@"Choose", @"Label to have the user select which folder to choose")];
    [panel setDelegate:self];
    
    _languageChooserViewController = [[SavePanelLanguageChooserViewController alloc] initWithNibName:@"SavePanelLanguageChooserViewController" bundle:nil];
    [panel setAccessoryView:_languageChooserViewController.view];
    
    [panel beginSheetModalForWindow:self.mainWindow completionHandler:^(NSInteger result) {        
        if (result == NSOKButton)
        {
            OutputLanguage language = [_languageChooserViewController chosenLanguage];
            
            BOOL filesHaveBeenWritten = NO;
            BOOL filesHaveHadError = NO;
            
            if(self.modeler) {
                
                NSURL *selectedDirectory = [panel URL];
                id<OutputLanguageWriterProtocol> writer = nil;
                NSDictionary *optionsDict = nil;
                
                if (language == OutputLanguageObjectiveC) {
                    writer = [[OutputLanguageWriterObjectiveC alloc] init];
                    optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:_languageChooserViewController.baseClassName, kObjectiveCWritingOptionBaseClassName, [NSNumber numberWithBool:_languageChooserViewController.buildForARC], kObjectiveCWritingOptionUseARC, nil];
                }
                else if (language == OutputLanguageJava) {
                    writer = [[OutputLanguageWriterJava alloc] init];
                    optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:_languageChooserViewController.baseClassName, kJavaWritingOptionBaseClassName, _languageChooserViewController.packageName, kJavaWritingOptionPackageName, nil];
                }
                else if (language == OutputLanguageCoreDataObjectiveC) {
                    writer = [[OutputLanguageWriterCoreData alloc] init];
                    optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:_languageChooserViewController.baseClassName, kCoreDataWritingOptionBaseClassName, nil];
                }
                else if (language == OutputLanguageDjangoPython) {
                    writer = [[OutputLanguageWriterDjango alloc] init];
                    optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:_languageChooserViewController.baseClassName, kDjangoWritingOptionBaseClassName, nil];
                }
                
                [self.modeler loadJSONWithString:[self.JSONTextView string] outputLanguageWriter:writer];
                
                filesHaveBeenWritten = [writer writeClassObjects:[self.modeler parsedDictionary] toURL:selectedDirectory options:optionsDict generatedError:&filesHaveHadError];
                
            }
            
            NSString *statusString = @"";
            if(filesHaveBeenWritten) {
                statusString = NSLocalizedString(@"Your files have successfully been generated.", @"Success message in an action sheet");
                if(filesHaveHadError) {
                    statusString = [statusString stringByAppendingString:NSLocalizedString(@" However, there was an error writing one or more of the files", @"If something went wrong, but the writing was generally successful")];
                }
            } else {
                statusString = NSLocalizedString(@"An error has occurred and no files have been generated.", @"Actionsheet message for stating that nothing was generated ");
            }
            
            NSString *titleMessage = nil;
            if(filesHaveBeenWritten) {
                titleMessage = NSLocalizedString(@"Success!", @"Message in an actionsheet stating that the write is successful");
            } else {
                titleMessage = NSLocalizedString(@"No file were written to the disk", @"Message when writing the files, nothing was written");
            }
            
            NSAlert *statusAlert = [NSAlert alertWithMessageText:titleMessage
                                                   defaultButton:NSLocalizedString(@"Dismiss", @"Button to dismiss an action sheet")
                                                 alternateButton:nil
                                                     otherButton:nil
                                       informativeTextWithFormat:@"%@", statusString];
            [statusAlert runModal];
            //[statusAlert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:nil contextInfo:nil]; 
        }
    }];
    
}

-(BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError *__autoreleasing *)outError {
    
    OutputLanguage language = [_languageChooserViewController chosenLanguage];
    // If we're creating java files, and there's no package name, reject
    if (language == OutputLanguageJava && (_languageChooserViewController.packageName == nil || _languageChooserViewController.packageName == @"") ) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"No Package Name" defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please enter a package name."];
        [alert runModal];
        return NO;
    }
    
    // Check to see if we're going to overwrite files
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *filePath = [url path];
    
    BOOL willOverwriteFiles = NO;
    NSArray *outputObjects = [[self.modeler parsedDictionary] allValues];
    if (language == OutputLanguageObjectiveC) {
        for (ClassBaseObject *outputObject in outputObjects) {
            if ( [fileManager fileExistsAtPath:[[filePath stringByAppendingPathComponent:outputObject.className] stringByAppendingPathExtension:@"m"]]
                || [fileManager fileExistsAtPath:[[filePath stringByAppendingPathComponent:outputObject.className] stringByAppendingPathExtension:@"h"]] ) {
                willOverwriteFiles = YES;
            }
        }
    }
    else if (language == OutputLanguageJava) {
        for (ClassBaseObject *outputObject in outputObjects) {
            if ( [fileManager fileExistsAtPath:[[filePath stringByAppendingPathComponent:outputObject.className] stringByAppendingPathExtension:@"java"]] ) {
                willOverwriteFiles = YES;
            }
        }
    }
    
    if (willOverwriteFiles) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Overwrite files?", @"The title of the prompt to tell the user they are about to overwrite the files in the existing application") defaultButton:NSLocalizedString(@"Overwrite Files", @"Button text to overwrite files") alternateButton:NSLocalizedString(@"Cancel", @"Cancel button in the overwrite files prompt") otherButton:nil informativeTextWithFormat:NSLocalizedString(@"This operation will overwrite files in this directory. Are you sure you want to continue?", @"The prompt to tell the user they are about to overwrite the files in the existing application")];
        NSInteger alertReturn = [alert runModal];
        if (alertReturn == NSAlertDefaultReturn) {
            return YES;
        }
        else if (alertReturn == NSAlertAlternateReturn) {
            return NO;
        }
        
    }
    
    return YES;
    
}

#pragma mark - Custom Delegate method

- (void)clickViewPressed:(id)sender
{
    if(sender  == self.genFilesView) {
        [self generateFilesPressed:nil];
    }
}

#pragma mark - NSTextViewDelegate methods

-(NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex {
    
    NSInteger layoutOrientationIdx =  [menu indexOfItemWithTitle:@"Layout Orientation"];
    if ( layoutOrientationIdx != -1 ) {
        [menu removeItemAtIndex:layoutOrientationIdx];
    }
    
    return menu;
    
}

@end
