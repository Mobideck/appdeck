#import <UIKit/UIKit.h>

@class MFRedirectChecker;

@protocol MFRedirectCheckerDelegate <NSObject>

- (void)checker:(MFRedirectChecker *)checker detectedRedirectionTo:(NSURL *)redirectURL;
- (void)checker:(MFRedirectChecker *)checker didFinishWithData:(NSData *)data;

@optional
- (void)checker:(MFRedirectChecker *)checker didFailWithError:(NSError *)error;

@end

@interface MFRedirectChecker : NSObject 
{
	__unsafe_unretained id <MFRedirectCheckerDelegate> _delegate;
	NSMutableData *receivedData;
	NSString *mimeType;
	NSString *textEncodingName;
	NSURLConnection *_connection;
}

- (id)initWithURL:(NSURL *)url userAgent:(NSString *)userAgent delegate:(id<MFRedirectCheckerDelegate>) delegate;

@property (nonatomic, assign) __unsafe_unretained id <MFRedirectCheckerDelegate> delegate;

@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *textEncodingName;

@end
