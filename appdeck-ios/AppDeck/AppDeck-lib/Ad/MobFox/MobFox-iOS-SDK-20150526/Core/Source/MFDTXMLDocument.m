#import "MFDTXMLDocument.h"
#import "MFDTXMLElement.h"

@implementation MFDTXMLDocument

#pragma mark Factory Methods
+ (MFDTXMLDocument *) documentWithData:(NSData *)data
{
	return [[MFDTXMLDocument alloc] initWithData:data];
}

+ (MFDTXMLDocument *) documentWithContentsOfFile:(NSString *)path
{
	return [[MFDTXMLDocument alloc] initWithContentsOfFile:path];
}

+ (MFDTXMLDocument *) documentWithContentsOfFile:(NSString *)path delegate:(id<MFDTXMLDocumentDelegate>)delegate
{
	return [[MFDTXMLDocument alloc] initWithContentsOfFile:path delegate:delegate];
}

+ (MFDTXMLDocument *) documentWithContentsOfURL:(NSURL *)url delegate:(id<MFDTXMLDocumentDelegate>)delegate
{
	return [[MFDTXMLDocument alloc] initWithContentsOfURL:url delegate:delegate];
}

#pragma mark Initializer

- (id) init
{
	if (self = [super init])
	{
	}
	return self;
}

- (id) initWithData:(NSData *)data
{
	if (self = [super init])
	{
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];	
		[parser setShouldProcessNamespaces: YES];
		[parser setShouldReportNamespacePrefixes:YES];
		[parser setShouldResolveExternalEntities:NO];
		[parser setDelegate:(id)self];

		if ([parser parse])
		{
			if ([_delegate respondsToSelector:@selector(didFinishLoadingXmlDocument:)])
			{
				[_delegate didFinishLoadingXmlDocument:self];
			}
		}
		else 
		{
			return nil;
		}
	}
	return self;
}

- (id) initWithContentsOfFile:(NSString *)path
{
	if (self = [super init])
	{
		NSURL *fileURL = [NSURL fileURLWithPath:path];

		NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:fileURL];	
		[parser setShouldProcessNamespaces: YES];
		[parser setShouldReportNamespacePrefixes:YES];
		[parser setShouldResolveExternalEntities:NO];
		[parser setDelegate:(id)self];

		if ([parser parse])
		{
			if ([_delegate respondsToSelector:@selector(didFinishLoadingXmlDocument:)])
			{
				[_delegate didFinishLoadingXmlDocument:self];
			}
		}
	}
	return self;
}

- (id) initWithContentsOfFile:(NSString *)path delegate:(id<MFDTXMLDocumentDelegate>)delegate
{
	if (self = [super init])
	{
		self.delegate = delegate;
		NSURL *fileURL = [NSURL fileURLWithPath:path];

		NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:fileURL];	
		[parser setShouldProcessNamespaces: YES];
		[parser setShouldReportNamespacePrefixes:YES];
		[parser setShouldResolveExternalEntities:NO];
		[parser setDelegate:(id)self];

		if ([parser parse])
		{
			if ([_delegate respondsToSelector:@selector(didFinishLoadingXmlDocument:)])
			{
				[_delegate didFinishLoadingXmlDocument:self];
			}
		}
	}
	return self;
}

- (id) initWithContentsOfURL:(NSURL *)url delegate:(id<MFDTXMLDocumentDelegate>)xmlDelegate
{
	if (self = [super init])
	{
		self.delegate = xmlDelegate;

		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:60.0];

		theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];

		if (theConnection) 
		{
			receivedData=[NSMutableData data];
		}
	}
	return self;
}

#pragma mark Parser Protocol

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	MFDTXMLElement *newElement = [[MFDTXMLElement alloc] initWithName:elementName];
	newElement.attributes = [NSMutableDictionary dictionaryWithDictionary:attributeDict];

	if (!currentElement)
	{
		self.documentRoot = newElement;
		currentElement = documentRoot;
	}
	else
	{
		[currentElement.children addObject:newElement];
		newElement.parent = currentElement;
	}

	currentElement = newElement;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[currentElement.text appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	currentElement = currentElement.parent;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	doneLoading = YES;
	if ([_delegate respondsToSelector:@selector(xmlDocument:didFailWithError:)])
	{
		[_delegate xmlDocument:self didFailWithError:parseError];
	}
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
	doneLoading = YES;
	if ([_delegate respondsToSelector:@selector(xmlDocument:didFailWithError:)])
	{
		[_delegate xmlDocument:self didFailWithError:validationError];
	}
}

#pragma mark URL Loading
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	receivedData = nil;
	doneLoading = YES;
	if ([_delegate respondsToSelector:@selector(xmlDocument:didFailWithError:)])
	{
		[_delegate xmlDocument:self didFailWithError:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];	
	receivedData = nil;
	[parser setShouldProcessNamespaces: YES];
	[parser setShouldReportNamespacePrefixes:YES];
	[parser setShouldResolveExternalEntities:NO];
	[parser setDelegate:(id)self];
	doneLoading = YES;
	if ([parser parse])
	{

		if ([_delegate respondsToSelector:@selector(didFinishLoadingXmlDocument:)])
		{
			[_delegate  didFinishLoadingXmlDocument:self];
		}
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge previousFailureCount] == 0) 
	{
		NSURLCredential *newCredential;

		if ([_delegate respondsToSelector:@selector(userCredentialForAuthenticationChallenge:)])
		{
			newCredential = [_delegate userCredentialForAuthenticationChallenge:challenge];
			if (newCredential)
			{
				[[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
			}
			else
			{
				[[challenge sender] cancelAuthenticationChallenge:challenge];
			}
		}
		else 
		{
			[[challenge sender] cancelAuthenticationChallenge:challenge];
		}

	} 
	else 
	{
		[[challenge sender] cancelAuthenticationChallenge:challenge];
	}
}

#pragma mark External methods
- (void) cancelLoading
{
	doneLoading = YES;
	[theConnection cancel];
}

- (NSString *)description
{
	return [documentRoot description];
}

@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize documentRoot;
@synthesize doneLoading;

@end
