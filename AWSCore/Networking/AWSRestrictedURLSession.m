//
//  AWSRestrictedURLSession.m
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/15/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import "AWSRestrictedURLSession.h"
#import "AWSURLSessionConfiguration.h"
#import "AWSRestrictedURLSessionTask.h"

@interface AWSRestrictedURLSession ()<AWSRestrictedURLSessionTaskDelegate, AWSRestrictedURLSessionDataTaskDelegate, AWSRestrictedURLSessionDownloadTaskDelegate>

@property (readonly, retain) NSMutableDictionary<NSNumber *, AWSRestrictedURLSessionTask *> *sessionTasksByIdentifier;
@property (readonly, retain) NSLock *modifyingTasksLock;
@property (assign) BOOL finishingTasksRequested;
@property (retain) NSOperationQueue *delegateQueue;
@property (nullable, retain) id <AWSURLSessionDelegate> delegate;
@property (copy) AWSURLSessionConfiguration *configuration;

@end

@implementation AWSRestrictedURLSession

@synthesize sessionTasksByIdentifier = _sessionTasksByIdentifier;
@synthesize delegateQueue = _delegateQueue;
@synthesize modifyingTasksLock = _modifyingTasksLock;

+ (instancetype)sessionWithConfiguration:(AWSURLSessionConfiguration *)configuration delegate:(nullable id <AWSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue
{
	AWSRestrictedURLSession *session = [[self class] new];
	session.delegateQueue = queue;
	session.configuration = configuration;
	session.delegate = delegate;
	
	return session;
}

- (NSOperationQueue *)delegateQueue
{
	@synchronized (self)
	{
		if (_delegateQueue == nil)
		{
			_delegateQueue = [NSOperationQueue new];
			_delegateQueue.maxConcurrentOperationCount = 1;
		}
	}
	
	return _delegateQueue;
}

- (void)setDelegateQueue:(NSOperationQueue *)delegateQueue
{
	@synchronized (self)
	{
		if (_delegateQueue != delegateQueue)
		{
			_delegateQueue = delegateQueue;
		}
	}
}

- (NSMutableDictionary<NSNumber *, AWSRestrictedURLSessionTask *> *)sessionTasksByIdentifier
{
	@synchronized (self)
	{
		if (_sessionTasksByIdentifier == nil)
		{
			_sessionTasksByIdentifier = [NSMutableDictionary new];
		}
	}
	return _sessionTasksByIdentifier;
}

- (NSLock *)modifyingTasksLock
{
	@synchronized (self)
	{
		if (_modifyingTasksLock == nil)
		{
			_modifyingTasksLock = [NSLock new];
		}
	}
	return _modifyingTasksLock;
}


- (void)getTasksWithCompletionHandler:(void (^)(NSArray<id<AWSURLSessionDataTask>> *dataTasks, NSArray<id<AWSURLSessionUploadTask>> *uploadTasks, NSArray<id<AWSURLSessionDownloadTask>> *downloadTasks))completionHandler
{
	
	NSMutableArray<AWSRestrictedURLSessionDataTask *> *dataTasks = [NSMutableArray array];
	NSMutableArray<AWSRestrictedURLSessionUploadTask *> *uploadTasks = [NSMutableArray array];
	NSMutableArray<AWSRestrictedURLSessionDataTask *> *downloadTasks = [NSMutableArray array];
	
	[self.modifyingTasksLock lock];
	
	[self.sessionTasksByIdentifier enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, AWSRestrictedURLSessionTask * _Nonnull task, BOOL * _Nonnull stop)
	 {
		 if ([task isKindOfClass:[AWSRestrictedURLSessionDataTask class]])
		 {
			 [dataTasks addObject:(AWSRestrictedURLSessionDataTask *)task];
		 }
		 else if ([task isKindOfClass:[AWSRestrictedURLSessionDownloadTask class]])
		 {
			 [downloadTasks addObject:(AWSRestrictedURLSessionDataTask *)task];
		 }
		 else if ([task isKindOfClass:[AWSRestrictedURLSessionUploadTask class]])
		 {
			 [uploadTasks addObject:(AWSRestrictedURLSessionUploadTask *)task];
		 }
	 }];
	
	[self.modifyingTasksLock unlock];
	
	completionHandler([dataTasks copy], [uploadTasks copy], [downloadTasks copy]);
}

- (void)finishTasksAndInvalidate
{
	self.finishingTasksRequested = YES;
}

