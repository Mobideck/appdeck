#import <Foundation/Foundation.h>

@class MFDTXMLDocument, MFDTXMLElement;

@protocol MFDTXMLDocumentDelegate <NSObject>

@optional

- (void) didFinishLoadingXmlDocument:(MFDTXMLDocument *)xmlDocument;
- (void) xmlDocument:(MFDTXMLDocument *)xmlDocument didFailWithError:(NSError *)error;

- (NSURLCredential *) userCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

@interface MFDTXMLDocument : NSObject 
{
	NSURL *_url;
	MFDTXMLElement *documentRoot;
	__unsafe_unretained id <MFDTXMLDocumentDelegate> _delegate;

	MFDTXMLElement *currentElement;

	NSMutableData *receivedData;
	NSURLConnection *theConnection;
	BOOL doneLoading;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) MFDTXMLElement *documentRoot;
@property (nonatomic, assign) __unsafe_unretained id <MFDTXMLDocumentDelegate> delegate;
@property (nonatomic, readonly) BOOL doneLoading;

+ (MFDTXMLDocument *) documentWithData:(NSData *)data;
+ (MFDTXMLDocument *) documentWithContentsOfFile:(NSString *)path;
+ (MFDTXMLDocument *) documentWithContentsOfFile:(NSString *)path delegate:(id<MFDTXMLDocumentDelegate>)delegate;
+ (MFDTXMLDocument *) documentWithContentsOfURL:(NSURL *)url delegate:(id<MFDTXMLDocumentDelegate>)adelegate;

- (id) initWithContentsOfFile:(NSString *)path;
- (id) initWithContentsOfFile:(NSString *)path delegate:(id<MFDTXMLDocumentDelegate>)delegate;
- (id) initWithContentsOfURL:(NSURL *)url delegate:(id<MFDTXMLDocumentDelegate>)delegate;
- (id) initWithData:(NSData *)data;

@end
