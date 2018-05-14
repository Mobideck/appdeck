//
//  AdActionHelper.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 18/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AdActionHelper.h"

@implementation AdActionHelper 

-(id)initWithURL:(NSString *)url target:(NSString *)target adManager:(AdManager *)adManager
{
    self = [super init];
    if (self)
    {
        self.url = url;
        self.target = target;
        self.adManager = adManager;
        [self load];
    }
    return self;
}

-(void)load
{
    AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:self.adManager.loader];
    [appdeckProgressHUD show];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [request addValue:[[AppDeck sharedInstance] userAgent] forHTTPHeaderField:@"User-Agent"];

    NSURLSessionConfiguration*config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask*downloadTask =[session dataTaskWithRequest:request];
    
    [downloadTask resume];
    if (downloadTask)
    {
        currentRequest = request;
        receivedData = [NSMutableData data];
    } else
    {
        [self failed];
    }
    
}

-(void)success
{
    AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:self.adManager.loader];
    [appdeckProgressHUD hide];
}

-(void)failed
{
    NSLog(@"AdAction failed");
    AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:self.adManager.loader];
    [appdeckProgressHUD hide];
}

-(void)cancel
{
    [conn cancel];
}

-(void)handleAppStore:(NSURLRequest *)request
{
    NSLog(@"AppStore: %@", request.URL);
    
    NSString *url = request.URL.absoluteString;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/id([0-9]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSAssert(regex, @"Unable to create regular expression");
    
    NSArray *matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, url.length)];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchID = [match rangeAtIndex:1];
        
        NSString *productId = [url substringWithRange:matchID];
        
        NSLog(@"id: %@", productId);

        SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];

        productViewController.delegate = self;
        NSDictionary *storeParameters = [NSDictionary dictionaryWithObject:productId forKey:SKStoreProductParameterITunesItemIdentifier];
        
        // Try to load the product and dismiss the product view controller in case of failure
        [productViewController loadProductWithParameters:storeParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                [self success];                
                // Present the product view controller
                [self.adManager.loader presentViewController:productViewController animated:YES completion:^(void) {
                    NSLog(@"OK!");

                }];
            } else {
                [self failed];
            }
        }];
        
    }
    
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self.adManager.loader dismissViewControllerAnimated:YES  completion:^() {
        NSLog(@"dissmiss");
    }];
}

-(void)handleURL:(NSURLRequest *)request
{
/*     if ([target isEqualToString:@"internalbrowser"])
     {
     LoaderChildViewController    *page = [self.loader getChildViewControllerFromURL:url type:@"browser"];
     [self.loader loadChild:page root:YES popup:LoaderPopUpYes];
     return YES;
     } else {*/
    [self success];
    [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
/*     return YES;
     }*/
    
}

-(void)handleHTML:(NSURLRequest *)request data:(NSMutableData *)data
{
    NSLog(@"HTML: %@", request.URL);
    [self success];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    
    [task cancel];
    NSLog(@"Redirect: %@", request.URL.absoluteString);
    
    //https://itunes.apple.com/app/game-of-war-fire-age/id667728512?ls=1&mt=8
    //itms-appss://itunes.apple.com/fr/app/empire-four-kingdoms/id585661281?mt=8&ls=1&uo=4
    if ([request.URL.scheme isEqualToString:@"itms-appss"] || [request.URL.host isEqualToString:@"itunes.apple.com"])
    {
        [self handleAppStore:request];
    }
    
    // update current Request if needed
    currentRequest = request;
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] != 200)
        [self failed];
        
        [dataTask cancel];
        [self handleURL:currentRequest];
        return;
        
    }
    [receivedData setLength:0];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if (error){
         [self failed];
    }else{
         [self handleHTML:currentRequest data:receivedData];
    }
    
}

@end
