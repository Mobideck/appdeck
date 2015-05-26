//
//  MRBundleManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRBundleManagerMF : NSObject

+ (MRBundleManagerMF *)sharedManager;
- (NSString *)mraidPath;

@end
