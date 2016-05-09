package com.mobideck.appdeck;

import android.util.Log;
import android.view.View;

import com.mopub.nativeads.MoPubNative;
import com.mopub.nativeads.NativeErrorCode;
//import com.mopub.nativeads.NativeResponse;
import com.mopub.nativeads.RequestParameters;

import java.util.EnumSet;
import java.util.Map;

/**
 * Created by mathieudekermadec on 12/11/15.
 */
public class AppDeckAdNetworkMoPubNativeAd extends AppDeckAdNative {
/*
    AppDeckAdNetworkMoPub mMopubNetwork;

    private MoPubNative mMoPubNativeAd;
    private NativeResponse mNativeResponse;

    AppDeckAdNetworkMoPubNativeAd(AppDeckAdNetworkMoPub network)
    {
        mMopubNetwork = network;
        mMoPubNativeAd = new MoPubNative(mMopubNetwork.manager.loader, mMopubNetwork.mopubNativeId, new MoPubNative.MoPubNativeNetworkListener() {

            @Override
            public void onNativeLoad(NativeResponse nativeResponse) {
                Log.d(TAG, "onNativeLoad");
                mNativeResponse = nativeResponse;

                Map<String, Object> properties = mNativeResponse.getExtras();

                adExtras = properties;
                adMainImageUrl = mNativeResponse.getMainImageUrl();
                adText = mNativeResponse.getText();
                adClickToActionText = mNativeResponse.getCallToAction();
                adIconImageUrl = mNativeResponse.getIconImageUrl();
                adTitle = mNativeResponse.getTitle();

                onNativeAdReady();
            }

            @Override
            public void onNativeFail(NativeErrorCode nativeErrorCode) {
                Log.d(TAG, "onNativeFail");

                onNativeAdFailed();
            }
        });

        mMoPubNativeAd.setNativeEventListener(new MoPubNative.MoPubNativeEventListener() {
            @Override
            public void onNativeImpression(View view) {
                Log.d(TAG, "onNativeImpression");
            }

            @Override
            public void onNativeClick(View view) {
                Log.d(TAG, "onNativeClick");
            }
        });

        //Specify which native assets you want to use in your ad.
        EnumSet<RequestParameters.NativeAdAsset> assetsSet = EnumSet.of(RequestParameters.NativeAdAsset.TITLE, RequestParameters.NativeAdAsset.TEXT,
                RequestParameters.NativeAdAsset.CALL_TO_ACTION_TEXT, RequestParameters.NativeAdAsset.MAIN_IMAGE,
                RequestParameters.NativeAdAsset.ICON_IMAGE, RequestParameters.NativeAdAsset.STAR_RATING);

        RequestParameters requestParameters = new RequestParameters.Builder()
                //.keywords("gender:m,age:27")
                //.location(exampleLocation)
                .desiredAssets(assetsSet)
                .build();

        mMoPubNativeAd.makeRequest(requestParameters);
    }

    public void recordImpression(AppDeckApiCall call) {
        mNativeResponse.recordImpression(call.appDeckFragment.getView());
    }

    public void recordClick(AppDeckApiCall call) {
        mMopubNetwork.manager.loader.willShowActivity = true;
        mNativeResponse.handleClick(call.appDeckFragment.getView());
    }

*/
}
