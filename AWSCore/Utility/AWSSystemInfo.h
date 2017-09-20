//
//  AWSSystemInfo.h
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/11/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWSSystemInfo : NSObject

@property (class, readonly) BOOL isSnowLeopardOrGreater;
@property (class, readonly) BOOL isLionOrGreater;
@property (class, readonly) BOOL isMountainLionOrGreater;
@property (class, readonly) BOOL isMavericksOrGreater;
@property (class, readonly) BOOL isYosemiteOrGreater;
@property (class, readonly) BOOL isElCapitanOrGreater;

@end
