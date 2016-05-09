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
//import com.mopub.nativeads.MoPubNativeAdRenderer;
import com.mopub.nativeads.MoPubStreamAdPlacer;
import com.mopub.nativeads.NativeErrorCode;
//import com.mopub.nativeads.NativeResponse;
import com.mopub.nativeads.RequestParameters;
import com.mopub.nativeads.ViewBinder;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by mathieudekermadec on 26/09/15.
 */
public class AppDeckAdNative {

    public static String TAG = "NativeAd";

    public String adMainImageUrl;
    public String adText;
    public String adClickToActionText;
    public String adIconImageUrl;
    public String adTitle;
    public Map<String, Object> adExtras;

    public ArrayList<AppDeckApiCall> mApiCalls;

    private boolean mNativeAdReady;

    AppDeckAdNative() {}

    public void addApiCall(AppDeckApiCall call)
    {
        if (mApiCalls == null)
            mApiCalls = new ArrayList<AppDeckApiCall>();
        mApiCalls.add(call);
        if (mNativeAdReady)
            injectInApiCalls();
    }

    public void injectInApiCalls()
    {
        if (mApiCalls == null)
            return;
        for (int k = 0; k < mApiCalls.size(); k++)
        {
            AppDeckApiCall call = mApiCalls.get(k);

            String divId = call.param.getString("id");
            if (adExtras == null)
                adExtras = new HashMap<String, Object>();
            Map<String, Object> properties = adExtras;
            properties.put("mainimage", adMainImageUrl);
            properties.put("text", adText);
            properties.put("ctatext", adClickToActionText);
            properties.put("iconimage", adIconImageUrl);
            properties.put("title", adTitle);

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
                recordImpression(call);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        mApiCalls.clear();
    }


    public void click(AppDeckApiCall call)
    {
        recordClick(call);
    }


    /* api */

    public void onNativeAdReady() {
        mNativeAdReady = true;
        injectInApiCalls();
    }

    public void onNativeAdFailed() {}

    // To implement

    public void recordImpression(AppDeckApiCall call) {}

    public void recordClick(AppDeckApiCall call) {}

}
