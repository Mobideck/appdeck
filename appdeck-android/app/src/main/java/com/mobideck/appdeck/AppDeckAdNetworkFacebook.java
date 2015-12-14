package com.mobideck.appdeck;

import android.util.Log;

import org.json.JSONObject;
import com.facebook.ads.*;

/**
 * Created by mathieudekermadec on 13/11/15.
 */
public class AppDeckAdNetworkFacebook extends AppDeckAdNetwork {


    public static String TAG = "Facebook";

    public String facebookBannerId = "";
    public String facebookRectangleId = "";
    public String facebookInterstitialId = "";
    public String facebookNativeId = "";

    public AppDeckAdNetworkFacebook(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            facebookBannerId = conf.optString("facebookBannerId");
            facebookRectangleId = conf.optString("facebookRectangleId");
            facebookInterstitialId = conf.optString("facebookInterstitialId");
            facebookNativeId = conf.optString("facebookNativeId");
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: facebookBannerId:" + facebookBannerId + " facebookRectangleId:" + facebookRectangleId + " facebookInterstitialId:" + facebookInterstitialId + " facebookNativeId:" + facebookNativeId);

    }

    /* Interstitial Ads */

    private InterstitialAd interstitialAd;


    public boolean supportInterstitial() {
        if (facebookInterstitialId == null || facebookInterstitialId.isEmpty())
            return false;
        return true;
    }
    public void fetchInterstitialAd() {
        interstitialAd = new InterstitialAd(manager.loader, facebookInterstitialId);
        interstitialAd.setAdListener(new InterstitialAdListener() {

            @Override
            public void onInterstitialDisplayed(Ad ad) {
                Log.d(TAG, "onInterstitialDisplayed");
                manager.onInterstitialAdDisplayed(AppDeckAdNetworkFacebook.this);
            }

            @Override
            public void onInterstitialDismissed(Ad ad) {
                Log.d(TAG, "onInterstitialDismissed");
                manager.onInterstitialAdClosed(AppDeckAdNetworkFacebook.this);
            }

            @Override
            public void onError(Ad ad, AdError adError) {
                Log.d(TAG, "onInterstitialError");
                manager.onInterstitialAdFailed(AppDeckAdNetworkFacebook.this);
            }

            @Override
            public void onAdLoaded(Ad ad) {
                Log.d(TAG, "onInterstitialAdLoaded");
                manager.onInterstitialAdFetched(AppDeckAdNetworkFacebook.this);
            }

            @Override
            public void onAdClicked(Ad ad) {
                Log.d(TAG, "onInterstitialAdClicked");
                manager.onInterstitialAdClicked(AppDeckAdNetworkFacebook.this);
            }
        });
        interstitialAd.loadAd();
    }

    public boolean showInterstitial() {
        if (interstitialAd.isAdLoaded()) {
            manager.loader.willShowActivity = true;
            interstitialAd.show();
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        if (interstitialAd != null)
            interstitialAd.destroy();
        interstitialAd = null;
    }

    /* Banner Ads */

    private AdView adView;

    public boolean supportBanner() {
        if (facebookBannerId == null || facebookBannerId.isEmpty())
            return false;
        return true;
    }

    public void fetchBannerAd() {
        adView = new AdView(manager.loader, facebookBannerId, (manager.loader.appDeck.isTablet ?  AdSize.BANNER_HEIGHT_90 : AdSize.BANNER_HEIGHT_50));
        adView.setAdListener(new AdListener() {
            @Override
            public void onError(Ad ad, AdError adError) {
                Log.d(TAG, "onBannerAdError");
                manager.onBannerAdFailed(AppDeckAdNetworkFacebook.this, adView);
            }

            @Override
            public void onAdLoaded(Ad ad) {
                Log.d(TAG, "onBannerAdLoaded");
                manager.onBannerAdFetched(AppDeckAdNetworkFacebook.this, adView);
            }

            @Override
            public void onAdClicked(Ad ad) {
                Log.d(TAG, "onBannerAdClicked");
                manager.onBannerAdClicked(AppDeckAdNetworkFacebook.this, adView);
            }
        });
        adView.loadAd();
    }
    public void destroyBannerAd() {
        adView.destroy();
    }

    /* Native Ads */

    AppDeckAdNative mNativeAd = null;

    public boolean supportNative() {
        if (facebookNativeId == null || facebookNativeId.isEmpty())
            return false;
        return true;
    }

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
        mNativeAd = new AppDeckAdNetworkFacebookNativeAd(this);
    }

    public String getName() { return TAG; }

}
