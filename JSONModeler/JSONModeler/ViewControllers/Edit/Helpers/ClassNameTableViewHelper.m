//
//  Class.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/17/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "ClassNameTableViewHelper.h"
#import "JSONModeler.h"
#import "ClassBaseObject.h"

@implementation ClassNameTableViewHelper
@synthesize modeler = _modeler;
@synthesize delegate = _delegate;

// The only essential/required tableview dataSource method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[[self.modeler parsedDictionary] allKeys] count];
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    NSArray *keysArray = [[self.modeler parsedDictionary ] allKeys];
    ClassBaseObject *object = (ClassBaseObject *)[[self.modeler parsedDictionary] objectForKey:[keysArray objectAtIndex:row]];
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
    NSString *sizeString = [NSString stringWithFormat:@"%@ : %@", object.className, object.baseClass];
    textField.objectValue = sizeString;
    return textField;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if([self.delegate conformsToProtocol:@protocol(TableSelectionChangeDelegate)]) {
        [self.delegate tableDidChangeSelection:[notification object]];
    }
}

@end
