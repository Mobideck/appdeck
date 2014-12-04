#import "MPAdServerCommunicator.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface FakeMPAdServerCommunicatorDelegate : NSObject <MPAdServerCommunicatorDelegate>

@property (nonatomic, assign) MPAdConfiguration *configuration;
@property (nonatomic, assign) NSError *error;

@end

@implementation FakeMPAdServerCommunicatorDelegate

- (void)communicatorDidReceiveAdConfiguration:(MPAdConfiguration *)configuration
{
    self.configuration = configuration;
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    self.error = error;
}

@end

SPEC_BEGIN(MPAdServerCommunicatorSpec)

describe(@"MPAdServerCommunicator", ^{
    __block MPAdServerCommunicator *communicator;
    __block FakeMPAdServerCommunicatorDelegate *delegate;
    beforeEach(^{
        delegate = [[[FakeMPAdServerCommunicatorDelegate alloc] init] autorelease];
        communicator = [[[MPAdServerCommunicator alloc] initWithDelegate:delegate] autorelease];
    });
    
    describe(@"when told to load a URL", ^{
        __block NSURL *URL;
        __block NSURLConnection *connection;
        
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.mopub.com"];
            [communicator loadURL:URL];
            connection = [NSURLConnection lastConnection];
        });
        
        it(@"should make a connection", ^{
            connection.request.URL should equal(URL);
        });
        
        it(@"should be loading", ^{
            communicator.loading should equal(YES);
        });
        
        context(@"when the request succeeds", ^{
            beforeEach(^{
                NSDictionary *headers = [MPAdConfigurationFactory defaultBannerHeaders];
                PSHKFakeHTTPURLResponse *response = [[[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:200
                                                                                              andHeaders:headers
                                                                                                 andBody:@"<h1>Foo</h1>"] autorelease];
                [connection receiveResponse:response];
            });
            
            it(@"should create a configuration and notify the delegate", ^{
                delegate.configuration.preferredSize.height should equal(50);
                delegate.configuration.adResponseHTMLString should equal(@"<h1>Foo</h1>");
            });
            
            it(@"should not be loading", ^{
                communicator.loading should equal(NO);
            });
        });
        
        context(@"when the request fails", ^{
            context(@"because the request is not in the success range", ^{
                beforeEach(^{
                    PSHKFakeHTTPURLResponse *response = [[[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:404
                                                                                                  andHeaders:nil
                                                                                                     andBody:nil] autorelease];
                    [connection receiveResponse:response];
                });
                
                it(@"should notify the delegate", ^{
                    delegate.configuration should be_nil;
                    delegate.error.code should equal(404);
                });
                
                it(@"should not be loading", ^{
                    communicator.loading should equal(NO);
                });
            });

            context(@"because the connection failed", ^{
                __block NSError *error;
                
                beforeEach(^{
                    error = [NSErrorFactory genericError];
                    [connection failWithError:error];
                });
                
                it(@"should notify the delegate", ^{
                    delegate.configuration should be_nil;
                    delegate.error should equal(error);
                });
                
                it(@"should not be loading", ^{
                    communicator.loading should equal(NO);
                });                
            });
        });
        
        describe(@"when cancelled", ^{
            beforeEach(^{
                [communicator cancel];
            });
            
            it(@"should cancel the request", ^{
                [NSURLConnection connections] should be_empty;
            });
            
            it(@"should not be loading", ^{
                communicator.loading should equal(NO);
            });
        });
    });
});

SPEC_END
