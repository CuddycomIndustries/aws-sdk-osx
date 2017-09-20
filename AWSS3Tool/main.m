//
//  main.m
//  AWSS3Tool
//
//  Created by Vitaly Afanasyev on 8/16/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSCredentialsProvider.h"
#import "AWSS3Service.h"
#import "AWSS3TransferManager.h"
#import "AWSExecutor.h"

static NSString * const kAWSS3ToolUsageString = @"Usage:\n"
@"AWSS3Tool --upload -sourceFile <path> -bucket <bucket> -key <key> -accessKey <accessKey> -secretKey <secretKey>\n"
@"AWSS3Tool --download -bucket <bucket> -key <key> -accessKey <accessKey> -secretKey <secretKey>\n\n";

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		NSArray *arguments = [[NSProcessInfo processInfo] arguments];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *accessKey = [defaults stringForKey:@"accessKey"];
		NSString *secretKey = [defaults stringForKey:@"secretKey"];
		NSString *key = [defaults stringForKey:@"key"];
		NSString *bucket = [defaults stringForKey:@"bucket"];
		
		if (accessKey != nil && secretKey != nil && key != nil && bucket != nil)
		{
			AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
			AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
			[AWSServiceManager defaultServiceManager].defaultServiceConfiguration = serviceConfiguration;
			
			BOOL shouldUpload = [arguments containsObject:@"--upload"];
			BOOL shouldDownload  = !shouldUpload && [arguments containsObject:@"--download"];
			
			if (shouldUpload)
			{
				NSString *sourceFile = [defaults stringForKey:@"sourceFile"];
				if (sourceFile != nil)
				{
					AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
					AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
					uploadRequest.bucket = bucket;
					uploadRequest.key = key;
					uploadRequest.body = [NSURL fileURLWithPath:sourceFile];
					AWSTask *upload = [transferManager upload:uploadRequest];
					__block BOOL uploading = YES;
					NSLog(@"Start uploading...");
					[upload continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task)
					{
						if (task.result)
						{
							NSLog(@"Upload complete.");
						}
						else
						{
							NSError *taskError = task.error;
							if (taskError)
							{
								NSLog(@"Upload error - %@", taskError);
							}
						}

						uploading = NO;
						return nil;
					}];
					
					NSRunLoop *currentRunLoop = NSRunLoop.currentRunLoop;
					while (uploading)
					{
						[currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture];
					}
				}
				else
				{
					NSLog(@"%@", kAWSS3ToolUsageString);
				}
			}
			else if (shouldDownload)
			{
				AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
				AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
				downloadRequest.bucket = bucket;
				downloadRequest.key = key;
				AWSTask *download = [transferManager download:downloadRequest];
				__block BOOL downloading = YES;
				NSLog(@"Start downloading...");
				[download continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task)
				{
					if (task.result)
					{
						NSLog(@"Download complete. Target path - %@", [[task.result body] path]);
					}
					else
					{
						NSError *taskError = task.error;
						if (taskError)
						{
							NSLog(@"Download error - %@", taskError);
						}
					}
					
					downloading = NO;
					return nil;
				}];
				
				NSRunLoop *currentRunLoop = NSRunLoop.currentRunLoop;
				while (downloading)
				{
					[currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture];
				}
			}
			else
			{
				NSLog(@"%@", kAWSS3ToolUsageString);
			}
		}
		else
		{
			NSLog(@"%@", kAWSS3ToolUsageString);
		}
		
	}
	return 0;
}
