//
//  ClickView.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 3/13/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import "ClickView.h"

@interface ClickView ()


@end

@implementation ClickView
@synthesize capLeft = _capLeft;
@synthesize capMiddle = _capMiddle;
@synthesize capRight = _capRight;
@synthesize disabledCapLeft = _disabledCapLeft;
@synthesize disabledCapMiddle = _disabledCapMiddle;
@synthesize disabledCapRight = _disabledCapRight;
@synthesize delegate = _delegate;
@synthesize enabled = _enabled;

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self) {
        // Tracking area
        NSTrackingAreaOptions trackingOptions =
		NSTrackingCursorUpdate | NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited |
		NSTrackingActiveInActiveApp;
        
        _enabled = YES;
        
        myTrackingArea = [[NSTrackingArea alloc]
                          initWithRect: [self bounds] // in our case track the entire view
                          options: trackingOptions
                          owner: self
                          userInfo: nil];
        [self addTrackingArea: myTrackingArea];
        
        // Cap Setup
        self.capLeft = [[NSImageView alloc] init];
        self.capMiddle = [[NSImageView alloc] init];
        self.capRight= [[NSImageView alloc] init];
        self.disabledCapLeft = [[NSImageView alloc] init];
        self.disabledCapMiddle = [[NSImageView alloc] init];
        self.disabledCapRight = [[NSImageView alloc] init];
        
        [self addSubview:self.capLeft];
        [self addSubview:self.capMiddle];
        [self addSubview:self.capRight];
        [self addSubview:self.disabledCapLeft];
        [self addSubview:self.disabledCapMiddle];
        [self addSubview:self.disabledCapRight];
    }
    return self;
}



- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    NSLog ( @"Accepts First Mouse" );
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    NSLog ( @"Accepts First Responder" );
    return YES;
}

- (void)mouseDown:(NSEvent*)theEvent
{
    if(self.enabled && self.delegate != nil) {
        [self.delegate clickViewPressed:self];
    }
}






@end
