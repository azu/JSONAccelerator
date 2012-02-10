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
#import "OutputLanguageWriterProtocol.h"

@interface JSONModeler () {
    NSUInteger _numUnnamedClasses;
}

- (void)loadJSONWithData:(NSData *)data outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer;
- (ClassBaseObject *)parseData:(NSDictionary *)dict intoObjectsWithBaseObjectName:(NSString *)baseObjectName andBaseObjectClass:(NSString *)baseObjectClass outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer;

@end

@implementation JSONModeler
@synthesize rawJSONObject = _rawJSONDictionary;
@synthesize parsedDictionary = _parsedDictionary;
@synthesize parseComplete = _parseComplete;
@synthesize JSONString = _JSONString;

- (id)init {
    self = [super init];
    if (self) {
        _numUnnamedClasses = 0;
    }
    return self;
}

- (void)loadJSONWithURL:(NSString *)url outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer
{
    JSONFetcher *fetcher = [[JSONFetcher alloc] init];
    [fetcher downloadJSONFromLocation:url withSuccess:^(id object) {
        [self loadJSONWithData:object outputLanguageWriter:writer];
    } 
   andFailure:^(NSHTTPURLResponse *response, NSError *error) {
       DLog(@"An error occured here, but it's not too much trouble because this method is only used in debugging");
   }];
}

- (void)loadJSONWithString:(NSString *)string outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer
{
    [self loadJSONWithData:[string dataUsingEncoding:NSUTF8StringEncoding] outputLanguageWriter:writer];
}

- (void)loadJSONWithData:(NSData *)data outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer
{
    NSError *error = nil;    
    self.parsedDictionary = nil;
        
    //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    // Just for testing
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if([object isKindOfClass:[NSDictionary class]]) {
        self.rawJSONObject = object;
        self.parseComplete = NO;
        [self parseData:(NSDictionary *)self.rawJSONObject intoObjectsWithBaseObjectName:@"InternalBaseClass" andBaseObjectClass:@"NSObject" outputLanguageWriter:writer];
        self.parseComplete = YES;
    }
    
    if([object isKindOfClass:[NSArray class]]) {
        self.parseComplete = NO;
        self.rawJSONObject = object;        
        for(NSObject *arrayObject in (NSArray *)object) {
            if([arrayObject isKindOfClass:[NSDictionary class]]) {
                [self parseData:(NSDictionary *)arrayObject intoObjectsWithBaseObjectName:@"InternalBaseClass" andBaseObjectClass:@"NSObject" outputLanguageWriter:writer];
            }
        }
        self.parseComplete = YES;
    }
}

#pragma mark - Create the model objects

