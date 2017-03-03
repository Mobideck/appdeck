//
//  NSURLConnection+MPSpecs.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (MPSpecs)

+ (NSURLConnection *)lastConnection;
+ (void)spoofSendSynchronousRequestWithResponse:(NSHTTPURLResponse *)response;
+ (void)sendSynchronousRequestsNormally;
- (void)receiveSuccessfulResponse:(NSString *)body;
- (void)receiveResponseWithStatusCode:(int)code body:(NSString *)body;

@end
