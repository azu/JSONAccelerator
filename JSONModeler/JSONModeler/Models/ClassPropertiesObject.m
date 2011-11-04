//
//  ClassPropertiesObject.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/4/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "ClassPropertiesObject.h"

@implementation ClassPropertiesObject
@synthesize name = _name;
@synthesize jsonName = _mappedName;
@synthesize  type = _type;

@synthesize isClass = _isClass;
@synthesize isAtomic = _isAtomic;
@synthesize isReadWrite = _isReadWrite;
@synthesize semantics = _semantics;

// Builds the header implementation and is convienient for debugging
- (NSString *) description 
{
    NSString *returnString = @"@property (";
    if(_isAtomic == NO) {
        returnString = [returnString stringByAppendingString:@"nonatomic, "];
    }

    if(_isReadWrite == NO) {
        returnString = [returnString stringByAppendingString:@"readonly, "];
    }
    
    switch (_semantics) {
        case SetterSemanticStrong:
            returnString = [returnString stringByAppendingString:@"strong"];
            break;
        case SetterSemanticWeak:
            returnString = [returnString stringByAppendingString:@"weak"];
            break;
        case SetterSemanticAssign:
            returnString = [returnString stringByAppendingString:@"assign"];
            break;
        case SetterSemanticRetain:
            returnString = [returnString stringByAppendingString:@"retain"];
            break;
        case SetterSemanticCopy:
            returnString = [returnString stringByAppendingString:@"copy"];
            break;
        default:
            break;
    }
    
    returnString = [returnString stringByAppendingFormat:@") %@ %@%@;", _type, (_semantics != SetterSemanticAssign) ? @"*" : @"" , _name];
        
    return returnString;
}

@end
