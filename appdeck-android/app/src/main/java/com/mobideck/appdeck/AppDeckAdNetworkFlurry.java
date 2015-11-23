package com.mobideck.appdeck;

import android.util.Log;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import com.flurry.android.FlurryAgent;
import com.flurry.android.ads.FlurryAdErrorType;
import com.flurry.android.ads.FlurryAdInterstitial;
import com.flurry.android.ads.FlurryAdInterstitialListener;
import com.flurry.android.ads.FlurryAdBanner;
import com.flurry.android.ads.FlurryAdBannerListener;
import com.flurry.android.ads.FlurryAdTargeting;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 13/11/15.
 */
public class AppDeckAdNetworkFlurry extends AppDeckAdNetwork {


    public static String TAG = "Flurry";

    public String flurryApiKey = "";
    public String flurryBannerId = "";
    public String flurryRectangleId = "";
    public String flurryInterstitialId = "";
    public String flurryNativeId = "";

    public AppDeckAdNetworkFlurry(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            flurryApiKey = conf.optString("flurryApiKey");
            flurryBannerId = conf.optString("flurryBannerId");
            flurryRectangleId = conf.optString("flurryRectangleId");
            flurryInterstitialId = conf.optString("flurryInterstitialId");
            flurryNativeId = conf.optString("flurryNativeId");
        } catch (Exception e) {
            e.printStackTrace();
        }

        // configure Flurry
        FlurryAgent.setLogEnabled(true);
        // init Flurry
        FlurryAgent.init(manager.loader, flurryApiKey);