- (AWSRestrictedURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL;
{
	NSMutableURLRequest *mutableRequest = [request mutableCopy];
	mutableRequest.HTTPBodyStream = [NSInputStream inputStreamWithURL:fileURL];
	AWSRestrictedURLSessionUploadTask *result = [[AWSRestrictedURLSessionUploadTask alloc] initWithRequest:mutableRequest];
	result.delegate = self;
	
	if (result != nil)
	{
		[self registerTask:result];
	}
	
	return result;
}

- (AWSRestrictedURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
{
	AWSRestrictedURLSessionDownloadTask *result = [[AWSRestrictedURLSessionDownloadTask alloc] initWithRequest:request];
	result.delegate = self;
	
	if (result != nil)
	{
		[self registerTask:result];
	}
	
	return result;
}

- (AWSRestrictedURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
{
	AWSRestrictedURLSessionDataTask *result = [[AWSRestrictedURLSessionDataTask alloc] initWithRequest:request];
	result.delegate = self;
	
	if (result != nil)
	{
		[self registerTask:result];
	}
	
	return result;
}

- (void)registerTask:(AWSRestrictedURLSessionTask *)task
{
	[self.modifyingTasksLock lock];
	NSMutableDictionary *sessionTasksByIdentifier = self.sessionTasksByIdentifier;
	NSUInteger identifier = 0;
	
	do
	{
		identifier = arc4random();
	}
	while (sessionTasksByIdentifier[@(identifier)] != nil);
	
	task.taskIdentifier = identifier;
	
	self.sessionTasksByIdentifier[@(identifier)] = task;
	
	[self.modifyingTasksLock unlock];
}

- (void)unregisterTask:(AWSRestrictedURLSessionTask *)task
{
	[self.modifyingTasksLock lock];
	
	[self.sessionTasksByIdentifier removeObjectForKey:@(task.taskIdentifier)];
	
	[self.modifyingTasksLock unlock];
	
	if (self.sessionTasksByIdentifier.count == 0)
	{
		if ([self.delegate respondsToSelector:@selector(URLSession:didBecomeInvalidWithError:)])
		{
			[(id<AWSURLSessionTaskDelegate>)self.delegate URLSession:self didBecomeInvalidWithError:nil];
		}
	}
}

#pragma mark - AWSRestrictedURLSessionTaskDelegate

- (void)task:(AWSRestrictedURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error
{
	[self.delegateQueue addOperationWithBlock:^
	 {
		 if ([self.delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)])
		 {
			 [(id<AWSURLSessionTaskDelegate>)self.delegate URLSession:self task:sessionTask didCompleteWithError:error];
		 }
	 }];
	
	[self unregisterTask:sessionTask];
}

- (void)task:(AWSRestrictedURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent
{
	[self.delegateQueue addOperationWithBlock:^
	 {
		 if ([self.delegate respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:)])
		 {
			 [(id<AWSURLSessionTaskDelegate>)self.delegate URLSession:self task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent];
		 }
	 }];
}

#pragma mark - AWSRestrictedURLSessionDataTaskDelegate

- (void)dataTask:(AWSRestrictedURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(AWSURLSessionResponseDisposition disposition))completionHandler
{
	[self.delegateQueue addOperationWithBlock:^
	 {
		 if ([self.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)])
		 {
			 [(id<AWSURLSessionDataDelegate>)self.delegate URLSession:self dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
		 }
	 }];
}

- (void)dataTask:(AWSRestrictedURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
	[self.delegateQueue addOperationWithBlock:^
	 {
		 if ([self.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)])
		 {
			 [(id<AWSURLSessionDataDelegate>)self.delegate URLSession:self dataTask:dataTask didReceiveData:data];
		 }
	 }];
}

#pragma mark - AWSRestrictedURLSessionDownloadTaskDelegate

- (void)downloadTask:(AWSRestrictedURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
	[self.delegateQueue addOperationWithBlock:^
	 {
		 [(id<AWSURLSessionDownloadDelegate>)self.delegate URLSession:self downloadTask:downloadTask didFinishDownloadingToURL:location];
	 }];
}

- (void)downloadTask:(AWSRestrictedURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
	[self.delegateQueue addOperationWithBlock:^
	 {
		 [(id<AWSURLSessionDownloadDelegate>)self.delegate URLSession:self downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
	 }];
}

@end
