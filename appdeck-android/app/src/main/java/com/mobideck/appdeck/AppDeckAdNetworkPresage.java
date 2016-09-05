package com.mobideck.appdeck;

import android.util.Log;

import org.json.JSONObject;

import io.presage.Presage;
import io.presage.utils.IADHandler;


public class AppDeckAdNetworkPresage extends AppDeckAdNetwork {

    public static String TAG = "Presage";

    public String presageSdkKey = "";

    public AppDeckAdNetworkPresage(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            presageSdkKey = conf.optString("presageSdkKey");
        } catch (Exception e) {
            e.printStackTrace();
        }

        Presage.getInstance().setContext(manager.loader);
        Presage.getInstance().setKey(presageSdkKey);
        Presage.getInstance().start();

        Log.i(TAG, "Read: presageSdkKey:" + presageSdkKey);
    }


    /* Interstitial Ads */

    private IADHandler mInterstitial;

    public boolean supportInterstitial() {
        if (presageSdkKey == null || presageSdkKey .isEmpty())
            return false;
        return true;
    }
    public void fetchInterstitialAd() {

        mInterstitial = new IADHandler() {

            @Override
            public void onAdNotFound() {
                Log.i(TAG, "onAdNotFound");
                manager.onInterstitialAdFailed(AppDeckAdNetworkPresage.this);
            }

            @Override
            public void onAdFound() {
                Log.d(TAG, "onAdFound");
                manager.onInterstitialAdFetched(AppDeckAdNetworkPresage.this);
            }

            @Override
            public void onAdClosed() {
                Log.d(TAG, "onAdClosed");
                manager.onInterstitialAdClosed(AppDeckAdNetworkPresage.this);
            }
            @Override
            public void onAdError(int code) {
                Log.i(TAG, String.format("onAdError with code %d", code));
                manager.onInterstitialAdFailed(AppDeckAdNetworkPresage.this);
            }

            @Override
            public void onAdDisplayed() {
                Log.d(TAG, "onAdDisplayed");
                manager.onInterstitialAdDisplayed(AppDeckAdNetworkPresage.this);
            }
        };

        Presage.getInstance().loadInterstitial(mInterstitial);
        /*
        Presage.getInstance().adToServe("interstitial", new IADHandler() {

            @Override
            public void onAdNotFound() {
                Log.i(TAG, "onAdNotFound");
                manager.onInterstitialAdFailed(AppDeckAdNetworkPresage.this);
            }

            @Override
            public void onAdFound() {
                Log.d(TAG, "onAdFound");
                manager.onInterstitialAdFetched(AppDeckAdNetworkPresage.this);
            }

            @Override
            public void onAdClosed() {
                Log.d(TAG, "onAdClosed");
                manager.onInterstitialAdClosed(AppDeckAdNetworkPresage.this);
            }
            @Override
            public void onAdError(int code) {
                Log.i(TAG, String.format("onAdError with code %d", code));
                manager.onInterstitialAdFailed(AppDeckAdNetworkPresage.this);
            }

            @Override
            public void onAdDisplayed() {
                Log.d(TAG, "onAdDisplayed");
                manager.onInterstitialAdDisplayed(AppDeckAdNetworkPresage.this);
            }
        });
*/
        /*
                        Log.d(TAG, "onInterstitialClicked");
                manager.onInterstitialAdClicked(AppDeckAdNetworkPresage.this);
         */

    }

    public boolean showInterstitial() {
        if (mInterstitial != null) {
            manager.loader.willShowActivity = true;

            Presage.getInstance().showInterstitial(mInterstitial);

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
