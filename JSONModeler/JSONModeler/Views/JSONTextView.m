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


@end
