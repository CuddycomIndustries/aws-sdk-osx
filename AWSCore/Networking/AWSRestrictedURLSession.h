//
//  AWSRestrictedURLSession.h
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/15/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import "AWSURLSessionProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@class AWSURLSessionConfiguration;

@interface AWSRestrictedURLSession : NSObject<AWSURLSession>

+ (instancetype)sessionWithConfiguration:(AWSURLSessionConfiguration *)configuration delegate:(nullable id <AWSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue;

@end

NS_ASSUME_NONNULL_END
