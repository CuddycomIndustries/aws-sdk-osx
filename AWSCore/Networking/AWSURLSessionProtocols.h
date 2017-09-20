//
//  AWSURLSessionProtocols.h
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/15/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const int64_t AWSURLSessionTransferSizeUnknown;    /* -1LL */

@protocol AWSURLSessionDelegate;
@protocol AWSURLSessionConfiguration;

typedef NS_ENUM(NSInteger, AWSURLSessionResponseDisposition) {
	AWSURLSessionResponseCancel = 0,                                      /* Cancel the load, this is the same as -[task cancel] */
	AWSURLSessionResponseAllow = 1,                                       /* Allow the load to continue */
	AWSURLSessionResponseBecomeDownload = 2,                              /* Turn this request into a download */
	AWSURLSessionResponseBecomeStream NS_ENUM_AVAILABLE(10_11, 9_0) = 3,  /* Turn this task into a stream task */
};

typedef NS_ENUM(NSInteger, AWSURLSessionTaskState) {
	AWSURLSessionTaskStateRunning = 0,                     /* The task is currently being serviced by the session */
	AWSURLSessionTaskStateSuspended = 1,
	AWSURLSessionTaskStateCanceling = 2,                   /* The task has been told to cancel.  The session will receive a URLSession:task:didCompleteWithError: message. */
	AWSURLSessionTaskStateCompleted = 3,                   /* The task has completed and the session will receive no more delegate notifications */
};

@protocol AWSURLSessionConfiguration <NSObject>

/* identifier for the background session configuration */
@property (nullable, readonly, copy) NSString *identifier;

/* The URL resource cache, or nil to indicate that no caching is to be performed */
@property (nullable, retain) NSURLCache *URLCache;

/* default timeout for requests.  This will cause a timeout if no data is transmitted for the given timeout value, and is reset whenever data is transmitted. */
@property NSTimeInterval timeoutIntervalForRequest;

/* default timeout for requests.  This will cause a timeout if a resource is not able to be retrieved within a given timeout. */
@property NSTimeInterval timeoutIntervalForResource;

@end

@protocol AWSURLSessionTask <NSObject>

@property (readonly) NSUInteger taskIdentifier;    /* an identifier for this task, assigned by and unique to the owning session */
@property (nullable, readonly, copy) NSURLResponse *response;         /* may be nil if no response has been received */
@property (nullable, readonly, copy) NSURLRequest  *originalRequest;  /* may be nil if this is a stream task */
@property (nullable, readonly, copy) NSURLRequest  *currentRequest;   /* may differ from originalRequest due to http server redirection */
/*
 * The current state of the task within the session.
 */
@property (readonly) AWSURLSessionTaskState state;

- (void)suspend; // currently does nothing
- (void)resume;
- (void)cancel;

@end

@protocol AWSURLSessionDataTask <AWSURLSessionTask>

@end

@protocol AWSURLSessionUploadTask <AWSURLSessionTask>

@end

@protocol AWSURLSessionDownloadTask <AWSURLSessionTask>

@end

@protocol AWSURLSession <NSObject>

@property (readonly, retain) NSOperationQueue *delegateQueue;
@property (nullable, readonly, retain) id <AWSURLSessionDelegate> delegate;
@property (readonly, copy) id<AWSURLSessionConfiguration> configuration;

/* Creates an upload task with the given request.  The body of the request will be created from the file referenced by fileURL */
- (id<AWSURLSessionUploadTask>)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL;

/* Creates a download task with the given request. */
- (id<AWSURLSessionDownloadTask>)downloadTaskWithRequest:(NSURLRequest *)request;

/* Creates a data task with the given request.  The request may have a body stream. */
- (id<AWSURLSessionDataTask>)dataTaskWithRequest:(NSURLRequest *)request;

- (void)getTasksWithCompletionHandler:(void (^)(NSArray<id<AWSURLSessionDataTask>> * _Nonnull, NSArray<id<AWSURLSessionUploadTask>> * _Nonnull, NSArray<id<AWSURLSessionDownloadTask>> * _Nonnull))completionHandler; /* invokes completionHandler with outstanding data, upload and download tasks. */

- (void)finishTasksAndInvalidate;

@end

@protocol AWSURLSessionTaskDelegate <AWSURLSessionDelegate>

@optional
- (void)URLSession:(id<AWSURLSession>)session task:(id<AWSURLSessionTask>)sessionTask didCompleteWithError:(NSError *)error;
- (void)URLSession:(id<AWSURLSession>)session task:(id<AWSURLSessionTask>)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent;

@end

@protocol AWSURLSessionDataDelegate <AWSURLSessionTaskDelegate>

@optional
- (void)URLSession:(id<AWSURLSession>)session dataTask:(id<AWSURLSessionDataTask>)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(AWSURLSessionResponseDisposition disposition))completionHandler;

- (void)URLSession:(id<AWSURLSession>)session dataTask:(id<AWSURLSessionDataTask>)dataTask didReceiveData:(NSData *)data;

@end

@protocol AWSURLSessionDownloadDelegate <AWSURLSessionTaskDelegate>

- (void)URLSession:(id<AWSURLSession>)session downloadTask:(id<AWSURLSessionDownloadTask>)downloadTask didFinishDownloadingToURL:(NSURL *)location;

@optional
- (void)URLSession:(id<AWSURLSession>)session downloadTask:(id<AWSURLSessionDownloadTask>)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

@end

NS_ASSUME_NONNULL_END

