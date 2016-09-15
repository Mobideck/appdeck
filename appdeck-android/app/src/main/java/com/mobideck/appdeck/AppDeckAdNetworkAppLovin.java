package com.mobideck.appdeck;

import android.util.Log;
import android.widget.LinearLayout;

import com.applovin.adview.AppLovinInterstitialAd;
import com.applovin.adview.AppLovinInterstitialAdDialog;
import com.applovin.sdk.AppLovinAd;
import com.applovin.sdk.AppLovinAdClickListener;
import com.applovin.sdk.AppLovinAdDisplayListener;
import com.applovin.sdk.AppLovinAdLoadListener;
import com.applovin.sdk.AppLovinAdSize;
import com.applovin.sdk.AppLovinSdk;
import com.applovin.sdk.AppLovinSdkSettings;

import org.json.JSONObject;

public class AppDeckAdNetworkAppLovin extends AppDeckAdNetwork {

    public static String TAG = "AerServ";

    public String appLovinSdkKey = "";
    //public String appLovinBannerId = "";
    //public String appLovinRectangleId = "";
    public String appLovinInterstitialId = "";
    public String appLovinNativeId = "";

    private AppLovinSdk appLovinSdk = null;

    public AppDeckAdNetworkAppLovin(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            appLovinSdkKey= conf.optString("appLovinSdkKey");
            //appLovinBannerId= conf.optString("appLovinBannerId");
            //appLovinRectangleId= conf.optString("appLovinRectangleId");
            appLovinInterstitialId= conf.optString("appLovinInterstitialId");
            appLovinNativeId= conf.optString("appLovinNativeId");
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (appLovinSdkKey != null && !appLovinSdkKey.isEmpty()) {
            AppLovinSdkSettings settings = new AppLovinSdkSettings();
            if (manager.shouldEnableTestMode())
                settings.setVerboseLogging(true);
            settings.setBannerAdRefreshSeconds(0);
            //settings.setAutoPreloadSizes("INTERSTITIAL");
            //settings.setAutoPreloadTypes("REGULAR");
            appLovinSdk = AppLovinSdk.getInstance(appLovinSdkKey, settings, manager.loader);
        }

        Log.i(TAG, "Read: appLovinSdkKey:" + appLovinSdkKey + /*"appLovinBannerId:" + appLovinBannerId+ " appLovinRectangleId:" + appLovinRectangleId+*/ " appLovinInterstitialId:" + appLovinInterstitialId+ " appLovinNativeId:" + appLovinNativeId);

    }


        /* Interstitial Ads */

    private AppLovinInterstitialAdDialog mInterstitial;

    public boolean supportInterstitial() {
        if (appLovinSdkKey != null && !appLovinSdkKey.isEmpty() && appLovinInterstitialId != null && !appLovinInterstitialId.isEmpty())
            return true;
        return false;
    }
    public void fetchInterstitialAd() {

        mInterstitial = AppLovinInterstitialAd.create(appLovinSdk, manager.loader);

        mInterstitial.setAdDisplayListener(new AppLovinAdDisplayListener() {
            @Override
            public void adDisplayed(AppLovinAd appLovinAd) {
                Log.d(TAG, "onInterstitialAdDisplayed");
                manager.onInterstitialAdDisplayed(AppDeckAdNetworkAppLovin.this);
            }
            @Override
            public void adHidden(AppLovinAd appLovinAd) {
                // An interstitial ad was hidden.
                Log.d(TAG, "onInterstitialAdClosed");
                manager.onInterstitialAdClosed(AppDeckAdNetworkAppLovin.this);
            }
        });

        mInterstitial.setAdClickListener(new AppLovinAdClickListener() {
            @Override
            public void adClicked(AppLovinAd appLovinAd) {
                Log.d(TAG, "onInterstitialClicked");
                manager.onInterstitialAdClicked(AppDeckAdNetworkAppLovin.this);
            }
        });

        appLovinSdk.getAdService().loadNextAd(AppLovinAdSize.INTERSTITIAL, new AppLovinAdLoadListener() {
            @Override
            public void adReceived(AppLovinAd appLovinAd) {
                Log.d(TAG, "onInterstitialFetched");
                manager.onInterstitialAdFetched(AppDeckAdNetworkAppLovin.this);
            }

            @Override
            public void failedToReceiveAd(int i) {
                Log.d(TAG, "onInterstitialFailed:"+ i);
                manager.onInterstitialAdFailed(AppDeckAdNetworkAppLovin.this);
            }
        });

    }

    public boolean showInterstitial() {
        if (mInterstitial != null && mInterstitial.isAdReadyToDisplay()) {
            manager.loader.willShowActivity = true;
            mInterstitial.show();
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        if (mInterstitial != null) {
            mInterstitial = null;
        }
    }
}
