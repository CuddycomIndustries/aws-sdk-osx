//
//  AWSURLSessionTask.m
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/15/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import "AWSRestrictedURLSessionTask.h"
#import "AWSSystemInfo.h"

@interface AWSRestrictedURLSessionTask ()<NSURLConnectionDelegate>


@property (readonly, retain) NSURLConnection *connection;
@property (copy) NSURLResponse *response;
@property (assign) AWSURLSessionTaskState state;
@property (copy) NSURLRequest *currentRequest;

@end

@interface AWSRestrictedURLSessionDataTask ()

@property (assign) id<AWSRestrictedURLSessionDataTaskDelegate> delegate;

@end

@interface AWSRestrictedURLSessionDownloadTask ()

@property (assign) id<AWSRestrictedURLSessionDownloadTaskDelegate> delegate;

@end

@implementation AWSRestrictedURLSessionTask

@synthesize currentRequest = _currentRequest;

- (instancetype)initWithRequest:(NSURLRequest *)request
{
	self = [super init];
	
	if (self != nil)
	{
		_state = AWSURLSessionTaskStateSuspended;
		_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	}
	
	return self;
}

- (void)dealloc
{
	if (_state == AWSURLSessionTaskStateRunning)
	{
		[_connection unscheduleFromRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];
		[_connection cancel];
	}
}

- (NSURLRequest *)originalRequest
{
	NSURLConnection *connection = self.connection;
	return AWSSystemInfo.isMountainLionOrGreater ? connection.originalRequest : self.currentRequest;
}

- (NSURLRequest *)currentRequest
{
	return AWSSystemInfo.isMountainLionOrGreater ? self.connection.currentRequest : _currentRequest;
}

- (void)setCurrentRequest:(NSURLRequest *)currentRequest
{
	@synchronized (self)
	{
		if (!AWSSystemInfo.isMountainLionOrGreater && currentRequest != _currentRequest)
		{
			_currentRequest = [currentRequest copy];
		}
	}
}

- (void)cancel
{
	[self.connection cancel];
	self.state = AWSURLSessionResponseCancel;
}

- (void)resume
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
				   {
					   NSRunLoop *runLoop = NSRunLoop.currentRunLoop;
					   [self.connection scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
					   [self.connection start];
					   self.state = AWSURLSessionTaskStateRunning;
					   
					   while (self.state == AWSURLSessionTaskStateRunning)
					   {
						   [runLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture];
					   }
				   });
}

- (void)suspend
{
	
}

#pragma mark - NSURLConnectionDelegate

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
	self.currentRequest = request;
	return request;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
	return NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return YES;
}

- (nullable NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.response = response;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.state = AWSURLSessionTaskStateCompleted;
	[self.delegate task:self didCompleteWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.state = AWSURLSessionTaskStateCompleted;
	[self.delegate task:self didCompleteWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	[self.delegate task:self didSendBodyData:bytesWritten totalBytesSent:totalBytesWritten];
}

@end

@implementation AWSRestrictedURLSessionUploadTask

@end

@implementation AWSRestrictedURLSessionDataTask

@dynamic delegate;

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[super connection:connection didReceiveResponse:response];
	
	[self.delegate dataTask:self didReceiveResponse:response completionHandler:^(AWSURLSessionResponseDisposition disposition)
	 {
		 // AWSURLSession currenlty supports only AWSURLSessionResponseAllow disposition value in completion handler
		 NSParameterAssert(disposition == AWSURLSessionResponseAllow);
	 }];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.delegate dataTask:self didReceiveData:data];
}

@end

@implementation AWSRestrictedURLSessionDownloadTask

@dynamic delegate;

#pragma mark - NSURLConnectionDelegate

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
	self.state = AWSURLSessionTaskStateCompleted;
	[self.delegate downloadTask:self didFinishDownloadingToURL:destinationURL];
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
	[self.delegate downloadTask:self didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:expectedTotalBytes];
}

@end

