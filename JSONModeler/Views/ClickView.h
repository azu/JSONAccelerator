//
//  ClickView.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 3/13/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ClickViewDelegate <NSObject>

- (void)clickViewPressed:(id)sender;

@end

@interface ClickView : NSView {
	NSTrackingArea* myTrackingArea;
}

@property (strong) NSImageView *capLeft;
@property (strong) NSImageView *capMiddle;
@property (strong) NSImageView *capRight;
@property (strong) NSImageView *disabledCapLeft;
@property (strong) NSImageView *disabledCapMiddle;
@property (strong) NSImageView *disabledCapRight;
@property (assign) id<ClickViewDelegate> delegate;

@property (assign) BOOL enabled;

@end
