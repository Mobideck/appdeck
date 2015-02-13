//
//  ViewController.m
//

#import "ViewController.h"

static int const kNativeAdQueueSize = 3; //number of native ads that will be loaded into queue

@interface ViewController ()
@property (nonatomic, assign) BOOL tableNeedsReloadAfterLoadingNativeAd; //flag to indicate if table view should be reloaded after successfully loading native ad
@property (nonatomic, strong) NSMutableDictionary* loadedNativeAdViews; //array with already loaded native ad views, used to avoid reloading them when user scrolls back table view
@property (nonatomic, strong) NSMutableArray* loadedNativeAds; //simple queue with loaded native ads
@property (nonatomic, assign) NSInteger nativeAdRequestsInProgress;
@end

@implementation ViewController

@synthesize tableNeedsReloadAfterLoadingNativeAd;
@synthesize videoInterstitialViewController;
@synthesize bannerView;
@synthesize loadedNativeAdViews;
@synthesize nativeAdRequestsInProgress;
@synthesize loadedNativeAds;
@synthesize nativeAdView;
@synthesize tableViewWithAds;
@synthesize tableData;
@synthesize tableViewHelper;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //allocate arrays
    loadedNativeAdViews = [[NSMutableDictionary alloc] init];
    loadedNativeAds = [[NSMutableArray alloc] init];

    // Create, add Interstitial/Video Ad View Controller and add view to view hierarchy
    self.videoInterstitialViewController = [[MobFoxVideoInterstitialViewController alloc] init];
    
    // Assign delegate
    self.videoInterstitialViewController.delegate = self;
    
    // Defaults to NO. Set to YES to get locationAware Adverts
    self.videoInterstitialViewController.locationAwareAdverts = YES;
    
    // Add view. Note when it is created is transparent, with alpha = 0.0 and hidden
    // Only when an ad is being presented it become visible
    [self.view addSubview:self.videoInterstitialViewController.view];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark MobFox Banner Handling

// Methods used to show how you might slide a banner view in and out

-(BOOL)isBannerViewInHiearchy {
    
    for (UIView *oneView in self.view.subviews)
    {
        if(oneView == self.bannerView) {
            return YES;
        }
    }
    
    return NO;
}

- (void)slideOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self.bannerView removeFromSuperview];
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}

- (void)slideOutBannerView:(MobFoxBannerView *)banner {
    
    // move banner to below the bottom of screen
    banner.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height - banner.bounds.size.height/2.0);

    // animate banner outside view
    [UIView beginAnimations:@"MobFox" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideOutDidStop:finished:context:)];
    banner.transform = CGAffineTransformMakeTranslation(0, banner.bounds.size.height);
    [UIView commitAnimations];
}

- (void)slideInBannerView:(MobFoxBannerView *)banner {
    
    banner.bounds = CGRectMake(0, 0, self.view.bounds.size.width, banner.bounds.size.height);
    
    // move banner to be at bottom of screen
    banner.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height - banner.bounds.size.height/2.0);
    
    // set transform to be outside of screen
    banner.transform = CGAffineTransformMakeTranslation(0, banner.bounds.size.height);
    
    // animate banner into view
    [UIView beginAnimations:@"MobFox" context:nil];
    [UIView setAnimationDuration:1];
    banner.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

- (IBAction)requestBannerAdvert:(id)sender {
    
    if (!self.bannerView) {
        
        self.bannerView = [[MobFoxBannerView alloc] initWithFrame:CGRectZero];
        // size does not matter yet
        
        // Don't trigger an Advert load when setting delegate
        self.bannerView.allowDelegateAssigmentToRequestAd = NO;
        
        self.bannerView.delegate = self;
        
        self.bannerView.backgroundColor = [UIColor clearColor];
        self.bannerView.refreshAnimation = UIViewAnimationTransitionFlipFromLeft;
        
        self.bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [self.view addSubview:self.bannerView];
    }

    self.bannerView.requestURL = @"http://my.mobfox.com/request.php";
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
    {
        self.bannerView.adspaceWidth = 320; //optional, used to set the custom size of banner placement. Without setting it, the SDK will use default sizes (320x50 for iPhone, 728x90 for iPad).
        self.bannerView.adspaceHeight = 50;
        
        self.bannerView.adspaceStrict = NO; //optional, tells the server to only supply Adverts that are exactly of desired size. Without setting it, the server could also supply smaller Ads when no ad of desired size is available.
    }
    else
    {
        self.bannerView.adspaceWidth = 728;
        self.bannerView.adspaceHeight = 90;
        
        self.bannerView.adspaceStrict = YES;
    }
   
    
    self.bannerView.locationAwareAdverts = YES;
    [self.bannerView setLocationWithLatitude:235 longitude:178];
    
    self.bannerView.userAge = 22; //optional, sends user's age
    self.bannerView.userGender = @"female"; //optional, sends user's gender (allowed values: "female" and "male")
    NSArray* keywords = [NSArray arrayWithObjects:@"cars", @"finance", nil];
    self.bannerView.keywords = keywords; //optional, to send list of keywords (user interests) to ad server.

    [self.bannerView requestAd]; // Request a Banner Advert
    
}


