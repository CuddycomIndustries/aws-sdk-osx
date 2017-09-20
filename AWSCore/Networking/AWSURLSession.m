//
//  AWSURLSession.m
//  AWSS3
//
//  Created by Vitaly Afanasyev on 8/7/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import "AWSURLSession.h"
#import "AWSSystemInfo.h"
#import "AWSRestrictedURLSessionTask.h"
#import "AWSURLSessionConfiguration.h"
#import "AWSRestrictedURLSession.h"
#import <stdlib.h>

@interface NSURLSession (AWSNetwork) <AWSURLSession>

@end

@interface AWSURLSession ()

@property (readonly, retain) id<AWSURLSession> internalSession;

@end

@implementation AWSURLSession

@synthesize internalSession = _internalSession;

+ (instancetype)sessionWithConfiguration:(AWSURLSessionConfiguration *)configuration delegate:(nullable id <AWSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue
{
	return [[self alloc] initWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

- (instancetype)initWithConfiguration:(AWSURLSessionConfiguration *)configuration delegate:(nullable id <AWSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue
{
	self = [super init];
	
	if (self != nil)
	{
		if (AWSSystemInfo.isMavericksOrGreater)
		{
			NSURLSessionConfiguration *sessionConfiguration = nil;
			NSString *identifier = configuration.identifier;
			if (identifier)
			{
				if ([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)])
				{
					sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
				}
				else
				{
					sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
				}
			}
			else
			{
				[NSURLSessionConfiguration defaultSessionConfiguration];
			}
			
			sessionConfiguration.URLCache = configuration.URLCache;
			
			if (configuration.timeoutIntervalForRequest > 0)
			{
				sessionConfiguration.timeoutIntervalForRequest = configuration.timeoutIntervalForRequest;
			}
			
			if (configuration.timeoutIntervalForResource > 0)
			{
				sessionConfiguration.timeoutIntervalForResource = configuration.timeoutIntervalForResource;
			}

			_internalSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:(id<NSURLSessionDelegate>)delegate delegateQueue:queue];
		}
		else
		{
			_internalSession = [AWSRestrictedURLSession sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
		}
	}
	return self;
}

- (id<AWSURLSessionDelegate>)delegate
{
	return self.internalSession.delegate;
}

- (NSOperationQueue *)delegateQueue
{
	return self.internalSession.delegateQueue;
}

- (id<AWSURLSessionConfiguration>)configuration
{
	return self.internalSession.configuration;
}

- (id<AWSURLSessionUploadTask>)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL
{
	return [self.internalSession uploadTaskWithRequest:request fromFile:fileURL];
}

- (void)finishTasksAndInvalidate
{
	[self.internalSession finishTasksAndInvalidate];
}

- (id<AWSURLSessionDataTask>)dataTaskWithRequest:(NSURLRequest *)request
{
	return [self.internalSession dataTaskWithRequest:request];
}

- (id<AWSURLSessionDownloadTask>)downloadTaskWithRequest:(NSURLRequest *)request
{
	return [self.internalSession downloadTaskWithRequest:request];
}

- (void)getTasksWithCompletionHandler:(void (^)(NSArray<id<AWSURLSessionDataTask>> * _Nonnull, NSArray<id<AWSURLSessionUploadTask>> * _Nonnull, NSArray<id<AWSURLSessionDownloadTask>> * _Nonnull))completionHandler
{
	[self.internalSession getTasksWithCompletionHandler:completionHandler];
}

@end
