package com.mobideck.appdeck;

import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.mngads.MNGAdsFactory;
import com.mngads.listener.MNGAdsSDKFactoryListener;
import com.mngads.listener.MNGBannerListener;
import com.mngads.listener.MNGClickListener;
import com.mngads.listener.MNGInterstitialListener;
import com.mngads.util.MNGFrame;

import org.json.JSONObject;

public class AppDeckAdNetworkMng extends AppDeckAdNetwork implements MNGAdsSDKFactoryListener {

    public static String TAG = "MngAds";

    public String mngAppId = "";
    public String mngBannerId = "";
    public String mngRectangleId = "";
    public String mngInterstitialId = "";
    public String mngNativeId = "";

    public AppDeckAdNetworkMng(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            mngAppId = conf.optString("mngAppId");
            mngBannerId = conf.optString("mngBannerId");
            mngRectangleId = conf.optString("mngRectangleId");
            mngInterstitialId = conf.optString("mngInterstitialId");
            mngNativeId = conf.optString("mngNativeId");
        } catch (Exception e) {
            e.printStackTrace();
        }
        MNGAdsFactory.initialize(manager.loader, mngAppId);

        if (manager.shouldEnableTestMode())
            MNGAdsFactory.setDebugModeEnabled(true);

        Log.i(TAG, "Read: mngAppId: " + mngAppId + " mngBannerId :" + mngBannerId + " mngRectangleId :" + mngRectangleId + " mngInterstitialId :" + mngInterstitialId + " mngNativeId :" + mngNativeId);

    }

    @Override
    public void onMNGAdsSDKFactoryDidFinishInitializing() {
        Log.d(TAG, "MNGAds SDK Factory Did Finish Initializing");
    }

    /* Interstitial Ads */

    private MNGAdsFactory mngAdsInterstitialAdsFactory;

    public boolean supportInterstitial() {
        if (!MNGAdsFactory.isInitialized())
            return false;
        if (mngInterstitialId == null || mngInterstitialId.isEmpty())
            return false;
        return true;
    }
    public void fetchInterstitialAd() {

        mngAdsInterstitialAdsFactory = new MNGAdsFactory(manager.loader);
        mngAdsInterstitialAdsFactory.setPlacementId(mngInterstitialId);

        mngAdsInterstitialAdsFactory.setInterstitialListener(new MNGInterstitialListener() {
             @Override
             public void interstitialDidLoad() {
                 Log.d(TAG, "onInterstitialFetched");
                 manager.onInterstitialAdFetched(AppDeckAdNetworkMng.this);
             }

             @Override
             public void interstitialDidFail(Exception e) {
                 Log.d(TAG, "onInterstitialFailed:" + e.toString());
                 manager.onInterstitialAdFailed(AppDeckAdNetworkMng.this);
             }

             @Override
             public void interstitialDisappear() {
                 Log.d(TAG, "onInterstitialAdClosed");
                 manager.onInterstitialAdClosed(AppDeckAdNetworkMng.this);
             }
         });

        mngAdsInterstitialAdsFactory.setClickListener(new MNGClickListener() {
              @Override
              public void onAdClicked() {
                  Log.d(TAG, "onInterstitialClicked");
                  manager.onInterstitialAdClicked(AppDeckAdNetworkMng.this);
              }
        });

        /*
        Log.d(TAG, "onInterstitialAdDisplayed");
        manager.onInterstitialAdDisplayed(AppDeckAdNetworkMng.this);


        */

        if (mngAdsInterstitialAdsFactory.createInterstitial()) {
            //Wait callBack from interstitial listener
        }else{
            Log.d(TAG, "onInterstitialFailed");
            manager.onInterstitialAdFailed(AppDeckAdNetworkMng.this);
        }

    }

    public boolean showInterstitial() {
        if (mngAdsInterstitialAdsFactory != null) {
            manager.loader.willShowActivity = true;
            //mngAdsInterstitialAdsFactory.
            //mInterstitial.show();
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        if (mngAdsInterstitialAdsFactory != null) {
            mngAdsInterstitialAdsFactory.releaseMemory();
            mngAdsInterstitialAdsFactory = null;
        }
    }

    /* Banner Ads */

    private FrameLayout bannerContainer;
    private MNGAdsFactory mngAdsBannerAdsFactory;

    public boolean supportBanner() {
        if (!MNGAdsFactory.isInitialized())
            return false;
        if (mngBannerId == null || mngBannerId.isEmpty())
            return false;
        return true;
    }
    public void fetchBannerAd() {


        mngAdsBannerAdsFactory = new MNGAdsFactory(manager.loader);
        mngAdsBannerAdsFactory.setTimeOut(3);
        mngAdsBannerAdsFactory.setPlacementId(mngBannerId);
        mngAdsBannerAdsFactory.setBannerListener(new MNGBannerListener() {
            @Override
            public void bannerDidLoad(View view, int preferredHeightDP) {
                Log.d(TAG, "onBannerAdFetched");

                FrameLayout bannerContainer = new FrameLayout(manager.loader);
                int scaledWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 320, manager.loader.getResources().getDisplayMetrics());
                int scaledHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, preferredHeightDP, manager.loader.getResources().getDisplayMetrics());
                FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(scaledWidth, scaledHeight, Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL);
                bannerContainer.setLayoutParams(lp);
                bannerContainer.addView(view, lp);

                manager.onBannerAdFetched(AppDeckAdNetworkMng.this, bannerContainer);
            }

            @Override
            public void bannerDidFail(Exception e) {
                Log.d(TAG, "onBannerFailed:"+ e.toString());
                manager.onBannerAdFailed(AppDeckAdNetworkMng.this, bannerContainer);
            }

            @Override
            public void bannerResize(MNGFrame mngFrame) {
                Log.d(TAG, "Banner did resize w dp " + mngFrame.getWidth() + " h dp " + mngFrame.getHeight());
                int scaledWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, mngFrame.getWidth(), manager.loader.getResources().getDisplayMetrics());
                int scaledHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, mngFrame.getHeight(), manager.loader.getResources().getDisplayMetrics());
                FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(scaledWidth, scaledHeight, Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL);
                bannerContainer.setLayoutParams(lp);
            }
        });

        mngAdsBannerAdsFactory.setClickListener(new MNGClickListener() {
            @Override
            public void onAdClicked() {
                Log.d(TAG, "onBannerAdClicked");
                manager.onBannerAdClicked(AppDeckAdNetworkMng.this, bannerContainer);
            }
        });

        if(mngAdsBannerAdsFactory.createBanner(new MNGFrame(320, 50))){
            //Wait callBack from listener
        } else {
            Log.d(TAG, "onBannerFailed");
            manager.onBannerAdFailed(AppDeckAdNetworkMng.this, bannerContainer);
        }
    }

    public void destroyBannerAd() {
        if (mngAdsBannerAdsFactory != null) {
            mngAdsBannerAdsFactory.releaseMemory();
            mngAdsBannerAdsFactory = null;
        }
    }

}