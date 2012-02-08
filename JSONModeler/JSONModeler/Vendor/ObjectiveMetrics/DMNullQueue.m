//
//  DMNullQueue.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 6/19/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMNullQueue.h"


@implementation DMNullQueue

- (NSUInteger)count { return 0; }
- (NSDictionary *)eventAtIndex:(NSUInteger)index { return nil; }

- (void)add:(NSDictionary *)event { return; }
- (void)send:(NSDictionary *)event { return; }

- (void)flush { return; }
- (BOOL)blockingFlush { return YES; }
- (void)discard { return; }

@end
