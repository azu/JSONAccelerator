//
//  DMRequester.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/24/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMRequester.h"

#import "DMURLConnection.h"
#import "DMHosts.h"
#import "SBJson.h"

static NSString * const DMAnalyticsURLKey = @"DMAnalyticsURL";
static NSString * const DMAppIdKey = @"DMAppId";
static NSString * const DMAnalyticsURLFormat = @"https://%@.api.deskmetrics.com/sendData";
static NSString * const DMStatusCodeKey = @"status_code";

@interface DMRequester ()

@property (retain) NSMutableArray *connections;
@property (retain) NSMutableURLRequest *request;

@end


@implementation DMRequester

@synthesize delegate, request, connections;

- (id)init
{
    self = [super init];
    if (self) {
        DMSUHost *host = [DMHosts sharedAppHost];
        NSString *URL = [host objectForInfoDictionaryKey:DMAnalyticsURLKey];
        if (!URL)
        {
            NSString *appId = [host objectForInfoDictionaryKey:DMAppIdKey];
            if (!appId)
            {
                NSLog(@"Could not find neither %@ nor %@ in Info.plist!", DMAnalyticsURLKey, DMAppIdKey);
                [self release];
                return nil;
            }

            URL = [NSString stringWithFormat:DMAnalyticsURLFormat, appId];
        }

        DLog(@"URL: %@", URL);
        DMSUHost *frameworkHost = [DMHosts sharedFrameworkHost];
        NSString *userAgent = [NSString stringWithFormat:@"%@ v%@",
                               [frameworkHost objectForInfoDictionaryKey:@"CFBundleName"],
                               [frameworkHost version]];

        [self setRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];

        [self setConnections:[NSMutableArray array]];
    }

    return self;
}

- (id)initWithDelegate:(id)theDelegate
{
    self = [self init];
    if (self)
    {
        [self setDelegate:theDelegate];
    }

    return self;
}

- (void)dealloc
{
    [self setDelegate:nil];
    [self setRequest:nil];
    [self setConnections:nil];

    [super dealloc];
}

- (void)send:(NSArray *)events
{
    
    
    
    NSData *json = [[events JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *sentRequest = [request copy];

    [sentRequest setValue:[NSString stringWithFormat:@"%d", [json length]] forHTTPHeaderField:@"Content-Length"];
    [sentRequest setHTTPBody:json];

    DLog(@"Sending data: %@", [events JSONRepresentation]);

    DMURLConnectionCompleteBlock complete = ^(DMURLConnection *connection, NSString *responseBody) {
        BOOL error = NO;
        id result = [responseBody JSONValue];
        DLog(@"Completed with data: %@", result);
        if ([result isKindOfClass:[NSDictionary class]])
        {
            id status = [result objectForKey:DMStatusCodeKey];
            NSInteger statuscode = [status integerValue];
            if (statuscode == 0 || statuscode == 1)
            {
                if ([delegate respondsToSelector:@selector(requestSucceeded:)])
                    [delegate requestSucceeded:events];
            }
            else
            {
                if (statuscode < 0)
                    NSLog(@"Got error code from DeskMetrics: %ld", statuscode);
                else
                    NSLog(@"Got unexpected positive code from DeskMetrics: %ld", statuscode);
                error = YES;
            }
        }
        else
        {
            error = YES;
            NSLog(@"Got unknown JSON from DeskMetrics: %@ (%@)", responseBody, result);
        }

        if (error && [delegate respondsToSelector:@selector(requestFailed:)])
            [delegate requestFailed:events];

        [connections removeObject:connection];
    };

    DMURLConnectionErrorBlock error = ^(DMURLConnection *connection, NSError *error) {
        NSLog(@"DeskMetrics connection failed: %@", error);

        if (error && [delegate respondsToSelector:@selector(requestFailed:)])
            [delegate requestFailed:events];

        [connections removeObject:connection];
    };

    DMURLConnection *connection = [DMURLConnection connectionWithRequest:[sentRequest autorelease]
                                                           completeBlock:[complete autorelease]
                                                              errorBlock:[error autorelease]];
    [connections addObject:connection];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
}

- (void)wait
{
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    while ([connections count] > 0 && [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

@end
