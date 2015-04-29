

#import "MobFoxAdBrowserViewController.h"

#import "NSURL+MobFox.h"
#import "UIImage+MobFox.h"

@interface MobFoxAdBrowserViewController () {
    UIActivityIndicatorView *activityView;
    UIBarButtonItem *activityIndicator;
    UIBarButtonItem *backButton;
    UIBarButtonItem *forwardButton;
    UIBarButtonItem *reloadButton;
    UIBarButtonItem *safariButton;
    UIActionSheet *actionSheet;
}

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *textEncodingName;
@property (nonatomic, strong) NSURL *url;
@end


@implementation MobFoxAdBrowserViewController

@synthesize url = _url;
@synthesize userAgent;
@synthesize receivedData;
@synthesize mimeType;
@synthesize textEncodingName;
@synthesize webView = _webView;

@synthesize delegate;

- (id)initWithUrl:(NSURL *)url
{
	if (self = [super init])
	{
		self.url = url;
	}
	return self;
}

- (void)dealloc 
{
	delegate = nil;
    activityView = nil;
    _webView = nil;
}

- (void)loadView 
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        barSize = 35.0f;
    }
    else
    {
        barSize = 45.0f;
    }

    CGRect mainFrame = [UIScreen mainScreen].applicationFrame;
	self.view = [[UIView alloc] initWithFrame:mainFrame];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    CGRect frame, remain;
    CGRectDivide(self.view.bounds, &frame, &remain, barSize, CGRectMaxYEdge);
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:frame];
    toolbar.barStyle = UIBarStyleBlack;
    [toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss:)];
    safariButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openSafari:)];
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    backButton = [[UIBarButtonItem alloc] initWithTitle:@"◁" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    forwardButton = [[UIBarButtonItem alloc] initWithTitle:@"▷" style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    
    reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    
    NSArray *buttons = [NSArray arrayWithObjects: safariButton, flexibleSpace, backButton, flexibleSpace, forwardButton, flexibleSpace, reloadButton, flexibleSpace, activityIndicator, flexibleSpace, closeButton, nil];
    [toolbar setItems:buttons animated:NO];
    
    [self.view addSubview:toolbar];
    
    self.webView.frame = remain;
    [self.view addSubview:self.webView];
}

- (UIWebView *)webView
{
	if (!_webView)
	{
		_webView = [[UIWebView alloc] initWithFrame:CGRectZero];
		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_webView.delegate = self;
	}
	return _webView;
}

- (void)loadURL:(NSURL *)url
{
	if (!_url)
	{
		self.url = url;
		return;
	}
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	if (userAgent)
	{
		[request addValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

		NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
		[connection start];
		[self webViewDidStartLoad:_webView];
	}
	else 
	{
		[_webView loadRequest:request];
	}	
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	[self loadURL:_url];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) appDidBecomeActive:(NSNotification *)notification //automatically close after opening external app
{
    [self dismiss:nil];
}

- (void)updateButtons
{
    forwardButton.enabled = _webView.canGoForward;
    backButton.enabled = _webView.canGoBack;
}

#pragma mark Actions

-(void)dismiss:(id)sender
{
    [self dismissActionSheet];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	if ([delegate respondsToSelector:@selector(mobfoxAdBrowserControllerDidDismiss:)])
	{
		[delegate mobfoxAdBrowserControllerDidDismiss:self];
	}
	else 
	{
		[self dismissModalViewControllerAnimated:NO];
	}
}

-(void)reload:(id)sender {
    [self dismissActionSheet];
    [_webView reload];
}

-(void)goBack:(id)sender {
    [self dismissActionSheet];
    [_webView goBack];
}

-(void)goForward:(id)sender {
    [self dismissActionSheet];
    [_webView goForward];
    
}

-(void)openSafari:(id)sender {
  
    if (actionSheet)
    {
        [self dismissActionSheet];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Open in Safari", nil];
        
        if ([UIActionSheet instancesRespondToSelector:@selector(showFromBarButtonItem:animated:)]) {
            [actionSheet showFromBarButtonItem:safariButton animated:YES];
        } else {
            [actionSheet showInView:self.webView];
        }
    }

}

- (void)dismissActionSheet
{
    if(actionSheet) {
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        actionSheet = nil;
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet2 clickedButtonAtIndex:(NSInteger)buttonIndex
{
    actionSheet = nil;
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: _webView.request.URL.absoluteString]];
    }
}

#pragma mark Web View Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		NSURL *url = [request URL];

		if ( [url isDeviceSupported])
		{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
			[[UIApplication sharedApplication] openURL:url];
		}

		return YES;
	}

	if (self.userAgent)
	{
		if ([request isKindOfClass:[NSMutableURLRequest class]])
		{
			[(NSMutableURLRequest *)request addValue:self.userAgent  forHTTPHeaderField:@"User-Agent"];
		}
	}
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityView startAnimating];
    [self updateButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityView stopAnimating];
    [self updateButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityView stopAnimating];
    [self updateButtons];
}

#pragma mark Manual URL Loading for custom user agent
- (NSMutableData *)receivedData
{
	if (!receivedData)
	{
		receivedData = [[NSMutableData alloc] init];
	}
	return receivedData;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
	self.url = request.URL;
    if ([self.url isDeviceSupported])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[UIApplication sharedApplication] openURL:self.url];
    }
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.mimeType = response.MIMEType;
	self.textEncodingName = response.textEncodingName;

	[self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	receivedData = nil;
	[self webView:_webView didFailLoadWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *scheme = [_url scheme];
	NSString *host = [_url host];
	NSString *path = [[_url path] stringByDeletingLastPathComponent];
	NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@/", scheme, host, path]];
	[_webView loadData:receivedData MIMEType:self.mimeType textEncodingName:textEncodingName baseURL:baseURL];
	[self webViewDidFinishLoad:_webView];
}

@end
