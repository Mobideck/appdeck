#import "MPAdTableViewController.h"
#import "MPAdInfo.h"
#import "MPBannerAdDetailViewController.h"
#import "MPAdSection.h"
#import "MPInterstitialAdDetailViewController.h"
#import "MPAdEntryViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdTableViewControllerSpec)

describe(@"MPAdTableViewController", ^{
    __block UINavigationController *navigationController;
    __block MPAdTableViewController *controller;
    __block UITableView *tableView;
    __block NSArray *adSections;

    beforeEach(^{
        NSArray *bannerAds = @[
                               [MPAdInfo infoWithTitle:@"test1" ID:@"id1" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"test2" ID:@"id2" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"test3" ID:@"id3" type:MPAdInfoBanner],
                               ];
        NSArray *interstitialAds = @[[MPAdInfo infoWithTitle:@"intl1" ID:@"intlid1" type:MPAdInfoInterstitial]];
        adSections = @[
                       [MPAdSection sectionWithTitle:@"banner" ads:bannerAds],
                       [MPAdSection sectionWithTitle:@"interstitial" ads:interstitialAds]
                       ];
        controller = [[MPAdTableViewController alloc] initWithAdSections:adSections];
        controller.view should_not be_nil;
        tableView = controller.tableView;

        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    });

    it(@"should have 2 sections", ^{
        tableView.numberOfSections should equal(2);
    });

    it(@"should have the right number of rows in its sections", ^{
        [tableView numberOfRowsInSection:0] should equal(3);
        [tableView numberOfRowsInSection:1] should equal(1);
    });

    it(@"should configure its cells with titles and detail text", ^{
        [[tableView.visibleCells[0] textLabel] text] should equal(@"test1");
        [[tableView.visibleCells[1] textLabel] text] should equal(@"test2");
        [[tableView.visibleCells[2] textLabel] text] should equal(@"test3");

        [[tableView.visibleCells[0] detailTextLabel] text] should equal(@"id1");
        [[tableView.visibleCells[1] detailTextLabel] text] should equal(@"id2");
        [[tableView.visibleCells[2] detailTextLabel] text] should equal(@"id3");

        [[tableView.visibleCells[3] textLabel] text] should equal(@"intl1");
        [[tableView.visibleCells[3] detailTextLabel] text] should equal(@"intlid1");
    });

    it(@"should have the right section headers", ^{
        [tableView.dataSource tableView:tableView titleForHeaderInSection:0] should equal(@"banner");
        [tableView.dataSource tableView:tableView titleForHeaderInSection:1] should equal(@"interstitial");
    });

    context(@"when a banner cell is clicked", ^{
        beforeEach(^{
            [controller tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        });

        it(@"should push a banner detail view controller onto the navigation stack", ^{
            navigationController.topViewController should be_instance_of([MPBannerAdDetailViewController class]);

            MPBannerAdDetailViewController *detailController = (MPBannerAdDetailViewController *)navigationController.topViewController;
            detailController.view should_not be_nil;
            detailController.titleLabel.text should equal(@"test1");
            detailController.IDLabel.text should equal(@"id1");
        });
    });

    context(@"when an interstitial cell is clicked", ^{
        beforeEach(^{
            [controller tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        });

        it(@"should push an interstitial detail view controller onto the navigation stack", ^{
            navigationController.topViewController should be_instance_of([MPInterstitialAdDetailViewController class]);

            MPInterstitialAdDetailViewController *detailController = (MPInterstitialAdDetailViewController *)navigationController.topViewController;
            detailController.view should_not be_nil;
            detailController.titleLabel.text should equal(@"intl1");
            detailController.IDLabel.text should equal(@"intlid1");
        });
    });

    context(@"when the + button is pressed", ^{
        it(@"should push an ad entry view controller onto the navigation stack", ^{
            [controller.navigationItem.rightBarButtonItem tap];

            navigationController.topViewController should be_instance_of([MPAdEntryViewController class]);
        });
    });

});

SPEC_END
