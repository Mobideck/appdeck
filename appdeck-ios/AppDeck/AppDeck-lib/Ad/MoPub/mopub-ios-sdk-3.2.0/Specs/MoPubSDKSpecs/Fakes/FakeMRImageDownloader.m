//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMRImageDownloader.h"

@implementation FakeMRImageDownloader

@synthesize willSucceed = _willSucceed;

- (void)downloadImageWithURL:(NSURL *)URL
{
    if (!self.willSucceed) {
        [self.delegate downloaderDidFailToSaveImageWithURL:nil error:nil];
    }
}

@end
