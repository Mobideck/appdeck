#import <Foundation/Foundation.h>

@class DTXMLDocument, DTXMLElement;

@protocol DTXMLDocumentDelegate <NSObject>

@optional

- (void) didFinishLoadingXmlDocument:(DTXMLDocument *)xmlDocument;
- (void) xmlDocument:(DTXMLDocument *)xmlDocument didFailWithError:(NSError *)error;

- (NSURLCredential *) userCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

@interface DTXMLDocument : NSObject 
{
	NSURL *_url;
	DTXMLElement *documentRoot;
	__unsafe_unretained id <DTXMLDocumentDelegate> _delegate;

	DTXMLElement *currentElement;

	NSMutableData *receivedData;
	NSURLConnection *theConnection;
	BOOL doneLoading;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) DTXMLElement *documentRoot;
@property (nonatomic, assign) __unsafe_unretained id <DTXMLDocumentDelegate> delegate;
@property (nonatomic, readonly) BOOL doneLoading;

+ (DTXMLDocument *) documentWithData:(NSData *)data;
+ (DTXMLDocument *) documentWithContentsOfFile:(NSString *)path;
+ (DTXMLDocument *) documentWithContentsOfFile:(NSString *)path delegate:(id<DTXMLDocumentDelegate>)delegate;
+ (DTXMLDocument *) documentWithContentsOfURL:(NSURL *)url delegate:(id<DTXMLDocumentDelegate>)adelegate;

- (id) initWithContentsOfFile:(NSString *)path;
- (id) initWithContentsOfFile:(NSString *)path delegate:(id<DTXMLDocumentDelegate>)delegate;
- (id) initWithContentsOfURL:(NSURL *)url delegate:(id<DTXMLDocumentDelegate>)delegate;
- (id) initWithData:(NSData *)data;

@end
