//
//  JSONFetcher.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "JSONFetcher.h"
#import "AFHTTPRequestOperation.h"

@interface JSONFetcher ()

@property (strong) NSOperationQueue *jsonOperationQueue;
@property (strong) AFHTTPRequestOperation *operation;

@end

@implementation JSONFetcher
@synthesize document = _document;
@synthesize jsonOperationQueue = _jsonOperationQueue;
@synthesize operation = _operation;

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.jsonOperationQueue = [[NSOperationQueue alloc] init];
    self.jsonOperationQueue.maxConcurrentOperationCount = 8;
    self.operation = [[AFHTTPRequestOperation alloc] init];
    
    
    return self;
}

- (void) downloadJSONFromLocation: (NSString *) location withSuccess: (void (^)(id object))success 
                          andFailure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:location]];
    NSString *method = nil;
    
    NSString *variables = @"";
    NSString *headerValue = nil;
    NSString *keyValue = nil;
    
    // Build the request string
    for(NSDictionary *header in self.document.httpHeaders) {
        if(![variables isEqualToString:@""]) {
            variables = [variables stringByAppendingString:@"&"];
        }
        headerValue = [header objectForKey:@"headerValue"];
        keyValue = [header objectForKey:@"headerKey"];
        
        headerValue = [headerValue stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        keyValue = [keyValue stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        variables = [variables stringByAppendingString:[NSString stringWithFormat:@"%@=%@", keyValue, headerValue]];
    }

    
    switch (self.document.httpMethod) {
        case HTTPMethodGet: {
            method = @"GET";
            NSArray *array = [location componentsSeparatedByString:@"?"];
            if([array count] == 1) {
                // There are no post parameters
                [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", location, variables]]];
            } else if ([array count] == 2) {
                if([[array objectAtIndex:1] isEqualToString:@""]) {
                    // Try to fake me out with a fake url? How dare you
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", location, variables]]];
                } else {
                    // Let's just keep appending stuff
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&%@", location, variables]]];
                }
            } else {
                // Forget about it
            }
            
            break;
        }
        case HTTPMethodPut: {
            method = @"PUT";
            [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            NSData *postData = [NSData dataWithBytes: [variables UTF8String] length: [variables length]];
            
            [ request setHTTPBody: postData ];

            break;
        }
        case HTTPMethodPost:
            method = @"POST";
            break;
        case HTTPMethodHead:
            method = @"HEAD";
            break;
        default:
            method = @"GET";
            break;
    }
    [request setHTTPMethod:method];
    
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.completionBlock = ^ {
        if ([self.operation isCancelled]) {
            return;
        }
        
        if (self.operation.error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(self.operation.response, self.operation.error);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    success(self.operation.responseData);
                });
            }
        }
    };
    
    [self.jsonOperationQueue addOperation:self.operation];
}

@end
