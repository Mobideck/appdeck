#import "MFRedirectChecker.h"

@implementation MFRedirectChecker

@synthesize delegate = _delegate;
@synthesize mimeType;
@synthesize textEncodingName;

- (id)initWithURL:(NSURL *)url userAgent:(NSString *)userAgent delegate:(id<MFRedirectCheckerDelegate>) delegate
{
	if (self = [super init])
	{
		_delegate = delegate;

		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		[request addValue:userAgent forHTTPHeaderField:@"User-Agent"];

		_connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];

		receivedData = [[NSMutableData alloc] init];
		[_connection start];
	}
	return self;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	if (redirectResponse)
	{
		[_delegate checker:self detectedRedirectionTo:[request URL]];

		[_connection cancel];

		return nil;
	}
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.mimeType = [response MIMEType];
	self.textEncodingName = [response textEncodingName];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[_delegate checker:self didFinishWithData:receivedData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
	if ([_delegate respondsToSelector:@selector(checker:didFailWithError:)])
	{
		[_delegate checker:self didFailWithError:error];
	}
}

@end
