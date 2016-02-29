package com.mobideck.appdeck;

import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import com.inmobi.ads.InMobiAdRequestStatus;
import com.inmobi.ads.InMobiBanner;
import com.inmobi.sdk.InMobiSdk;

import org.json.JSONObject;

import java.util.Map;

public class AppDeckAdNetworkInMobi extends AppDeckAdNetwork {

    public static String TAG = "InMobi";

    public String inMobiAccountId = "";
    public long inMobiBannerId = 0;
    public long inMobiRectangleId = 0;
    public long inMobiInterstitialId = 0;
    public long inMobiNativeId = 0;

    public AppDeckAdNetworkInMobi(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            inMobiAccountId = conf.optString("inMobiAccountId");
            inMobiBannerId = conf.optLong("inMobiBannerId", 0);
            inMobiRectangleId = conf.optLong("inMobiRectangleId", 0);
            inMobiInterstitialId = conf.optLong("inMobiInterstitialId", 0);
            inMobiNativeId = conf.optLong("inMobiNativeId", 0);
        } catch (Exception e) {
            e.printStackTrace();
        }
        InMobiSdk.init(manager.loader, inMobiAccountId); //'this' is used specify context

        if (manager.shouldEnableTestMode())
            InMobiSdk.setLogLevel(InMobiSdk.LogLevel.DEBUG);

        Log.i(TAG, "Read: inMobiAccountId: " + inMobiAccountId + " inMobiBannerId :" + inMobiBannerId + " inMobiRectangleId :" + inMobiRectangleId + " inMobiInterstitialId :" + inMobiInterstitialId + " inMobiNativeId :" + inMobiNativeId);
    }


    /* Banner Ads */

    private LinearLayout bannerContainer;
    private InMobiBanner banner;

    public boolean supportBanner() {
        if (inMobiAccountId == null || inMobiAccountId.isEmpty() || inMobiBannerId <= 0)
            return false;
        return true;
    }
    public void fetchBannerAd() {

        banner = new InMobiBanner(manager.loader, inMobiBannerId);
        //banner.setAnimationType(InMobiBanner.AnimationType.ANIMATION_OFF);
        banner.setEnableAutoRefresh(false);

        banner.setListener(new InMobiBanner.BannerAdListener() {
            @Override
            public void onAdLoadSucceeded(InMobiBanner inMobiBanner) {
                Log.d(TAG, "onBannerAdFetched");
                manager.onBannerAdFetched(AppDeckAdNetworkInMobi.this, bannerContainer);
            }

            @Override
            public void onAdLoadFailed(InMobiBanner inMobiBanner, InMobiAdRequestStatus inMobiAdRequestStatus) {
                Log.d(TAG, "onBannerAdFailed:"+inMobiAdRequestStatus.getMessage());
                manager.onBannerAdFailed(AppDeckAdNetworkInMobi.this, bannerContainer);
            }

            @Override
            public void onAdDisplayed(InMobiBanner inMobiBanner) {
                Log.d(TAG, "onBannerAdDisplayed");
                //manager.onBannerAd(AppDeckAdNetworkInMobi.this, banner);
            }

            @Override
            public void onAdDismissed(InMobiBanner inMobiBanner) {
                Log.d(TAG, "onBannerAdClosed");
                manager.onBannerAdClosed(AppDeckAdNetworkInMobi.this, bannerContainer);
            }

            @Override
            public void onAdInteraction(InMobiBanner inMobiBanner, Map<Object, Object> map) {
                Log.d(TAG, "onBannerAdClicked");
                manager.onBannerAdClicked(AppDeckAdNetworkInMobi.this, bannerContainer);
            }

            @Override
            public void onUserLeftApplication(InMobiBanner inMobiBanner) {

            }

            @Override
            public void onAdRewardActionCompleted(InMobiBanner inMobiBanner, Map<Object, Object> map) {

            }
        });

        bannerContainer = (LinearLayout)LayoutInflater.from(manager.loader).inflate(R.layout.ad_inmobi, null);

        int scaledWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 320, manager.loader.getResources().getDisplayMetrics());
        int scaledHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 50, manager.loader.getResources().getDisplayMetrics());

        LinearLayout.LayoutParams bannerLayoutParams = new LinearLayout.LayoutParams(scaledWidth, scaledHeight);
        //bannerLayoutParams.addRule(LinearLayout.ALIGN_PARENT_BOTTOM);
        //bannerLayoutParams.addRule(LinearLayout.CENTER_HORIZONTAL);
        bannerContainer.addView(banner, bannerLayoutParams);
        banner.load();
    }

    public void destroyBannerAd() {
        if (banner != null) {
            banner = null;
        }
    }

}
