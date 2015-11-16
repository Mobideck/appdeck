package com.mobideck.appdeck;

import android.provider.Settings;
import android.util.Log;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;

import org.json.JSONObject;

public class AppDeckAdNetworkAdMob extends AppDeckAdNetwork {

    public static String TAG = "AdMob";

    public static final String ADMOB_BANNER_ID = "admob_banner_id";
    public static final String ADMOB_RECTANGLE_ID = "admob_rectangle_id";
    public static final String ADMOB_INTERSTITIAL_ID = "admob_interstitial_id";

    public String adMobBannerId = null;
    public String adMobRectangleId = null;
    public String adMobInterstitialId = null;


    public AppDeckAdNetworkAdMob(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            adMobBannerId = conf.optString("adMobBannerId");
            adMobRectangleId = conf.optString("adMobRectangleId");
            adMobInterstitialId = conf.optString("adMobInterstitialId");
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: AdMobBannerId:" + adMobBannerId + " AdMobRectangleId:" + adMobRectangleId + " AdMobInterstitialId:" + adMobInterstitialId);
    }

    /* Interstitial Ads */

    public boolean supportInterstitial() {
        if (adMobInterstitialId == null || adMobInterstitialId.isEmpty())
            return false;
        return true;
    }

    InterstitialAd mInterstitialAd = null;
    AdRequest mInterstitialAdRequest = null;

    public void fetchInterstitialAd()
    {
        if (mInterstitialAd != null && mInterstitialAd.getAdUnitId().equalsIgnoreCase(adMobInterstitialId) == false)
            mInterstitialAd = null;
        if (mInterstitialAd != null)
            return;

        mInterstitialAd = new InterstitialAd(manager.loader);
        mInterstitialAd.setAdUnitId(adMobInterstitialId);
        mInterstitialAd.setAdListener(new AdListener() {

            public static final String TAG = "AdMobInterstitialAd";

            @Override
            public void onAdLoaded() {
                Log.d(TAG, "onAdLoaded");
                manager.onInterstitialAdFetched(AppDeckAdNetworkAdMob.this);
            }

            @Override
            public void onAdClosed() {
                Log.d(TAG, "onAdClosed");
                mInterstitialAd = null;
                manager.onInterstitialAdClosed(AppDeckAdNetworkAdMob.this);
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                Log.d(TAG, "onAdFailedToLoad:"+errorCode);
                manager.onInterstitialAdFailed(AppDeckAdNetworkAdMob.this);
            }

            @Override
            public void onAdOpened() {
                Log.d(TAG, "onAdOpened");
                manager.onInterstitialAdClicked(AppDeckAdNetworkAdMob.this);
            }

        });
        requestNewInterstitial();
    }

    private void requestNewInterstitial() {
        AdRequest.Builder builder = new AdRequest.Builder();

        builder.addTestDevice(com.google.android.gms.ads.AdRequest.DEVICE_ID_EMULATOR);
        builder.addTestDevice("315E930E16E8C801");  // Mobideck Galaxy S4

        if (manager.loader.appDeck.isDebugBuild) //debug flag from somewhere that you set
        {
            String android_id = Settings.Secure.getString(manager.loader.getContentResolver(), Settings.Secure.ANDROID_ID);
            String deviceId = Utils.md5(android_id).toUpperCase();
            builder.addTestDevice(deviceId);
        }

        mInterstitialAdRequest = builder.build();

        boolean isTestDevice = mInterstitialAdRequest.isTestDevice(manager.loader);

        Log.v(TAG, "is Admob Test Device ? " + isTestDevice); //to confirm it worked
        mInterstitialAd.loadAd(mInterstitialAdRequest);
    }


