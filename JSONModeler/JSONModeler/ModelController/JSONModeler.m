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
#import "NSString+Nerdery.h"

@interface JSONModeler ()

- (void) loadJSONWithData: (NSData *) data;
- (ClassBaseObject *) parseData: (NSDictionary *)dict intoObjectsWithBaseObjectName: (NSString *) baseObjectName andBaseObjectClass: (NSString *) baseObjectClass;

@end

@implementation JSONModeler
@synthesize rawJSONDictionary = _rawJSONDictionary;
@synthesize parsedDictionary = _parsedDictionary;
@synthesize parseComplete = _parseComplete;

- (void) loadJSONWithURL: (NSString *) url
{
    JSONFetcher *fetcher = [[JSONFetcher alloc] init];
    [fetcher downloadJSONFromLocation:url withSuccess:^(id object) {
        [self loadJSONWithData:object];
    } 
   andFailure:^(NSHTTPURLResponse *response, NSError *error) {
       DLog(@"An error occured here, but it's not too much trouble because this method is only used in debugging");
   }];
}

- (void) loadJSONWithString: (NSString *) string
{
    [self loadJSONWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) loadJSONWithData: (NSData *) data
{
    NSError *error = nil;    
        
    //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    // Just for testing
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if([object isKindOfClass:[NSDictionary class]]) {
        self.rawJSONDictionary = object;
        self.parseComplete = NO;
        [self parseData:self.rawJSONDictionary intoObjectsWithBaseObjectName:@"MyClass" andBaseObjectClass:@"NSObject"];
        self.parseComplete = YES;
    }
}

#pragma mark - Create the model objects

- (ClassBaseObject *) parseData: (NSDictionary *)dict intoObjectsWithBaseObjectName: (NSString *) baseObjectName andBaseObjectClass: (NSString *) baseObjectClass
{
    if(_parsedDictionary == nil) {
        self.parsedDictionary = [NSMutableDictionary dictionary];
    }

    ClassBaseObject *tempClass = nil;
    
    if([self.parsedDictionary objectForKey:baseObjectName]) {
        tempClass = [self.parsedDictionary objectForKey:baseObjectName];
    } else {
        tempClass = [ClassBaseObject new];
        [tempClass setBaseClass:baseObjectClass];
        
        // Massage the names of the application
        NSMutableArray *components = [NSMutableArray arrayWithArray:[baseObjectName componentsSeparatedByString:@"_"]];
        for(NSUInteger i = 0; i < [components count]; i++) {
            [components replaceObjectAtIndex:i withObject:[[components objectAtIndex:i] capitalizeFirstCharacter]];
        }
        NSString *tempClassName = [components componentsJoinedByString:@""];
        [tempClass setClassName:[tempClassName capitalizeFirstCharacter]];
    }
    
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
            } else if ([currentKey isEqualToString:@"self"]) {
                [tempPropertyObject setName:[baseObjectName stringByAppendingString:@"Self"]];
            }else {
                [tempPropertyObject setName:currentKey];
            }
            
            [tempPropertyObject setIsAtomic:NO];
            [tempPropertyObject setIsClass:NO];
            [tempPropertyObject setIsReadWrite:YES];
            [tempPropertyObject setSemantics:SetterSemanticRetain];
            
            tempObject = [dict objectForKey:currentKey];
            
            BOOL shouldSetObject = YES;
            
            if([[tempClass properties] objectForKey:currentKey]) {
                shouldSetObject = NO;
            }
            
            
            if([tempObject isKindOfClass:[NSArray class]]) {
                // NSArray Objects
                if(shouldSetObject == NO) {
                    if ([[[tempClass properties] objectForKey:currentKey] isKindOfClass:[NSDictionary class]]) {
                        // Just in case it originally came in as a Dictionary and then later is shown as an array
                        // We should switch this to using an array.
                        shouldSetObject = YES;
                    }
                }
                
                [tempPropertyObject setType:PropertyTypeArray];
                
                // We now need to check to see if the first object in the array is a NSDictionary
                // if it is, then we need to create a new class
                if([(NSArray *)tempObject count] > 0) {
                    tempArrayObject = [(NSArray *)tempObject objectAtIndex:0];
                    if([tempArrayObject isKindOfClass:[NSDictionary class]]) {
                        [tempPropertyObject setReferenceClass:[self parseData:(NSDictionary *)tempArrayObject intoObjectsWithBaseObjectName:currentKey andBaseObjectClass:@"NSObject"]];
                    }
                }
                
            } else if([tempObject isKindOfClass:[NSString class]]) {
                // NSString Objects
                [tempPropertyObject setType:PropertyTypeString];
                
            } else if([tempObject isKindOfClass:[NSDictionary class]]) {
                // NSDictionary Objects
                [tempPropertyObject setIsClass:YES];
                [tempPropertyObject setType:PropertyTypeClass];
                [tempPropertyObject setReferenceClass:[self parseData:(NSDictionary *)tempObject intoObjectsWithBaseObjectName:currentKey andBaseObjectClass:@"NSObject"]];
                
            } else {
                // Miscellaneous
                NSString *classDecription = [[tempObject class] description];
                if([classDecription rangeOfString:@"NSCFNumber"].location != NSNotFound) {
                    [tempPropertyObject setType:PropertyTypeInt];
                    [tempPropertyObject setSemantics:SetterSemanticAssign];
                } else if([classDecription rangeOfString:@"NSDecimalNumber"].location != NSNotFound) {
                    [tempPropertyObject setType:PropertyTypeDouble];
                    [tempPropertyObject setSemantics:SetterSemanticAssign];
                } 
                else {
                    DLog(@"UNDEFINED TYPE: %@", [tempObject class]);
                }
                // This is undefined right now - add other if
            }
                        
            if(shouldSetObject) {
                [[tempClass properties] setObject:tempPropertyObject forKey:currentKey];
            }
        }
    }
    
    [self.parsedDictionary setObject:tempClass forKey:baseObjectName];
    return tempClass;
}


@end
