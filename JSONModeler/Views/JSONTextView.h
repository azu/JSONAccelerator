//
//  JSONTextView.h
//  JSONModeler
//
//  Created by Sean Hickey on 12/19/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JSONTextView : NSTextView

/**
 *  @author Toshiro Sugii, 16-03-10 17:03:03
 *
 *  Parses the current self.string text and Returns a 
 *  NSJSONWritingPrettyPrinted JSON String.
 *
 *  @return A pretty printed version of the current string
 *
 *  @since 1.0.10
 */
- (NSString *)prettyPrintedString;

@end
