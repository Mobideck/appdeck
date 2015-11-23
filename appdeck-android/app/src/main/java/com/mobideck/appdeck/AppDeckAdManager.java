package com.mobideck.appdeck;

import android.content.Context;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.util.Log;
import android.view.View;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;

import cz.msebera.android.httpclient.Header;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.CookieHandler;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Created by mathieudekermadec on 05/08/15.
 */
public class AppDeckAdManager {

    Loader loader;

    static final String TAG = "AdManager";

    boolean ready = false;

    static final int EVENT_START = 0;
    static final int EVENT_PUSH = 1;
    static final int EVENT_POP = 2;
    static final int EVENT_ROOT = 3;
    static final int EVENT_SWIPE = 4;
    static final int EVENT_WAKEUP = 5;

    public long timeBeforeFirstInterstitial = 0;
    public long timeBetweenInterstitial = 3600;
    public long timeBeforeFirstRectangle = 60;
    public long timeBetweenRectangle = 600;
    public long timeBeforeFirstBanner = 0;
    public long timeBetweenBanner = 0;
    public long timeBetweenBannerRefresh = 60;

    private long lastSeenInterstitial = 0;
    private long appLaunch;

    private AsyncHttpClient httpClient;

    HashMap<String, AppDeckAdNetwork> networksByName;

    boolean isFetchingInterstitialAd = false;
    AppDeckAdNetwork interstitialAdNetwork;

    AppDeckAdNetwork bannerAdNetwork;

    AppDeckAdNetwork nativeAdNetwork;

    ArrayList<AppDeckAdNetwork> networks;

    AppDeckAdManager(Loader loader) {
        this.loader = loader;
        this.loader.adManager = this;
        this.appLaunch = System.currentTimeMillis()/1000;
        fetchAdConf();
    }

