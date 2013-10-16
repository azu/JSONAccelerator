//
//  JSONModeler.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OutputLanguageWriterProtocol;


@interface JSONModeler : NSObject <NSCoding>

#ifndef COMMAND_LINE
    - (void)loadJSONWithURL:(NSString *)url outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer;
#endif
- (void)loadJSONWithString:(NSString *)string outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer;

@property (assign) BOOL parseComplete;
@property (strong) NSObject *rawJSONObject;
@property (strong) NSMutableDictionary *parsedDictionary;
@property (strong) NSString *JSONString;

- (NSDictionary *)parsedDictionaryByReplacingReservedWords:(NSArray *)reservedWords;

@end
