//
//  InvalidDataButton.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 3/12/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "InvalidDataButton.h"

@interface InvalidDataButton ()

@end

@implementation InvalidDataButton
@synthesize textField = _textField;

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self) {
        self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(32, -7, frameRect.size.width, frameRect.size.height)];
        [self.textField setAlignment:NSLeftTextAlignment];
        [_textField setBezeled:NO];
        [_textField setDrawsBackground:NO];
        [_textField setEditable:NO];
        [_textField setSelectable:NO];
        [[_textField cell] setBackgroundStyle:NSBackgroundStyleRaised];
        [self addSubview:self.textField];
        [_textField setStringValue:NSLocalizedString(@"Invalid Data Structure", @"This is a message stating that the JSON that is in the application is not of valid form")];
        [self.textField setTextColor:[NSColor blackColor]];

        NSImage *alertImage = [NSImage imageNamed:@"alert"];
        NSImageView *alertImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(8, 9, alertImage.size.width, alertImage.size.height)];
        alertImageView.image = alertImage;
        [self addSubview:alertImageView];
        
        
        // Setup the images
        NSImage *leftCapImage = [NSImage imageNamed:@"alertLeftCap.png"];
        NSImage *middleCapImage = [NSImage imageNamed:@"alertBackground.png"];
        NSImage *rightCapImage = [NSImage imageNamed:@"alertRightCap.png"];
        
        self.capLeft.image = leftCapImage;
        self.capLeft.frame = NSMakeRect(0, 0, leftCapImage.size.width, leftCapImage.size.height);
        
        [[self capMiddle] setImageScaling:NSImageScaleAxesIndependently];
        self.capMiddle.image = middleCapImage;
        self.capMiddle.frame = NSMakeRect(leftCapImage.size.width, 0, frameRect.size.width - leftCapImage.size.width - rightCapImage.size.width, middleCapImage.size.height);
        
        self.capRight.image = rightCapImage;
        self.capRight.frame = NSMakeRect(frameRect.size.width-rightCapImage.size.width, 0, rightCapImage.size.width, rightCapImage.size.height);     
        
        self.capLeft.hidden = YES;
        self.capMiddle.hidden = YES;
        self.capRight.hidden = YES;

    }
    return self;
}

- (void)mouseEntered:(NSEvent *)theEvent 
{
    self.capLeft.hidden = NO;
    self.capMiddle.hidden = NO;
    self.capRight.hidden = NO;
}
- (void)mouseExited:(NSEvent *)theEvent
{
    self.capLeft.hidden = YES;
    self.capMiddle.hidden = YES;
    self.capRight.hidden = YES;
}


- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
}


@end
