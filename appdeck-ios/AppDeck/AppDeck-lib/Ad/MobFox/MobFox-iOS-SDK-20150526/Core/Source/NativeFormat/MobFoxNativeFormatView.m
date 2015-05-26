//
//  MobFoxNativeFormatView.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 20.04.2015.
//
//

#import "MobFoxNativeFormatView.h"
#import <AdSupport/AdSupport.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "NSString+MobFox.h"
#import "UIView+FindViewController.h"
#import "MobFoxAdBrowserViewController.h"


NSString * const MobFoxNativeFormatAdErrorDomain = @"MobFoxNativeFormatAd";
static NSString * const SERVER_URL = @"http://my.mobfox.com/request.php";

@interface MobFoxNativeFormatView() <UIWebViewDelegate, MobFoxAdBrowserViewController>
@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) NSString* userAgent;

@property (nonatomic, strong) NSData* dataReply;
@property (nonatomic, strong) NSString* templateString;

@property (nonatomic, assign) BOOL shouldInjectJavascript;
@end

@implementation MobFoxNativeFormatView


-(instancetype)init {
    self = [super init];
    [self setup];
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

-(void) setup {
    self.backgroundColor = [UIColor clearColor];
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}



-(void)requestAdWithCreative:(MobFoxNativeFormatCreative*)creative andPublisherId:(NSString*)publisherId {

    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, creative.width, creative.height)];
    
    self.webView.delegate = self;
    self.webView.scrollView.scrollsToTop = false;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.scalesPageToFit = YES;
    
    self.templateString = creative.templateString;
    
    self.shouldInjectJavascript = YES;
    
    [self performSelectorInBackground:@selector(asyncRequestAdWithPublisherId:) withObject:@[publisherId, creative.name]];
}

- (void)asyncRequestAdWithPublisherId:(NSArray*)array
{
    
    @autoreleasepool
    {
        NSString *publisherId = array[0];
        NSString *templateName = array[1];
        
        NSString *osVersion = [UIDevice currentDevice].systemVersion;
        
        NSString *requestString;
        
        int r = arc4random_uniform(50000);
        NSString *random = [NSString stringWithFormat:@"%d", r];
        
        NSString *requestType;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            requestType = @"iphone_app";
        }
        else
        {
            requestType = @"ipad_app";
        }
        
        NSString *iosadvid;
        if ([ASIdentifierManager instancesRespondToSelector:@selector(advertisingIdentifier )]) {
            iosadvid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            
            requestString=[NSString stringWithFormat:@"r_type=native&rt=%@&r_resp=json&n_img=icon&n_txt=headline&u=%@&u_wv=%@&u_br=%@&o_iosadvid=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@&template_name=%@",
                           [requestType stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [iosadvid stringByUrlEncoding],
                           [SDK_VERSION stringByUrlEncoding],
                           [publisherId stringByUrlEncoding],
                           [osVersion stringByUrlEncoding],
                           [random stringByUrlEncoding],
                           [templateName stringByUrlEncoding]];
            
        } else {
            requestString=[NSString stringWithFormat:@"r_type=native&rt=%@&r_resp=json&n_img=icon&n_txt=headline&u=%@&u_wv=%@&u_br=%@&&v=%@&s=%@&iphone_osversion=%@&r_random=%@&template_name=%@",
                           [requestType stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [SDK_VERSION stringByUrlEncoding],
                           [publisherId stringByUrlEncoding],
                           [osVersion stringByUrlEncoding],
                           [random stringByUrlEncoding],
                           [templateName stringByUrlEncoding]];
        }
        

        
        NSURL *url;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", SERVER_URL, requestString]];
        
        NSMutableURLRequest *request;
        NSError *error;
        NSURLResponse *response;
        
        request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod: @"GET"];
        [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
        
        self.dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(!self.dataReply || error || [self.dataReply length] == 0) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"NativeFormat ad request failed" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxNativeFormatAdErrorDomain code:0 userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            
            return;
        }
        
        [self performSelectorOnMainThread:@selector(setupAd) withObject:nil waitUntilDone:YES];
        
    }
}


