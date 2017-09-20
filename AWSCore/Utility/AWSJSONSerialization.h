//
//  AWSJSONSerialization.h
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/8/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, AWSJSONWritingOptions) {
	AWSJSONWritingPrettyPrinted = (1UL << 0)
};

typedef NS_OPTIONS(NSUInteger, AWSJSONReadingOptions) {
	AWSJSONReadingMutableContainers = (1UL << 0),
	AWSJSONReadingMutableLeaves = (1UL << 1),
	AWSJSONReadingAllowFragments = (1UL << 2)
};

/*!
 \brief Wrapper over system \c NSJSONSerialization class, that supports 10.6. Reading and writing otions have effect only for 10.7 and higher.
 */
@interface AWSJSONSerialization : NSObject

+ (nullable NSData *)dataWithJSONObject:(id)obj options:(AWSJSONWritingOptions)opt error:(NSError **)error;
+ (nullable id)JSONObjectWithData:(NSData *)data options:(AWSJSONReadingOptions)opt error:(NSError **)error;

+ (BOOL)isValidJSONObject:(id)obj;

@end

NS_ASSUME_NONNULL_END
