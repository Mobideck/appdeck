//
//  MPSampleAppLogReader.m
//  MoPubSampleApp
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPSampleAppLogReader.h"
#import "MPLogProvider.h"

@interface MPSampleAppLogReader () <MPLogger, UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *warmingUpAlertView;

@end

@implementation MPSampleAppLogReader

+ (MPSampleAppLogReader *)sharedLogReader
{
    static dispatch_once_t once;
    static MPSampleAppLogReader *sharedLogReader;
    dispatch_once(&once, ^{
        sharedLogReader = [[self alloc] init];
    });

    return sharedLogReader;
}

- (void)dealloc
{
    [[MPLogProvider sharedLogProvider] removeLogger:self];
}

- (void)beginReadingLogMessages
{
    [[MPLogProvider sharedLogProvider] removeLogger:self];
    [[MPLogProvider sharedLogProvider] addLogger:self];
}

#pragma mark - <MPLogger>

- (MPLogLevel)logLevel
{
    return MPLogLevelAll;
}

- (void)logMessage:(NSString *)message
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[kMPWarmingUpErrorLogFormatWithAdUnitID stringByReplacingOccurrencesOfString:@"%@" withString:@".*"]
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];

    if (self.warmingUpAlertView == nil && [regex numberOfMatchesInString:message options:0 range:NSMakeRange(0, message.length)] > 0) {
        self.warmingUpAlertView = [[UIAlertView alloc] initWithTitle:@"Warming Up"
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [self.warmingUpAlertView show];
    }
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.warmingUpAlertView = nil;
}


@end