- (ClassBaseObject *)parseData:(NSDictionary *)dict intoObjectsWithBaseObjectName:(NSString *)baseObjectName andBaseObjectClass:(NSString *)baseObjectClass outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer
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
        BOOL isReservedWord;
        NSString *tempClassName = [baseObjectName alphanumericStringIsReservedWord:&isReservedWord fromReservedWordSet:[writer reservedWords]];
        if (isReservedWord) {
            tempClassName = [writer classNameForObject:tempClass fromReservedWord:tempClassName];
        }
        if ([tempClassName isEqualToString:@""]) {
            tempClassName = [NSString stringWithFormat:@"InternalBaseClass%u", ++_numUnnamedClasses];
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
            BOOL isReservedWord;
            NSString *tempPropertyName = [[currentKey alphanumericStringIsReservedWord:&isReservedWord fromReservedWordSet:[writer reservedWords]] uncapitalizeFirstCharacter];
            if (isReservedWord) {
                tempPropertyName = [writer propertyNameForObject:tempPropertyObject inClass:tempClass fromReservedWord:tempPropertyName];
            }
            if ([tempPropertyName isEqualToString:@""]) {
                tempPropertyName = [NSString stringWithFormat:@"myProperty%u", ++numUnnamedProperties];
            }
            [tempPropertyObject setName:tempPropertyName];
            
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
                // if it is, then we need to create a new class. Also, set the collection type for
                // the array (used by java)
                for(tempArrayObject in (NSArray *)tempObject) {
                    if([tempArrayObject isKindOfClass:[NSDictionary class]]) {
                        ClassBaseObject *newClass = [self parseData:(NSDictionary *)tempArrayObject intoObjectsWithBaseObjectName:currentKey andBaseObjectClass:@"NSObject" outputLanguageWriter:writer];
                        [tempPropertyObject setReferenceClass:newClass];
                        [tempPropertyObject setCollectionType:PropertyTypeClass];
                        [tempPropertyObject setCollectionTypeString:newClass.className];
                    }
                    else if ([tempArrayObject isKindOfClass:[NSString class]]) {
                        [tempPropertyObject setCollectionType:PropertyTypeString];
                    }
                    else {
                        // Miscellaneous
                        NSString *classDecription = [[tempArrayObject class] description];
                        if([classDecription rangeOfString:@"NSCFNumber"].location != NSNotFound) {
                            [tempPropertyObject setCollectionType:PropertyTypeInt];
                        } else if([classDecription rangeOfString:@"NSDecimalNumber"].location != NSNotFound) {
                            [tempPropertyObject setCollectionType:PropertyTypeDouble];
                        }  else if([classDecription rangeOfString:@"NSCFBoolean"].location != NSNotFound) {
                            [tempPropertyObject setCollectionType:PropertyTypeBool];
                        } 
                        else {
                            DLog(@"UNDEFINED TYPE: %@", [tempArrayObject class]);
                        }
                    }
                }
                
            } else if([tempObject isKindOfClass:[NSString class]]) {
                // NSString Objects
                [tempPropertyObject setType:PropertyTypeString];
                
            } else if([tempObject isKindOfClass:[NSDictionary class]]) {
                // NSDictionary Objects
                [tempPropertyObject setIsClass:YES];
                [tempPropertyObject setType:PropertyTypeClass];
                [tempPropertyObject setReferenceClass:[self parseData:(NSDictionary *)tempObject intoObjectsWithBaseObjectName:currentKey andBaseObjectClass:@"NSObject" outputLanguageWriter:writer]];
                
            } else {
                // Miscellaneous
                NSString *classDecription = [[tempObject class] description];
                if([classDecription rangeOfString:@"NSCFNumber"].location != NSNotFound) {
                    [tempPropertyObject setType:PropertyTypeInt];
                    [tempPropertyObject setSemantics:SetterSemanticAssign];
                } else if([classDecription rangeOfString:@"NSDecimalNumber"].location != NSNotFound) {
                    [tempPropertyObject setType:PropertyTypeDouble];
                    [tempPropertyObject setSemantics:SetterSemanticAssign];
                } else if([classDecription rangeOfString:@"NSCFBoolean"].location != NSNotFound) {
                    [tempPropertyObject setType:PropertyTypeBool];
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

- (NSDictionary *)parsedDictionaryByReplacingReservedWords:(NSArray *)reservedWords
{
    if (nil == _parsedDictionary) {
        return nil;
    }
}


#pragma mark - NSCoding methods

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    self.rawJSONObject = [aDecoder decodeObjectForKey:@"rawJSONObject"];
    self.parsedDictionary = [aDecoder decodeObjectForKey:@"parsedDictionary"];
    self.parseComplete = [aDecoder decodeBoolForKey:@"parseComplete"];
    self.JSONString = [aDecoder decodeObjectForKey:@"JSONString"];
    return self;
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:_rawJSONDictionary forKey:@"rawJSONObject"];
    [aCoder encodeObject:_parsedDictionary forKey:@"parsedDictionary"];
    [aCoder encodeBool:_parseComplete forKey:@"parseComplete"];
    [aCoder encodeObject:_JSONString forKey:@"JSONString"];
    
}

@end
