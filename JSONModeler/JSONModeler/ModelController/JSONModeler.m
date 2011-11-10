//
//  JSONModeler.m
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/3/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "JSONModeler.h"
#import "JSONFetcher.h"
#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"

@interface JSONModeler ()

- (void) loadJSONWithData: (NSData *) data;
- (void) parseData: (NSDictionary *)dict intoObjectsWithBaseObjectName: (NSString *) baseObjectName andBaseObjectClass: (NSString *) baseObjectClass;

@end

@implementation JSONModeler
@synthesize rawJSONDictionary = _rawJSONDictionary;
@synthesize parsedDictionary = _parsedDictionary;

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
    
    // Just for testing
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if([object isKindOfClass:[NSDictionary class]]) {
        self.rawJSONDictionary = object;
        [self parseData:self.rawJSONDictionary intoObjectsWithBaseObjectName:@"Movie" andBaseObjectClass:@"NSObject"];
    }
}

#pragma mark - Create the model objects

- (void) parseData: (NSDictionary *)dict intoObjectsWithBaseObjectName: (NSString *) baseObjectName andBaseObjectClass: (NSString *) baseObjectClass
{
    if(_parsedDictionary == nil) {
        self.parsedDictionary = [NSMutableDictionary dictionary];
    }
    
    if([self.parsedDictionary objectForKey:baseObjectName]) {
        return;
    }
        
    ClassBaseObject *tempClass = [ClassBaseObject new];
    [tempClass setBaseClass:baseObjectClass];
    [tempClass setClassName:[baseObjectName capitalizedString]];
    
    NSArray *array = [dict allKeys];
    ClassPropertiesObject *tempPropertyObject = nil;
    NSObject *tempObject = nil;
    NSObject *tempArrayObject = nil;
    
    for(NSString *currentKey in array) {
        @autoreleasepool {
            tempPropertyObject = [ClassPropertiesObject new];
            [tempPropertyObject setJsonName:currentKey];
            
            // Set the name
            if([currentKey isEqualToString:@"id"]) {
                [tempPropertyObject setName:[baseObjectName stringByAppendingString:@"Identifier"]];
            } else if ([currentKey isEqualToString:@"description"]) {
                [tempPropertyObject setName:[baseObjectName stringByAppendingString:@"Description"]];
            } else {
                [tempPropertyObject setName:currentKey];
            }
            
            [tempPropertyObject setIsAtomic:NO];
            [tempPropertyObject setIsClass:NO];
            [tempPropertyObject setIsReadWrite:YES];
            [tempPropertyObject setSemantics:SetterSemanticRetain];
            
            tempObject = [dict objectForKey:currentKey];
            
            if([tempObject isKindOfClass:[NSArray class]]) {
                [tempPropertyObject setType:@"NSArray"];
                
                // We now need to check to see if the first object in the array is a NSDictionary
                // if it is, then we need to create a new class
                if([(NSArray *)tempObject count] > 0) {
                    tempArrayObject = [(NSArray *)tempObject objectAtIndex:0];
                    if([tempArrayObject isKindOfClass:[NSDictionary class]]) {
                        [self parseData:(NSDictionary *)tempArrayObject intoObjectsWithBaseObjectName:currentKey andBaseObjectClass:@"NSObject"];
                    }
                }
            } else if([tempObject isKindOfClass:[NSString class]]) {
                [tempPropertyObject setType:@"NSString"];
            } else if([tempObject isKindOfClass:[NSDictionary class]]) {
                [tempPropertyObject setIsClass:YES];
                [tempPropertyObject setType:[currentKey capitalizedString]];
                [self parseData:(NSDictionary *)tempObject intoObjectsWithBaseObjectName:currentKey andBaseObjectClass:@"NSObject"];
            } else {
                NSString *classDecription = [[tempObject class] description];
                if([classDecription rangeOfString:@"NSCFNumber"].location != NSNotFound) {
                    [tempPropertyObject setType:@"NSInteger"];
                    [tempPropertyObject setSemantics:SetterSemanticAssign];
                } else if([classDecription rangeOfString:@"NSDecimalNumber"].location != NSNotFound) {
                    [tempPropertyObject setType:@"double"];
                    [tempPropertyObject setSemantics:SetterSemanticAssign];
                } 
                else {
                    NSLog(@"UNDEFINED TYPE: %@", [tempObject class]);
                }
                // This is undefined right now - add other if
            }
                        
            [[tempClass properties] addObject:tempPropertyObject];
        }
    }
    
    [self.parsedDictionary setObject:tempClass forKey:baseObjectName];
    
}


@end
