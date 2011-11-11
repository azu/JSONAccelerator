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
    // Drawing code here.
    if (backgroundGradient == nil) {
        backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.27 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.08 alpha:1.0]];
    }
    [backgroundGradient drawInRect:[self bounds] angle:90.0];
}

@end
