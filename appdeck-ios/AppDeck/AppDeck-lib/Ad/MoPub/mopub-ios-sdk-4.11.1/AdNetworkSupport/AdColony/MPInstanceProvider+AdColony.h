//
//  MPInstanceProvider+AdColony.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

/*
 * An extension of MPInstanceProvider to create the MPAdColonyRouter.
 */
@class MPAdColonyRouter;

@interface MPInstanceProvider (AdColony)

- (MPAdColonyRouter *)sharedMPAdColonyRouter;

@end
