//
//  ASIdentifierManager+MPAdditions.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "ASIdentifierManager+MPAdditions.h"

@implementation ASIdentifierManager (MPAdditions)

// Spoof the advertising identifier so InMobi test ads work. Typically we have to register
// a device in their configuration dashboard, but this allows us to skip that step in testing.

- (NSUUID *)advertisingIdentifier
{
    return [[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"];
}

@end
