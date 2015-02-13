//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import <MobFox/MobFox.h>

@interface ViewController : UIViewController <MobFoxVideoInterstitialViewControllerDelegate, MobFoxBannerViewDelegate, MobFoxNativeAdDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MobFoxVideoInterstitialViewController *videoInterstitialViewController;
@property (strong, nonatomic) MobFoxBannerView *bannerView;
@property (strong, nonatomic) UIView *nativeAdView;
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) MobFoxTableViewHelper *tableViewHelper;
@property (strong, nonatomic) MobFoxNativeAdController *nativeAdController;

- (IBAction)requestInterstitialAdvert:(id)sender;
- (IBAction)requestBannerAdvert:(id)sender;
- (IBAction)requestNativeAdvert:(id)sender;
- (IBAction)showTableViewWithNativeAds:(id)sender;
- (IBAction)showSingleNativeAd:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableViewWithAds;

@end
