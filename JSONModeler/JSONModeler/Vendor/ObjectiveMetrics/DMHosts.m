//
//  DMHosts.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "NSString+DMUUID.h"
#import "DMHosts.h"

static DMSUHost *sharedAppHost = nil;
static DMSUHost *sharedFrameworkHost = nil;

@implementation DMHosts

+ (DMSUHost *)sharedAppHost
{
    if (!sharedAppHost)
        sharedAppHost  = [[DMSUHost alloc] initWithBundle:[NSBundle mainBundle]];
    return [[sharedAppHost retain] autorelease];
}

+ (DMSUHost *)sharedFrameworkHost
{
    if (!sharedFrameworkHost)
        sharedFrameworkHost = [[DMSUHost alloc] initWithBundle:[NSBundle bundleWithIdentifier:@"no.devsoft.ObjectiveMetrics"]];
    return [[sharedFrameworkHost retain] autorelease];
}

@end
