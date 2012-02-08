//
//  DMHosts.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMSUHost.h"

@interface DMHosts : NSObject

+ (DMSUHost *)sharedAppHost;
+ (DMSUHost *)sharedFrameworkHost;

@end
