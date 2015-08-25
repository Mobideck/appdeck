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


    public static final String ADMOB_BANNER_ID = "admob_banner_id";
    public static final String ADMOB_RECTANGLE_ID = "admob_rectangle_id";
    public static final String ADMOB_INTERSTITIAL_ID = "admob_interstitial_id";

    public String adMobBannerId = "";
    public String adMobRectangleId = "";
    public String adMobInterstitialId = "";


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
            public void onFailure(int statusCode, Header[] headers, byte[] errorResponse, Throwable e) {
                // called when response HTTP status is "4XX" (eg. 401, 403, 404)
                Log.e(TAG, "Error: "+statusCode);
            }


            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                try {
                    String response = responseBody == null?null:new String(responseBody, this.getCharset());
                    Log.i(TAG, "Response: "+response);
                    try {
                        JSONObject conf = (JSONObject) new JSONTokener(response).nextValue();

                        // MoPub
                        try {
                            String newMopubBannerId = conf.getString("mopubBannerId");
                            String newMopubRectangleId = conf.getString("mopubRectangleId");
                            String newMopubInterstitialId = conf.getString("mopubInterstitialId");

                            mopubBannerId = newMopubBannerId;
                            mopubRectangleId = newMopubRectangleId;
                            mopubInterstitialId = newMopubInterstitialId;
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        // AdMob
                        try {
                            String newAdMobBannerId = conf.getString("adMobBannerId");
                            String newAdMobRectangleId = conf.getString("adMobRectangleId");
                            String newAdMobInterstitialId = conf.getString("adMobInterstitialId");

                            adMobBannerId = newAdMobBannerId;
                            adMobRectangleId = newAdMobRectangleId;
                            adMobInterstitialId = newAdMobInterstitialId;

                        } catch (Exception e) {
                            e.printStackTrace();
                        }

//                            if (newMopubBannerId.equals(mopubBannerId) && newMopubRectangleId.equals(mopubRectangleId) && newMopubInterstitialId.equals(mopubInterstitialId) &&
//                                    newAdMobBannerId.equals(adMobBannerId) && newAdMobRectangleId.equals(adMobRectangleId) && newAdMobInterstitialId.equals(adMobInterstitialId))
//                                return;


                        setAdConf(loader);

                    } catch (Exception e) {
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
        this.adMobBannerId = prefs.getString(ADMOB_BANNER_ID, "");
        this.adMobRectangleId = prefs.getString(ADMOB_RECTANGLE_ID, "");
        this.adMobInterstitialId = prefs.getString(ADMOB_INTERSTITIAL_ID, "");
        Log.i(TAG, "Read: AdMobBannerId:"+adMobBannerId+" AdMobRectangleId:"+adMobRectangleId+" AdMobInterstitialId:"+adMobInterstitialId);
    }

    private void setAdConf(Context context) {
        Log.i(TAG, "Store: mopubBannerId:"+mopubBannerId+" mopubRectangleId:"+mopubRectangleId+" mopubInterstitialId:"+mopubInterstitialId);
        final SharedPreferences prefs = getAdPreferences(context);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString(MOPUB_BANNER_ID, mopubBannerId);
        editor.putString(MOPUB_RECTANGLE_ID, mopubRectangleId);
        editor.putString(MOPUB_INTERSTITIAL_ID, mopubInterstitialId);

        Log.i(TAG, "Store: AdMobBannerId:"+adMobBannerId+" AdMobRectangleId:"+adMobRectangleId+" AdMobInterstitialId:"+adMobInterstitialId);
        editor.putString(ADMOB_BANNER_ID, adMobBannerId);
        editor.putString(ADMOB_RECTANGLE_ID, adMobRectangleId);
        editor.putString(ADMOB_INTERSTITIAL_ID, adMobInterstitialId);


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
