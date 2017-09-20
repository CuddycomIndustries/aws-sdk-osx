//
//  AWSJSONExtensions.h
//  AWSCore
//
//  Created by Vitaly Afanasyev on 8/8/17.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

// Following methods must be implemented by third-parties and should be accessable in runtime for compatibility with 10.6

#ifndef AWSJSONExtensions_h
#define AWSJSONExtensions_h

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary(JSON)

+ (nullable NSDictionary *)dictionaryWithJSONString:(nullable NSString *)jsonString;
+ (nullable NSDictionary *)dictionaryWithJSONStringIgnoringNulls:(nullable NSString *)jsonString;
- (NSString *)JSONString;

@end

@interface NSArray(JSON)

+ (nullable NSArray *)arrayWithJSONString:(nullable NSString *)jsonString;
+ (nullable NSArray *)arrayWithJSONStringIgnoringNulls:(nullable NSString *)jsonString;
- (NSString *)JSONString;

@end

@interface NSString (JSON)

- (NSString *)JSONString;

@end

@interface NSNumber(JSON)

- (NSString *)JSONString;

@end

@protocol JSONSerialization

- (NSString *)JSONString;

@end

NS_ASSUME_NONNULL_END

#endif /* AWSJSONExtensions_h */