- (IBAction)requestInterstitialAdvert:(id)sender {
    
    if(self.videoInterstitialViewController) {
        
        // If a BannerView is currently being displayed we should remove it
        if ([self isBannerViewInHiearchy]) {
            [self slideOutBannerView:self.bannerView];
        }
        
        self.videoInterstitialViewController.requestURL = @"http://my.mobfox.com/request.php";
        
        self.videoInterstitialViewController.enableInterstitialAds = YES; //enabled by default. Allows the SDK to request static interstitial ads.
        self.videoInterstitialViewController.enableVideoAds = YES; //disabled by default. Allows the SDK to request video fullscreen ads.
        self.videoInterstitialViewController.prioritizeVideoAds = YES; //disabled by default. If enabled, indicates that SDK should request video ads first, and only if there is no video request a static interstitial (if they are enabled).
        
        self.videoInterstitialViewController.userAge = 35; //optional, sends user's age
        self.videoInterstitialViewController.userGender = @"male";  //optional, sends user's gender (allowed values: "female" and "male")
        NSArray* keywords = [NSArray arrayWithObjects:@"football", @"sports", nil];
        self.videoInterstitialViewController.keywords = keywords; //optional, to send list of keywords (user interests) to ad server.

        
        [self.videoInterstitialViewController requestAd];
    }
}

#pragma mark MobFox Native Ad handling

- (IBAction)requestNativeAdvert:(id)sender {
    if(!self.nativeAdController) {
        self.nativeAdController = [[MobFoxNativeAdController alloc] init];
        self.nativeAdController.delegate = self;
        self.nativeAdController.requestURL = @"http://my.mobfox.com/request.php";
    }
    if (self.nativeAdView) {
        [self.nativeAdView removeFromSuperview];
        self.nativeAdView = nil;
    }
    
    [self fillNativeAdsQueue];
}

- (IBAction)showTableViewWithNativeAds:(id)sender {
    if(!self.nativeAdController) {
        self.nativeAdController = [[MobFoxNativeAdController alloc] init];
        self.nativeAdController.delegate = self;
        self.nativeAdController.requestURL = @"http://my.mobfox.com/request.php";
    }
    if (self.nativeAdView) {
        [self.nativeAdView removeFromSuperview];
        self.nativeAdView = nil;
    }
    
    tableData = [[NSMutableArray alloc]init]; // Fill the data for table view
    for (int i=0; i < 50; i++) {
        NSString* tableRow = [NSString stringWithFormat:@"some text %i",i];
        [tableData addObject:tableRow];
    }
    
    tableViewHelper = [[MobFoxTableViewHelper alloc]initWithFirstAdPosition:5 andRowsBetweenAds:10]; //prepare the helper for table view
    
    [tableViewWithAds reloadData]; //reload the table view with new data
    tableViewWithAds.hidden = NO;
}

- (IBAction)showSingleNativeAd:(id)sender {
    if (self.nativeAdView) {
        [self.nativeAdView removeFromSuperview];
        self.nativeAdView = nil;
    }
    tableViewWithAds.hidden = YES;
    MobFoxNativeAd* nativeAd = [self getNativeAdFromQueue];
    if(nativeAd) {
        nativeAdView = [self.nativeAdController getNativeAdViewForResponse:nativeAd xibName:@"NativeAdView_big"]; //prepare the native ad view from native ad response
        nativeAdView.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height - nativeAdView.bounds.size.height/2.0);
        nativeAdView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:nativeAdView];
        
    } else {
        NSLog(@"Cannot show native ad, it is not loaded!");
    }
}

- (void) fillNativeAdsQueue {
    NSInteger adsToBeRequested = kNativeAdQueueSize - [loadedNativeAds count] - nativeAdRequestsInProgress;
    for (int i=0; i < adsToBeRequested; i++) {
        nativeAdRequestsInProgress++;
        [self.nativeAdController requestAd];
    }
}

- (MobFoxNativeAd*)getNativeAdFromQueue {
    if([loadedNativeAds count] < 1) {
        return nil;
    }
    
    MobFoxNativeAd* ad = [loadedNativeAds objectAtIndex:0];
    [loadedNativeAds removeObjectAtIndex:0];
    return ad;
}

-(UIViewController *)viewControllerForNativeAds {
    return self;
}


