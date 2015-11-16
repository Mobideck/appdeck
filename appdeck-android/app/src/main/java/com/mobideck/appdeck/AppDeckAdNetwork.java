package com.mobideck.appdeck;

import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 10/11/15.
 */
public class AppDeckAdNetwork {

    public static String TAG = "AdNetWork";

    AppDeckAdNetwork() {}

    AppDeckAdManager manager;
    JSONObject conf;

    public AppDeckAdNetwork(AppDeckAdManager manager, JSONObject conf)
    {
        this.manager = manager;
        this.conf = conf;
    }


    public boolean supportRectangle() { return false; }

    /* Interstitial Ads */

    public boolean supportInterstitial() { return false; }
    public void fetchInterstitialAd() {}
    public boolean showInterstitial() { return false; }
    public void destroyInterstitial() {}

    /* Banner Ads */

    public boolean supportBanner() { return false; }
    public void fetchBannerAd() {}
    public void destroyBannerAd() {}


    protected View bannerAdView;

    public void setupBannerViewInLoader(View adView)
    {
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        layoutParams.gravity = Gravity.CENTER | Gravity.BOTTOM;
        FrameLayout container = manager.loader.getBannerAdViewContainer();

        if (container == null)
            return;

        bannerAdView = adView;

        container.addView(adView, layoutParams);

        container.bringChildToFront(adView);

    }

    public void removeBannerViewInLoader()
    {
        FrameLayout container = manager.loader.getBannerAdViewContainer();

        if (container == null)
            return;

        container.removeView(bannerAdView);

        bannerAdView = null;
    }

    /* Native Ads */

    public boolean supportNative() { return false; }
    public void fetchNativeAd() {}
    public AppDeckAdNative getNativeAd() { return null; }

    public String getName() { return TAG; }


}
