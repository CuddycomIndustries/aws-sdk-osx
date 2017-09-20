//
//  AWSSystemInfo.m
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/11/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import "AWSSystemInfo.h"
#import <Cocoa/Cocoa.h>

@implementation AWSSystemInfo

+ (BOOL)isSnowLeopardOrGreater
{
	return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5;
}

+ (BOOL)isLionOrGreater
{
	return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6;
}

+ (BOOL)isMountainLionOrGreater
{
	return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_7;
}

+ (BOOL)isMavericksOrGreater
{
	return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8;
}

+ (BOOL)isYosemiteOrGreater
{
	return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9;
}

+ (BOOL)isElCapitanOrGreater
{
	return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_10_Max;
}

@end
