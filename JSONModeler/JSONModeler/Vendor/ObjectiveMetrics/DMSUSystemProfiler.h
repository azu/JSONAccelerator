//
//  DMSUSystemProfiler.h
//  Sparkle
//
//  Created by Andy Matuschak on 12/22/07.
//  Copyright 2007 Andy Matuschak. All rights reserved.
//
// Renamed SUSystemProfiler -> DMSUSystemProfiler to prevent symbol conflicts with people who use this library.

#ifndef DMSUSYSTEMPROFILER_H
#define DMSUSYSTEMPROFILER_H

@class DMSUHost;
@interface DMSUSystemProfiler : NSObject {}
+ (DMSUSystemProfiler *)sharedSystemProfiler;
- (NSMutableArray *)systemProfileArrayForHost:(DMSUHost *)host;
@end

#endif
