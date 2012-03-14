//
//  BaseView.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/11/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "GradientView.h"

@interface GradientView () {
    // Appearance Attributes
    NSGradient *backgroundGradient;
}

@end

@implementation GradientView

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
    CGFloat tC = 72.0 / 255.0;
    NSColor *top = [NSColor colorWithCalibratedRed:tC green:tC blue:tC alpha:1.0f];
    NSColor *bottom = [NSColor colorWithCalibratedRed:39.0 / 255.0 green:39.0 / 255.0 blue:39.0 / 255.0 alpha:1.0];

    // Drawing code here.
//    [[NSColor darkGrayColor] setFill];
//    NSRectFill(dirtyRect);
    if (backgroundGradient == nil) {
        backgroundGradient = [[NSGradient alloc] initWithStartingColor:bottom endingColor:top];
    }
    
    NSRect tempBounds = [self bounds];
//    tempBounds.size.height--;
    [backgroundGradient drawInRect:tempBounds angle:90.0];
}

@end
