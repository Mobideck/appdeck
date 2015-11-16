package com.mobideck.appdeck;

import android.util.Log;
import android.view.View;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.AdListener;
import com.facebook.ads.NativeAd;
import com.mopub.nativeads.MoPubNative;
import com.mopub.nativeads.NativeErrorCode;
import com.mopub.nativeads.NativeResponse;
import com.mopub.nativeads.RequestParameters;

import java.util.EnumSet;
import java.util.Map;

/**
 * Created by mathieudekermadec on 13/11/15.
 */
public class AppDeckAdNetworkFacebookNativeAd extends AppDeckAdNative {

    AppDeckAdNetworkFacebook mFacebookNetwork;

    private NativeAd nativeAd;


    AppDeckAdNetworkFacebookNativeAd(AppDeckAdNetworkFacebook network)
    {
        mFacebookNetwork = network;
        nativeAd = new NativeAd(mFacebookNetwork.manager.loader, mFacebookNetwork.facebookNativeId);
        nativeAd.setAdListener(new AdListener() {

            @Override
            public void onError(Ad ad, AdError error) {
                Log.d(TAG, "onNativeAdError");
                onNativeAdFailed();
            }

            @Override
            public void onAdLoaded(Ad ad) {
                Log.d(TAG, "onNativeAdLoaded");

                adTitle = nativeAd.getAdTitle();
                adText = nativeAd.getAdBody();
                adClickToActionText = nativeAd.getAdCallToAction();
                adMainImageUrl = nativeAd.getAdCoverImage().getUrl();
                adIconImageUrl = nativeAd.getAdIcon().getUrl();

                onNativeAdReady();
            }

            @Override
            public void onAdClicked(Ad ad) {
                Log.d(TAG, "onNativeAdClicked");
            }
        });

        nativeAd.loadAd();
    }

    public void recordImpression(AppDeckApiCall call) {

    }

    public void recordClick(AppDeckApiCall call) {
        mFacebookNetwork.manager.loader.willShowActivity = true;
        nativeAd.registerViewForInteraction(call.webview);
        call.webview.performClick();
        nativeAd.unregisterView();
    }

}
