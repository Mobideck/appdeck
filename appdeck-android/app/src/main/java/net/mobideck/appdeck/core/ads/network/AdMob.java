package net.mobideck.appdeck.core.ads.network;

import android.provider.Settings;
import android.util.Log;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.core.ads.AdManager;
import net.mobideck.appdeck.core.ads.AdNetwork;
import net.mobideck.appdeck.util.Utils;

import org.json.JSONObject;

public class AdMob extends AdNetwork {

    public static String TAG = "AdMob";

    public static final String ADMOB_BANNER_ID = "admob_banner_id";
    public static final String ADMOB_RECTANGLE_ID = "admob_rectangle_id";
    public static final String ADMOB_INTERSTITIAL_ID = "admob_interstitial_id";

    public String adMobBannerId = null;
    public String adMobRectangleId = null;
    public String adMobInterstitialId = null;


    public AdMob(AdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            adMobBannerId = conf.optString("adMobBannerId");
            adMobRectangleId = conf.optString("adMobRectangleId");
            adMobInterstitialId = conf.optString("adMobInterstitialId");
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: AdMobBannerId:" + adMobBannerId + " AdMobRectangleId:" + adMobRectangleId + " AdMobInterstitialId:" + adMobInterstitialId);
    }

    /* Interstitial Ads */

    public boolean supportInterstitial() {
        if (adMobInterstitialId == null || adMobInterstitialId.isEmpty())
            return false;
        return true;
    }

    InterstitialAd mInterstitialAd = null;

    public void fetchInterstitialAd()
    {
        if (mInterstitialAd != null && mInterstitialAd.getAdUnitId().equalsIgnoreCase(adMobInterstitialId) == false)
            mInterstitialAd = null;
        if (mInterstitialAd != null)
            return;

        mInterstitialAd = new InterstitialAd(AppDeckApplication.getActivity());
        mInterstitialAd.setAdUnitId(adMobInterstitialId);
        mInterstitialAd.setAdListener(new AdListener() {

            public static final String TAG = "AdMobInterstitialAd";

            @Override
            public void onAdLoaded() {
                Log.d(TAG, "onAdLoaded");
                manager.onInterstitialAdFetched(AdMob.this);
            }

            @Override
            public void onAdClosed() {
                Log.d(TAG, "onAdClosed");
                mInterstitialAd = null;
                manager.onInterstitialAdClosed(AdMob.this);
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                Log.d(TAG, "onAdFailedToLoad:"+errorCode);
                manager.onInterstitialAdFailed(AdMob.this);
            }

            @Override
            public void onAdOpened() {
                Log.d(TAG, "onAdOpened");
                manager.onInterstitialAdClicked(AdMob.this);
            }

        });

        AdRequest.Builder builder = new AdRequest.Builder();

        builder.addTestDevice(com.google.android.gms.ads.AdRequest.DEVICE_ID_EMULATOR);
        builder.addTestDevice("315E930E16E8C801");  // Mobideck Galaxy S4

        if (manager.shouldEnableTestMode()) //debug flag from somewhere that you set
        {
            String android_id = Settings.Secure.getString(AppDeckApplication.getActivity().getContentResolver(), Settings.Secure.ANDROID_ID);
            String deviceId = Utils.md5(android_id).toUpperCase();
            builder.addTestDevice(deviceId);
        }
        AdRequest interstitialAdRequest = builder.build();
        boolean isTestDevice = interstitialAdRequest.isTestDevice(AppDeckApplication.getActivity());
        Log.v(TAG, "is Admob Test Device ? " + isTestDevice); //to confirm it worked
        mInterstitialAd.loadAd(interstitialAdRequest);
    }


    public boolean showInterstitial() {
        if (mInterstitialAd != null && mInterstitialAd.isLoaded()) {
            AppDeckApplication.getActivity().willShowActivity = true;
            mInterstitialAd.show();
            manager.onInterstitialAdDisplayed(AdMob.this);
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        if (mInterstitialAd != null) {
            mInterstitialAd = null;
        }
    }

    /* Banner Ads */

    AdView mBannerAd = null;

    public boolean supportBanner() {
        if (adMobBannerId == null || adMobBannerId.isEmpty())
            return false;
        return true;
    }

    public void fetchBannerAd()
    {
        mBannerAd = new AdView(AppDeckApplication.getActivity());
        mBannerAd.setAdSize(AdSize.BANNER);
        mBannerAd.setAdUnitId(adMobBannerId);
        mBannerAd.setAdListener(new AdListener() {

            public static final String TAG = "AdMobBannerAd";

            @Override
            public void onAdLoaded() {
                Log.d(TAG, "onAdLoaded");
                manager.onBannerAdFetched(AdMob.this, mBannerAd);
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                if (errorCode == AdRequest.ERROR_CODE_INTERNAL_ERROR)
                    Log.e(TAG, "onAdFailedToLoad: Internal Error");
                else if (errorCode == AdRequest.ERROR_CODE_INVALID_REQUEST)
                    Log.e(TAG, "onAdFailedToLoad: Invalid Request");
                else if (errorCode == AdRequest.ERROR_CODE_NETWORK_ERROR)
                    Log.e(TAG, "onAdFailedToLoad: Network Error");
                else if (errorCode == AdRequest.ERROR_CODE_NO_FILL)
                    Log.e(TAG, "onAdFailedToLoad: No Fill");
                else
                    Log.e(TAG, "onAdFailedToLoad: Unknow Error: " + errorCode);
                manager.onBannerAdFailed(AdMob.this, mBannerAd);
            }

            @Override
            public void onAdOpened() {
                Log.d(TAG, "onAdOpened");
                manager.onBannerAdClicked(AdMob.this, mBannerAd);
                AppDeckApplication.getActivity().willShowActivity = true;
            }

            @Override
            public void onAdLeftApplication() {
                Log.d(TAG, "onAdLeftApplication");
            }

            @Override
            public void onAdClosed() {
                Log.d(TAG, "onAdClosed");
                manager.onBannerAdClosed(AdMob.this, mBannerAd);
            }
        });

        AdRequest.Builder builder = new AdRequest.Builder();
        builder.addTestDevice(com.google.android.gms.ads.AdRequest.DEVICE_ID_EMULATOR);
        builder.addTestDevice("315E930E16E8C801");  // Mobideck Galaxy S4
        if (manager.shouldEnableTestMode()) //debug flag from somewhere that you set
        {
            String android_id = Settings.Secure.getString(AppDeckApplication.getActivity().getContentResolver(), Settings.Secure.ANDROID_ID);
            String deviceId = Utils.md5(android_id).toUpperCase();
            builder.addTestDevice(deviceId);
        }
        mBannerAd.loadAd(builder.build());
    }

    @Override
    public void destroyBannerAd() {
        if (mBannerAd != null) {
            mBannerAd.destroy();
            mBannerAd = null;
        }
    }
}
