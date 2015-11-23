package com.mobideck.appdeck;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.startapp.android.publish.Ad;
import com.startapp.android.publish.AdDisplayListener;
import com.startapp.android.publish.AdEventListener;
import com.startapp.android.publish.StartAppAd;
import com.startapp.android.publish.StartAppSDK;
import com.startapp.android.publish.banner.Banner;
import com.startapp.android.publish.banner.BannerListener;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 17/11/15.
 */
public class AppDeckAdNetworkStartApp extends AppDeckAdNetwork {


    public static String TAG = "StartApp";

    public String startAppId = "";
    public String startAppEnableIntertitial = "";
    public String startAppEnableBanner = "";
    public String startAppEnableNative = "";

    public AppDeckAdNetworkStartApp(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            startAppId = conf.optString("startAppId");
            startAppEnableIntertitial = conf.optString("startAppEnableIntertitial");
            startAppEnableBanner = conf.optString("startAppEnableBanner");
            startAppEnableNative = conf.optString("startAppEnableNative");
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (startAppId != null && !startAppId.isEmpty())
            StartAppSDK.init(manager.loader, startAppId, false);

        Log.i(TAG, "Read: startAppId:" + startAppId + " startAppEnableIntertitial:" + startAppEnableIntertitial + " startAppEnableBanner:" + startAppEnableBanner + " startAppEnableNative:" + startAppEnableNative);

    }

    /* Interstitial Ads */

    private StartAppAd mStartAppInterstitialAd;

    public boolean supportInterstitial() {
        if (startAppId == null || startAppId.isEmpty() || startAppEnableIntertitial == null || startAppEnableIntertitial.isEmpty() || startAppEnableIntertitial.equalsIgnoreCase("no"))
            return false;
        return true;
    }
    public void fetchInterstitialAd() {

        mStartAppInterstitialAd = new StartAppAd(manager.loader);

        mStartAppInterstitialAd.loadAd(new AdEventListener() {
            @Override
            public void onReceiveAd(Ad ad) {
                Log.d(TAG, "onReceiveAd");
                manager.onInterstitialAdFetched(AppDeckAdNetworkStartApp.this);
            }

            @Override
            public void onFailedToReceiveAd(Ad ad) {
                Log.d(TAG, "onFailedToReceiveAd");
                manager.onInterstitialAdFailed(AppDeckAdNetworkStartApp.this);
            }
        });
    }

    public boolean showInterstitial() {
        if (mStartAppInterstitialAd.isReady()) {
            mStartAppInterstitialAd.showAd((new AdDisplayListener() {
                @Override
                public void adHidden(Ad ad) {
                    Log.d(TAG, "adHidden");
                    manager.onInterstitialAdClosed(AppDeckAdNetworkStartApp.this);
                }
                @Override
                public void adDisplayed(Ad ad) {
                    Log.d(TAG, "adDisplayed");
                    manager.onInterstitialAdDisplayed(AppDeckAdNetworkStartApp.this);
                }
                @Override
                public void adClicked(Ad ad) {
                    Log.d(TAG, "adClicked");
                    manager.onInterstitialAdClicked(AppDeckAdNetworkStartApp.this);
                }

                @Override
                public void adNotDisplayed(Ad ad) {
                    Log.d(TAG, "adNotDisplayed");
                }
            }));
            manager.onInterstitialAdDisplayed(AppDeckAdNetworkStartApp.this);
        }
        return true;
    }

    public void destroyInterstitial() {
        if (mStartAppInterstitialAd != null) {
            mStartAppInterstitialAd.close();
            mStartAppInterstitialAd = null;
        }
    }


    /* Banner Ads */

    Banner mBannerAd;

    public boolean supportBanner() {
        if (startAppId == null || startAppId.isEmpty() || startAppEnableBanner == null || startAppEnableBanner.isEmpty() || startAppEnableBanner.equalsIgnoreCase("no"))
            return false;
        return true;
    }
    public void fetchBannerAd() {
        mBannerAd = new Banner(manager.loader, new BannerListener() {
            @Override
            public void onReceiveAd(View banner) {
                Log.d(TAG, "onReceiveAd");
                manager.onBannerAdFetched(AppDeckAdNetworkStartApp.this, mBannerAd);

            }
            @Override
            public void onFailedToReceiveAd(View banner) {
                Log.d(TAG, "onFailedToReceiveAd");
                manager.onBannerAdClosed(AppDeckAdNetworkStartApp.this, mBannerAd);
            }
            @Override
            public void onClick(View banner) {
                Log.d(TAG, "onClick");
                manager.onBannerAdClicked(AppDeckAdNetworkStartApp.this, mBannerAd);
            }
        });

        setupBannerViewInLoader(mBannerAd);
        mBannerAd.showBanner();

    }

    public void destroyBannerAd() {
        if (mBannerAd != null) {
            mBannerAd.hideBanner();
            mBannerAd = null;
        }
    }


    /* Activity Api */

    public void onActivityResume()
    {
        if (mStartAppInterstitialAd != null)
            mStartAppInterstitialAd.onResume();
    }

    public void onActivityPause()
    {
        if (mStartAppInterstitialAd != null)
            mStartAppInterstitialAd.onPause();
    }

    public void onActivitySaveInstanceState(Bundle outState) {
        if (mStartAppInterstitialAd != null)
            mStartAppInterstitialAd.onSaveInstanceState(outState);
    }

    public void onActivityRestoreInstanceState(Bundle outState) {
        if (mStartAppInterstitialAd != null)
            mStartAppInterstitialAd.onRestoreInstanceState(outState);

    }
}
