//
//  DMTrackingQueue.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DMTracker.h"

@class DMRequester;

@interface DMTrackingQueue : NSObject<DMTrackingQueueProtocol> {
@private
    NSMutableArray *events;
    NSMutableArray *pendingEvents;
    int maxSize;
    double maxSecondsOld;
    DMRequester *requester;
}

@end
