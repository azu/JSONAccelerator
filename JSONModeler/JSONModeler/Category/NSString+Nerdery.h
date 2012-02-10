//
//  NSString+NSString_Nerdery.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Nerdery)

- (NSString *)capitalizeFirstCharacter;
- (NSString *)uncapitalizeFirstCharacter;

/**
 * Returns a string by removing all characters except those in the set [A-Za-z0-9_]. Also returns by reference a BOOL that indicates whether the returned string is one of the words in the set `reservedWords`. Note: this method will return the empty string if the receiver consists entirely of characters outside the alphanumeric set.
 *
 * @param reserved Pointer to a boolean that indicates whether the returned string is an Objective-C reserved word
 * @param reservedWords Set of `NSString`s that are reserved words in a given language. The `reserved` flag will be set if the returned string matches any string in this set
 * @return NSString * String created by taking the value of the receiver and removing all characters except those in the set [A-Za-z0-9_]. Can be the empty string.
 */
- (NSString *)alphanumericStringIsReservedWord:(BOOL *)reserved fromReservedWordSet:(NSSet *)reservedWords;

- (NSString *)underscoreDelimitedString;

- (NSString *)uppercaseCamelcaseString;

- (NSString *)lowercaseCamelcaseString;
@end
