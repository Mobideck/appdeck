#import "MPLogProvider.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPLogProviderSpec)

describe(@"MPLogProvider", ^{
    __block NSString *logMessage;

    beforeEach(^{
        logMessage = @"Log Message";
    });

    describe(@"Adding and removing a Logger", ^{
        __block id <MPLogger, CedarDouble> fakeLogger;

        beforeEach(^{
            fakeLogger = nice_fake_for(@protocol(MPLogger));
            fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelAll);
        });

        afterEach(^{
            [[MPLogProvider sharedLogProvider] removeLogger:fakeLogger];
        });

        it(@"should not send messages to a logger that hasn't been added to its loggers", ^{
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
            fakeLogger should_not have_received(@selector(logMessage:));
        });

        it(@"should send all messages to added loggers", ^{
            [[MPLogProvider sharedLogProvider] addLogger:fakeLogger];
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
            fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
        });

        it(@"should not send any log messages to loggers after they're removed", ^{
            [[MPLogProvider sharedLogProvider] addLogger:fakeLogger];
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
            fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            [fakeLogger reset_sent_messages];

            [[MPLogProvider sharedLogProvider] removeLogger:fakeLogger];
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
            fakeLogger should_not have_received(@selector(logMessage:));
        });
    });

    describe(@"testing different log levels", ^{
        __block id <MPLogger, CedarDouble> fakeLogger;
        __block NSString *logMessage;

        beforeEach(^{
            fakeLogger = nice_fake_for(@protocol(MPLogger));
            [[MPLogProvider sharedLogProvider] addLogger:fakeLogger];
            logMessage = @"Log Message";
        });

        afterEach(^{
            [[MPLogProvider sharedLogProvider] removeLogger:fakeLogger];
        });

        context(@"when the logger is Log Level All", ^{
            beforeEach(^{
                fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelAll);
            });

            it(@"should pass the message to the logger for Trace", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Debug", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Info", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Warn", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Error", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Fatal", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });
        });

        context(@"when the logger is Log Level Trace", ^{
            beforeEach(^{
                fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelTrace);
            });

            it(@"should pass the message to the logger for Trace", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Debug", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Info", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Warn", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Error", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Fatal", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });
        });

        context(@"when the logger is Log Level Debug", ^{
            beforeEach(^{
                fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelDebug);
            });

            it(@"should not pass the message to the logger for Trace", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Debug", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Info", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Warn", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Error", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Fatal", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });
        });

        context(@"when the logger is Log Level Info", ^{
            beforeEach(^{
                fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelInfo);
            });

            it(@"should not pass the message to the logger for Trace", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Debug", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Info", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Warn", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Error", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Fatal", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });
        });

        context(@"when the logger is Log Level Warn", ^{
            beforeEach(^{
                fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelWarn);
            });

            it(@"should not pass the message to the logger for Trace", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Debug", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Info", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Warn", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Error", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Fatal", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });
        });

        context(@"when the logger is Log Level Error", ^{
            beforeEach(^{
                fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelError);
            });

            it(@"should not pass the message to the logger for Trace", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Debug", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Info", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Warn", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Error", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Fatal", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });
        });

        context(@"when the logger is Log Level Fatal", ^{
            beforeEach(^{
                fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelFatal);
            });

            it(@"should not pass the message to the logger for Trace", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Debug", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Info", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Warn", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Error", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should pass the message to the logger for Fatal", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
                fakeLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            });
        });

        context(@"when the logger is Log Level Off", ^{
            beforeEach(^{
                fakeLogger stub_method(@selector(logLevel)).and_return(MPLogLevelOff);
            });

            it(@"should not pass the message to the logger for Trace", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Debug", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Info", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Warn", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Error", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });

            it(@"should not pass the message to the logger for Fatal", ^{
                [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
                fakeLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            });
        });
    });

    describe(@"testing multiple loggers", ^{
        __block id<MPLogger, CedarDouble> fakeAllLogger;
        __block id<MPLogger, CedarDouble> fakeTraceLogger;
        __block id<MPLogger, CedarDouble> fakeDebugLogger;
        __block id<MPLogger, CedarDouble> fakeInfoLogger;
        __block id<MPLogger, CedarDouble> fakeWarnLogger;
        __block id<MPLogger, CedarDouble> fakeErrorLogger;
        __block id<MPLogger, CedarDouble> fakeFatalLogger;
        __block id<MPLogger, CedarDouble> fakeOffLogger;

        beforeEach(^{
            fakeAllLogger = nice_fake_for(@protocol(MPLogger));
            fakeAllLogger stub_method(@selector(logLevel)).and_return(MPLogLevelAll);
            [[MPLogProvider sharedLogProvider] addLogger:fakeAllLogger];

            fakeTraceLogger = nice_fake_for(@protocol(MPLogger));
            fakeTraceLogger stub_method(@selector(logLevel)).and_return(MPLogLevelTrace);
            [[MPLogProvider sharedLogProvider] addLogger:fakeTraceLogger];

            fakeDebugLogger = nice_fake_for(@protocol(MPLogger));
            fakeDebugLogger stub_method(@selector(logLevel)).and_return(MPLogLevelDebug);
            [[MPLogProvider sharedLogProvider] addLogger:fakeDebugLogger];

            fakeInfoLogger = nice_fake_for(@protocol(MPLogger));
            fakeInfoLogger stub_method(@selector(logLevel)).and_return(MPLogLevelInfo);
            [[MPLogProvider sharedLogProvider] addLogger:fakeInfoLogger];

            fakeWarnLogger = nice_fake_for(@protocol(MPLogger));
            fakeWarnLogger stub_method(@selector(logLevel)).and_return(MPLogLevelWarn);
            [[MPLogProvider sharedLogProvider] addLogger:fakeWarnLogger];

            fakeErrorLogger = nice_fake_for(@protocol(MPLogger));
            fakeErrorLogger stub_method(@selector(logLevel)).and_return(MPLogLevelError);
            [[MPLogProvider sharedLogProvider] addLogger:fakeErrorLogger];

            fakeFatalLogger = nice_fake_for(@protocol(MPLogger));
            fakeFatalLogger stub_method(@selector(logLevel)).and_return(MPLogLevelFatal);
            [[MPLogProvider sharedLogProvider] addLogger:fakeFatalLogger];

            fakeOffLogger = nice_fake_for(@protocol(MPLogger));
            fakeOffLogger stub_method(@selector(logLevel)).and_return(MPLogLevelOff);
            [[MPLogProvider sharedLogProvider] addLogger:fakeOffLogger];
        });

        afterEach(^{
            [[MPLogProvider sharedLogProvider] removeLogger:fakeAllLogger];
            [[MPLogProvider sharedLogProvider] removeLogger:fakeTraceLogger];
            [[MPLogProvider sharedLogProvider] removeLogger:fakeDebugLogger];
            [[MPLogProvider sharedLogProvider] removeLogger:fakeInfoLogger];
            [[MPLogProvider sharedLogProvider] removeLogger:fakeWarnLogger];
            [[MPLogProvider sharedLogProvider] removeLogger:fakeErrorLogger];
            [[MPLogProvider sharedLogProvider] removeLogger:fakeFatalLogger];
            [[MPLogProvider sharedLogProvider] removeLogger:fakeOffLogger];
        });

        it(@"should send callbacks to appropriate loggers for a trace log", ^{
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelTrace];
            fakeAllLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeTraceLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeDebugLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeInfoLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeWarnLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeErrorLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeFatalLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeOffLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
        });

        it(@"should send callbacks to appropriate loggers for a debug log", ^{
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelDebug];
            fakeAllLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeTraceLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeDebugLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeInfoLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeWarnLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeErrorLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeFatalLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeOffLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
        });

        it(@"should send callbacks to appropriate loggers for an info log", ^{
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelInfo];
            fakeAllLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeTraceLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeDebugLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeInfoLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeWarnLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeErrorLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeFatalLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeOffLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
        });

        it(@"should send callbacks to appropriate loggers for a warn log", ^{
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelWarn];
            fakeAllLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeTraceLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeDebugLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeInfoLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeWarnLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeErrorLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeFatalLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeOffLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
        });

        it(@"should send callbacks to appropriate loggers for an error log", ^{
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelError];
            fakeAllLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeTraceLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeDebugLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeInfoLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeWarnLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeErrorLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeFatalLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
            fakeOffLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
        });

        it(@"should send callbacks to appropriate loggers for a fatal log", ^{
            [[MPLogProvider sharedLogProvider] logMessage:logMessage atLogLevel:MPLogLevelFatal];
            fakeAllLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeTraceLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeDebugLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeInfoLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeWarnLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeErrorLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeFatalLogger should have_received(@selector(logMessage:)).with(@"Log Message");
            fakeOffLogger should_not have_received(@selector(logMessage:)).with(@"Log Message");
        });
    });
});

SPEC_END
