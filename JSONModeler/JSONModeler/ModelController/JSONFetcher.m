//
//  JSONFetcher.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JSONFetcher.h"
#import "AFHTTPRequestOperation.h"

@interface JSONFetcher ()

@property (strong) NSOperationQueue *jsonOperationQueue;

@end

@implementation JSONFetcher
@synthesize jsonOperationQueue = _jsonOperationQueue;

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.jsonOperationQueue = [[NSOperationQueue alloc] init];
    self.jsonOperationQueue.maxConcurrentOperationCount = 8;
    
    return self;
}

- (void) downloadJSONFromLocation: (NSString *) location withSuccess: (void (^)(id object))success 
                          andFailure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:location]];
    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation HTTPRequestOperationWithRequest:request success:success failure:failure];    
    
    [self.jsonOperationQueue addOperation:operation];
}

@end
