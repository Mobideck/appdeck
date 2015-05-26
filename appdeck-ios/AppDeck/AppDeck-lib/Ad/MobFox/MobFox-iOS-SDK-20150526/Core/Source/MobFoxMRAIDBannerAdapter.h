
#import "MPBaseBannerAdapterMF.h"
#import "MRAdViewMF.h"

@interface MobFoxMRAIDBannerAdapter : MPBaseBannerAdapterMF <MRAdViewDelegateMF> {
    MRAdViewMF *_adView;
}
@property(nonatomic,retain) MRAdViewMF* adView;
@property(nonatomic,retain) MPAdConfigurationMF* configuration;

@end
