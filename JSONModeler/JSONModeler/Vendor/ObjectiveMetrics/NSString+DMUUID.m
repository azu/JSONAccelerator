//
//  NSString+DMUUID.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/23/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "NSString+DMUUID.h"


@implementation NSString (DMUUIDString)

+ (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);

    if (uuid)
        CFRelease(uuid);

    return [NSMakeCollectable(uuidString) autorelease];
}

@end
