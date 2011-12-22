//
//  ModelerDocument.m
//  JSONModeler
//
//  Created by Sean Hickey on 12/21/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "ModelerDocument.h"
#import "MainWindowController.h"

@implementation ModelerDocument

@synthesize modeler = _modeler;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
        _modeler = [[JSONModeler alloc] init];
    }
    return self;
}

-(id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    // TODO Implement this. It's used for opening .json files.
    self = [self init];
    if (self) {
//        if ([typeName isEqualToString:@"JSONModelerType"]) {
//            NSData *fileData = [NSData dataWithContentsOfURL:url];
//            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:fileData];
//            _modeler = [unarchiver decodeObjectForKey:@"modeler"];
//            
//        }
//        else
        if ([typeName isEqualToString:@"JSONTextType"]) {
            _modeler = [[JSONModeler alloc] init];
        }
    }
    return self;
}

- (void)makeWindowControllers
{
    MainWindowController *mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    [self addWindowController:mainWindowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    */
    NSData *outData = [NSKeyedArchiver archivedDataWithRootObject:_modeler];
    
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return outData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    /*
    Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    */
    
    _modeler = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

@end
