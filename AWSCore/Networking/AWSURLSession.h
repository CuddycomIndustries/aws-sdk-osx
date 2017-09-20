//
//  AWSURLSession.h
//  AWSS3
//
//  Created by Vitaly Afanasyev on 8/7/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import "AWSURLSessionProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@class AWSURLSessionConfiguration;

@interface AWSURLSession : NSObject<AWSURLSession>

+ (instancetype)sessionWithConfiguration:(AWSURLSessionConfiguration *)configuration delegate:(nullable id <AWSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue;

@end

@protocol AWSURLSessionDelegate <NSObject>

@optional
- (void)URLSession:(id<AWSURLSession>)session didBecomeInvalidWithError:(nullable NSError *)error;

@end


NS_ASSUME_NONNULL_END
