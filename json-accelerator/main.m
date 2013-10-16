//
//  main.m
//  json-accelerator
//
//  Created by Jonathan Rexeisen on 12/6/12.
//  Copyright (c) 2012 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModeler.h"
#import "OutputLanguageWriterObjectiveC.h"
#import "OutputLanguageWriterJava.h"


@interface JSONHelperMethods : NSObject

@property (nonatomic, strong) JSONModeler *modeler;

- (BOOL)verifyJSON:(NSData *)data;
- (BOOL)generateFilesOfType:(OutputLanguage)language rootFolder:(NSURL *)selectedDirectory;

@end

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...        
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        
        if ([arguments count] != 4) {
            NSLog(@"Invalid number of arguments");
            NSLog(@"Usage: json-accelerator (java|objc) (input) (output)");
            NSLog(@"Example: json-accelerator objc input.json ~/OutputFiles/");
            return 0;
        }
        
        if ( !([arguments[1] isEqualToString:@"objc"] || [arguments[1] isEqualToString:@"java"])) {
            NSLog(@"Invalid type: output type must by objc or java");
            return 0;
        }
        
        NSString *urlString = arguments[2];        
        NSError *error = nil;
        NSData *jsonData = [NSData dataWithContentsOfFile:urlString
                                                  options:NSDataReadingMappedIfSafe
                                                    error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return 0;
        }
        
        JSONHelperMethods *helper = [[JSONHelperMethods alloc] init];
        [helper verifyJSON:jsonData];
        
        OutputLanguage language = OutputLanguageObjectiveC;
        
        if ([arguments[1] isEqualToString:@"java"]) {
            language = OutputLanguageJava;
        }
        
        [helper generateFilesOfType:language
                         rootFolder:[NSURL URLWithString:arguments[3]]];

    }
    return 0;
}

@implementation JSONHelperMethods

- (BOOL)verifyJSON:(NSData *)data
{
    NSError *error = nil;
    // Just for testing
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if(error) {
        NSDictionary *dict = [error userInfo];
        NSString *informativeText = [[dict allValues] objectAtIndex:0];
        if([informativeText isEqualToString:@"No value."]) {
            informativeText = NSLocalizedString(@"There is no content to parse.", @"If there is nothing in the JSON field, state that there is nothing there");
        } else if ([informativeText isEqualToString:@"JSON text did not start with array or object and option to allow fragments not set."]) {
            informativeText = NSLocalizedString(@"JSON text did not start with array or object.", @"Error message to state the JSON didn't start with a {} or []");
        }
        
        NSLog(@"Error: %@", informativeText);        
        return NO;
    } else {
        self.modeler = [[JSONModeler alloc] init];
        id output = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        self.modeler.JSONString = outputString;
        return YES;
    }
    return YES;

}

- (BOOL)generateFilesOfType:(OutputLanguage)language rootFolder:(NSURL *)selectedDirectory
{    
    BOOL filesHaveBeenWritten = NO;
    BOOL filesHaveHadError = NO;
    
    if(self.modeler) {
        
        id<OutputLanguageWriterProtocol> writer = nil;
        NSDictionary *optionsDict = nil;
        
        if (language == OutputLanguageObjectiveC) {
            writer = [[OutputLanguageWriterObjectiveC alloc] init];
            optionsDict = @{kObjectiveCWritingOptionUseARC: @(YES)};
        }
        else if (language == OutputLanguageJava) {
            writer = [[OutputLanguageWriterJava alloc] init];
            optionsDict = @{kJavaWritingOptionBaseClassName: @"BaseClass", kJavaWritingOptionPackageName: @"com.companyname"};
        } else {
            
        }
        
        [self.modeler loadJSONWithString:self.modeler.JSONString
                    outputLanguageWriter:writer];
        
        filesHaveBeenWritten = [writer writeClassObjects:[self.modeler parsedDictionary]
                                                   toURL:selectedDirectory
                                                 options:optionsDict
                                          generatedError:&filesHaveHadError];
        
    }

    
    
    NSString *statusString = @"";
    if(filesHaveBeenWritten) {
        statusString = NSLocalizedString(@"Your files have successfully been generated.", @"Success message in an action sheet");
        if(filesHaveHadError) {
            statusString = [statusString stringByAppendingString:NSLocalizedString(@" However, there was an error writing one or more of the files", @"If something went wrong, but the writing was generally successful")];
        }
    } else {
        statusString = NSLocalizedString(@"An error has occurred and no files have been generated.", @"Actionsheet message for stating that nothing was generated ");
    }
    
    if (!filesHaveBeenWritten || filesHaveHadError) {
        NSLog(@"%@", statusString);
        return NO;
    }
    return YES;
}

@end

