//
//  ClassPropertiesTableViewHelper.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/17/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "TableSelectionChangeDelegate.h"

@class JSONModeler;


@interface ClassPropertiesTableViewHelper : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (retain) JSONModeler *modeler;
@property (retain) id<TableSelectionChangeDelegate> delegate;

@property (weak) NSDictionary *properties;

@end
