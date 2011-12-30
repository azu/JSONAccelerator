//
//  HTTPOptionsWindowController.m
//  JSONModeler
//
//  Created by Sean Hickey on 12/29/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "HTTPOptionsWindowController.h"
#import "ModelerDocument.h"

NSString * const headerKey = @"headerKey";
NSString * const headerValue = @"headerValue";

@interface HTTPOptionsWindowController () <NSControlTextEditingDelegate> {
@private
    NSTextView *_headerKeyFieldEditor;
    NSArray *_httpHeaderStrings;
    BOOL _fieldIsCompleting;
    BOOL _handlingCommand;
}
@end

@implementation HTTPOptionsWindowController

@synthesize httpMethodRadioButtons = _httpMethodRadioButtons;
@synthesize httpMethod = _httpMethod;
@synthesize headerArrayController = _headerArrayController;
@synthesize headerKeyField = _headerKeyField;
@synthesize headerValueField = _headerValueField;
@synthesize headerTableView = _headerTableView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _httpHeaderStrings = [NSArray arrayWithObjects:@"Accept", @"Accept-Charset", @"Accept-Encoding", @"Accept-Language", @"Authorization", @"Cache-Control", @"Connection", @"Cookie", @"Content-Length", @"Content-MD5", @"Content-Type", @"Date", @"Expect", @"From", @"Host", @"If-Match", @"If-Modified-Since", @"If-None-Match", @"If-Range", @"If-Unmodified-Since", @"Max-Forwards", @"Pragma", @"Proxy-Authorization", @"Range", @"Referer", @"TE", @"Upgrade", @"User-Agent", @"Via", @"Warning", nil];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    ModelerDocument *document = self.document;
    self.httpMethod = document.httpMethod;
    for (NSDictionary *header in document.httpHeaders) {
        [self.headerArrayController addObject:header];
    }
    
    _fieldIsCompleting = NO;
    _handlingCommand = NO;
}

- (IBAction)addHeaderClicked:(id)sender {
    if (_headerKeyField.stringValue != nil && ![_headerKeyField.stringValue isEqualToString:@""] && _headerValueField.stringValue != nil && ![_headerValueField.stringValue isEqualToString:@""]) {
        [self.headerArrayController addObject:[NSDictionary dictionaryWithObjectsAndKeys:_headerKeyField.stringValue, headerKey, _headerValueField.stringValue, headerValue, nil]];
        
    }
}

- (IBAction)cancelClicked:(id)sender {
    [self.window close];
}

- (IBAction)saveClicked:(id)sender {
    ModelerDocument *document = self.document;
    document.httpMethod = _httpMethod;
    document.httpHeaders = [[_headerArrayController arrangedObjects] copy];
    [self.window close];
}

#pragma mark - NSControl Delegate Methods (for Header Key Text Field)
-(void)controlTextDidChange:(NSNotification *)obj
{    
    NSTextView *fieldEditor = [[obj userInfo] objectForKey:@"NSFieldEditor"];
    if (!_fieldIsCompleting && !_handlingCommand) {
        _fieldIsCompleting = YES;
        [fieldEditor complete:nil];
        _fieldIsCompleting = NO;
    }
}

-(NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{    
    NSMutableArray * matches = [NSMutableArray array];
    NSString *partialString = [[textView string] substringWithRange:charRange];
    NSLog(@"%@", partialString);
    
    for (NSString *headerString in _httpHeaderStrings) {
        if ([headerString rangeOfString:partialString options:NSAnchoredSearch | NSCaseInsensitiveSearch range:NSMakeRange(0, [headerString length])].location != NSNotFound) {
            [matches addObject:headerString];
        }
    }
    
    [matches sortUsingSelector:@selector(compare:)];
    
    return matches;
}

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
	
	if ([textView respondsToSelector:commandSelector])
	{
        _handlingCommand = YES;
        [textView performSelector:commandSelector withObject:nil];  // This call with usually issue a warning under ARC, but this has been suppressed with the warning flag -Wno-arc-performSelector-leaks
        _handlingCommand = NO;
		
		result = YES;
    }
	
    return result;

}

#pragma mark - NSResponder methods

- (void)delete:(id)sender
{
    NSInteger row = [_headerTableView selectedRow];
    if (row != -1) {
        [_headerArrayController removeObjectAtArrangedObjectIndex:row];
    }
}

@end
