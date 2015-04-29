
#import "MPBaseBannerAdapter.h"
#import "MRAdView.h"

@interface MobFoxMRAIDBannerAdapter : MPBaseBannerAdapter <MRAdViewDelegate> {
    MRAdView *_adView;
}
@property(nonatomic,retain) MRAdView* adView;
@property(nonatomic,retain) MPAdConfiguration* configuration;

@end
