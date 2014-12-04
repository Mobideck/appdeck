#import "MRImageDownloader.h"
#import "NSErrorFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MRImageDownloader (Spec)

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end

SPEC_BEGIN(MRImageDownloaderSpec)

describe(@"MRImageDownloader", ^{
    __block MRImageDownloader *downloader;
    __block FakeOperationQueue *fakeOperationQueue;
    __block id<CedarDouble, MRImageDownloaderDelegate> fakeDelegate;

    beforeEach(^{
        fakeOperationQueue = [[FakeOperationQueue alloc] init];
        fakeCoreProvider.fakeOperationQueue = fakeOperationQueue;
        fakeDelegate = nice_fake_for(@protocol(MRImageDownloaderDelegate));
        downloader = [[MRImageDownloader alloc] initWithDelegate:fakeDelegate];
    });

    context(@"when downloadImageWithURL is called", ^{
        beforeEach(^{
            [fakeOperationQueue reset];
            [downloader downloadImageWithURL:[NSURL URLWithString:@"http://image"]];
        });

        it(@"adds an operation to the queue", ^{
            [fakeOperationQueue operationCount] should equal(1);
        });

        context(@"when the operation finshes with error", ^{
            beforeEach(^{
                NSOperation *currentOperation = [[fakeOperationQueue operations] objectAtIndex:0];
                NSError *error = [NSErrorFactory genericError];

                [downloader image:[[UIImage alloc] init]
         didFinishSavingWithError:error
                      contextInfo:(void *)currentOperation];
            });

            it(@"tells its delegate that the download failed", ^{
                fakeDelegate should have_received(@selector(downloaderDidFailToSaveImageWithURL:error:));
            });
        });
    });
});

SPEC_END
