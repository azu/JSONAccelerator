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
    CGFloat tC = 180.0 / 255.0;
    NSColor *top = [NSColor colorWithCalibratedRed:tC green:tC blue:tC alpha:1.0f];

    // Drawing code here.
    [top setFill];
    NSRectFill(dirtyRect);
    
//    if (backgroundGradient == nil) {
//        backgroundGradient = [[NSGradient alloc] initWithStartingColor:top endingColor:top];
//    }
    
    NSRect tempBounds = [self bounds];
//    tempBounds.size.height--;
    [backgroundGradient drawInRect:tempBounds angle:90.0];
}

@end
