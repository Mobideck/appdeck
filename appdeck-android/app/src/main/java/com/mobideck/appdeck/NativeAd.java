package com.mobideck.appdeck;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.ValueCallback;

import com.mopub.nativeads.MoPubAdRenderer;
import com.mopub.nativeads.MoPubNative;
import com.mopub.nativeads.MoPubNativeAdLoadedListener;
import com.mopub.nativeads.MoPubNativeAdPositioning;
import com.mopub.nativeads.MoPubNativeAdRenderer;
import com.mopub.nativeads.MoPubStreamAdPlacer;
import com.mopub.nativeads.NativeErrorCode;
import com.mopub.nativeads.NativeResponse;
import com.mopub.nativeads.RequestParameters;
import com.mopub.nativeads.ViewBinder;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.Map;

/**
 * Created by mathieudekermadec on 26/09/15.
 */
public class NativeAd {

    /*private MoPubStreamAdPlacer mAdPlacer;

    private MoPubAdRenderer mAdRenderer;

    private ViewBinder mViewBinder;

    private MoPubNativeAdLoadedListener adLoadedListener;*/

    private MoPubNative mNativeAd;

    private NativeResponse mNativeResponse = null;

    public static String TAG = "NAtiveAd";

    public ArrayList<AppDeckApiCall> mApiCalls;

    private Loader loader;

    public NativeAd(Loader loader)
    {
        Log.d(TAG, "New Native Ad");

        this.loader = loader;

        mApiCalls = new ArrayList<AppDeckApiCall>();

        mNativeAd = new MoPubNative(loader, loader.adManager.mopubNativeId, new MoPubNative.MoPubNativeNetworkListener() {

            @Override
            public void onNativeLoad(NativeResponse nativeResponse) {
                Log.d(TAG, "onNativeLoad");
                mNativeResponse = nativeResponse;
                injectInApiCalls();
            }

            @Override
            public void onNativeFail(NativeErrorCode nativeErrorCode) {
                Log.d(TAG, "onNativeFail");
            }
        });

        mNativeAd.setNativeEventListener(new MoPubNative.MoPubNativeEventListener() {
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

        mNativeAd.makeRequest(requestParameters);

    }

    public void addApiCall(AppDeckApiCall call)
    {
        mApiCalls.add(call);
        if (mNativeResponse != null)
            injectInApiCalls();
    }

    public void injectInApiCalls()
    {
        for (int k = 0; k < mApiCalls.size(); k++)
        {
            AppDeckApiCall call = mApiCalls.get(k);

            String divId = call.param.getString("id");
            Map<String, Object> properties = mNativeResponse.getExtras();
            properties.put("mainimage", mNativeResponse.getMainImageUrl());
            properties.put("text", mNativeResponse.getText());
            properties.put("ctatext", mNativeResponse.getCallToAction());
            properties.put("iconimage", mNativeResponse.getIconImageUrl());
            properties.put("title", mNativeResponse.getTitle());

            try {
                JSONObject obj = new JSONObject(properties);
                String json = obj.toString();
                String javascript = "app.injectNativeAd('" + divId + "', " + json + ");";
                call.smartWebView.evaluateJavascript(javascript, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {
                        //Log.d(TAG, "onReceiveValue:"+value);

                    }
                });
                mNativeResponse.recordImpression(call.appDeckFragment.getView());
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

        }
        mApiCalls.clear();
    }


    public void click(AppDeckApiCall call)
    {
        loader.willShowActivity = true;
        mNativeResponse.handleClick(call.appDeckFragment.getView());
    }
}
