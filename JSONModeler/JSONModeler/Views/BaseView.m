//
//  BaseView.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/11/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "BaseView.h"

@interface BaseView () {
    // Appearance Attributes
    NSGradient *backgroundGradient;
}

@end

@implementation BaseView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *plainColor = [NSColor colorWithDeviceRed:237.0 / 255.0 green:237.0 / 255.0 blue:237.0 / 255.0 alpha:1.0];
    // Drawing code here.
    [[NSColor darkGrayColor] setFill];
    NSRectFill(dirtyRect);
    if (backgroundGradient == nil) {
        backgroundGradient = [[NSGradient alloc] initWithStartingColor:plainColor endingColor:plainColor];
    }
    
    NSRect tempBounds = [self bounds];
    tempBounds.size.height--;
    [backgroundGradient drawInRect:tempBounds angle:90.0];
}

@end