        Log.i(TAG, "Read: flurryApiKey:" + flurryApiKey + " flurryBannerId:" + flurryBannerId + " flurryRectangleId:" + flurryRectangleId + " flurryInterstitialId:" + flurryInterstitialId + " flurryNativeId:" + flurryNativeId);

    }

    /* Interstitial Ads */

    private FlurryAdInterstitial mFlurryAdInterstitial = null;

    public boolean supportInterstitial() {
        if (flurryInterstitialId == null || flurryInterstitialId.isEmpty())
            return false;
        return true;
    }
    public void fetchInterstitialAd() {
        mFlurryAdInterstitial = new FlurryAdInterstitial(manager.loader, flurryInterstitialId);

        // allow us to get callbacks for ad events
        mFlurryAdInterstitial.setListener(new FlurryAdInterstitialListener() {
            @Override
            public void onFetched(FlurryAdInterstitial flurryAdInterstitial) {
                Log.d(TAG, "onInterstitialAdFetched");
                manager.onInterstitialAdFetched(AppDeckAdNetworkFlurry.this);
            }

            @Override
            public void onRendered(FlurryAdInterstitial flurryAdInterstitial) {
                Log.d(TAG, "onInterstitialAdRendered");
            }

            @Override
            public void onDisplay(FlurryAdInterstitial flurryAdInterstitial) {
                Log.d(TAG, "onInterstitialAdDisplay");
                manager.onInterstitialAdDisplayed(AppDeckAdNetworkFlurry.this);
            }

            @Override
            public void onClose(FlurryAdInterstitial flurryAdInterstitial) {
                Log.d(TAG, "onInterstitialAdClose");
                manager.onInterstitialAdClosed(AppDeckAdNetworkFlurry.this);
            }

            @Override
            public void onAppExit(FlurryAdInterstitial flurryAdInterstitial) {
                Log.d(TAG, "onInterstitialAdAppExit");
            }

            @Override
            public void onClicked(FlurryAdInterstitial flurryAdInterstitial) {
                Log.d(TAG, "onInterstitialAdClicked");
                manager.onInterstitialAdClicked(AppDeckAdNetworkFlurry.this);
            }

            @Override
            public void onVideoCompleted(FlurryAdInterstitial flurryAdInterstitial) {
                Log.d(TAG, "onInterstitialAdCompleted");
            }

            @Override
            public void onError(FlurryAdInterstitial flurryAdInterstitial, FlurryAdErrorType flurryAdErrorType, int i) {
                Log.d(TAG, "onInterstitialAdError:"+flurryAdErrorType.toString()+":"+i);
                manager.onInterstitialAdFailed(AppDeckAdNetworkFlurry.this);
            }
        });
        if (manager.shouldEnableTestMode()) {
            FlurryAdTargeting adTargeting = new FlurryAdTargeting();
            adTargeting.setEnableTestAds(true);
            mFlurryAdInterstitial.setTargeting(adTargeting);
        }
        mFlurryAdInterstitial.fetchAd();
    }

    public boolean showInterstitial() {
        if (mFlurryAdInterstitial.isReady()) {
            manager.loader.willShowActivity = true;
            mFlurryAdInterstitial.displayAd();
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        mFlurryAdInterstitial.destroy();
        mFlurryAdInterstitial = null;
    }


    /* Banner Ads */

    private LinearLayout mFlurryAdBannerContainer;
    private FlurryAdBanner mFlurryAdBanner = null;

    public boolean supportBanner() {
        if (flurryBannerId == null || flurryBannerId.isEmpty())
            return false;
        return true;
    }
    public void fetchBannerAd() {
        mFlurryAdBannerContainer = (LinearLayout) LayoutInflater.from(manager.loader).inflate(R.layout.ad_flurry_banner, null);
        mFlurryAdBanner = new FlurryAdBanner(manager.loader, mFlurryAdBannerContainer, flurryBannerId);
        mFlurryAdBanner.setListener(new FlurryAdBannerListener() {
            @Override
            public void onFetched(FlurryAdBanner flurryAdBanner) {
                Log.d(TAG, "onBannerAdFetched");
                manager.onBannerAdFetched(AppDeckAdNetworkFlurry.this, mFlurryAdBannerContainer);
                mFlurryAdBanner.displayAd();
            }

            @Override
            public void onRendered(FlurryAdBanner flurryAdBanner) {
                Log.d(TAG, "onBannerAdRendered");
            }

            @Override
            public void onShowFullscreen(FlurryAdBanner flurryAdBanner) {
                Log.d(TAG, "onBannerAdShowFullscreen");
            }

            @Override
            public void onCloseFullscreen(FlurryAdBanner flurryAdBanner) {
                Log.d(TAG, "onBannerAdCloseFullscreen");
            }

            @Override
            public void onAppExit(FlurryAdBanner flurryAdBanner) {
                Log.d(TAG, "onBannerAdAppExit");
            }

            @Override
            public void onClicked(FlurryAdBanner flurryAdBanner) {
                Log.d(TAG, "onBannerAdClicked");
                manager.onBannerAdClicked(AppDeckAdNetworkFlurry.this, mFlurryAdBannerContainer);
            }

            @Override
            public void onVideoCompleted(FlurryAdBanner flurryAdBanner) {
                Log.d(TAG, "onBannerAdVideoComplete");
            }

            @Override
            public void onError(FlurryAdBanner flurryAdBanner, FlurryAdErrorType flurryAdErrorType, int i) {
                Log.d(TAG, "onBannerAdError:" + flurryAdErrorType.toString() + ":" + i);
                manager.onBannerAdFailed(AppDeckAdNetworkFlurry.this, mFlurryAdBannerContainer);
            }
        });
        if (manager.shouldEnableTestMode()) {
            FlurryAdTargeting adTargeting = new FlurryAdTargeting();
            adTargeting.setEnableTestAds(true);
            mFlurryAdBanner.setTargeting(adTargeting);
        }
        mFlurryAdBanner.fetchAd();
    }

    public void destroyBannerAd() {
        if (mFlurryAdBanner != null)
            mFlurryAdBanner.destroy();
        mFlurryAdBanner = null;
    }


    /* Native Ads */

    AppDeckAdNative mNativeAd = null;

    public boolean supportNative() {
        if (flurryNativeId == null || flurryNativeId.isEmpty())
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
        mNativeAd = new AppDeckAdNetworkFlurryNativeAd(this);
    }

/*
    adBanner = new FlurryAdBanner(this, fContainer, "UFB Android Banner");
    adBanner.fetchAndDisplayAd();
    */
}
