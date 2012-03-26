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
    NSString *method;
    switch (self.document.httpMethod) {
        case HTTPMethodGet:
            method = @"GET";
            break;
        case HTTPMethodPut:
            method = @"PUT";
            break;
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
    
    for (NSDictionary *header in self.document.httpHeaders) {
        [request addValue:[header objectForKey:@"headerValue"] forHTTPHeaderField:[header objectForKey:@"headerKey"]];
    }
    
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
