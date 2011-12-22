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

- (NSString *)uncapitalizeFirstCharacter
{    
    if ([self length] == 0) {
        return @"";
    }
    else if ([self length] == 1) {
        return [self lowercaseString];
    }
    
    NSString *lowercase = [self lowercaseString];
    NSString *firstLetter = [lowercase substringToIndex:1];
    NSString *restOfString = [self substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@", firstLetter, restOfString];
}

- (NSString *)alphanumericStringIsObjectiveCReservedWord:(BOOL *)reserved
{
    BOOL isReservedWord = NO;
    
    /* Remove any non-alphanumeric characters.
     * This uses a custom (very strict) character set instead of +alphanumericCharacterSet
     * so that characters like é don't appear in class/property names.
     */
    NSCharacterSet *nonAlphanumericCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"] invertedSet];
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self componentsSeparatedByCharactersInSet:nonAlphanumericCharacterSet]];
    NSUInteger componentCount = components.count;
    for (NSUInteger i = 0; i < componentCount; ++i) {
        [components replaceObjectAtIndex:i withObject:[[components objectAtIndex:i] capitalizeFirstCharacter]];
    }
    
    NSString *alphanumericString = [components componentsJoinedByString:@""];
    
    /* Make sure string isn't a C/Objective-C reserved word */
    NSSet *reservedWords = [NSSet setWithObjects:@"__autoreleasing", @"__block", @"__strong", @"__unsafe_unretained", @"__weak", @"_Bool", @"_Complex", @"_Imaginery", @"@catch", @"@class", @"@dynamic", @"@end", @"@finally", @"@implementation", @"@interface", @"@private", @"@property", @"@protected", @"@protocol", @"@public", @"@selector", @"@synthesize", @"@throw", @"@try", @"atomic", @"auto", @"autoreleasing", @"block", @"BOOL", @"break", @"bycopy", @"byref", @"case", @"catch", @"char", @"class", @"Class", @"const", @"continue", @"default", @"description", @"do", @"double", @"dynamic", @"else", @"end", @"enum", @"extern", @"finally", @"float", @"for", @"goto", @"id", @"if", @"IMP", @"implementation", @"in", @"inline", @"inout", @"int", @"interface", @"long", @"nil", @"NO", @"nonatomic", @"NULL", @"oneway", @"out", @"private", @"property", @"protected", @"protocol", @"Protocol", @"public", @"register", @"restrict", @"retain", @"return", @"SEL", @"selector", @"self", @"short", @"signed", @"sizeof", @"static", @"strong", @"struct", @"super", @"switch", @"synthesize", @"throw", @"try", @"typedef", @"union", @"unretained", @"unsafe", @"unsigned", @"void", @"volatile", @"weak", @"while", @"YES", nil];
    //We'll match the lowercase version of alphanumericString adgainst all lowercase versions of reserved words.
    //This will prevent property names like `Null` or `yes` from slipping through the cracks. 
    NSMutableSet *lowercaseReservedWords = [[NSMutableSet alloc] init];
    [reservedWords enumerateObjectsUsingBlock:^(NSString *word, BOOL *stop) {
        [lowercaseReservedWords addObject:[word lowercaseString]];
    }];
    for (NSString *word in lowercaseReservedWords) {
        if ( [[alphanumericString lowercaseString] isEqualToString:word] ) {
            isReservedWord = YES;
            break;
        }
    }
    
    *reserved = isReservedWord;
    return alphanumericString;
}

- (NSString *)objectiveCClassString {
    BOOL isReservedWord;
    NSString *alphanumeric = [self alphanumericStringIsObjectiveCReservedWord:&isReservedWord];
    if (isReservedWord) {
        alphanumeric = [[alphanumeric stringByAppendingString:@"Class"] capitalizeFirstCharacter];
    }
    NSRange startsWithNumeral = [[alphanumeric substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
    if ( startsWithNumeral.location == NSNotFound && startsWithNumeral.length == 0 ) {
        alphanumeric = [@"Num" stringByAppendingString:alphanumeric];
    }
    return [alphanumeric capitalizeFirstCharacter];
}

- (NSString *)objectiveCPropertyString
{
    BOOL isReservedWord;
    NSString *alphanumeric = [self alphanumericStringIsObjectiveCReservedWord:&isReservedWord];
    if (isReservedWord) {
        alphanumeric = [[alphanumeric stringByAppendingString:@"Property"] uncapitalizeFirstCharacter];
    }
    NSRange startsWithNumeral = [[alphanumeric substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
    if ( startsWithNumeral.location == NSNotFound && startsWithNumeral.length == 0 ) {
        alphanumeric = [@"num" stringByAppendingString:alphanumeric];
    }
    return [alphanumeric uncapitalizeFirstCharacter];
}

@end
