package com.mobideck.appdeck;
import android.util.Log;

import com.flurry.android.ads.FlurryAdErrorType;
import com.flurry.android.ads.FlurryAdNative;
import com.flurry.android.ads.FlurryAdNativeAsset;
import com.flurry.android.ads.FlurryAdNativeListener;
/**
 * Created by mathieudekermadec on 13/11/15.
 */
public class AppDeckAdNetworkFlurryNativeAd extends AppDeckAdNative {

    AppDeckAdNetworkFlurry mFlurryNetwork;

    private FlurryAdNative mFlurryAdNative;

    AppDeckAdNetworkFlurryNativeAd(AppDeckAdNetworkFlurry network)
    {
        mFlurryNetwork = network;
        mFlurryAdNative = new FlurryAdNative(mFlurryNetwork.manager.loader, mFlurryNetwork.flurryNativeId);
        // allow us to get callbacks for ad events
        mFlurryAdNative.setListener(new FlurryAdNativeListener() {
            @Override
            public void onFetched(FlurryAdNative flurryAdNative) {
                Log.d(TAG, "onNativeAdFetched");

                adTitle = flurryAdNative.getAsset("headline").getValue();
                adText = flurryAdNative.getAsset("summary").getValue();
                adClickToActionText = flurryAdNative.getAsset("callToAction").getValue();
                adMainImageUrl = flurryAdNative.getAsset("secHqImage").getValue();
                adIconImageUrl = flurryAdNative.getAsset("secHqBrandingLogo").getValue();

                onNativeAdReady();
            }

            @Override
            public void onShowFullscreen(FlurryAdNative flurryAdNative) {
                Log.d(TAG, "onNativeAdShowFullscreen");
            }

            @Override
            public void onCloseFullscreen(FlurryAdNative flurryAdNative) {
                Log.d(TAG, "onNativeAdCloseFullscreen");
            }

            @Override
            public void onAppExit(FlurryAdNative flurryAdNative) {
                Log.d(TAG, "onNativeAdAppExit");
            }

            @Override
            public void onClicked(FlurryAdNative flurryAdNative) {
                Log.d(TAG, "onNativeAdClicked");
            }

            @Override
            public void onImpressionLogged(FlurryAdNative flurryAdNative) {
                Log.d(TAG, "onNativeAdImpressionLogged");
            }

            @Override
            public void onError(FlurryAdNative flurryAdNative, FlurryAdErrorType flurryAdErrorType, int i) {
                Log.d(TAG, "onNativeAdError:" + flurryAdErrorType.toString() + ":" + i);
                onNativeAdFailed();
            }
        });

        mFlurryAdNative.fetchAd();
    }

    public void recordImpression(AppDeckApiCall call) {

    }

    public void recordClick(AppDeckApiCall call) {
        mFlurryNetwork.manager.loader.willShowActivity = true;
        mFlurryAdNative.setTrackingView(call.webview);
        call.webview.performClick();
        mFlurryAdNative.removeTrackingView();
    }

}