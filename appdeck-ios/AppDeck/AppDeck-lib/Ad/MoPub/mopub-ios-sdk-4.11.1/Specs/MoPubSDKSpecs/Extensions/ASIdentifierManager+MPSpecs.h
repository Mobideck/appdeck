//
//  ASIdentifierManager+MPSpecs.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <AdSupport/AdSupport.h>

typedef NS_ENUM(NSInteger, MPSpecAdvertisingIdentifierType) {
    MPSpecAdvertisingIdentifierTypeNil = 0,
    MPSpecAdvertisingIdentifierTypeOriginal,    // original ID from advertisingIdentifier method
    MPSpecAdvertisingIdentifierTypeAllZero      // hard coded 00000000-0000-0000-0000-000000000000
};

@interface ASIdentifierManager (MPSpecs)

+ (void)useAdvertisingIdentifierType:(MPSpecAdvertisingIdentifierType)type;

@end
