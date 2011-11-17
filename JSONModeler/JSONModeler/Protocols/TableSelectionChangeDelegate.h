//
//  TableSelectionChangeDelegate.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/17/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TableSelectionChangeDelegate <NSObject>

@required
- (void)tableDidChangeSelection;

@end
