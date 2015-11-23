package com.mobideck.appdeck;

import android.util.Log;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import com.mopub.mobileads.MoPubErrorCode;
import com.mopub.mobileads.MoPubInterstitial;
import com.mopub.mobileads.MoPubView;
import com.mopub.nativeads.NativeResponse;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 10/11/15.
 */
public class AppDeckAdNetworkMoPub extends AppDeckAdNetwork {

    public static String TAG = "MoPub";

    public String mopubBannerId = "";
    public String mopubRectangleId = "";
    public String mopubInterstitialId = "";
    public String mopubNativeId = "";

    public AppDeckAdNetworkMoPub(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            mopubBannerId = conf.optString("mopubBannerId");
            mopubRectangleId = conf.optString("mopubRectangleId");
            mopubInterstitialId = conf.optString("mopubInterstitialId");
            mopubNativeId = conf.optString("mopubNativeId");
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: mopubBannerId:" + mopubBannerId + " mopubRectangleId:" + mopubRectangleId + " mopubInterstitialId:" + mopubInterstitialId + " mopubNativeId:" + mopubNativeId);

    }

    /* Interstitial Ads */

    private MoPubInterstitial mInterstitial;

    public boolean supportInterstitial() {
        if (mopubInterstitialId == null || mopubInterstitialId.isEmpty())
            return false;
        return true;
    }
    public void fetchInterstitialAd() {
        mInterstitial = new MoPubInterstitial(manager.loader, mopubInterstitialId);
        mInterstitial.setInterstitialAdListener(new MoPubInterstitial.InterstitialAdListener() {
            @Override
            public void onInterstitialLoaded(MoPubInterstitial interstitial) {
                Log.d(TAG, "onInterstitialLoaded");
                manager.onInterstitialAdFetched(AppDeckAdNetworkMoPub.this);
            }

            @Override
            public void onInterstitialFailed(MoPubInterstitial interstitial, MoPubErrorCode errorCode) {
                Log.d(TAG, "onInterstitialFailed");
                manager.onInterstitialAdFailed(AppDeckAdNetworkMoPub.this);
            }

            @Override
            public void onInterstitialShown(MoPubInterstitial interstitial) {
                Log.d(TAG, "onInterstitialShown");
                manager.onInterstitialAdDisplayed(AppDeckAdNetworkMoPub.this);
            }

            @Override
            public void onInterstitialClicked(MoPubInterstitial interstitial) {
                Log.d(TAG, "onInterstitialClicked");
                manager.onInterstitialAdClicked(AppDeckAdNetworkMoPub.this);
            }

            @Override
            public void onInterstitialDismissed(MoPubInterstitial interstitial) {
                Log.d(TAG, "onInterstitialDismissed");
                manager.onInterstitialAdClosed(AppDeckAdNetworkMoPub.this);
            }
        });
        mInterstitial.load();
    }

    public boolean showInterstitial() {
        if (mInterstitial.isReady()) {
            manager.loader.willShowActivity = true;
            mInterstitial.show();
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        if (mInterstitial != null) {
            mInterstitial.destroy();
            mInterstitial = null;
        }
    }

    /* Banner Ads */

    private LinearLayout moPubViewContainer;
    private MoPubView moPubView;

    public boolean supportBanner() {
        if (mopubBannerId == null || mopubBannerId.isEmpty())
            return false;
        return true;
    }
    public void fetchBannerAd() {
        moPubViewContainer = (LinearLayout)LayoutInflater.from(manager.loader).inflate(R.layout.ad_mopub_banner, null);
        moPubView = (MoPubView) moPubViewContainer.findViewById(R.id.mopub_banner);
        moPubView.setAdUnitId(mopubBannerId);
        moPubView.setBannerAdListener(new MoPubView.BannerAdListener() {
            @Override
            public void onBannerLoaded(MoPubView banner) {
                Log.d(TAG, "onBannerLoaded");
                manager.onBannerAdFetched(AppDeckAdNetworkMoPub.this, moPubViewContainer);
            }

            @Override
            public void onBannerFailed(MoPubView banner, MoPubErrorCode errorCode) {
                Log.d(TAG, "onBannerFailed:"+errorCode);
                manager.onBannerAdFailed(AppDeckAdNetworkMoPub.this, moPubViewContainer);
            }

            @Override
            public void onBannerClicked(MoPubView banner) {
                Log.d(TAG, "onBannerClicked");
                manager.onBannerAdClicked(AppDeckAdNetworkMoPub.this, moPubViewContainer);
            }

            @Override
            public void onBannerExpanded(MoPubView banner) {
                Log.d(TAG, "onBannerExpanded");
            }

            @Override
            public void onBannerCollapsed(MoPubView banner) {
                Log.d(TAG, "onBannerCollapsed");
            }
        });
        moPubView.setAutorefreshEnabled(false);
        moPubView.setTesting(true);
        moPubView.loadAd();
    }

    public void destroyBannerAd() {
        if (moPubView != null) {
            moPubView.destroy();
            moPubView = null;
        }
    }



    /* Native Ads */

    public boolean supportNative() {
        if (mopubNativeId == null || mopubNativeId.isEmpty())
            return false;
        return true;
    }



    private NativeResponse mNativeResponse = null;


    AppDeckAdNative mNativeAd = null;

    public void fetchNativeAd()
    {
        requestNewNativeAd();
    }

    public AppDeckAdNative getNativeAd() {
        if (mNativeAd == null)
            requestNewNativeAd();
        AppDeckAdNative nativeAd = mNativeAd;
        mNativeAd = null;
        requestNewNativeAd();
        return nativeAd;
    }

    private void requestNewNativeAd()
    {
        if (mopubNativeId.isEmpty())
            return;
        mNativeAd = new AppDeckAdNetworkMoPubNativeAd(this);
    }



}
