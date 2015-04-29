#import <UIKit/UIKit.h>

@class RedirectChecker;

@protocol RedirectCheckerDelegate <NSObject>

- (void)checker:(RedirectChecker *)checker detectedRedirectionTo:(NSURL *)redirectURL;
- (void)checker:(RedirectChecker *)checker didFinishWithData:(NSData *)data;

@optional
- (void)checker:(RedirectChecker *)checker didFailWithError:(NSError *)error;

@end

@interface RedirectChecker : NSObject 
{
	__unsafe_unretained id <RedirectCheckerDelegate> _delegate;
	NSMutableData *receivedData;
	NSString *mimeType;
	NSString *textEncodingName;
	NSURLConnection *_connection;
}

- (id)initWithURL:(NSURL *)url userAgent:(NSString *)userAgent delegate:(id<RedirectCheckerDelegate>) delegate;

@property (nonatomic, assign) __unsafe_unretained id <RedirectCheckerDelegate> delegate;

@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *textEncodingName;

@end