- (void)setupAd {

    NSString *path = [[NSBundle mainBundle] pathForResource: @"render_template" ofType: @"html"];
    if (!path) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot load template HTML for ad" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxNativeFormatAdErrorDomain code:0 userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    NSError* error;
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error reading template HTML for ad" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxNativeFormatAdErrorDomain code:0 userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    self.bounds = self.webView.bounds;
    [self insertSubview:self.webView atIndex:0];
    
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:path]];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if(!self.shouldInjectJavascript) {
        return;
    }
    self.shouldInjectJavascript = NO;
    
    @try {
        
        NSError *jsonError = nil;
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:self.dataReply options:NSJSONReadingMutableContainers error:&jsonError];
    
        NSString *path = [[NSBundle mainBundle] pathForResource: @"libs" ofType: @"js"];
        if (!path) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot load javascript libraries" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxNativeFormatAdErrorDomain code:0 userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }
    
        NSError* error;
        NSString *libsString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if(error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error reading bundled javascript libraries" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxNativeFormatAdErrorDomain code:0 userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }
    
        NSMutableDictionary* inp = [NSMutableDictionary dictionary];
        [inp setObject:self.templateString forKey:@"template"];
    
        libsString = [NSString stringWithFormat:@"<script type='text/javascript'>%@</script>", libsString];
    
        [json setObject:libsString forKey:@"libs"];
    
        [inp setObject:json forKey:@"data"];
    
    
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:inp
                                                       options:0
                                                         error:&error];
    
    
        if (! jsonData || error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error creating JSON string" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxNativeFormatAdErrorDomain code:0 userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }
    
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString* scriptString = [NSString stringWithFormat:@"renderTemplate(%@)",jsonString];
    
        JSContext *ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        ctx[@"console"][@"log"] = ^(JSValue * msg) {
            ctx[@"console"][@"log"] = nil;
    
            [self.webView loadHTMLString:[msg toString] baseURL:nil];
    
            if ([delegate respondsToSelector:@selector(mobfoxNativeFormatDidLoad:)])
            {
                [delegate mobfoxNativeFormatDidLoad:self];
            }
    
        };
    
        [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
        
    }
    @catch (NSException *exception) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Exception when loading Native Format Ad." forKey:NSLocalizedDescriptionKey];
        NSError *myerror = [NSError errorWithDomain:MobFoxNativeFormatAdErrorDomain code:0 userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:myerror waitUntilDone:YES];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error loading data into webview" forKey:NSLocalizedDescriptionKey];
    NSError *myerror = [NSError errorWithDomain:MobFoxNativeFormatAdErrorDomain code:0 userInfo:userInfo];
    [self performSelectorOnMainThread:@selector(reportError:) withObject:myerror waitUntilDone:YES];
    return;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSURL *url = [request URL];
    NSString *urlString = [url absoluteString];
    
    UIViewController *viewController = [self firstAvailableUIViewController];
    if (!viewController)
    {
        return YES;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if (![urlString isEqualToString:@"about:blank"] && ![urlString isEqualToString:@""]) {
            MobFoxAdBrowserViewController *browser = [[MobFoxAdBrowserViewController alloc] initWithUrl:url];
            browser.delegate = self;
            browser.userAgent = self.userAgent;
            if ([delegate respondsToSelector:@selector(mobfoxNativeFormatWillPresent)])
            {
                [delegate mobfoxNativeFormatWillPresent];
            }
            [viewController presentModalViewController:browser animated:YES];
            return NO;
        }
    }

    return YES;
}

- (void)mobfoxAdBrowserControllerDidDismiss:(MobFoxAdBrowserViewController *)mobfoxAdBrowserController
{
    if ([delegate respondsToSelector:@selector(mobfoxNativeFormatActionWillFinish)])
    {
        [delegate mobfoxNativeFormatActionWillFinish];
    }
    [mobfoxAdBrowserController dismissModalViewControllerAnimated:YES];
    
    if ([delegate respondsToSelector:@selector(mobfoxNativeFormatActionDidFinish)])
    {
        [delegate mobfoxNativeFormatActionDidFinish];
    }
}

- (void)dealloc {
    delegate = nil;
    self.webView = nil;
    self.userAgent = nil;
    self.dataReply = nil;
    self.templateString = nil;
}

- (void)reportError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(mobfoxNativeFormatDidFailToLoadWithError:)])
    {
        [delegate mobfoxNativeFormatDidFailToLoadWithError:error];
    }
}



@synthesize delegate;


@end
