package com.mobideck.appdeck;

import android.util.Log;

import com.ironsource.mobilcore.AdUnitEventListener;
import com.ironsource.mobilcore.MobileCore;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 22/11/15.
 */
public class AppDeckAdNetworkMobileCore extends AppDeckAdNetwork {

    public static String TAG = "MobileCore";

    /*
    Triggers:

    Intertitial: BUTTON_CLICK
    Banner: APP_START
    Native: MAIN_MENU

     */

    public String mobilecoreDeveloperHashcode = "";
    public String mobilecoreEnableIntertitial = "";
    public String mobilecoreEnableBanner = "";
    public String mobilecoreEnableNative = "";;

    public AppDeckAdNetworkMobileCore(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            mobilecoreDeveloperHashcode = conf.optString("mobilecoreDeveloperHashcode");
            mobilecoreEnableBanner = conf.optString("mobilecoreEnableBanner");
            mobilecoreEnableIntertitial = conf.optString("mobilecoreEnableIntertitial");
            mobilecoreEnableNative = conf.optString("mobilecoreEnableNative");

            if (mobilecoreDeveloperHashcode != null && !mobilecoreDeveloperHashcode.isEmpty()) {
                MobileCore.init(manager.loader, mobilecoreDeveloperHashcode, MobileCore.LOG_TYPE.DEBUG, MobileCore.AD_UNITS.INTERSTITIAL, MobileCore.AD_UNITS.STICKEEZ);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: mobilecoreDeveloperHashcode:" + mobilecoreDeveloperHashcode + " mobilecoreEnableBanner:" + mobilecoreEnableBanner + " mobilecoreEnableIntertitial:" + mobilecoreEnableIntertitial + " mobilecoreEnableNative:" + mobilecoreEnableNative);
    }


    /* Banner Ads */

    public boolean supportBanner() {
        if (mobilecoreDeveloperHashcode == null || mobilecoreDeveloperHashcode.isEmpty() || mobilecoreEnableBanner == null || mobilecoreEnableBanner.isEmpty() || mobilecoreEnableBanner.equalsIgnoreCase("no"))
            return false;
        return true;
    }
    public void fetchBannerAd() {

        MobileCore.setAdUnitEventListener(new AdUnitEventListener() {
            @Override
            public void onAdUnitEvent(MobileCore.AD_UNITS adUnit, EVENT_TYPE eventType,
                                      MobileCore.AD_UNIT_TRIGGER... trigger) {
                if (adUnit != MobileCore.AD_UNITS. STICKEEZ)
                    return;
                if (eventType == EVENT_TYPE.AD_UNIT_INIT_SUCCEEDED) {
                    Log.d(TAG, "AD_UNIT_INIT_SUCCEEDED");
                }
                if (eventType == EVENT_TYPE.AD_UNIT_INIT_FAILED) {
                    Log.d(TAG, "AD_UNIT_INIT_FAILED");
                    manager.onBannerAdFailed(AppDeckAdNetworkMobileCore.this, null);
                }
                if (eventType == EVENT_TYPE.AD_UNIT_LOAD_ERROR) {
                    Log.d(TAG, "AD_UNIT_LOAD_ERROR");
                    manager.onBannerAdFailed(AppDeckAdNetworkMobileCore.this, null);
                }
                if (eventType == EVENT_TYPE.AD_UNIT_ALREADY_LOADING) {
                    Log.d(TAG, "AD_UNIT_ALREADY_LOADING");
                    manager.onBannerAdFailed(AppDeckAdNetworkMobileCore.this, null);
                }
                if (eventType == EVENT_TYPE.AD_UNIT_TRIGGER_DISABLED) {
                    Log.d(TAG, "AD_UNIT_TRIGGER_DISABLED");
                    manager.onBannerAdFailed(AppDeckAdNetworkMobileCore.this, null);
                }
                if (eventType == EVENT_TYPE.AD_UNIT_READY) {
                    Log.d(TAG, "AD_UNIT_READY");
                    manager.onBannerAdFetched(AppDeckAdNetworkMobileCore.this, null);
                    MobileCore.showStickee(manager.loader, MobileCore.AD_UNIT_TRIGGER.APP_START);
                }
                if (eventType == EVENT_TYPE.AD_UNIT_NOT_READY) {
                    Log.d(TAG, "AD_UNIT_NOT_READY");
                    manager.onBannerAdFailed(AppDeckAdNetworkMobileCore.this, null);
                }
                if (eventType == EVENT_TYPE.AD_UNIT_SHOW) {
                    Log.d(TAG, "AD_UNIT_SHOW");
                }
                if (eventType == EVENT_TYPE.AD_UNIT_SHOW_ERROR) {
                    Log.d(TAG, "AD_UNIT_SHOW_ERROR");
                }
                if (eventType == EVENT_TYPE.AD_UNIT_ALREADY_SHOWING) {
                    Log.d(TAG, "AD_UNIT_ALREADY_SHOWING");
                }
                if (eventType == EVENT_TYPE.AD_UNIT_CLICK) {
                    Log.d(TAG, "AD_UNIT_CLICK");
                    manager.onBannerAdClicked(AppDeckAdNetworkMobileCore.this, null);
                }
                if (eventType == EVENT_TYPE.AD_UNIT_DISMISSED) {
                    Log.d(TAG, "AD_UNIT_DISMISSED");
                    manager.onBannerAdClosed(AppDeckAdNetworkMobileCore.this, null);
                }
                if (eventType == EVENT_TYPE.AD_UNIT_SENT_TO_STORE) {
                    Log.d(TAG, "AD_UNIT_SENT_TO_STORE");
                }
                if (eventType == EVENT_TYPE.AD_UNIT_SENT_TO_STORE_FAILED) {
                    Log.d(TAG, "AD_UNIT_SENT_TO_STORE_FAILED");
                }
        }
    });

        MobileCore.loadAdUnit(MobileCore.AD_UNITS.STICKEEZ, MobileCore.AD_UNIT_TRIGGER.APP_START);

    }

    public void destroyBannerAd() {
        MobileCore.hideStickee();
    }

    @Override
    public void onActivityPause() {
        MobileCore.hideStickee();
    }
}
