//
//  DMTrackingQueue.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTrackingQueue.h"

#import "DMRequester.h"
#import "DMHosts.h"

static NSString * const DMEventQueueKey = @"DMEventQueue";
static NSString * const DMEventQueueMaxSizeKey = @"DMEventQueueMaxSize";
static NSString * const DMEventQueueMaxDaysOldKey = @"DMEventQueueMaxDaysOld";
static NSString * const DMNullPlaceholder = @"<[Aija8kua]NULL-VALUE[ep6gae3U]>";

static int const DMEventQueueDefaultMaxSize = 100;
static int const DMEventQueueDefaultMaxDaysOld = 7;

static double kDMEventQueueSecondsInADay = 60.0*60.0*24.0;

@interface DMTrackingQueue () <DMRequesterDelegate>

@property (retain) NSMutableArray *events, *pendingEvents;
@property (retain) DMRequester *requester;

- (void)sendEvents:(NSArray *)theEvents;
- (BOOL)flushIfExceedsBounds;
- (void)save;
- (void)load;

@end

@implementation DMTrackingQueue

@synthesize events, pendingEvents, requester;

- (id)init
{
    self = [super init];
    if (self) {
        DMSUHost *host = [DMHosts sharedAppHost];
        [self setPendingEvents:[NSMutableArray array]];
        [self setRequester:[[[DMRequester alloc] initWithDelegate:self] autorelease]];

        /* TODO: Use NSApplicationSupportDirectory for the queue?
        NSArray *supportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSLog(@"%@", supportDirectories);*/

        if ([host objectForKey:DMEventQueueMaxSizeKey] == nil)
            maxSize = DMEventQueueDefaultMaxSize;
        else
            maxSize = [[host objectForKey:DMEventQueueMaxSizeKey] intValue];

        int maxDaysOld;
        if ([host objectForKey:DMEventQueueMaxDaysOldKey] == nil)
            maxDaysOld = DMEventQueueDefaultMaxDaysOld;
        else
            maxDaysOld = [[host objectForKey:DMEventQueueMaxDaysOldKey] intValue];

        maxSecondsOld = maxDaysOld * kDMEventQueueSecondsInADay;

        [self load];
    }

    return self;
}

- (void)dealloc
{
    [self setPendingEvents:nil];
    [self setEvents:nil];
    [self setRequester:nil];

    [super dealloc];
}

- (NSUInteger)count
{
    return [events count];
}

- (NSDictionary *)eventAtIndex:(NSUInteger)index
{
    return (NSDictionary *)[events objectAtIndex:index];
}

- (void)add:(NSDictionary *)event
{
    @synchronized (self)
    {
        [events addObject:event];
        [self save];
        [self flushIfExceedsBounds];
    }
}

- (void)sendEvents:(NSArray *)sentEvents
{
    @synchronized (self)
    {
        [pendingEvents addObjectsFromArray:sentEvents];
        [requester send:sentEvents];
    }
}

- (void)send:(NSDictionary *)event
{
    @synchronized (self)
    {
        [events insertObject:event
                     atIndex:[pendingEvents count]];
        [self sendEvents:[NSArray arrayWithObject:event]];
    }
}

- (void)flush
{
    @synchronized (self)
    {
        NSInteger pendingCount = [pendingEvents count];
        NSRange range = NSMakeRange(pendingCount, [events count] - pendingCount);
        if (range.length > 0)
            [self sendEvents:[events subarrayWithRange:range]];
    }
}

- (BOOL)blockingFlush
{
    @synchronized (self)
    {
        [self flush];

        // We lock around this code so that we won't make new requests.
        [requester wait];

        return [events count] == 0;
    }
}

- (void)discard
{
    @synchronized (self)
    {
        [events removeAllObjects];
    }
}

- (BOOL)flushIfExceedsBounds
{
    @synchronized (self)
    {
        if ([events count] - [pendingEvents count] > 0)
        {
            NSDictionary *oldestEvent = [events objectAtIndex:[pendingEvents count]];
            NSDate *oldestEventDate = [NSDate dateWithTimeIntervalSince1970:[[oldestEvent objectForKey:@"ts"] intValue]];

            if (oldestEventDate == nil)
                [self flush];
            else if ([[NSDate date] timeIntervalSinceDate:oldestEventDate] >= maxSecondsOld)
                [self flush];
            else if ([events count] >= maxSize)
                [self flush];
            else
                return NO;

            return YES;
        }
    }

    return NO;
}

- (void)save
{
    NSMutableArray *outputEvents = [NSMutableArray array];
    @synchronized (self)
    {
        for (NSDictionary *immutableMessage in events)
        {
            NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:immutableMessage];

            for (NSString *key in [message allKeysForObject:[NSNull null]])
            {
                [message setObject:DMNullPlaceholder
                            forKey:key];
            }

            [outputEvents addObject:message];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:outputEvents
                                              forKey:DMEventQueueKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)load
{
    NSArray *loadedEvents = [[NSUserDefaults standardUserDefaults] objectForKey:DMEventQueueKey];
    if (!loadedEvents)
        loadedEvents = [NSArray array];

    NSMutableArray *newEvents = [NSMutableArray array];

    for (NSDictionary *immutableMessage in loadedEvents)
    {
        if (![immutableMessage isKindOfClass:[NSDictionary class]])
            continue;

        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:immutableMessage];
        for (NSString *key in [message allKeys])
        {
            id value = [message objectForKey:key];
            if ([value isKindOfClass:[NSString class]] && [value isEqualToString:DMNullPlaceholder])
            {
                [message setObject:[NSNull null]
                            forKey:key];
            }
        }

        [newEvents addObject:message];
    }

    @synchronized (self)
    {
        /* Make sure no-one is fiddling with events before overwriting it, even if the write is atomic. */
        [self setEvents:newEvents];
    }
}

- (void)requestSucceeded:(NSArray *)theEvents
{
    DLog(@"Request succeeded. Removing events: %@", theEvents);
    @synchronized (self)
    {
        [pendingEvents removeObjectsInArray:theEvents];
        [events removeObjectsInArray:theEvents];
        [self save];
    }
}

- (void)requestFailed:(NSArray *)theEvents
{
    DLog(@"Request failed. Removing events from pending: %@", theEvents);
    @synchronized (self)
    {
        [pendingEvents removeObjectsInArray:theEvents];
    }
}


@end
