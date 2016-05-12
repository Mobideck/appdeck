package com.mobideck.appdeck;

import android.os.Build;
import android.util.Log;
import android.widget.FrameLayout;

import com.widespace.AdInfo;
import com.widespace.AdSpace;
import com.widespace.adspace.models.PrefetchStatus;
import com.widespace.exception.ExceptionTypes;
import com.widespace.interfaces.AdErrorEventListener;
import com.widespace.interfaces.AdEventListener;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 13/11/15.
 */
public class AppDeckAdNetworkWideSpace extends AppDeckAdNetwork {


    public static String TAG = "WideSpace";

    public String widespaceBannerSiteId = "";
    public String widespaceInterstitialSiteId = "";
    public String widespaceRectangleSiteId = "";

    public AppDeckAdNetworkWideSpace(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            widespaceBannerSiteId = conf.optString("widespaceBannerSiteId");
            widespaceInterstitialSiteId = conf.optString("widespaceInterstitialSiteId");
            widespaceRectangleSiteId = conf.optString("widespaceRectangleSiteId");
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: widespaceBannerSiteId:" + widespaceBannerSiteId + " widespaceInterstitialSiteId:" + widespaceInterstitialSiteId + " widespaceRectangleSiteId:" + widespaceRectangleSiteId);

    }


    /* Interstitial Ads */

    private AdSpace mInterstitialAdSpace;

