//
//  MPLogging.m
//  MoPub
//
//  Created by Andrew He on 2/10/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MpLoggingMF.h"
#import "MPIdentityProviderMF.h"

static MPLogLevelMF MPLOG_LEVEL = MPLogLevelInfo;

MPLogLevelMF MPLogGetLevelMF()
{
    return MPLOG_LEVEL;
}

void MPLogSetLevelMF(MPLogLevelMF level)
{
    MPLOG_LEVEL = level;
}

void _MPLogMF(NSString *format, va_list args)
{
    static NSString *sIdentifier;
    static NSString *sObfuscatedIdentifier;

    if (!sIdentifier) {
        sIdentifier = [[MPIdentityProviderMF identifier] copy];
    }

    if (!sObfuscatedIdentifier) {
        sObfuscatedIdentifier = [[MPIdentityProviderMF obfuscatedIdentifier] copy];
    }

    NSString *logString = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];

    // Replace identifier with a obfuscated version when logging.
    logString = [logString stringByReplacingOccurrencesOfString:sIdentifier withString:sObfuscatedIdentifier];

    NSLog(@"%@", logString);
}

void _MPLogTraceMF(NSString *format, ...)
{
    if (MPLOG_LEVEL <= MPLogLevelTrace)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _MPLogMF(format, args);
        va_end(args);
    }
}

void _MPLogDebugMF(NSString *format, ...)
{
    if (MPLOG_LEVEL <= MPLogLevelDebug)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _MPLogMF(format, args);
        va_end(args);
    }
}

void _MPLogWarnMF(NSString *format, ...)
{
    if (MPLOG_LEVEL <= MPLogLevelWarn)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _MPLogMF(format, args);
        va_end(args);
    }
}

void _MPLogInfoMF(NSString *format, ...)
{
    if (MPLOG_LEVEL <= MPLogLevelInfo)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _MPLogMF(format, args);
        va_end(args);
    }
}

void _MPLogErrorMF(NSString *format, ...)
{
    if (MPLOG_LEVEL <= MPLogLevelError)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _MPLogMF(format, args);
        va_end(args);
    }
}

void _MPLogFatalMF(NSString *format, ...)
{
    if (MPLOG_LEVEL <= MPLogLevelFatal)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _MPLogMF(format, args);
        va_end(args);
    }
}
