//
//  NSViewControllerCallback.h
//  JSONModeler
//
//  Created by Jon Rexeisen on 11/11/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MasterControllerDelegate <NSObject>

@required
-(void)moveToNextViewController;

@end
