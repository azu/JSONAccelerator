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

@interface JSONModeler () {
    NSUInteger _numUnnamedClasses;
}

- (void) loadJSONWithData: (NSData *) data;
- (ClassBaseObject *) parseData: (NSDictionary *)dict intoObjectsWithBaseObjectName: (NSString *) baseObjectName andBaseObjectClass: (NSString *) baseObjectClass;

@end

@implementation JSONModeler
@synthesize rawJSONObject = _rawJSONDictionary;
@synthesize parsedDictionary = _parsedDictionary;
@synthesize parseComplete = _parseComplete;

- (id)init {
    self = [super init];
    if (self) {
        _numUnnamedClasses = 0;
    }
    return self;
}

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
        self.rawJSONObject = object;
        self.parseComplete = NO;
        [self parseData:(NSDictionary *)self.rawJSONObject intoObjectsWithBaseObjectName:@"MyClass" andBaseObjectClass:@"NSObject"];
        self.parseComplete = YES;
    }
    
    if([object isKindOfClass:[NSArray class]]) {
        self.parseComplete = NO;
        self.rawJSONObject = object;        
        for(NSObject *arrayObject in (NSArray *)object) {
            if([arrayObject isKindOfClass:[NSDictionary class]]) {
                [self parseData:(NSDictionary *)arrayObject intoObjectsWithBaseObjectName:@"MyClass" andBaseObjectClass:@"NSObject"];
            }
        }
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
        
        // Set the name of the class
        NSString *tempClassName = [baseObjectName objectiveCClassString];
        if ([tempClassName isEqualToString:@""]) {
            tempClassName = [NSString stringWithFormat:@"MyClass%u", ++_numUnnamedClasses];
        }
        [tempClass setClassName:tempClassName];
    }
    
    NSArray *array = [dict allKeys];
    ClassPropertiesObject *tempPropertyObject = nil;
    NSObject *tempObject = nil;
    NSObject *tempArrayObject = nil;
    
    NSUInteger numUnnamedProperties = 0;
    for(NSString *currentKey in array) {
        @autoreleasepool {
            tempPropertyObject = [ClassPropertiesObject new];
            [tempPropertyObject setJsonName:currentKey];
            // Set the name of the property
            if([currentKey isEqualToString:@"id"]) {
                [tempPropertyObject setName:[[tempClass.className stringByAppendingString:@"Identifier"] uncapitalizeFirstCharacter]];
            } else if ([currentKey isEqualToString:@"description"]) {
                [tempPropertyObject setName:[[tempClass.className stringByAppendingString:@"Description"] uncapitalizeFirstCharacter]];
            } else if ([currentKey isEqualToString:@"self"]) {
                [tempPropertyObject setName:[[tempClass.className stringByAppendingString:@"Self"] uncapitalizeFirstCharacter]];
            }else {
                NSString *tempPropertyName = [currentKey objectiveCPropertyString];
                if ([tempPropertyName isEqualToString:@""]) {
                    tempPropertyName = [NSString stringWithFormat:@"myProperty%u", ++numUnnamedProperties];
                }
                [tempPropertyObject setName:tempPropertyName];
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
