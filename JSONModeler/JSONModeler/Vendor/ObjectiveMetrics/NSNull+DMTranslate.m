//
//  NSNull+DMTranslate.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/28/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "NSNull+DMTranslate.h"


@implementation NSNull (DMTranslate)

+ (id)translate:(id)object
{
    if (object == nil)
        return [self null];
    else
        return object;
}

@end
