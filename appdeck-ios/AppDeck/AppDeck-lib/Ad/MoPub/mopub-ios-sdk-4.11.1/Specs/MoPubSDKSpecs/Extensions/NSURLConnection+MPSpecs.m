//
//  NSURLConnection+MPSpecs.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "NSURLConnection+MPSpecs.h"
#import <objc/runtime.h>

static char ASSOCIATED_SYNCHRONOUS_RESPONSE_KEY;
static BOOL SPOOF_SYNCHRONOUS_REQUEST;

//@interface NSURLConnection ()
//
//+ (NSData *)originalSendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;
//
//@end

@implementation NSURLConnection (MPSpecs)

+(void)load
{
    Method original, swizzled;

    original = class_getClassMethod(self, @selector(sendSynchronousRequest:returningResponse:error:));
    swizzled = class_getClassMethod(self, @selector(mpc_sendSynchronousRequest:returningResponse:error:));
    method_exchangeImplementations(original, swizzled);
}

+ (NSURLConnection *)lastConnection
{
    return [[NSURLConnection connections] lastObject];
}

- (void)receiveSuccessfulResponse:(NSString *)body
{
    PSHKFakeHTTPURLResponse *response = [[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:200
                                                                                  andHeaders:nil
                                                                                     andBody:body];
    [self receiveResponse:response];
}

- (void)receiveResponseWithStatusCode:(int)code body:(NSString *)body
{
    PSHKFakeHTTPURLResponse *response = [[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:code
                                                                                  andHeaders:nil
                                                                                     andBody:body];
    [self receiveResponse:response];
}

#pragma mark - Synchronous Network Requests
+ (void)spoofSendSynchronousRequestWithResponse:(NSHTTPURLResponse *)response
{
    objc_setAssociatedObject(self, &ASSOCIATED_SYNCHRONOUS_RESPONSE_KEY, response, OBJC_ASSOCIATION_RETAIN);
    SPOOF_SYNCHRONOUS_REQUEST = YES;
}

+ (void)sendSynchronousRequestsNormally
{
    SPOOF_SYNCHRONOUS_REQUEST = NO;
}

+ (NSData *)mpc_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    if(SPOOF_SYNCHRONOUS_REQUEST) {
        *response = objc_getAssociatedObject(self, &ASSOCIATED_SYNCHRONOUS_RESPONSE_KEY);
        return [NSData data];
    } else {
        return [NSURLConnection mpc_sendSynchronousRequest:request returningResponse:response error:error];
    }
}


@end
