#import "MPURLResolver.h"
#import "NSURL+MPAdditions.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPURLResolver (Spec)

- (NSStringEncoding)stringEncodingFromContentType:(NSString *)contentType;
- (MPURLActionInfo *)actionInfoFromURL:(NSURL *)URL error:(NSError **)error;

@end

SPEC_BEGIN(MPURLResolverSpec)

describe(@"MPURLResolver", ^{
    __block MPURLResolver *urlResolver;
    __block NSURL *url;
    __block MPURLActionInfo *resolvedActionInfo;
    __block NSError *resolverError;

    subjectAction(^{
        urlResolver = [MPURLResolver resolverWithURL:url completion:^(MPURLActionInfo *actionInfo, NSError *error) {
            resolvedActionInfo = actionInfo;
            resolverError = error;
        }];
        [urlResolver start];
    });

    describe(@"when the URL should be opened in an in-app browser", ^{
        context(@"when the scheme is HTTP", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"http://www.google.com/"];
            });

            it(@"should resolve to an info object with the right HTML string and base URL", ^{
                NSString *responseString = @"This is Google!";
                NSURLConnection *lastConnection = [NSURLConnection lastConnection];
                lastConnection.request.URL should equal(url);
                [lastConnection receiveSuccessfulResponse:responseString];

                resolvedActionInfo.actionType should equal(MPURLActionTypeOpenInWebView);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.HTTPResponseString should equal(responseString);
                resolvedActionInfo.webViewBaseURL should equal(url);
            });

            it(@"should make the resolution request using the right user agent", ^{
                NSURLConnection *lastConnection = [NSURLConnection lastConnection];
                [[lastConnection.request allHTTPHeaderFields] objectForKey:@"User-Agent"] should equal([fakeCoreProvider userAgent]);
            });
        });

        context(@"when the scheme is HTTPS", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"https://www.fandango.com/"];
            });

            it(@"should resolve to an info object with the right HTML string and base URL", ^{
                NSString *responseString = @"Secret Movies";
                NSURLConnection *lastConnection = [NSURLConnection lastConnection];
                lastConnection.request.URL should equal(url);
                [lastConnection receiveSuccessfulResponse:responseString];

                resolvedActionInfo.actionType should equal(MPURLActionTypeOpenInWebView);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.HTTPResponseString should equal(responseString);
                resolvedActionInfo.webViewBaseURL should equal(url);
            });

            it(@"should make the resolution request using the right user agent", ^{
                NSURLConnection *lastConnection = [NSURLConnection lastConnection];
                [[lastConnection.request allHTTPHeaderFields] objectForKey:@"User-Agent"] should equal([fakeCoreProvider userAgent]);
            });
        });

        context(@"based on the response's Content-Type header", ^{
            it(@"should figure out the correct string encoding", ^{
                NSString *contentType = @"type=sdlkfjsl; charset=utf-8;";
                NSStringEncoding encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSUTF8StringEncoding);

                contentType = @"type=sdlkfjsl; charset=UTF-8;";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSUTF8StringEncoding);

                contentType = @"type=sdlkfjsl; charset=iso-8859-1;";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSISOLatin1StringEncoding);

                contentType = @"type=sdlkfjsl; charset=windows-1251;";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSWindowsCP1251StringEncoding);

                contentType = @"type=sdlkfjsl; charset=iso-8859-2;";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSISOLatin2StringEncoding);

                contentType = @"type=sdlkfjsl; charset=iso-8859-15;";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                //no constant available for iso-8859-15
                encoding should equal(2147484175);

                contentType = @"type=sdlkfjsl; charset=windows-1252;";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSWindowsCP1252StringEncoding);

                contentType = @"type=sdlkfjsl; charset=us-ascii;";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSASCIIStringEncoding);

                contentType = @"type=sdlkfjsl;";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSUTF8StringEncoding);

                contentType = @"";
                encoding = [urlResolver stringEncodingFromContentType:contentType];
                encoding should equal(NSUTF8StringEncoding);
            });
        });

        describe(@"when there is a problem fetching the contents of the URL", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"https://www.google.com/"];
            });


            it(@"should resolve with an error", ^{
                NSError *error = [NSError errorWithDomain:@"com.mopub" code:500 userInfo:nil];
                [[NSURLConnection lastConnection] failWithError:error];

                resolvedActionInfo should be_nil;
                resolverError should equal(error);
            });
        });
    });

    describe(@"when the URL should be handled by an installed app", ^{
        context(@"when the scheme is tel", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"tel:5555555555"];
            });

            it(@"should resolve to an info object indicating a deeplink", ^{
                resolvedActionInfo.actionType should equal(MPURLActionTypeGenericDeeplink);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.deeplinkURL should equal(url);
            });
        });

        context(@"when the scheme is telprompt", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"telprompt:5555555555"];
            });

            it(@"should resolve to an info object indicating a deeplink", ^{
                resolvedActionInfo.actionType should equal(MPURLActionTypeGenericDeeplink);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.deeplinkURL should equal(url);
            });
        });

        context(@"when the scheme is neither http nor https", ^{
            context(@"when the scheme is mopubnativebrowser://", ^{
                context(@"when the requested URL is well-formed URL", ^{
                    beforeEach(^{
                        url = [NSURL URLWithString:@"mopubnativebrowser://navigate?url=https%3A%2F%2Fwww.google.com"];
                    });

                    it(@"should resolve to an info object indicating a deeplink", ^{
                        [NSURLConnection lastConnection] should be_nil;

                        resolvedActionInfo.actionType should equal(MPURLActionTypeOpenInSafari);
                        resolvedActionInfo.originalURL should equal(url);
                        resolvedActionInfo.safariDestinationURL.absoluteString should equal(@"https://www.google.com");
                    });
                });

                context(@"when the requested URL is not a well-formed URL", ^{
                    beforeEach(^{
                        url = [NSURL URLWithString:@"mopubnativebrowser://navigate?url=åß∂∆"];
                    });

                    it(@"should call the completion block with an error", ^{
                        [NSURLConnection lastConnection] should be_nil;

                        resolvedActionInfo should be_nil;
                        resolverError should_not be_nil;
                    });
                });
            });
        });

        context(@"when the URL points to a map", ^{
            it(@"should resolve to an info object indicating a deeplink", ^{
                // Reset this state because the subject-action block will have executed first.
                [NSURLConnection resetAll];
                resolvedActionInfo = nil;
                resolverError = nil;

                for (NSString *path in @[@"http://maps.google.com/floop?flap", @"http://maps.apple.com/flip?flop", @"http://2.maps.google.com/whatever?hey"]) {
                    url = [NSURL URLWithString:path];
                    urlResolver = [MPURLResolver resolverWithURL:url completion:^(MPURLActionInfo *actionInfo, NSError *error) {
                        resolvedActionInfo = actionInfo;
                        resolverError = error;
                    }];
                    [urlResolver start];

                    [NSURLConnection lastConnection] should be_nil;

                    resolvedActionInfo.actionType should equal(MPURLActionTypeGenericDeeplink);
                    resolvedActionInfo.originalURL should equal(url);
                    resolvedActionInfo.deeplinkURL should equal(url);

                    [NSURLConnection resetAll];
                }
            });
        });
    });

    describe(@"when the URL has a deeplink+:// scheme", ^{
        context(@"if the URL host is 'navigate'", ^{
            context(@"if the query has a primaryUrl", ^{
                context(@"if the query does not have a primaryTrackingUrl", ^{
                    beforeEach(^{
                        url = [NSURL URLWithString:@"deeplink+://navigate?primaryUrl=maps%3A%2F%2F"];
                    });

                    it(@"should resolve to an info object indicating an enhanced deeplink", ^{
                        resolvedActionInfo.actionType should equal(MPURLActionTypeEnhancedDeeplink);
                        resolvedActionInfo.originalURL should equal(url);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryURL should equal([NSURL URLWithString:@"maps://"]);
                    });
                });

                context(@"if the query has a primaryTrackingUrl", ^{
                    beforeEach(^{
                        url = [NSURL URLWithString:@"deeplink+://navigate?primaryUrl=maps%3A%2F%2F&primaryTrackingUrl=http%3A%2F%2Fwww.mopub.com"];
                    });

                    it(@"should resolve to an info object indicating an enhanced deeplink with a tracking URL", ^{
                        resolvedActionInfo.actionType should equal(MPURLActionTypeEnhancedDeeplink);
                        resolvedActionInfo.originalURL should equal(url);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryURL should equal([NSURL URLWithString:@"maps://"]);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryTrackingURLs.count should equal(1);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryTrackingURLs should contain([NSURL URLWithString:@"http://www.mopub.com"]);
                    });
                });

                context(@"if the query has multiple primaryTrackingUrls", ^{
                    beforeEach(^{
                        url = [NSURL URLWithString:@"deeplink+://navigate?primaryUrl=maps%3A%2F%2F&primaryTrackingUrl=http%3A%2F%2Fwww.mopub.com&primaryTrackingUrl=http%3A%2F%2Fwww.twitter.com"];
                    });

                    it(@"should resolve to an info object indicating an enhanced deeplink with multiple tracking URLs", ^{
                        resolvedActionInfo.actionType should equal(MPURLActionTypeEnhancedDeeplink);
                        resolvedActionInfo.originalURL should equal(url);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryURL should equal([NSURL URLWithString:@"maps://"]);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryTrackingURLs.count should equal(2);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryTrackingURLs should contain([NSURL URLWithString:@"http://www.mopub.com"]);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryTrackingURLs should contain([NSURL URLWithString:@"http://www.twitter.com"]);
                    });
                });

                context(@"if the query has a fallbackUrl", ^{
                    beforeEach(^{
                        url = [NSURL URLWithString:@"deeplink+://navigate?primaryUrl=maps%3A%2F%2F&fallbackUrl=http%3A%2F%2Fwww.mopub.com"];
                    });

                    it(@"should resolve to an info object indicating an enhanced deeplink with a fallback URL", ^{
                        resolvedActionInfo.actionType should equal(MPURLActionTypeEnhancedDeeplink);
                        resolvedActionInfo.originalURL should equal(url);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryURL should equal([NSURL URLWithString:@"maps://"]);
                        resolvedActionInfo.enhancedDeeplinkRequest.fallbackURL should equal([NSURL URLWithString:@"http://www.mopub.com"]);
                    });
                });

                context(@"if the query has a fallbackTrackingUrl", ^{
                    beforeEach(^{
                        url = [NSURL URLWithString:@"deeplink+://navigate?primaryUrl=maps%3A%2F%2F&fallbackTrackingUrl=http%3A%2F%2Fwww.mopub.com"];
                    });

                    it(@"should resolve to an info object indicating an enhanced deeplink with a tracking URL", ^{
                        resolvedActionInfo.actionType should equal(MPURLActionTypeEnhancedDeeplink);
                        resolvedActionInfo.originalURL should equal(url);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryURL should equal([NSURL URLWithString:@"maps://"]);
                        resolvedActionInfo.enhancedDeeplinkRequest.fallbackTrackingURLs.count should equal(1);
                        resolvedActionInfo.enhancedDeeplinkRequest.fallbackTrackingURLs should contain([NSURL URLWithString:@"http://www.mopub.com"]);
                    });
                });

                context(@"if the query has multiple fallbackTrackingUrls", ^{
                    beforeEach(^{
                        url = [NSURL URLWithString:@"deeplink+://navigate?primaryUrl=maps%3A%2F%2F&fallbackTrackingUrl=http%3A%2F%2Fwww.mopub.com&fallbackTrackingUrl=http%3A%2F%2Fwww.twitter.com"];
                    });

                    it(@"should resolve to an info object indicating an enhanced deeplink with multiple tracking URLs", ^{
                        resolvedActionInfo.actionType should equal(MPURLActionTypeEnhancedDeeplink);
                        resolvedActionInfo.originalURL should equal(url);
                        resolvedActionInfo.enhancedDeeplinkRequest.primaryURL should equal([NSURL URLWithString:@"maps://"]);
                        resolvedActionInfo.enhancedDeeplinkRequest.fallbackTrackingURLs.count should equal(2);
                        resolvedActionInfo.enhancedDeeplinkRequest.fallbackTrackingURLs should contain([NSURL URLWithString:@"http://www.mopub.com"]);
                        resolvedActionInfo.enhancedDeeplinkRequest.fallbackTrackingURLs should contain([NSURL URLWithString:@"http://www.twitter.com"]);
                    });
                });
            });

            context(@"if the query does not have a primaryUrl parameter", ^{
                beforeEach(^{
                    url = [NSURL URLWithString:@"deeplink+://navigate?something=invalid"];
                });

                it(@"should resolve to an info object indicating a regular deeplink", ^{
                    resolvedActionInfo.actionType should equal(MPURLActionTypeGenericDeeplink);
                    resolvedActionInfo.originalURL should equal(url);
                    resolvedActionInfo.deeplinkURL should equal(url);
                });
            });
        });

        context(@"if the URL host is not 'navigate'", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"deeplink+://not-navigating.com?primaryUrl=maps%3A%2F%2F"];
            });

            it(@"should resolve to an info object indicating a regular deeplink", ^{
                resolvedActionInfo.actionType should equal(MPURLActionTypeGenericDeeplink);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.deeplinkURL should equal(url);
            });
        });

        describe(@"URL scheme and host matching", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"deepLINK+://NAVIgate?primaryUrl=maps%3A%2F%2F"];
            });

            it(@"should be case-insensitive", ^{
                resolvedActionInfo.actionType should equal(MPURLActionTypeEnhancedDeeplink);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.enhancedDeeplinkRequest.primaryURL should equal([NSURL URLWithString:@"maps://"]);
            });
        });
    });

    describe(@"when the URL has a mopubshare:// scheme", ^{
        beforeEach(^{
            url = [NSURL URLWithString:@"mopubshare://tweet"];
        });

        it(@"should resolve to an info object with a share URL", ^{
            resolvedActionInfo.actionType should equal(MPURLActionTypeShare);
            resolvedActionInfo.originalURL should equal(url);
            resolvedActionInfo.shareURL should equal(url);
        });
    });

    describe(@"when the URL should be opened in store kit", ^{
        context(@"when the URL was generated by the link maker", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"http://m1.itunes.apple.com/lb/anything/in/the/world/can_go-here/id1138?mt=8&cg=2"];
            });

            it(@"should resolve to an info object with the correct item ID and a fallback URL", ^{
                [NSURLConnection lastConnection] should be_nil;

                resolvedActionInfo.actionType should equal(MPURLActionTypeStoreKit);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.iTunesItemIdentifier should equal(@"1138");
                resolvedActionInfo.iTunesStoreFallbackURL should equal(url);
            });
        });

        context(@"when the URL has the ID as a param", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"http://itunes.apple.com/anything/in/the/world/can_go-here?id=1138&cg=2"];
            });

            it(@"should resolve to an info object with the correct item ID and a fallback URL", ^{
                [NSURLConnection lastConnection] should be_nil;

                resolvedActionInfo.actionType should equal(MPURLActionTypeStoreKit);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.iTunesItemIdentifier should equal(@"1138");
                resolvedActionInfo.iTunesStoreFallbackURL should equal(url);
            });
        });

        context(@"when the URL points to phobos", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"http://b1.phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1138&cg=2&foo=bar"];
            });

            it(@"should resolve to an info object with the correct item ID and a fallback URL", ^{
                [NSURLConnection lastConnection] should be_nil;

                resolvedActionInfo.actionType should equal(MPURLActionTypeStoreKit);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.iTunesItemIdentifier should equal(@"1138");
                resolvedActionInfo.iTunesStoreFallbackURL should equal(url);
            });
        });

        context(@"when the URL is an itms:// url", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"itms://itunes.apple.com/us/app/pages/id1138?mt=8&uo=4"];
            });

            it(@"should resolve to an info object with the correct item ID and a fallback URL", ^{
                [NSURLConnection lastConnection] should be_nil;

                resolvedActionInfo.actionType should equal(MPURLActionTypeStoreKit);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.iTunesItemIdentifier should equal(@"1138");
                resolvedActionInfo.iTunesStoreFallbackURL should equal(url);
            });
        });

        context(@"when the URL is an itms-apps:// url", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/pages/id1138?mt=8&uo=4"];
            });

            it(@"should resolve to an info object with the correct item ID and a fallback URL", ^{
                [NSURLConnection lastConnection] should be_nil;

                resolvedActionInfo.actionType should equal(MPURLActionTypeStoreKit);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.iTunesItemIdentifier should equal(@"1138");
                resolvedActionInfo.iTunesStoreFallbackURL should equal(url);
            });
        });


        context(@"when the URL is malformed", ^{
            __block NSArray *malformedURLs;

            beforeEach(^{
                malformedURLs = @[
                                  [NSURL URLWithString:@"https://itunes.apple.com/lb/anything/in/the/world/can_go-here/id1138a2?mt=8&cg=2"],
                                  [NSURL URLWithString:@"https://itunes.apple.com/lb/flubber"],
                                  [NSURL URLWithString:@"https://itunes.apple.com/idiotic"],
                                  [NSURL URLWithString:@"https://itunes.apple.com/us/id"],
                                  [NSURL URLWithString:@"https://itunes.apple.com/us/id2123/not-valid-actually"],
                                  [NSURL URLWithString:@"https://itunes.apple.com/us/album?id=132ab3&floop=132"],
                                  [NSURL URLWithString:@"https://itunes.apple.com/us/floop?id=132ab&marb"],
                                  [NSURL URLWithString:@"https://itunes.apple.com/us/?id=132ab&"],
                                  [NSURL URLWithString:@"https://phobos.apple.com/us/WebObjects/MZStore.woa/wa/viewSoftware?id=132ab3&floop=132"],
                                  [NSURL URLWithString:@"https://phobos.apple.com/us/floop?id=132ab&marb"],
                                  [NSURL URLWithString:@"https://phobos.apple.com/"],
                                  [NSURL URLWithString:@"https://phobos.apple.com/WebObjects"],
                                  [NSURL URLWithString:@"https://phobos.apple.com/us/?foo=bar"],
                                  [NSURL URLWithString:@"https://newton.apple.com/us/id2123"]
                                  ];
            });

            it(@"should not resolve to an info object", ^{
                // Reset this state because the subject-action block will have executed first.
                [NSURLConnection resetAll];
                resolvedActionInfo = nil;
                resolverError = nil;

                for (NSURL *URL in malformedURLs) {
                    urlResolver = [MPURLResolver resolverWithURL:URL completion:^(MPURLActionInfo *actionInfo, NSError *error) {
                        resolvedActionInfo = actionInfo;
                        resolverError = error;
                    }];
                    [urlResolver start];

                    [[[NSURLConnection lastConnection] request] URL] should equal(URL);
                    [NSURLConnection resetAll];

                    resolvedActionInfo should be_nil;
                }
            });
        });
    });

    describe(@"when url and error are nil", ^{
        it(@"should return nil and not crash", ^{
            [urlResolver actionInfoFromURL:nil error:nil] should be_nil;
        });
    });

    describe(@"when the URL is a redirect to something else", ^{
        __block NSURLConnection *lastConnection;
        beforeEach(^{
            url = [NSURL URLWithString:@"https://i.will.redirect/"];
        });

        context(@"when the final URL should be opened in an in-app browser", ^{
            it(@"should resolve to an info object with the right HTML string and base URL", ^{
                lastConnection = [NSURLConnection lastConnection];
                lastConnection.request.URL should equal(url);

                NSURL *redirectURL = [NSURL URLWithString:@"https://i.am.a.webpage"];
                NSURLRequest *redirectRequest = [NSURLRequest requestWithURL:redirectURL];
                NSURLRequest *approvedRedirectRequest = [lastConnection.delegate connection:lastConnection willSendRequest:redirectRequest redirectResponse:nil];
                approvedRedirectRequest should equal(redirectRequest);

                [lastConnection receiveSuccessfulResponse:@"Payload!"];

                resolvedActionInfo.actionType should equal(MPURLActionTypeOpenInWebView);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.webViewBaseURL should equal(redirectURL);
                resolvedActionInfo.HTTPResponseString should equal(@"Payload!");
            });
        });

        context(@"when the final URL should be opened in the application", ^{
            it(@"should resolve to an info object with a deeplink", ^{
                lastConnection = [NSURLConnection lastConnection];
                lastConnection.request.URL should equal(url);

                NSURL *redirectURL = [NSURL URLWithString:@"http://maps.google.com/floop?flap"];
                NSURLRequest *redirectRequest = [NSURLRequest requestWithURL:redirectURL];
                NSURLRequest *approvedRedirectRequest = [lastConnection.delegate connection:lastConnection willSendRequest:redirectRequest redirectResponse:nil];
                approvedRedirectRequest should be_nil;

                // Expect that the connection was canceled. This is a URL that should be handled by
                // an installed application, so we don't want to fetch the contents of the URL.
                [NSURLConnection lastConnection] should be_nil;

                resolvedActionInfo.actionType should equal(MPURLActionTypeGenericDeeplink);
                resolvedActionInfo.originalURL should equal(url);
                resolvedActionInfo.deeplinkURL should equal(redirectURL);
            });
        });
    });

    describe(@"when canceled", ^{
        beforeEach(^{
            url = [NSURL URLWithString:@"https://www.google.com/"];
        });

        it(@"should cancel the connection", ^{
            // Sanity check to make sure we're trying to fetch the contents of the URL.
            [NSURLConnection lastConnection] should_not be_nil;

            [urlResolver cancel];
            [NSURLConnection lastConnection] should be_nil;
        });
    });

    describe(@"tests for proper string encoding/decoding", PENDING);
});

SPEC_END
