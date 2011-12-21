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
 * Returns a string by removing all characters except those in the set [A-Za-z0-9]. Also returns by reference a BOOL that indicates whether the returned string is an Objective-C reserved word. Note: this method will return the empty string if the receiver consists entirely of characters outside the alphanumeric set.
 *
 * @param reserved Pointer to a bool object that indicates whether the returned string is an Objective-C reserved word
 * @return NSString * String created by taking the value of the receiver and removing all characters except those in the set [A-Za-z0-9]. Can be the empty string.
 */
- (NSString *)alphanumericStringIsObjectiveCReservedWord:(BOOL *)reserved;

/**
 * Returns a string created by removing all non-alphanumeric characters from the receiver, checking if this string is an Objective-C reserved word, and appending the string "Class" if so. The first letter will also be capitalized. Note: this method will return the empty string if the receiver consists entirely of characters outside the alphanumeric set [A-Za-z0-9].
 *
 * @return NSString * Alphanumeric, non-Objective-C reserved word, in proper camelcase for the name of an Objective-C class. Can be the empty string.
 */
- (NSString *)objectiveCClassString;

/**
 * Returns a string created by removing all non-alphanumeric characters from the receiver, checking if this string is an Objective-C reserved word, and appending the string "Property" if so. The first letter will also be uncapitalized. Note: this method will return the empty string if the receiver consists entirely of characters outside the alphanumeric set [A-Za-z0-9].
 *
 * @return NSString * Alphanumeric, non-Objective-C reserved word, in proper camelcase for the name of an Objective-C property. Can be the empty string.
 */
- (NSString *)objectiveCPropertyString;

@end
