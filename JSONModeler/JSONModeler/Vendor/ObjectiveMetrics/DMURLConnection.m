//
//  DMURLConnection.m
//  ObjectiveMetrics
//
//  Created by Jørgen Tjernø on 10/24/11.
//  Copyright (c) 2011 devSoft. All rights reserved.
//

#import "DMURLConnection.h"

const NSInteger kDMHTTPError = 1;

@implementation DMURLConnection

+ (id)connectionWithRequest:(NSURLRequest *)request
              completeBlock:(DMURLConnectionCompleteBlock)completeBlock
                 errorBlock:(DMURLConnectionErrorBlock)errorBlock
{
    return [[[self alloc] initWithRequest:request
                            completeBlock:completeBlock
                               errorBlock:errorBlock] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request
        completeBlock:(DMURLConnectionCompleteBlock)aCompleteBlock
           errorBlock:(DMURLConnectionErrorBlock)anErrorBlock
{
    // We delay start until we've assigned the blocks. :-)
    self = [super initWithRequest:request
                         delegate:self
                 startImmediately:NO];
    if (self)
    {
        data = [[NSMutableData alloc] init];
        completeBlock = [aCompleteBlock copy];
        errorBlock = [anErrorBlock copy];
        encounteredError = NO;
        encoding = NSUTF8StringEncoding;
    }

    return self;
}

- (void)dealloc
{
    [data release];
    [completeBlock release];
    [errorBlock release];

    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [data setLength:0];
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] < 200 || [httpResponse statusCode] > 299)
        {
            NSLog(@"Request fail: %ld", [httpResponse statusCode]);
            encounteredError = YES;
        }

        DLog(@"Got DeskMetrics response, encoding: %@, status code: %ld",
             [httpResponse textEncodingName], [httpResponse statusCode]);
    }
    else
    {
        NSLog(@"Got DeskMetrics response, but not HTTP. Encoding: %@", [response textEncodingName]);
    }

    NSString *encodingName = [response textEncodingName];
    if (encodingName)
    {
        CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName);
        if (cfEncoding != kCFStringEncodingInvalidId)
        {
            encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
        }
    }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)theData
{
	[data appendData:theData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (encounteredError)
    {
        // TODO: Should we send an intelligent userInfo here?
        NSError *error = [NSError errorWithDomain:@"no.devsoft.ObjectiveMetrics"
                                             code:kDMHTTPError
                                         userInfo:nil];
        errorBlock(self, error);
    } else {
        NSString *responseBody = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
        completeBlock(self, responseBody);
    }
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	errorBlock(self, error);
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

@end
