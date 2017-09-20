//
//  AWSRestrictedURLSessionTask.h
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/15/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import "AWSURLSessionProtocols.h"

#pragma mark - AWSRestrictedURLSessionTask

@interface AWSRestrictedURLSessionTask : NSObject<AWSURLSessionTask>

@property (assign) id delegate;
@property (assign) NSUInteger taskIdentifier;    /* an identifier for this task, assigned by and unique to the owning session */

- (instancetype)initWithRequest:(NSURLRequest *)request;

@end

@protocol AWSRestrictedURLSessionTaskDelegate <NSObject>

- (void)task:(AWSRestrictedURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error;
- (void)task:(AWSRestrictedURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent;

@end

#pragma mark - AWSRestrictedURLSessionDataTask

@interface AWSRestrictedURLSessionDataTask : AWSRestrictedURLSessionTask<AWSURLSessionDataTask>

@end

@protocol AWSRestrictedURLSessionDataTaskDelegate <AWSRestrictedURLSessionTaskDelegate>

- (void)dataTask:(AWSRestrictedURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(AWSURLSessionResponseDisposition disposition))completionHandler;
- (void)dataTask:(AWSRestrictedURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;

@end

#pragma mark - AWSRestrictedURLSessionUploadTask

@interface AWSRestrictedURLSessionUploadTask : AWSRestrictedURLSessionTask<AWSURLSessionUploadTask>

@end

@interface AWSRestrictedURLSessionDownloadTask : AWSRestrictedURLSessionTask<AWSURLSessionDownloadTask>

@end

#pragma mark - AWSRestrictedURLSessionDownloadTaskDelegate

@protocol AWSRestrictedURLSessionDownloadTaskDelegate <AWSRestrictedURLSessionTaskDelegate>

- (void)downloadTask:(AWSRestrictedURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;
- (void)downloadTask:(AWSRestrictedURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

@end


