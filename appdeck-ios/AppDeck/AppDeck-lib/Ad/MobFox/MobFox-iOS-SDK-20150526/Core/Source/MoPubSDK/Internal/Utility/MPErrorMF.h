//
//  MPAdRequestError.h
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kLaunchpageHeaderKeyMFMF;

typedef enum {
    MPErrorNoInventory = 0,
    MPErrorNetworkTimedOut = 4,
    MPErrorServerError = 8,
    MPErrorAdapterNotFound = 16,
    MPErrorAdapterInvalid = 17,
    MPErrorAdapterHasNoInventory = 18
} MPErrorCode;

@interface MPErrorMF : NSError

+ (MPErrorMF *)errorWithCode:(MPErrorCode)code;

@end
