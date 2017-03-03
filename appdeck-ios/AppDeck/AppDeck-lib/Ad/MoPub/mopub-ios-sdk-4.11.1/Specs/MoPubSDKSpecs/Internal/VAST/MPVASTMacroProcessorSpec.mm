#import "MPVASTMacroProcessor.h"
#import "NSURL+MPAdditions.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPVASTMacroProcessorSpec)

describe(@"MPVASTMacroProcessor", ^{
    __block NSRegularExpression *cachebusterRegex;

    beforeEach(^{
        cachebusterRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d{8}" options:0 error:nil];
    });

    context(@"expanding the [ERRORCODE] macro", ^{
        __block NSURL *originalURL;

        beforeEach(^{
            originalURL = [NSURL URLWithString:@"http://www.hello.com?world=[ERRORCODE]"];
        });

        it(@"should not expand if a nil error code is provided", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil];
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=%5BERRORCODE%5D");
        });

        it(@"should not expand if an empty error code is provided", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:@"  "];
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=%5BERRORCODE%5D");
        });

        it(@"should expand if a valid error code is provided", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:@"900"];
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=900");
        });
    });

    context(@"expanding the [CONTENTPLAYHEAD] macro", ^{
        __block NSURL *originalURL;

        beforeEach(^{
            originalURL = [NSURL URLWithString:@"http://www.hello.com?world=[CONTENTPLAYHEAD]"];
        });

        it(@"should not expand when calling +macroExpandedURLForURL:errorCode:", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil];
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=%5BCONTENTPLAYHEAD%5D");
        });

        it(@"should not expand when a negative time offset is provided", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil videoTimeOffset:-6 videoAssetURL:nil];
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=%5BCONTENTPLAYHEAD%5D");
        });

        it(@"should expand if a positive time offset is provided", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil videoTimeOffset:7555.12345 videoAssetURL:nil];
            // HH:MM:SS.mmm
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=02:05:55.123");
        });
    });

    context(@"expanding the [ASSETURI] macro", ^{
        __block NSURL *originalURL;

        beforeEach(^{
            originalURL = [NSURL URLWithString:@"http://www.hello.com?world=[ASSETURI]"];
        });

        it(@"should not expand when calling +macroExpandedURLForURL:errorCode:", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil];
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=%5BASSETURI%5D");
        });

        it(@"should not expand when a nil asset URL is provided", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil videoTimeOffset:-6 videoAssetURL:nil];
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=%5BASSETURI%5D");
        });

        it(@"should expand if a valid asset URL is provided", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil videoTimeOffset:-6 videoAssetURL:[NSURL URLWithString:@"http://www.twitter.com"]];
            [expandedURL absoluteString] should equal(@"http://www.hello.com?world=http%3A%2F%2Fwww.twitter.com");
        });
    });

    context(@"expanding the [CACHEBUSTING] macro", ^{
        __block NSURL *originalURL;

        beforeEach(^{
            originalURL = [NSURL URLWithString:@"http://www.hello.com?world=[CACHEBUSTING]"];
        });

        it(@"should expand when calling +macroExpandedURLForURL:errorCode:", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil];
            NSString *cachebuster = [expandedURL mp_queryParameterForKey:@"world"];
            NSArray *matches = [cachebusterRegex matchesInString:cachebuster options:0 range:NSMakeRange(0, [cachebuster length])];
            NSTextCheckingResult *match = matches[0];
            match.range should equal(NSMakeRange(0, [cachebuster length]));
        });

        it(@"should expand when calling +macroExpandedURLForURL:errorCode:videoTimeOffset:videoAssetURL:", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:nil videoTimeOffset:-6 videoAssetURL:nil];
            NSString *cachebuster = [expandedURL mp_queryParameterForKey:@"world"];
            NSArray *matches = [cachebusterRegex matchesInString:cachebuster options:0 range:NSMakeRange(0, [cachebuster length])];
            NSTextCheckingResult *match = matches[0];
            match.range should equal(NSMakeRange(0, [cachebuster length]));
        });
    });

    context(@"expanding multiple macros", ^{
        __block NSURL *originalURL;

        beforeEach(^{
            originalURL = [NSURL URLWithString:@"http://www.hello.com?error=[ERRORCODE]&playhead=[CONTENTPLAYHEAD]&cachebuster=[CACHEBUSTING]&asset=[ASSETURI]"];
        });

        it(@"should expand properly", ^{
            NSURL *expandedURL = [MPVASTMacroProcessor macroExpandedURLForURL:originalURL errorCode:@"369" videoTimeOffset:4200 videoAssetURL:[NSURL URLWithString:@"http://www.mopub.com?query=param"]];
            [expandedURL mp_queryParameterForKey:@"error"] should equal(@"369");
            [expandedURL mp_queryParameterForKey:@"playhead"] should equal(@"01:10:00.000");

            NSString *cachebuster = [expandedURL mp_queryParameterForKey:@"cachebuster"];
            NSArray *matches = [cachebusterRegex matchesInString:cachebuster options:0 range:NSMakeRange(0, [cachebuster length])];
            NSTextCheckingResult *match = matches[0];
            match.range should equal(NSMakeRange(0, [cachebuster length]));

            [expandedURL mp_queryParameterForKey:@"asset"] should equal(@"http://www.mopub.com?query=param");
        });
    });
});

SPEC_END
