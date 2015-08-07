package com.mobideck.appdeck;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;

import org.apache.http.Header;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.UnsupportedEncodingException;
import java.util.Locale;

/**
 * Created by mathieudekermadec on 05/08/15.
 */
public class AppDeckAdManager {
    Loader loader;

    static final String TAG = "AdManager";

    public static final String MOPUB_BANNER_ID = "mopub_banner_id";
    public static final String MOPUB_RECTANGLE_ID = "mopub_rectangle_id";
    public static final String MOPUB_INTERSTITIAL_ID = "mopub_interstitial_id";

    public String mopubBannerId = "";
    public String mopubRectangleId = "";
    public String mopubInterstitialId = "";

    private AsyncHttpClient httpClient;

    AppDeckAdManager(Loader loader) {
        this.loader = loader;
        getAdConf(loader);
        syncAdConf();
    }

    public void syncAdConf() {

        String url = "http://xad.appdeck.mobi/android?";
        StringBuilder finalUrl = new StringBuilder(url);

        AppDeck appDeck = loader.appDeck;

        if (appDeck.isTablet)
            finalUrl.append("type=androidtablet");
        else
            finalUrl.append("type=android");

        finalUrl.append("&apikey=");
        finalUrl.append(appDeck.config.app_api_key);

        finalUrl.append("&deviceuid=");
        finalUrl.append(appDeck.uid);

        finalUrl.append("&appid=");
        finalUrl.append(appDeck.packageName);

        finalUrl.append("&lang=");
        finalUrl.append(Locale.getDefault().getLanguage());

        url = finalUrl.toString();

        Log.i(TAG, url);

        httpClient = new AsyncHttpClient();
        httpClient.get(url, new AsyncHttpResponseHandler() {

            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                try {
                    String response = responseBody == null?null:new String(responseBody, this.getCharset());
                    Log.i(TAG, "Response: "+response);
                    try {
                        JSONObject conf = (JSONObject) new JSONTokener(response).nextValue();
                        String newMopubBannerId = conf.getString("mopubBannerId");
                        String newMopubRectangleId = conf.getString("mopubRectangleId");
                        String newMopubInterstitialId = conf.getString("mopubInterstitialId");

                        if (newMopubBannerId.equals(mopubBannerId) && newMopubRectangleId.equals(mopubRectangleId) && newMopubInterstitialId.equals(mopubInterstitialId))
                            return;

                        mopubBannerId = newMopubBannerId;
                        mopubRectangleId = newMopubRectangleId;
                        mopubInterstitialId = newMopubInterstitialId;

                        setAdConf(loader);

                    } catch (JSONException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                } catch (UnsupportedEncodingException var5) {
                    Log.e(TAG, var5.toString());
                }

            }
        });

    }


    private void getAdConf(Context context) {
        final SharedPreferences prefs = getAdPreferences(context);
        this.mopubBannerId = prefs.getString(MOPUB_BANNER_ID, "");
        this.mopubRectangleId = prefs.getString(MOPUB_RECTANGLE_ID, "");
        this.mopubInterstitialId = prefs.getString(MOPUB_INTERSTITIAL_ID, "");
        Log.i(TAG, "Read: mopubBannerId:"+mopubBannerId+" mopubRectangleId:"+mopubRectangleId+" mopubInterstitialId:"+mopubInterstitialId);
    }

    private void setAdConf(Context context) {
        Log.i(TAG, "Store: mopubBannerId:"+mopubBannerId+" mopubRectangleId:"+mopubRectangleId+" mopubInterstitialId:"+mopubInterstitialId);
        final SharedPreferences prefs = getAdPreferences(context);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString(MOPUB_BANNER_ID, mopubBannerId);
        editor.putString(MOPUB_RECTANGLE_ID, mopubRectangleId);
        editor.putString(MOPUB_INTERSTITIAL_ID, mopubInterstitialId);
        editor.apply();
    }

    /**
     * @return Application's {@code SharedPreferences}.
     */
    private SharedPreferences getAdPreferences(Context context) {
        return context.getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
    }

    public boolean shouldShowInterstitial() {
        return true;
    }
}
