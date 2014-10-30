//
//  IMBaseViewController.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import "IMBaseViewController.h"

@interface IMBaseViewController ()

@end

@implementation IMBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar setTintColor:RGBToUIColor(101, 151, 213)];
    self.statusLabel = [[UILabel alloc] initWithFrame:self.view.frame];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = self.view.frame;
    [self.view addSubview:self.activityIndicator];
    
    [self.activityIndicator startAnimating];
    
    self.items = [[NSMutableArray alloc] init];
    
    NSString* serverUrl = [self serverUrl];
    if (serverUrl == nil) {
        return;
    }
    
    NSURL* url = [NSURL URLWithString:serverUrl];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    
    self.responseData = [[NSMutableData alloc] init];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.connection start];
    
    [self loadNativeAd];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.requstStatusCode = ((NSHTTPURLResponse*)response).statusCode;
    self.responseData.length = 0;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.statusLabel.text = @"Couldnt connect to server";
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //stop activity indicator
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
    NSError* errror = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&errror];
    
    if (json==nil) {
        [self.view addSubview:self.statusLabel];
        self.statusLabel.text = @"Got improper response from the server";
        return;
    }
    
    if (errror!=nil) {
        [self.view addSubview:self.statusLabel];
        self.statusLabel.text = [NSString stringWithFormat:@"Got error from server , %@", errror];
        return;
    }
    
    NSArray* itemsFromDict = [self itemsFromJsonDict:json];
    if (itemsFromDict != nil) {
        [self.items addObjectsFromArray:itemsFromDict];
    }
}

-(NSString*)serverUrl {
    return nil; //Should be implemented by subclasses
}

-(void)loadNativeAd {
    // IMPLEMENT THIS IN SUBCLASSES
}

-(NSArray*)itemsFromJsonDict:(NSDictionary*)jsonDict {
    return nil; // IMPLEMENT THIS IN SUBCLASSES
}

-(void)attachNativeAdToView:(UIView*)view {
    //Implement this in subclasses
}
-(NSDictionary*)dictFromNativeContent {
    return nil; //Implement this in subclasses
}

-(NSUInteger)heightOfCellForCurrentOrientation {
    return 0;
    // should be implemented by subclasses
}

-(CGRect)frameForCellAtCurrentOrientation {
    return CGRectZero;    // should be implemented by subclasses
}

-(NSUInteger)widthtOfCellForCurrentOrientation {
    return 0;    // should be implemented by subclasses
}

@end