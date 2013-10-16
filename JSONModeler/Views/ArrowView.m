//
//  ArrowView.m
//  JSONAccelerator
//
//  Created by Jonathan Rexeisen on 6/14/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "ArrowView.h"

@implementation ArrowView

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
    //// Color Declarations
    NSColor* newGradientColor = [NSColor colorWithCalibratedRed: 0.2 green: 0.64 blue: 0.68 alpha: 1];
    NSColor* newGradientColor2 = [NSColor colorWithCalibratedRed: 0 green: 0.37 blue: 0.56 alpha: 1];
    
    //// Gradient Declarations
    NSGradient* newGradient = [[NSGradient alloc] initWithStartingColor: newGradientColor endingColor: newGradientColor2];
    
    
    //// Bezier 2 Drawing
    NSBezierPath* bezier2Path = [NSBezierPath bezierPath];
    [bezier2Path moveToPoint: NSMakePoint(53.5, 19.5)];
    [bezier2Path lineToPoint: NSMakePoint(41.4, 7.5)];
    [bezier2Path lineToPoint: NSMakePoint(41.4, 14.56)];
    [bezier2Path lineToPoint: NSMakePoint(11.5, 14.56)];
    [bezier2Path lineToPoint: NSMakePoint(11.5, 24.44)];
    [bezier2Path lineToPoint: NSMakePoint(41.4, 24.44)];
    [bezier2Path lineToPoint: NSMakePoint(41.4, 31.5)];
    [bezier2Path lineToPoint: NSMakePoint(53.5, 19.5)];
    [bezier2Path closePath];
    [newGradient drawInBezierPath: bezier2Path angle: -90];
    
    [newGradientColor2 setStroke];
    [bezier2Path setLineWidth: 1];
    [bezier2Path stroke];
    
}

@end
