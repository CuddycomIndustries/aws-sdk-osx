//
//  AWSURLSessionConfiguration.h
//  AWSS3
//
//  Created by Vitaly Afanasyev on 8/7/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSURLSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWSURLSessionConfiguration : NSObject<NSCopying, AWSURLSessionConfiguration>

+ (instancetype)defaultSessionConfiguration;

+ (instancetype)backgroundSessionConfigurationWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
