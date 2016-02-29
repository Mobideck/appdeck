package com.mobideck.appdeck;

import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.millennialmedia.InlineAd;
import com.millennialmedia.InterstitialAd;
import com.millennialmedia.MMSDK;

import org.json.JSONObject;

public class AppDeckAdNetworkMMedia extends AppDeckAdNetwork {


    public static String TAG = "MMedia";

    public String mmediaBannerId = "";
    public String mmediaRectangleId = "";
    public String mmediaInterstitialId = "";
    public String mmediaNativeId = "";

    public AppDeckAdNetworkMMedia(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            mmediaBannerId = conf.optString("mmediaBannerId");
            mmediaRectangleId = conf.optString("mmediaRectangleId");
            mmediaInterstitialId = conf.optString("mmediaInterstitialId");
            mmediaNativeId = conf.optString("mmediaNativeId");
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
            MMSDK.initialize(manager.loader);

        Log.i(TAG, "Read: mmediaBannerId:" + mmediaBannerId+ " mmediaRectangleId:" + mmediaRectangleId+ " mmediaInterstitialId:" + mmediaInterstitialId+ " mmediaNativeId:" + mmediaNativeId);

    }

        /* Interstitial Ads */

    private InterstitialAd mInterstitial;

    public boolean supportInterstitial() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN)
            return false;
        if (mmediaInterstitialId == null || mmediaInterstitialId.isEmpty())
            return false;
        return true;
    }
    public void fetchInterstitialAd() {

        try {
            mInterstitial = InterstitialAd.createInstance(mmediaInterstitialId);
        } catch (Exception e) {
            Log.d(TAG, "onInterstitialFailed:"+ e.getMessage());
            manager.onInterstitialAdFailed(AppDeckAdNetworkMMedia.this);
        }

        if (mInterstitial == null) {
            Log.d(TAG, "onInterstitialFailed: null object");
            manager.onInterstitialAdFailed(AppDeckAdNetworkMMedia.this);
            return;
        }

        mInterstitial.setListener(new InterstitialAd.InterstitialListener() {
            @Override
            public void onLoaded(InterstitialAd interstitialAd) {
                Log.d(TAG, "onInterstitialFetched");
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                    manager.onInterstitialAdFetched(AppDeckAdNetworkMMedia.this);
                }});
            }

            @Override
            public void onLoadFailed(InterstitialAd interstitialAd, InterstitialAd.InterstitialErrorStatus interstitialErrorStatus) {
                Log.d(TAG, "onInterstitialFailed:"+interstitialErrorStatus.toString());
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                    manager.onInterstitialAdFailed(AppDeckAdNetworkMMedia.this);
                }});
            }

            @Override
            public void onShown(InterstitialAd interstitialAd) {
                Log.d(TAG, "onInterstitialAdDisplayed");
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                    manager.onInterstitialAdDisplayed(AppDeckAdNetworkMMedia.this);
                }});
            }

            @Override
            public void onShowFailed(InterstitialAd interstitialAd, InterstitialAd.InterstitialErrorStatus interstitialErrorStatus) {
                Log.d(TAG, "onShowFailed:"+interstitialErrorStatus.toString());
            }

            @Override
            public void onClosed(InterstitialAd interstitialAd) {
                Log.d(TAG, "onInterstitialAdClosed");
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                    manager.onInterstitialAdClosed(AppDeckAdNetworkMMedia.this);
                }});
            }

            @Override
            public void onClicked(InterstitialAd interstitialAd) {
                Log.d(TAG, "onInterstitialAdClicked");
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                    manager.onInterstitialAdClicked(AppDeckAdNetworkMMedia.this);
                }});
            }

            @Override
            public void onAdLeftApplication(InterstitialAd interstitialAd) {

            }

            @Override
            public void onExpired(InterstitialAd interstitialAd) {

            }
        });

        mInterstitial.load(manager.loader, null);

    }

    public boolean showInterstitial() {
        if (mInterstitial != null && mInterstitial.isReady() && !mInterstitial.hasExpired()) {
            manager.loader.willShowActivity = true;
            try {
                mInterstitial.show(manager.loader);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        if (mInterstitial != null) {
            mInterstitial = null;
        }
    }
    /* Banner Ads */

    private LinearLayout bannerContainer;
    private InlineAd banner;

    public boolean supportBanner() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN)
            return false;
        if (mmediaBannerId == null || mmediaBannerId.isEmpty())
            return false;
        return true;
    }
    public void fetchBannerAd() {

        bannerContainer = (LinearLayout) LayoutInflater.from(manager.loader).inflate(R.layout.ad_mmedia_banner, null);

        try {
            banner = InlineAd.createInstance(mmediaBannerId, bannerContainer);
        } catch (Exception e) {
            Log.d(TAG, "onBannerAdFailed: Exception:"+e.getMessage());
            manager.onBannerAdFailed(AppDeckAdNetworkMMedia.this, bannerContainer);
            return;
        }

        if (banner == null) {
            Log.d(TAG, "onBannerAdFailed: null object");
            manager.onBannerAdFailed(AppDeckAdNetworkMMedia.this, bannerContainer);
            return;
        }

        banner.setListener(new InlineAd.InlineListener() {
            @Override
            public void onRequestSucceeded(InlineAd inlineAd) {
                Log.d(TAG, "onBannerAdFetched");
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                        manager.onBannerAdFetched(AppDeckAdNetworkMMedia.this, bannerContainer);
                }});
            }

            @Override
            public void onRequestFailed(InlineAd inlineAd, InlineAd.InlineErrorStatus errorStatus) {
                Log.d(TAG, "onBannerAdFailed:"+errorStatus.toString());
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                    manager.onBannerAdFailed(AppDeckAdNetworkMMedia.this, bannerContainer);
                }});
            }
            @Override
            public void onClicked(InlineAd inlineAd) {
                Log.d(TAG, "onBannerAdClicked");
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                    manager.onBannerAdClicked(AppDeckAdNetworkMMedia.this, bannerContainer);
                }});
            }
            @Override
            public void onResize(InlineAd inlineAd, int width, int height) {
                Log.d(TAG, "Inline Ad starting resize."); }
            @Override
            public void onResized(InlineAd inlineAd, int width, int height, boolean toOriginalSize) {
                Log.d(TAG, "Inline Ad resized."); }
            @Override
            public void onExpanded(InlineAd inlineAd) {
                Log.d(TAG, "Inline Ad expanded."); }
            @Override
            public void onCollapsed(InlineAd inlineAd) {
                Log.d(TAG, "onBannerAdClosed");
                (new Handler(Looper.getMainLooper())).post(new Runnable() { @Override public void run() {
                    manager.onBannerAdClosed(AppDeckAdNetworkMMedia.this, bannerContainer);
                }});
            }
            @Override
            public void onAdLeftApplication(InlineAd inlineAd) {
                Log.d(TAG, "Inline Ad left application."); }
        });

        banner.setRefreshInterval(0);
        // The InlineAdMetadata instance is used to pass additional metadata to the server to // improve ad selection
        InlineAd.InlineAdMetadata bannerMetadata = new InlineAd.InlineAdMetadata().
                setAdSize(InlineAd.AdSize.BANNER);
        banner.request(bannerMetadata);

/*
        int scaledWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 320, manager.loader.getResources().getDisplayMetrics());
        int scaledHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 50, manager.loader.getResources().getDisplayMetrics());

        LinearLayout.LayoutParams bannerLayoutParams = new LinearLayout.LayoutParams(scaledWidth, scaledHeight);
        //bannerLayoutParams.addRule(LinearLayout.ALIGN_PARENT_BOTTOM);
        //bannerLayoutParams.addRule(LinearLayout.CENTER_HORIZONTAL);
        bannerContainer.addView(banner, bannerLayoutParams);
        banner.load();*/
    }

    public void destroyBannerAd() {
        if (banner != null) {
            banner = null;
        }
    }


}
