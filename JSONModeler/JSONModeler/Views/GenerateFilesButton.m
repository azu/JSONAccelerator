//
//  GenerateFilesButton.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 3/13/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "GenerateFilesButton.h"
#import <QuartzCore/QuartzCore.h>

@interface GenerateFilesButton ()

@end

@implementation GenerateFilesButton
@synthesize textField = _textField;

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self) {
        self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, -6, frameRect.size.width, frameRect.size.height)];
        [self.textField setAlignment:NSCenterTextAlignment];
        [_textField setBezeled:NO];
        [_textField setDrawsBackground:NO];
        [_textField setEditable:NO];
        [_textField setSelectable:NO];
        [self addSubview:self.textField];
        
        // Setup the images
        NSImage *leftCapImage = [NSImage imageNamed:@"generateDataLeftCap.png"];
        NSImage *middleCapImage = [NSImage imageNamed:@"generateDataBackground.png"];
        NSImage *rightCapImage = [NSImage imageNamed:@"generateDataRightCap.png"];

        self.capLeft.image = leftCapImage;
        self.capLeft.frame = NSMakeRect(0, 0, leftCapImage.size.width, leftCapImage.size.height);
        
        [[self capMiddle] setImageScaling:NSImageScaleAxesIndependently];
        self.capMiddle.image = middleCapImage;
        self.capMiddle.frame = NSMakeRect(leftCapImage.size.width, 0, frameRect.size.width - leftCapImage.size.width - rightCapImage.size.width, middleCapImage.size.height);
        
        self.capRight.image = rightCapImage;
        self.capRight.frame = NSMakeRect(frameRect.size.width-rightCapImage.size.width, 0, rightCapImage.size.width, rightCapImage.size.height);

        // Setup disabled images
        NSImage *leftCapImageDisabled = [NSImage imageNamed:@"generateDataLeftCapDisabled.png"];
        NSImage *middleCapImageDisabled = [NSImage imageNamed:@"generateDataBackgroundDisabled.png"];
        NSImage *rightCapImageDisabled = [NSImage imageNamed:@"generateDataRightCapDisabled.png"];
        
        self.disabledCapLeft.image = leftCapImageDisabled;
        self.disabledCapLeft.frame = NSMakeRect(0, 0, leftCapImageDisabled.size.width, leftCapImageDisabled.size.height);
        
        [[self disabledCapMiddle] setImageScaling:NSImageScaleAxesIndependently];
        self.disabledCapMiddle.image = middleCapImageDisabled;
        self.disabledCapMiddle.frame = NSMakeRect(leftCapImageDisabled.size.width, 0, frameRect.size.width - leftCapImageDisabled.size.width - rightCapImageDisabled.size.width, middleCapImageDisabled.size.height);
        
        self.disabledCapRight.image = rightCapImageDisabled;
        self.disabledCapRight.frame = NSMakeRect(frameRect.size.width-rightCapImageDisabled.size.width, 0, rightCapImageDisabled.size.width, rightCapImageDisabled.size.height);

        
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self.disabledCapRight setHidden:enabled];
    [self.disabledCapMiddle setHidden:enabled];
    [self.disabledCapLeft setHidden:enabled];
  
    [self.capLeft setHidden:!enabled];
    [self.capMiddle setHidden:!enabled];
    [self.capRight setHidden:!enabled];
    
    [self.textField setTextColor:(enabled) ? [NSColor whiteColor] : [NSColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
}

@end