    public boolean showInterstitial() {
        if (mInterstitialAd != null && mInterstitialAd.isLoaded()) {
            manager.loader.willShowActivity = true;
            mInterstitialAd.show();
            manager.onInterstitialAdDisplayed(AppDeckAdNetworkAdMob.this);
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        mInterstitialAd = null;
    }

    /* Banner Ads */

    AdView mBannerAd = null;
    AdRequest mBannerAdRequest = null;

    public boolean supportBanner() {
        if (adMobBannerId == null || adMobBannerId.isEmpty())
            return false;
        return true;
    }

    boolean bannerFetchedCalled;

    public void fetchBannerAd()
    {
        if (mBannerAd != null && mBannerAd.getAdUnitId().equalsIgnoreCase(adMobBannerId) == false)
            mBannerAd = null;
        bannerFetchedCalled = false;
        mBannerAd = new AdView(manager.loader);
        /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mBannerAd.setElevation(2.0f);
        }*/
        mBannerAd.setAdSize(AdSize.BANNER);
        mBannerAd.setAdUnitId(adMobBannerId);
        mBannerAd.setAdListener(new AdListener() {

            public static final String TAG = "AdMobBannerAd";

            @Override
            public void onAdLoaded() {
                // Code to be executed when an ad finishes loading.
                Log.d(TAG, "onAdLoaded");

                if (bannerFetchedCalled == false) {
                    manager.onBannerAdFetched(AppDeckAdNetworkAdMob.this, mBannerAd);
                    bannerFetchedCalled = true;
                }
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                // Code to be executed when an ad request fails.

                if (errorCode == AdRequest.ERROR_CODE_INTERNAL_ERROR)
                    Log.e(TAG, "onAdFailedToLoad: Internal Error");
                else if (errorCode == AdRequest.ERROR_CODE_INVALID_REQUEST)
                    Log.e(TAG, "onAdFailedToLoad: Invalid Request");
                else if (errorCode == AdRequest.ERROR_CODE_NETWORK_ERROR)
                    Log.e(TAG, "onAdFailedToLoad: Network Error");
                else if (errorCode == AdRequest.ERROR_CODE_NO_FILL)
                    Log.e(TAG, "onAdFailedToLoad: No Fill");
                else
                    Log.e(TAG, "onAdFailedToLoad: Unknow Error: " + errorCode);

                manager.onBannerAdFailed(AppDeckAdNetworkAdMob.this, mBannerAd);

            }

            @Override
            public void onAdOpened() {
                // Code to be executed when an ad opens an overlay that
                // covers the screen.
                Log.d(TAG, "onAdOpened");
                manager.onBannerAdClicked(AppDeckAdNetworkAdMob.this, mBannerAd);
                manager.loader.willShowActivity = true;
            }

            @Override
            public void onAdLeftApplication() {
                // Code to be executed when the user has left the app.
                Log.d(TAG, "onAdLeftApplication");
                //if (bannerAdView != null) {
                //    rootView.removeView(bannerAdView);
                //    bannerAdView.destroy();
                //    bannerAdView = null;
                //}
            }

            @Override
            public void onAdClosed() {
                // Code to be executed when when the user is about to return
                // to the app after tapping on an ad.
                Log.d(TAG, "onAdClosed");
                manager.onBannerAdClosed(AppDeckAdNetworkAdMob.this, mBannerAd);
            }
        });

        requestNewBanner(mBannerAd);
    }

    private void requestNewBanner(AdView adView) {
        AdRequest.Builder builder = new AdRequest.Builder();
        builder.addTestDevice(com.google.android.gms.ads.AdRequest.DEVICE_ID_EMULATOR);
        builder.addTestDevice("315E930E16E8C801");  // Mobideck Galaxy S4
        if (manager.loader.appDeck.isDebugBuild) //debug flag from somewhere that you set
        {
            String android_id = Settings.Secure.getString(manager.loader.getContentResolver(), Settings.Secure.ANDROID_ID);
            String deviceId = Utils.md5(android_id).toUpperCase();
            builder.addTestDevice(deviceId);
        }
        mBannerAdRequest = builder.build();
        adView.loadAd(mBannerAdRequest);
    }


}