#pragma mark Table View methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger originalCount = [tableData count];
    return [tableViewHelper calculateShiftedNumberOfRowsForNumberOfRows:originalCount]; //calculate new size of table, including ad positions
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if([tableViewHelper isAdPosition:indexPath.row]) { //return row with native ad
        
        NSString *identifier = @"AdTableItem";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        } else {
            [[cell.contentView subviews] //clear the cell view
             makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        nativeAdView = [loadedNativeAdViews objectForKey:@(indexPath.row)]; //check if native ad view is already available for given row
        if(!nativeAdView) {
            MobFoxNativeAd* nativeAd = [self getNativeAdFromQueue];
            nativeAdView = [self.nativeAdController getNativeAdViewForResponse:nativeAd xibName:@"NativeAdView_small"]; //if it was not available, try to create it
            
            [self fillNativeAdsQueue]; //we used one native ad, so we need to refill the queue
        }
        
        if (!nativeAdView) { //if loading of native ad view failed, table might need reloading to correctly display native ad when it becomes available
            tableNeedsReloadAfterLoadingNativeAd = YES;
        } else {
            [loadedNativeAdViews setObject:nativeAdView forKey:@(indexPath.row)]; //save the ready native ad view for the row
            nativeAdView.backgroundColor = [UIColor clearColor]; //set clear background to avoid glitches on some devices
            [cell.contentView addSubview:nativeAdView];
        }
    } else { //return your regular content cell

        NSString *identifier = @"OriginalTableItem";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        NSInteger shiftedRow = [tableViewHelper calculateShiftedPositionForPosition:indexPath.row]; //shift the number of rows, taking displayed ads into account
        cell.textLabel.text = [tableData objectAtIndex:shiftedRow];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableViewHelper isAdPosition:indexPath.row]) { //return height of view for ad
        return 110;
    }
    return 20; //return your normal table content height
}


#pragma mark MobFox BannerView Delegate Methods

- (NSString *)publisherIdForMobFoxBannerView:(MobFoxBannerView *)banner {

    return @"ENTER_PUBLISHER_ID_HERE";
}

- (void)mobfoxBannerViewDidLoadMobFoxAd:(MobFoxBannerView *)banner {
    NSLog(@"MobFox Banner: did load ad");
    
    [self slideInBannerView:banner];
}

- (void)mobfoxBannerViewDidLoadRefreshedAd:(MobFoxBannerView *)banner {
    NSLog(@"MobFox Banner: Received a 'refreshed' advert");
    
    if (![self isBannerViewInHiearchy]) {
        
        [self slideInBannerView:banner];
    }
    else {
        
        banner.transform = CGAffineTransformIdentity;
        
        // animate banner into view
        [UIView beginAnimations:@"MobFox" context:nil];
        [UIView setAnimationDuration:1];
        banner.transform = CGAffineTransformIdentity;
        [UIView commitAnimations];
    }
}

- (void)mobfoxBannerView:(MobFoxBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFox Banner: did fail to load ad: %@", [error localizedDescription]);
    
    [self slideOutBannerView:bannerView];
}

-(void)mobfoxBannerViewActionWillPresent:(MobFoxBannerView *)banner {
    NSLog(@"MobFox Banner: will present");
}


#pragma mark MobFox Interstitial Delegate Methods

- (NSString *)publisherIdForMobFoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    return @"ENTER_PUBLISHER_ID_HERE";
}

- (void)mobfoxVideoInterstitialViewDidLoadMobFoxAd:(MobFoxVideoInterstitialViewController *)videoInterstitial advertTypeLoaded:(MobFoxAdType)advertType {

    NSLog(@"MobFox Interstitial: did load ad");
    
    // Means an advert has been retrieved and configured.
    // Display the ad using the presentAd method and ensure you pass back the advertType
    
    [videoInterstitial presentAd:advertType];
}

- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial didFailToReceiveAdWithError:(NSError *)error {

     NSLog(@"MobFox Interstitial: did fail to load ad: %@", [error localizedDescription]);
}

-(void)mobfoxVideoInterstitialViewDidDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    
    NSLog(@"MobFox Interstitial: did dismiss screen");
}

-(void)mobfoxVideoInterstitialViewWasClicked:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    NSLog(@"MobFox Interstitial: was clicked");
}

#pragma mark MobFox Native Ad Delegate Methods

- (NSString *)publisherIdForMobFoxNativeAdController:(MobFoxNativeAdController *)controller {
    return @"ENTER_YOUR_PUBLISHER_ID";
}

- (void) nativeAdDidLoad:(MobFoxNativeAd *)ad {
    NSLog(@"Obtained native ad.");
    [loadedNativeAds addObject:ad];
    nativeAdRequestsInProgress--;
    if (tableNeedsReloadAfterLoadingNativeAd) {
        tableNeedsReloadAfterLoadingNativeAd = NO;
        [tableViewWithAds reloadData];
    }
}

-(void)nativeAdFailedToLoadWithError:(NSError *)error {
    NSLog(@"Failed to load native ad, %@",[error localizedDescription]);
    nativeAdRequestsInProgress--;
}

- (void)nativeAdWasClicked {
    NSLog(@"Native ad was clicked");
}

- (void)nativeAdWasShown {
    NSLog(@"Native ad was shown");
}

@end
