#ifndef swadapi_h__
#define swadapi_h__

typedef enum SwConversionMode	{
	SwConversionModeUnique = 0,
	SwConversionModeUniquePerVersion = 1,
	SwConversionModeUniquePerSession = 2,
	SwConversionModeMultiple = 3
} SwConversionMode;

typedef enum _sw_error {
    SW_ERR_NOADS,
    SW_ERR_CON,
    SW_ERR_ALREADY_RUNNING,
    SW_ERR_BLOCKED,
    SW_ERR_INTERNAL,
    SW_ERR_SLOT
} sw_error_e;

typedef struct swGADAdSize {
    CGSize size;
    NSUInteger flags;
} swGADAdSize;

swGADAdSize swkGADAdSizeSmartBannerPortrait;

#define SW_LOAD_ADMOB() \
do { \
[GADBannerView alloc]; \
memcpy((void *)&swkGADAdSizeSmartBannerPortrait, &kGADAdSizeSmartBannerPortrait, sizeof(GADAdSize)); \
} while(0)

#define SW_LOAD_INMOBI(id) \
do { \
[InMobi initialize:id];\
} while(0)

@class swAdView;
@class swAdInterstitial;

@protocol swelenDelegate
@optional

- (void) swAdVideoDidStartPlaying;
- (void) swAdVideoDidStopPlaying;
- (void) swAdDidDisplay:(swAdView *)slot args:(id)args;
- (void) swAdDidFail:(swAdView *)slot args:(id)args;
- (void) swAdDidClose:(swAdView *)slot args:(id)args;
- (void) swAdDidReceiveClick:(swAdView *)slot args:(id)args;

@end

@protocol swelenDelegateInterstitial
@optional

- (void) swAdInterstitialVideoDidStartPlaying;
- (void) swAdInterstitialVideoDidStopPlaying;
- (void) swAdInterstitialDidDisplay:(swAdInterstitial *)slot args:(id)args;
- (void) swAdInterstitialDidFail:(swAdInterstitial *)slot args:(id)args;
- (void) swAdInterstitialDidClose:(swAdInterstitial *)slot args:(id)args;
- (void) swAdInterstitialDidReceiveClick:(swAdInterstitial *)slot args:(id)args;

@end


@interface swAdView : UIView

- (id) initWithSlot:(NSString *)slot;
- (id) initWithSlot:(NSString *)slot andSize:(CGSize)size;
- (void) loadAd;
- (void) stopAd;

@property (nonatomic, copy) NSString *slot;
@property (nonatomic, copy) NSString *customUserAgent;
@property (nonatomic, weak) id<swelenDelegate> delegate;
@property (nonatomic, assign) BOOL getLocation;

@end


@interface swAdInterstitial : NSObject

- (id) initWithSlot:(NSString *)slot;
- (void) loadAd;

@property (nonatomic, copy) NSString *slot;
@property (nonatomic, copy) NSString *customUserAgent;
@property (nonatomic, weak) id<swelenDelegateInterstitial> delegate;
@property (nonatomic, assign) BOOL getLocation;
@property (nonatomic, assign) BOOL autoCloseAfterCountdown;
@property (nonatomic, assign) BOOL userCanCloseAfterDisplay;

@end

@interface swAdSlot : NSObject
{
}

@property (readonly, nonatomic) int tag;
@property (readonly, nonatomic) BOOL isActive;
@property (readonly, nonatomic) id debug;
@property (readonly, nonatomic) NSString *UID;

@end



@interface swAdMain : NSObject <NSCopying>

/* Public methods */
- (id) init;
+ (id) sharedSwAd;


- (void) registerConversion:(NSString *)uid mode:(SwConversionMode)mode;

- (void) registerConversion:(NSString *)uid
                       mode:(SwConversionMode)mode
                   currency:(NSString *)currency
                      value:(double)value;
@end

#endif
