//
//  FakeUIDevice.m
//  MoPub
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "FakeUIDevice.h"

@implementation FakeUIDevice

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userInterfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    }
    return self;
}

@end
