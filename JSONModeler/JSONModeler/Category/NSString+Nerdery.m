//
//  NSString+NSString_Nerdery.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "NSString+Nerdery.h"

@implementation NSString (Nerdery)

- (NSString *)capitalizeFirstCharacter
{
    if([self length] == 0) {
        return @"";
    } else if ([self length] == 1) {
        return [self capitalizedString];
    }
    
    NSString *uppercase = [self uppercaseString];
    NSString *firstLetter = [uppercase substringToIndex:1];
    NSString *restOfString = [self substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@", firstLetter, restOfString];
}

@end
