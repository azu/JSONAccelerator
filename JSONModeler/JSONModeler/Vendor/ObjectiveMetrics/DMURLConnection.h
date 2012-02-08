//
//  DMURLConnection.h
//  ObjectiveMetrics
//
//  Created by Jørgen Tjernø on 10/24/11.
//  Copyright (c) 2011 devSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

const NSInteger kDMHTTPError;

@class DMURLConnection;

typedef void (^DMURLConnectionCompleteBlock)(DMURLConnection *connection, NSString *responseBody);
typedef void (^DMURLConnectionErrorBlock)(DMURLConnection *connection, NSError *error);

@interface DMURLConnection : NSURLConnection {
    DMURLConnectionCompleteBlock completeBlock;
    DMURLConnectionErrorBlock errorBlock;
    NSMutableData *data;
    BOOL encounteredError;
    NSStringEncoding encoding;
}

+ (id)connectionWithRequest:(NSURLRequest *)request
              completeBlock:(DMURLConnectionCompleteBlock)completeBlock
                 errorBlock:(DMURLConnectionErrorBlock)errorBlock;

- (id)initWithRequest:(NSURLRequest *)request
        completeBlock:(DMURLConnectionCompleteBlock)completeBlock
           errorBlock:(DMURLConnectionErrorBlock)errorBlock;

@end
