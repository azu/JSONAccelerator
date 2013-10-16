//
//  ClassPropertiesTableViewHelper.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/17/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "ClassPropertiesTableViewHelper.h"
#import "JSONModeler.h"
#import "ClassPropertiesObject.h"
#import "OutputLanguageWriterObjectiveC.h"
@implementation ClassPropertiesTableViewHelper
@synthesize properties = _properties;
@synthesize modeler = _modeler;
@synthesize delegate = _delegate;


// The only essential/required tableview dataSource method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(self.properties == nil) {
        return 0;
    }
    
    return [[self.properties allValues] count];
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    ClassPropertiesObject *object = [[self.properties allValues] objectAtIndex:row];
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"Attribute"]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        NSString *sizeString = object.description;
        textField.objectValue = sizeString;
        return textField;
    } else if ([identifier isEqualToString:@"Type"]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        OutputLanguageWriterObjectiveC *writer = [OutputLanguageWriterObjectiveC new];
        NSString *sizeString = [writer typeStringForProperty:object];
        textField.objectValue = sizeString;
        return textField;
    } else {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if([self.delegate conformsToProtocol:@protocol(TableSelectionChangeDelegate)]) {
        [self.delegate tableDidChangeSelection:[notification object]];
    }
}


@end
