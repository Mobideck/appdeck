//
//  MpLoggingMF.h
//  MoPub
//
//  Created by Andrew He on 2/10/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPConstantsMF.h"

// Lower = finer-grained logs.
typedef enum
{
    MPLogLevelAll        = 0,
    MPLogLevelTrace        = 10,
    MPLogLevelDebug        = 20,
    MPLogLevelInfo        = 30,
    MPLogLevelWarn        = 40,
    MPLogLevelError        = 50,
    MPLogLevelFatal        = 60,
    MPLogLevelOff        = 70
} MPLogLevelMF;

MPLogLevelMF MPLogGetLevelMF(void);
void MPLogSetLevelMF(MPLogLevelMF level);
void _MPLogTraceMF(NSString *format, ...);
void _MPLogDebugMF(NSString *format, ...);
void _MPLogInfoMF(NSString *format, ...);
void _MPLogWarnMF(NSString *format, ...);
void _MPLogErrorMF(NSString *format, ...);
void _MPLogFatalMF(NSString *format, ...);

#if MP_DEBUG_MODE && !SPECS

#define MPLogTraceMF(...) _MPLogTraceMF(__VA_ARGS__)
#define MPLogDebugMF(...) _MPLogDebugMF(__VA_ARGS__)
#define MPLogInfoMF(...) _MPLogInfoMF(__VA_ARGS__)
#define MPLogWarnMF(...) _MPLogWarnMF(__VA_ARGS__)
#define MPLogErrorMF(...) _MPLogErrorMF(__VA_ARGS__)
#define MPLogFatalMF(...) _MPLogFatalMF(__VA_ARGS__)

#else

#define MPLogTraceMF(...) {}
#define MPLogDebugMF(...) {}
#define MPLogInfoMF(...) {}
#define MPLogWarnMF(...) {}
#define MPLogErrorMF(...) {}
#define MPLogFatalMF(...) {}

#endif
