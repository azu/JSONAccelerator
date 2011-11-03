//
//  JSONModeler.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "JSONModeler.h"
#import "JSONFetcher.h"

@interface JSONModeler ()

- (void) loadJSONWithData: (NSData *) data;

@end

@implementation JSONModeler

- (void) loadJSONWithURL: (NSString *) url
{
    JSONFetcher *fetcher = [[JSONFetcher alloc] init];
    [fetcher downloadJSONFromLocation:url withSuccess:^(id object) {
        [self loadJSONWithData:object];
    } 
   andFailure:^(NSHTTPURLResponse *response, NSError *error) {
#warning Handle the error case gracefully
   }];
    
}

- (void) loadJSONWithString: (NSString *) string
{
    [self loadJSONWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) loadJSONWithData: (NSData *) data
{
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if([object isKindOfClass:[NSDictionary class]]) {
        self.jsonDictionary = object;
    }
}

@end
