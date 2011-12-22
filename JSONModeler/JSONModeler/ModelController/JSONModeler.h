//
//  JSONModeler.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONModeler : NSObject <NSCoding>

- (void) loadJSONWithURL: (NSString *) url;
- (void) loadJSONWithString: (NSString *) string;

@property (assign) BOOL parseComplete;
@property (strong) NSObject *rawJSONObject;
@property (strong) NSMutableDictionary *parsedDictionary;
@property (strong) NSString *JSONString;

@end
