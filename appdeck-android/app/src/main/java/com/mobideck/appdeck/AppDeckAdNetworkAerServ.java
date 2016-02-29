package com.mobideck.appdeck;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import com.aerserv.sdk.*;

import org.json.JSONObject;

import java.util.List;

public class AppDeckAdNetworkAerServ extends AppDeckAdNetwork {

    public static String TAG = "AerServ";

    public String aerServBannerPLC = "";
    public String aerServRectanglePLC = "";
    public String aerServInterstitialPLC = "";
    public String aerServNativePLC = "";

    public AppDeckAdNetworkAerServ(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            aerServBannerPLC= conf.optString("aerServBannerPLC");
            aerServRectanglePLC= conf.optString("aerServRectanglePLC");
            aerServInterstitialPLC= conf.optString("aerServInterstitialPLC");
            aerServNativePLC= conf.optString("aerServNativePLC");
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: aerServBannerPLC:" + aerServBannerPLC+ " aerServRectanglePLC:" + aerServRectanglePLC+ " aerServInterstitialPLC:" + aerServInterstitialPLC+ " aerServNativePLC:" + aerServNativePLC);

    }

        /* Interstitial Ads */

    private AerServInterstitial mInterstitial;

    public boolean supportInterstitial() {
        if (aerServInterstitialPLC == null || aerServInterstitialPLC.isEmpty())
            return false;
        return true;
    }
    public void fetchInterstitialAd() {

        AerServEventListener listener = new AerServEventListener(){
            @Override
            public void onAerServEvent(final AerServEvent event, final List<Object> args){
                Runnable uiSafeCode = new Runnable(){
                    @Override
                    public void run(){
                        AerServVirtualCurrency vc = null;
                        switch(event){
                            case AD_FAILED:
                                Log.d(TAG, "onInterstitialFailed:"+ args.get(0).toString());
                                manager.onInterstitialAdFailed(AppDeckAdNetworkAerServ.this);
                                break;
                            case PRELOAD_READY:
                                Log.d(TAG, "onInterstitialFetched");
                                manager.onInterstitialAdFetched(AppDeckAdNetworkAerServ.this);
                                break;
                            case AD_LOADED:
                                Log.d(TAG, "onInterstitialLoaded");
                                break;
                            case AD_IMPRESSION:
                                Log.d(TAG, "onInterstitialAdDisplayed");
                                manager.onInterstitialAdDisplayed(AppDeckAdNetworkAerServ.this);
                                break;
                            case AD_COMPLETED:
                                Log.d(TAG, "onInterstitialAdClosed");
                                manager.onInterstitialAdClosed(AppDeckAdNetworkAerServ.this);
                                break;
                            case AD_CLICKED:
                                Log.d(TAG, "onInterstitialClicked");
                                manager.onInterstitialAdClicked(AppDeckAdNetworkAerServ.this);
                                break;
                            default:
                                Log.d(TAG, event.toString() + " event fired with args " + args.toString());
                        }
                    }
                };
                (new Handler(Looper.getMainLooper())).post(uiSafeCode);
            }
        };

        AerServConfig config = new AerServConfig(manager.loader, aerServInterstitialPLC).setPreload(true);

        config.setEventListener(listener);

        mInterstitial = new AerServInterstitial(config);

    }

    public boolean showInterstitial() {
        if (mInterstitial != null) {
            manager.loader.willShowActivity = true;
            mInterstitial.show();
            return true;
        }
        return false;
    }

    public void destroyInterstitial() {
        if (mInterstitial != null) {
            mInterstitial.kill();
            mInterstitial = null;
        }
    }


    /* Banner Ads */

    private LinearLayout bannerContainer;
    private AerServBanner banner;

    public boolean supportBanner() {
        if (aerServBannerPLC == null || aerServBannerPLC.isEmpty())
            return false;
        return true;
    }
    public void fetchBannerAd() {

        AerServEventListener listener = new AerServEventListener(){
            @Override
            public void onAerServEvent(final AerServEvent event, final List<Object> args){
                Runnable uiSafeCode = new Runnable(){
                    @Override
                    public void run(){
                        AerServVirtualCurrency vc = null;
                        switch(event){
                            case AD_LOADED:
                                Log.d(TAG, "onBannerAdFetched");
                                manager.onBannerAdFetched(AppDeckAdNetworkAerServ.this, bannerContainer);
                                break;
                            case AD_IMPRESSION:
                                Log.d(TAG, "Ad Impression");
                                break;
                            case AD_FAILED:
                                Log.d(TAG, "onBannerFailed:"+ args.get(0).toString());
                                manager.onBannerAdFailed(AppDeckAdNetworkAerServ.this, bannerContainer);
                                break;
                            case VC_READY:
                                vc = (AerServVirtualCurrency) args.get(0);
                                Log.d(TAG, "Virtual Currency ready! " + vc.getAmount() + " " + vc.getName());
                                break;
                            case VC_REWARDED:
                                vc = (AerServVirtualCurrency) args.get(0);
                                Log.d(TAG, "Virtual Currency rewarded! " + vc.getAmount() + " " + vc.getName());
                                break;
                            case PRELOAD_READY:
                                Log.d(TAG, "Ad Preload Ready");
                                break;
                            case AD_CLICKED:
                                Log.d(TAG, "onBannerClicked");
                                manager.onBannerAdClicked(AppDeckAdNetworkAerServ.this, bannerContainer);
                                break;
                            default:
                                Log.d(TAG, event.toString() + " event fired with args " + args.toString());
                        }
                    }
                };
                (new Handler(Looper.getMainLooper())).post(uiSafeCode);
            }
        };

        bannerContainer = (LinearLayout)LayoutInflater.from(manager.loader).inflate(R.layout.ad_aerserv_banner, null);
        banner = (AerServBanner)bannerContainer.findViewById(R.id.banner);

        AerServConfig config = new AerServConfig(manager.loader, aerServBannerPLC);
        config.setEventListener(listener);

        banner.configure(config).show();

    }

    public void destroyBannerAd() {
        if (banner != null) {
            banner.kill();
            banner = null;
        }
    }

}