    public boolean supportInterstitial() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT)
            return false;
        if (widespaceInterstitialSiteId == null || widespaceInterstitialSiteId.isEmpty())
            return false;
        return true;
    }

    public void fetchInterstitialAd() {
        mInterstitialAdSpace = new AdSpace(manager.loader, widespaceInterstitialSiteId, false, false); //sid, autoStart, autoUpdate
        mInterstitialAdSpace.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));

        mInterstitialAdSpace.setAdEventListener(new AdEventListener() {
            @Override
            public void onAdClosing(AdSpace adSpace, AdInfo.AdType adType) {
                Log.d(TAG, "onInterstitialAdClosing");
            }

            @Override
            public void onAdClosed(AdSpace adSpace, AdInfo.AdType adType) {
                Log.d(TAG, "onInterstitialAdClosed");
                manager.onInterstitialAdClosed(AppDeckAdNetworkWideSpace.this);
            }

            @Override
            public void onAdLoading(AdSpace adSpace) {
                Log.d(TAG, "onInterstitialAdLoading");
            }

            @Override
            public void onAdLoaded(AdSpace adSpace, AdInfo.AdType adType) {
                Log.d(TAG, "onInterstitialAdLoaded");

            }

            @Override
            public void onNoAdRecieved(AdSpace adSpace) {
                Log.d(TAG, "onInterstitialNoAdRecieved");
                manager.onInterstitialAdFailed(AppDeckAdNetworkWideSpace.this);
            }

            @Override
            public void onPrefetchAd(AdSpace adSpace, PrefetchStatus prefetchStatus) {
                Log.d(TAG, "onInterstitialPrefetchAd");
                manager.onInterstitialAdFetched(AppDeckAdNetworkWideSpace.this);
            }

            @Override
            public void onAdPresenting(AdSpace adSpace, boolean b, AdInfo.AdType adType) {
                Log.d(TAG, "onInterstitialAdPresenting");
            }

            @Override
            public void onAdPresented(AdSpace adSpace, boolean b, AdInfo.AdType adType) {
                Log.d(TAG, "onInterstitialAdPresented");
            }

            @Override
            public void onAdDismissing(AdSpace adSpace, boolean b, AdInfo.AdType adType) {
                Log.d(TAG, "onInterstitialAdDismissing");
            }

            @Override
            public void onAdDismissed(AdSpace adSpace, boolean b, AdInfo.AdType adType) {
                Log.d(TAG, "onInterstitialAdDismissed");
            }
        });

        mInterstitialAdSpace.setAdErrorEventListener(new AdErrorEventListener() {
            @Override
            public void onFailedWithError(Object o, ExceptionTypes exceptionTypes, String s, Exception e) {
                manager.onInterstitialAdFailed(AppDeckAdNetworkWideSpace.this);
            }
        });

        mInterstitialAdSpace.prefetchAd();
        //mInterstitialAdSpace.runAd();
    }

    public boolean showInterstitial() {
        //if (mInterstitialAdSpace.) {
            manager.loader.willShowActivity = true;
        manager.loader.getInterstitialAdViewContainer().addView(mInterstitialAdSpace);
        mInterstitialAdSpace.runAd();
            return true;
        //}
        //return false;
    }

    public void destroyInterstitial() {
        if (mInterstitialAdSpace != null) {
            manager.loader.getInterstitialAdViewContainer().removeView(mInterstitialAdSpace);
            mInterstitialAdSpace.destroy();
        }
        mInterstitialAdSpace = null;
    }


    /* Banner Ads */

    private AdSpace mBannerAdSpace;

    public boolean supportBanner() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT)
            return false;
        if (widespaceBannerSiteId == null || widespaceBannerSiteId.isEmpty())
            return false;
        return true;
    }
    public void fetchBannerAd() {
        mBannerAdSpace = new AdSpace(manager.loader, widespaceBannerSiteId, false, false); //sid, autoStart, autoUpdate


        mBannerAdSpace.setAdEventListener(new AdEventListener() {
            @Override
            public void onAdClosing(AdSpace adSpace, AdInfo.AdType adType) {
                Log.d(TAG, "onBannerAdClosing");
            }

            @Override
            public void onAdClosed(AdSpace adSpace, AdInfo.AdType adType) {
                Log.d(TAG, "onBannerAdClosed");
                manager.onBannerAdClosed(AppDeckAdNetworkWideSpace.this, adSpace);
            }

            @Override
            public void onAdLoading(AdSpace adSpace) {
                Log.d(TAG, "onBannerAdLoading");
            }

            @Override
            public void onAdLoaded(AdSpace adSpace, AdInfo.AdType adType) {
                Log.d(TAG, "onBannerAdLoaded");

            }

            @Override
            public void onNoAdRecieved(AdSpace adSpace) {
                Log.d(TAG, "onBannerNoAdRecieved");
                manager.onBannerAdFailed(AppDeckAdNetworkWideSpace.this, adSpace);
            }

            @Override
            public void onPrefetchAd(AdSpace adSpace, PrefetchStatus prefetchStatus) {
                Log.d(TAG, "onBannerPrefetchAd");
                manager.onBannerAdFetched(AppDeckAdNetworkWideSpace.this, adSpace);
                mBannerAdSpace.runAd();
            }

            @Override
            public void onAdPresenting(AdSpace adSpace, boolean b, AdInfo.AdType adType) {
                Log.d(TAG, "onBannerAdPresenting");
            }

            @Override
            public void onAdPresented(AdSpace adSpace, boolean b, AdInfo.AdType adType) {
                Log.d(TAG, "onBannerAdPresented");
            }

            @Override
            public void onAdDismissing(AdSpace adSpace, boolean b, AdInfo.AdType adType) {
                Log.d(TAG, "onBannerAdDismissing");
            }

            @Override
            public void onAdDismissed(AdSpace adSpace, boolean b, AdInfo.AdType adType) {
                Log.d(TAG, "onBannerAdDismissed");
            }
        });

        mBannerAdSpace.setAdErrorEventListener(new AdErrorEventListener() {
            @Override
            public void onFailedWithError(Object o, ExceptionTypes exceptionTypes, String s, Exception e) {
                manager.onBannerAdFailed(AppDeckAdNetworkWideSpace.this, mBannerAdSpace);
            }
        });

        //manager.loader.getBannerAdViewContainer().addView(bannerAdSpace);
        mBannerAdSpace.prefetchAd();

    }

    public void destroyBannerAd() {
        if (mBannerAdSpace != null)
            mBannerAdSpace.destroy();
        mBannerAdSpace = null;
    }

}
