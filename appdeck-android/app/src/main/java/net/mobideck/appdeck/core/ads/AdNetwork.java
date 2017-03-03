package net.mobideck.appdeck.core.ads;

import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.widget.FrameLayout;

import net.mobideck.appdeck.AppDeckApplication;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 10/11/15.
 */
public class AdNetwork {

    public static String TAG = "AdNetWork";

    AdNetwork() {}

    public AdManager manager;
    JSONObject conf;

    private boolean enableInterstitial;
    private boolean enableRectangle;
    private boolean enableBanner;
    private long timeBetweenBannerRefresh;

    public AdNetwork(AdManager manager, JSONObject conf)
    {
        this.manager = manager;
        this.conf = conf;
        // read ads configuration
        enableInterstitial = conf.optBoolean("enableInterstitial", true);
        enableRectangle = conf.optBoolean("enableRectangle", true);
        enableBanner = conf.optBoolean("enableBanner", true);
        timeBetweenBannerRefresh = conf.optLong("timeBetweenBannerRefresh", 0);
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
        // no view to setup
        if (adView == null)
            return;

        // view already setup
        if (adView == bannerAdView)
            return;

        FrameLayout container = AppDeckApplication.getActivity().getBannerAdViewContainer();
        if (container == null)
            return;
        if (bannerAdView != null)
            container.removeView(bannerAdView);

        bannerAdView = adView;
        if (bannerAdView.getParent() == container)
            container.removeView(bannerAdView);

        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        layoutParams.gravity = Gravity.CENTER | Gravity.BOTTOM;

        container.addView(adView, layoutParams);

        container.bringChildToFront(adView);

        AlphaAnimation animation = new AlphaAnimation( 0.0f, 1.0f );
        animation.setDuration(250);
        animation.setFillAfter(true);
        animation.setInterpolator(new AccelerateInterpolator());
        bannerAdView.startAnimation(animation);
    }

    public void removeBannerViewInLoader()
    {
        FrameLayout container = AppDeckApplication.getActivity().getBannerAdViewContainer();

        if (container == null)
            return;

        container.removeAllViews();

        bannerAdView = null;
    }

    /* Native Ads */
/*
    public boolean supportNative() { return false; }
    public void fetchNativeAd() {}
    public AppDeckAdNative getNativeAd() { return null; }
*/

    /* Utils */

    public String getName() { return getClass().getSimpleName(); }

    /* config api */

    public long getTimeBetweenBannerRefresh() {
        if (timeBetweenBannerRefresh == 0)
            return manager.timeBetweenBannerRefresh;
        return timeBetweenBannerRefresh;
    }

    public boolean interstitialEnabled() {
        return enableInterstitial;
    }
    public boolean rectangleEnabled() {
        return enableRectangle;
    }
    public boolean bannerEnabled() {
        return enableBanner;
    }

    /* Activity Api */

    public void onActivityResume()
    {

    }

    public void onActivityPause()
    {

    }

    public void onActivitySaveInstanceState(Bundle outState){
    }

    public void onActivityRestoreInstanceState(Bundle outState){
    }
}