    public void fetchAdConf() {

        String url = "http://xad.appdeck.mobi/android2?";
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
                Log.e(TAG, "Error: " + statusCode);
                startAds(getAdConf());
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                try {
                    String response = responseBody == null?null:new String(responseBody, this.getCharset());
                    Log.i(TAG, "Response: "+response);

                    setAdConf(response);
                    startAds(response);

                } catch (UnsupportedEncodingException var5) {
                    Log.e(TAG, var5.toString());
                }

            }
        });

    }

    /* Ad Context */

    private void loadAdContext() {
        final SharedPreferences prefs = getAdPreferences(loader);
        lastSeenInterstitial = prefs.getLong("lastSeenInterstitial", 0);
    }

    private void saveAdContext() {
        final SharedPreferences prefs = getAdPreferences(loader);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putLong("lastSeenInterstitial", lastSeenInterstitial);
        editor.apply();
    }

    /* Ad Conf */

    private String getAdConf() {
        final SharedPreferences prefs = getAdPreferences(loader);
        return prefs.getString("adConf", "");
    }

    private void setAdConf(String adConf) {
        final SharedPreferences prefs = getAdPreferences(loader);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("adConf", adConf);
        editor.apply();
    }

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

    public void startAds(String adConf)
    {
        if (adConf == null || adConf.length() == 0)
            return;

        networks = new ArrayList<AppDeckAdNetwork>();
        networksByName = new HashMap<String, AppDeckAdNetwork>(8);

        try {
            JSONObject conf = (JSONObject) new JSONTokener(adConf).nextValue();

            // read ads configuration
            timeBeforeFirstInterstitial = conf.optLong("timeBeforeFirstInterstitial", timeBeforeFirstInterstitial);
            timeBetweenInterstitial = conf.optLong("timeBetweenInterstitial", timeBetweenInterstitial);
            timeBeforeFirstRectangle = conf.optLong("timeBeforeFirstRectangle", timeBeforeFirstRectangle);
            timeBetweenRectangle = conf.optLong("timeBetweenRectangle", timeBetweenRectangle);
            timeBeforeFirstBanner = conf.optLong("timeBeforeFirstBanner", timeBeforeFirstBanner);
            timeBetweenBanner = conf.optLong("timeBetweenBanner", timeBetweenBanner);
            timeBetweenBannerRefresh = conf.optLong("timeBetweenBannerRefresh", timeBetweenBannerRefresh);

            // read networks configuration
            JSONObject networksConf = conf.getJSONObject("networks");
            Iterator<?> keys = networksConf.keys();
            while( keys.hasNext() ) {
                String key = (String)keys.next();
                JSONObject netWorkConf = networksConf.optJSONObject(key);
                if (networksConf != null && networksConf instanceof JSONObject ) {
                    AppDeckAdNetwork network = null;
                    if (key.equalsIgnoreCase("admob"))
                        network = new AppDeckAdNetworkAdMob(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("mopub"))
                        network = new AppDeckAdNetworkMoPub(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("facebook"))
                        network = new AppDeckAdNetworkFacebook(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("flurry"))
                        network = new AppDeckAdNetworkFlurry(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("widespace"))
                        network = new AppDeckAdNetworkWideSpace(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("aditic"))
                        network = new AppDeckAdNetworkAditic(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("smart"))
                        network = new AppDeckAdNetworkSmartAdServer(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("startapp"))
                        network = new AppDeckAdNetworkStartApp(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("smaato"))
                        network = new AppDeckAdNetworkSmaato(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("mobilecore"))
                        network = new AppDeckAdNetworkMobileCore(AppDeckAdManager.this, netWorkConf);
                    else
                        Log.e(TAG, "Unsupported Ad Network:"+key);
                    if (network == null)
                        continue;
                    networks.add(network);
                    networksByName.put(key.toLowerCase(), network);
                }
            }

            // Scenario
            try {
                JSONObject scenario = conf.optJSONObject("scenario");
                if (scenario != null)
                    scenario(loader, scenario);

            } catch (Exception e) {
                e.printStackTrace();
            }

        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        if (networks.size() == 0) {
            Log.d(TAG, "No Ad Networks defined");
            return;
        }

        // start ads

        loadAdContext();

        mInterstitialHandler = new Handler();
        mInterstitialHandler.postDelayed(mInterstitialRunnable, timeBeforeFirstInterstitial * 1000);

        mBannerHandler = new Handler();
        mBannerHandler.postDelayed(mBannerRunnable, timeBeforeFirstBanner * 1000);

        startNativeAd(0);

        ready = true;
        showAds(EVENT_START);
    }

    private Handler mBannerHandler;
    private Runnable mBannerRunnable = new Runnable() {
        @Override
        public void run() {

            if (bannerAdNetwork != null) {
                bannerAdNetwork.removeBannerViewInLoader();
                bannerAdNetwork.destroyBannerAd();
                bannerAdNetwork = null;
            }

            startBannerAd(0);
            mBannerHandler.postDelayed(this, timeBetweenBannerRefresh * 1000);
        }
    };

    private Handler mInterstitialHandler;
    private Runnable mInterstitialRunnable = new Runnable() {
        @Override
        public void run() {

            if (interstitialAdNetwork != null) {
                interstitialAdNetwork.destroyInterstitial();
                interstitialAdNetwork = null;
            }

            startInterstitialAd(0);
            mInterstitialHandler.postDelayed(this, timeBetweenInterstitial * 1000);
        }
    };

    void startInterstitialAd(int idx)
    {
        if (interstitialAdNetwork != null) {
            interstitialAdNetwork.destroyInterstitial();
            interstitialAdNetwork = null;
        }
        isFetchingInterstitialAd = false;
        interstitialAdNetwork = null;
        for (; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            if (adNetwork.supportInterstitial()) {
                isFetchingInterstitialAd = true;
                interstitialAdNetwork = adNetwork;
                interstitialAdNetwork.fetchInterstitialAd();
                return;
            }
        }
    }

    void startBannerAd(int idx) {
        if (bannerAdNetwork != null) {
            bannerAdNetwork.removeBannerViewInLoader();
            bannerAdNetwork.destroyBannerAd();
            bannerAdNetwork = null;
        }
        for (; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            if (adNetwork.supportBanner()) {
                bannerAdNetwork = adNetwork;
                bannerAdNetwork.fetchBannerAd();
                return;
            }
        }
    }

    void startNativeAd(int idx)
    {
        nativeAdNetwork = null;
        for (; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            if (adNetwork.supportNative()) {
                nativeAdNetwork = adNetwork;
                nativeAdNetwork.fetchNativeAd();
                return;
            }
        }
    }

    public boolean showAds(int event) {
        if (ready == false)
            return false;
        if (showInterstitial(event))
            return true;
        return false;
    }

    /* Api - Interstitial */

    public void onInterstitialAdFetched(AppDeckAdNetwork network)
    {
        interstitialAdNetwork = network;
        isFetchingInterstitialAd = false;
    }

    public void onInterstitialAdFailed(AppDeckAdNetwork network)
    {
        int idx = networks.indexOf(network);
        startInterstitialAd(idx + 1);
    }

    public void onInterstitialAdDisplayed(AppDeckAdNetwork network)
    {

    }

    public void onInterstitialAdClicked(AppDeckAdNetwork network)
    {

    }

    public void onInterstitialAdClosed(AppDeckAdNetwork network)
    {
        if (interstitialAdNetwork != null)
            interstitialAdNetwork.destroyInterstitial();
        interstitialAdNetwork = null;
    }

    /* Api - Banner */

    public void onBannerAdFetched(AppDeckAdNetwork network, View adView)
    {
        bannerAdNetwork = network;
        network.setupBannerViewInLoader(adView);
    }

    public void onBannerAdFailed(AppDeckAdNetwork network, View adView)
    {
        network.destroyBannerAd();
        int idx = networks.indexOf(network);
        startBannerAd(idx + 1);
    }

    public void onBannerAdClosed(AppDeckAdNetwork network, View adView)
    {
        network.removeBannerViewInLoader();
        network.destroyBannerAd();
        bannerAdNetwork = null;
    }

    public void onBannerAdClicked(AppDeckAdNetwork network, View adView)
    {

    }

    /* interstitial */

    private boolean showInterstitial(int event) {
        if (event != EVENT_PUSH)
            return false;
        long currentTime = System.currentTimeMillis()/1000;
        if (lastSeenInterstitial == 0 && appLaunch + timeBeforeFirstInterstitial > currentTime) {
            Log.v(TAG, "No interstitial as we need to wait "+timeBeforeFirstInterstitial+" before first interstitial");
            return false;
        }
        if (lastSeenInterstitial != 0 && lastSeenInterstitial + timeBetweenInterstitial > currentTime) {
            Log.v(TAG, "No interstitial as we need to wait "+timeBeforeFirstInterstitial+" between two interstitials");
            return false;
        }
        if (interstitialAdNetwork != null) {
            Log.v(TAG, "Show interstitial from netowork "+interstitialAdNetwork.getName());
            boolean res = interstitialAdNetwork.showInterstitial();
            lastSeenInterstitial = currentTime;
            saveAdContext();
            return res;
        } else {
            Log.v(TAG, "No interstitial as interstitial is not loaded yet");
        }
        return false;
    }

    /* Native Ad */

    public AppDeckAdNative getNativeAd()
    {
        if (nativeAdNetwork != null)
            return nativeAdNetwork.getNativeAd();
        return null;
    }

    /* Activity Api */

    public void onActivityResume()
    {
        if (networks == null)
            return;
        for (int idx = 0; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            adNetwork.onActivityResume();
        }
    }

    public void onActivityPause()
    {
        if (networks == null)
            return;
        for (int idx = 0; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            adNetwork.onActivityPause();
        }
    }

    public void onActivitySaveInstanceState(Bundle outState) {
        if (networks == null)
            return;
        for (int idx = 0; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            adNetwork.onActivitySaveInstanceState(outState);
        }
    }

    public void onActivityRestoreInstanceState(Bundle outState) {
        if (networks == null)
            return;
        for (int idx = 0; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            adNetwork.onActivityRestoreInstanceState(outState);
        }
    }

    public boolean shouldEnableTestMode()
    {
        if (loader.appDeck.isDebugBuild)
            return true;
        if (Build.FINGERPRINT.contains("generic"))
            return true;
        if (Build.HARDWARE.contains("golfdish"))
            return true;
        if ("google_sdk".equals(Build.PRODUCT) || "sdk".equals(Build.PRODUCT) || "sdk_x86".equals(Build.PRODUCT) || "vbox86p".equals(Build.PRODUCT))
            return true;
        return false;
    }

}
