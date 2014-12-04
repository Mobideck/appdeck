#import "MPURLResolver.h"
#import "FakeMPURLResolverDelegate.h"
#import "NSURL+MPAdditions.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPURLResolver (Spec)

@property (nonatomic, retain) NSMutableData *responseData;

- (NSStringEncoding)stringEncodingFromContentType:(NSString *)contentType;

@end

SPEC_BEGIN(MPURLResolverSpec)

describe(@"MPURLResolver", ^{
    __block MPURLResolver *urlResolver;
    __block NSURL *url;
    __block FakeMPURLResolverDelegate *delegate;

    beforeEach(^{
        delegate = [[[FakeMPURLResolverDelegate alloc] init] autorelease];
        urlResolver = [MPURLResolver resolver];
    });

    describe(@"when the URL should be opened in an in-app browser", ^{
        context(@"when the scheme is HTTP", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"http://www.google.com/"];
                [urlResolver startResolvingWithURL:url delegate:delegate];
            });

            it(@"should inform the delegate with the URL and HTML string", ^{
                NSURLConnection *lastConnection = [NSURLConnection lastConnection];
                lastConnection.request.URL should equal(url);
                [lastConnection receiveSuccessfulResponse:@"This is Google!"];

                delegate.webViewURL.absoluteString should equal(@"http://www.google.com/");
                delegate.HTMLString should equal(@"This is Google!");
            });

            it(@"should make the request using the right user agent", ^{
                NSURLConnection *lastConnection = [NSURLConnection lastConnection];
                [[lastConnection.request allHTTPHeaderFields] objectForKey:@"User-Agent"] should equal([fakeCoreProvider userAgent]);
            });
        });

        context(@"when the scheme is HTTPS", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"https://www.fandango.com/"];
                [urlResolver startResolvingWithURL:url delegate:delegate];
            });

            it(@"should inform the delegate with the URL and HTML string", ^{
                NSURLConnection *lastConnection = [NSURLConnection lastConnection];
                lastConnection.request.URL should equal(url);
                [lastConnection receiveSuccessfulResponse:@"Secret Movies"];

                delegate.webViewURL.absoluteString should equal(@"https://www.fandango.com/");
                delegate.HTMLString should equal(@"Secret Movies");
            });

            it(@"should make the request using the right user agent", ^{
                NSURLConnection *lastConnection = [NSURLConnection lastConnection];
                [[lastConnection.request allHTTPHeaderFields] objectForKey:@"User-Agent"] should equal([fakeCoreProvider userAgent]);
            });
        });

        context(@"when another request is made during the current request", ^{
            it(@"should ", ^{
                NSURL *firstUrl = [NSURL URLWithString:@"http://www.google.com/"];
                [urlResolver startResolvingWithURL:firstUrl delegate:delegate];
                NSURLConnection *firstConnection = [NSURLConnection lastConnection];
                [firstConnection.delegate connection:firstConnection
                                      didReceiveData:[@"This is goo" dataUsingEncoding:NSUTF8StringEncoding]];

                NSURL *secondURL = [NSURL URLWithString:@"http://www.bing.com/"];
                [urlResolver startResolvingWithURL:secondURL delegate:delegate];
                [[NSURLConnection connections] count] should equal(1);
                NSURLConnection *secondConnection = [NSURLConnection lastConnection];
                [secondConnection receiveSuccessfulResponse:@"Bing it."];

                delegate.webViewURL.absoluteString should equal(@"http://www.bing.com/");
                delegate.HTMLString should equal(@"Bing it.");
            });
        });
        
        context(@"different results for a response's Content-Type charset", ^{
            it (@"should return the correct encoding", ^{
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
    });

    describe(@"when the URL should be opened by the application", ^{
        context(@"when the scheme is tel", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"tel:5555555555"];
            });

            it(@"should try to open application URL in application when device can open telephone schemes", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:YES];
                spy_on(delegate);
                [urlResolver startResolvingWithURL:url delegate:delegate];
                delegate should have_received(@selector(openURLInApplication:)).with(url);
            });

            it(@"should fail and not call openURLInApplication if device can't open tel schemes", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:NO];
                spy_on(delegate);
                [urlResolver startResolvingWithURL:url delegate:delegate];
                delegate should_not have_received(@selector(openURLInApplication:)).with(url);
                delegate should have_received(@selector(failedToResolveURLWithError:)).with(Arguments::any([NSError class]));
            });
        });

        context(@"when the scheme is telprompt", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"telprompt:5555555555"];
            });

            it(@"should try to open application URL in application when device can open telephone schemes", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:YES];
                spy_on(delegate);
                [urlResolver startResolvingWithURL:url delegate:delegate];
                delegate should have_received(@selector(openURLInApplication:)).with(url);
            });

            it(@"should fail and not call openURLInApplication if device can't open tel schemes", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:NO];
                spy_on(delegate);
                [urlResolver startResolvingWithURL:url delegate:delegate];
                delegate should_not have_received(@selector(openURLInApplication:)).with(url);
                delegate should have_received(@selector(failedToResolveURLWithError:)).with(Arguments::any([NSError class]));
            });
        });
        context(@"when the scheme is neither http nor https", ^{
            context(@"when the scheme is mopubnativebrowser://", ^{
                context(@"when the requested URL is well-formed URL", ^{
                    it(@"should tell the delegate to open the URL in the application", ^{
                        url = [NSURL URLWithString:@"mopubnativebrowser://navigate?url=https%3A%2F%2Fwww.google.com"];
                        [urlResolver startResolvingWithURL:url delegate:delegate];
                        [NSURLConnection lastConnection] should be_nil;
                        delegate.applicationURL.absoluteString should equal(@"https://www.google.com");
                    });
                });

                context(@"when the requested URL is not a well-formed URL", ^{
                    it(@"should tell the delegate that a failure has occurred", ^{
                        url = [NSURL URLWithString:@"mopubnativebrowser://navigate?url=åß∂∆"];
                        [urlResolver startResolvingWithURL:url delegate:delegate];
                        [NSURLConnection lastConnection] should be_nil;
                        delegate.error should_not be_nil;
                    });
                });
            });

            context(@"when the URL can otherwise be opened by the application", ^{
                beforeEach(^{
                    url = [NSURL URLWithString:@"ftp://www.google.com"];
                    [[UIApplication sharedApplication] canOpenURL:url] should be_truthy;

                    [urlResolver startResolvingWithURL:url delegate:delegate];
                });

                it(@"should tell the delegate to open the URL in the application", ^{
                    [NSURLConnection lastConnection] should be_nil;
                    delegate.applicationURL.absoluteString should equal(@"ftp://www.google.com");
                });
            });

            context(@"when the URL cannot be opened by the application", ^{
                beforeEach(^{
                    url = [NSURL URLWithString:@"asdf://www.google.com"];
                    [[UIApplication sharedApplication] canOpenURL:url] should_not be_truthy;

                    [urlResolver startResolvingWithURL:url delegate:delegate];
                });

                it(@"should tell the delegate that a failure has occured", ^{
                    [NSURLConnection lastConnection] should be_nil;
                    delegate.error should_not be_nil;
                });
            });
        });

        context(@"when the URL points to a map", ^{
            it(@"should tell the delegate to open the URL in the application", ^{
                for (NSString *path in @[@"http://maps.google.com/floop?flap", @"http://maps.apple.com/flip?flop", @"http://2.maps.google.com/whatever?hey"]) {
                    url = [NSURL URLWithString:path];
                    urlResolver = [MPURLResolver resolver];
                    [urlResolver startResolvingWithURL:url delegate:delegate];
                    [NSURLConnection lastConnection] should be_nil;
                    delegate.applicationURL.absoluteString should equal(path);
                    [NSURLConnection resetAll];
                }
            });
        });
    });

    describe(@"when the URL should be opened in store kit", ^{
        context(@"when the URL was generated by the link maker", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"http://m1.itunes.apple.com/lb/anything/in/the/world/can_go-here/id1138?mt=8&cg=2"];
                [urlResolver startResolvingWithURL:url delegate:delegate];
            });

            it(@"should tell the delegate to open the store kit and pass it the correct ID (and URL)", ^{
                [NSURLConnection lastConnection] should be_nil;
                delegate.storeKitParameter should equal(@"1138");
                delegate.storeFallbackURL.absoluteString should equal(@"http://m1.itunes.apple.com/lb/anything/in/the/world/can_go-here/id1138?mt=8&cg=2");
            });
        });

        context(@"when the URL has the ID as a param", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"http://itunes.apple.com/anything/in/the/world/can_go-here?id=1138&cg=2"];
                [urlResolver startResolvingWithURL:url delegate:delegate];
            });

            it(@"should tell the delegate to open the store kit and pass it the correct ID (and URL)", ^{
                [NSURLConnection lastConnection] should be_nil;
                delegate.storeKitParameter should equal(@"1138");
                delegate.storeFallbackURL.absoluteString should equal(@"http://itunes.apple.com/anything/in/the/world/can_go-here?id=1138&cg=2");
            });
        });

        context(@"when the URL points to phobos", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"http://b1.phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1138&cg=2&foo=bar"];
                [urlResolver startResolvingWithURL:url delegate:delegate];
            });

            it(@"should tell the delegate to open the store kit and pass it the correct ID (and URL)", ^{
                [NSURLConnection lastConnection] should be_nil;
                delegate.storeKitParameter should equal(@"1138");
                delegate.storeFallbackURL.absoluteString should equal(@"http://b1.phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1138&cg=2&foo=bar");
            });
        });

        context(@"when the URL is an itms:// url", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"itms://itunes.apple.com/us/app/pages/id1138?mt=8&uo=4"];
                [urlResolver startResolvingWithURL:url delegate:delegate];
            });

            it(@"should tell the delegate to open the store kit and pass it the correct ID (and URL)", ^{
                [NSURLConnection lastConnection] should be_nil;
                delegate.storeKitParameter should equal(@"1138");
                delegate.storeFallbackURL.absoluteString should equal(@"itms://itunes.apple.com/us/app/pages/id1138?mt=8&uo=4");
            });
        });

        context(@"when the URL is an itms-apps:// url", ^{
            beforeEach(^{
                url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/pages/id1138?mt=8&uo=4"];
                [urlResolver startResolvingWithURL:url delegate:delegate];
            });

            it(@"should tell the delegate to open the store kit and pass it the correct ID (and URL)", ^{
                [NSURLConnection lastConnection] should be_nil;
                delegate.storeKitParameter should equal(@"1138");
                delegate.storeFallbackURL.absoluteString should equal(@"itms-apps://itunes.apple.com/us/app/pages/id1138?mt=8&uo=4");
            });
        });


        context(@"when the URL is malformed", ^{
            __block NSArray *malformedURLs;
            beforeEach(^{
                malformedURLs = @[
                                  [NSURL URLWithString:@"http://itunes.apple.com/lb/anything/in/the/world/can_go-here/id1138a2?mt=8&cg=2"],
                                  [NSURL URLWithString:@"http://itunes.apple.com/lb/flubber"],
                                  [NSURL URLWithString:@"http://itunes.apple.com/idiotic"],
                                  [NSURL URLWithString:@"http://itunes.apple.com/us/id"],
                                  [NSURL URLWithString:@"http://itunes.apple.com/us/id2123/not-valid-actually"],
                                  [NSURL URLWithString:@"http://itunes.apple.com/us/album?id=132ab3&floop=132"],
                                  [NSURL URLWithString:@"http://itunes.apple.com/us/floop?id=132ab&marb"],
                                  [NSURL URLWithString:@"http://itunes.apple.com/us/?id=132ab&"],
                                  [NSURL URLWithString:@"http://phobos.apple.com/us/WebObjects/MZStore.woa/wa/viewSoftware?id=132ab3&floop=132"],
                                  [NSURL URLWithString:@"http://phobos.apple.com/us/floop?id=132ab&marb"],
                                  [NSURL URLWithString:@"http://phobos.apple.com/"],
                                  [NSURL URLWithString:@"http://phobos.apple.com/WebObjects"],
                                  [NSURL URLWithString:@"http://phobos.apple.com/us/?foo=bar"],
                                  [NSURL URLWithString:@"http://newton.apple.com/us/id2123"]
                                  ];
            });

            it(@"should tell the delegate to open the store kit and pass it the correct ID (and URL)", ^{
                for (NSURL *URL in malformedURLs) {
                    urlResolver = [MPURLResolver resolver];
                    [urlResolver startResolvingWithURL:URL delegate:delegate];
                    [[[NSURLConnection lastConnection] request] URL] should equal(URL);
                    delegate.storeKitParameter should be_nil;
                    delegate.storeFallbackURL should be_nil;
                    [NSURLConnection resetAll];
                }
            });
        });
    });


    describe(@"when the URL redirects", ^{
        __block NSURLConnection *lastConnection;
        beforeEach(^{
            url = [NSURL URLWithString:@"http://i.will.redirect/"];
            [urlResolver startResolvingWithURL:url delegate:delegate];
            lastConnection = [NSURLConnection lastConnection];

            lastConnection.request.URL should equal(url);
            delegate.webViewURL should be_nil;
        });

        context(@"when the final URL should be opened in a browser", ^{
            beforeEach(^{
                NSURLRequest *redirectRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://i.am.a.webpage"]];
                NSURLRequest *approvedRedirectRequest = [lastConnection.delegate connection:lastConnection willSendRequest:redirectRequest redirectResponse:nil];
                approvedRedirectRequest should equal(redirectRequest);
            });

            it(@"should tell the delegate to open the URL in a browser", ^{
                [lastConnection receiveSuccessfulResponse:@"Payload!"];

                delegate.webViewURL.absoluteString should equal(@"http://i.am.a.webpage");
                delegate.HTMLString should equal(@"Payload!");
            });
        });

        context(@"when the final URL should be opened in the application", ^{
            beforeEach(^{
                NSURLRequest *redirectRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://maps.google.com/floop?flap"]];
                NSURLRequest *approvedRedirectRequest = [lastConnection.delegate connection:lastConnection willSendRequest:redirectRequest redirectResponse:nil];
                approvedRedirectRequest should be_nil;
                [NSURLConnection lastConnection] should be_nil; //Cancelled the connection
            });

            it(@"should tell the delegate to open the URL in the application", ^{
                delegate.applicationURL.absoluteString should equal(@"http://maps.google.com/floop?flap");
            });
        });
    });

    describe(@"when the URL fails to fetch", ^{
        beforeEach(^{
            url = [NSURL URLWithString:@"http://www.google.com/"];
            [urlResolver startResolvingWithURL:url delegate:delegate];
        });


        it(@"should tell the delegate about the failure", ^{
            NSError *error = [NSError errorWithDomain:@"com.mopub" code:500 userInfo:nil];
            [[NSURLConnection lastConnection] failWithError:error];
            delegate.error should equal(error);
        });
    });

    describe(@"when canceled", ^{
        beforeEach(^{
            url = [NSURL URLWithString:@"http://www.google.com/"];
            [urlResolver startResolvingWithURL:url delegate:delegate];
            [NSURLConnection lastConnection] should_not be_nil;
            [urlResolver cancel];
        });

        it(@"should cancel the connection", ^{
            [NSURLConnection lastConnection] should be_nil;
        });
    });
    
    describe(@"tests for proper string encoding/decoding", PENDING);
});

SPEC_END
