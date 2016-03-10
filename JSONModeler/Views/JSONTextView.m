//
//  JSONTextView.m
//  JSONModeler
//
//  Created by Sean Hickey on 12/19/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "JSONTextView.h"

@implementation JSONTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType, NSPasteboardTypeString]];
    }
    
    return self;
}


#pragma mark - NSDraggingDestination Protocol Methods

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pb = [sender draggingPasteboard];
    NSDragOperation dragOperation = [sender draggingSourceOperationMask];
    
    if ([[pb types] containsObject:NSFilenamesPboardType]) {
        if (dragOperation & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    if ([[pb types] containsObject:NSPasteboardTypeString]) {
        if (dragOperation & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
    
}


-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pb = [sender draggingPasteboard];
    
    if ( [[pb types] containsObject:NSFilenamesPboardType] ) {
        NSArray *filenames = [pb propertyListForType:NSFilenamesPboardType];
        
        DLog(@"%@", filenames);
        
        for (NSString *filename in filenames) {
            if ([[filename pathExtension] isEqualToString:@"json"]) {
                NSStringEncoding encoding;
                NSError * error;
                NSString * fileContents = [NSString stringWithContentsOfFile:filename usedEncoding:&encoding error:&error];
                DLog(@"%@", fileContents);
                if (error) {
                    DLog(@"Error while reading file contents: %@", [error localizedDescription]);
                }
                else {
                    [self setString:fileContents];
                }
            }
        }
        
    }
    
    else if ( [[pb types] containsObject:NSPasteboardTypeString] ) {
        NSString *draggedString = [pb stringForType:NSPasteboardTypeString];
        [self setString:draggedString];
    }
    
    return YES;
    
}

#pragma mark Override Methods

- (void)paste:(id)sender
{
    [super paste:sender];
    self.string = [self prettyPrintedString] ?: self.string;
}

#pragma mark Public Methods

- (NSString *)prettyPrintedString
{
    NSError *error = nil;
    NSData *data = [self.string dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (!error && object)
    {
        id output = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        if (!error)
        {
            NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
            return outputString;
        }
    }
    return nil;
}

@end
