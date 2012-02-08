//
//  DMRequester.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/24/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DMRequester : NSObject {
@private
    NSMutableURLRequest *request;
    NSMutableArray *connections;
    id delegate;
}

@property (retain) id delegate;

- (id)initWithDelegate:(id)theDelegate;

- (void)send:(NSArray *)data;
- (void)wait;

@end

@protocol DMRequesterDelegate
@optional
- (void)requestFailed:(NSArray *)events;
- (void)requestSucceeded:(NSArray *)events;
@end
