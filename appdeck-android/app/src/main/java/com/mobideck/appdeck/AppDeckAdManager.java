package com.mobideck.appdeck;

import android.content.Context;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.os.SystemClock;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;

import net.grunt.gruntlib.Grunt;

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

    private boolean forceDebugInterstitial = false;

    static final int EVENT_START = 0;
    static final int EVENT_PUSH = 1;
    static final int EVENT_POP = 2;
    static final int EVENT_ROOT = 3;
    static final int EVENT_SWIPE = 4;
    static final int EVENT_WAKEUP = 5;

    public boolean enableInterstitial = true;
    public long timeBeforeFirstInterstitialEver = 3600;
    public long timeBeforeFirstInterstitial = 0;
    public long timeBetweenInterstitial = 3600;
    public long timeBetweenInterstitialPolling = 60;

    public boolean enableRectangle = true;
    public long timeBeforeFirstRectangle = 60;
    public long timeBetweenRectangle = 600;

    public boolean enableBanner = true;
    public long timeBeforeFirstBanner = 0;
    //public long timeBetweenBanner = 0;
    public long timeBetweenBannerRefresh = 30;

    private long lastSeenInterstitialEver = 0;
    private long lastSeenInterstitial = 0;
    private long appLaunch;

    public AsyncHttpClient httpClient;

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
        if (loader.originalProxyHost != null) {
            httpClient.setProxy(loader.originalProxyHost, loader.originalProxyPort);
        }
        httpClient.setUserAgent(loader.appDeck.userAgent);
        httpClient.post(url, new AsyncHttpResponseHandler() {

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
        lastSeenInterstitialEver = prefs.getLong("lastSeenInterstitialEver."+BuildConfig.VERSION_CODE, 0);
    }

    private void saveAdContext() {
        final SharedPreferences prefs = getAdPreferences(loader);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putLong("lastSeenInterstitial", lastSeenInterstitial);
        editor.putLong("lastSeenInterstitialEver."+BuildConfig.VERSION_CODE, lastSeenInterstitialEver);
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
            enableInterstitial = conf.optBoolean("enableInterstitial", true);
            timeBeforeFirstInterstitialEver = conf.optLong("timeBeforeFirstInterstitialEver", timeBeforeFirstInterstitialEver);
            timeBeforeFirstInterstitial = conf.optLong("timeBeforeFirstInterstitial", timeBeforeFirstInterstitial);

            if (forceDebugInterstitial) {
                timeBeforeFirstInterstitialEver = 0;
                timeBeforeFirstInterstitial = 0;
            }

            timeBetweenInterstitial = conf.optLong("timeBetweenInterstitial", timeBetweenInterstitial);
            timeBetweenInterstitialPolling = conf.optLong("timeBetweenInterstitialPolling", timeBetweenInterstitialPolling);
            enableRectangle = conf.optBoolean("enableRectangle", true);
            timeBeforeFirstRectangle = conf.optLong("timeBeforeFirstRectangle", timeBeforeFirstRectangle);
            timeBetweenRectangle = conf.optLong("timeBetweenRectangle", timeBetweenRectangle);
            enableBanner = conf.optBoolean("enableBanner", true);
            timeBeforeFirstBanner = conf.optLong("timeBeforeFirstBanner", timeBeforeFirstBanner);
            //timeBetweenBanner = conf.optLong("timeBetweenBanner", timeBetweenBanner);
            timeBetweenBannerRefresh = conf.optLong("timeBetweenBannerRefresh", timeBetweenBannerRefresh);

            // read networks configuration
            JSONObject networksConf = conf.optJSONObject("networks");
            if (networksConf == null)
                return;
            Iterator<?> keys = networksConf.keys();
            while( keys.hasNext() ) {
                String key = (String)keys.next();
                JSONObject netWorkConf = networksConf.optJSONObject(key);
                if (networksConf != null && networksConf instanceof JSONObject ) {
                    AppDeckAdNetwork network = null;
                    if (key.equalsIgnoreCase("admob"))
                        network = new AppDeckAdNetworkAdMob(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("grunt"))
                        Grunt.sharedInstance(loader, new WebView(loader)).start();
                    else
                        Log.e(TAG, "Unsupported Ad Network:"+key);
                    if (network == null)
                        continue;
                    Log.i(TAG, "AdNetwork: "+key);
                    networks.add(network);
                    networksByName.put(key.toLowerCase(), network);
                }
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

        startAdHandlers();

        startNativeAd(0);

        ready = true;
        showAds(EVENT_START);
    }

    private Handler mBannerHandler;
    private Runnable mBannerRunnable = new Runnable() {
        @Override
        public void run() {
            /*if (bannerAdNetwork != null) {
                bannerAdNetwork.removeBannerViewInLoader();
                bannerAdNetwork.destroyBannerAd();
                bannerAdNetwork = null;
            }*/
            startBannerAd(0);
            if (mBannerHandler != null)
                mBannerHandler.postDelayed(this, timeBetweenBannerRefresh * 1000 * 2); // fail safe: this timer should be cancel when banner is show
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
            if (mInterstitialHandler != null)
                mInterstitialHandler.postDelayed(this, timeBetweenInterstitialPolling * 1000);
        }
    };

    private void startAdHandlers() {
        if (enableInterstitial) {
            mInterstitialHandler = new Handler();
            mInterstitialHandler.postDelayed(mInterstitialRunnable, timeBeforeFirstInterstitial * 1000);
        }

        if (enableBanner) {
            mBannerHandler = new Handler();
            mBannerHandler.postDelayed(mBannerRunnable, timeBeforeFirstBanner * 1000);
        }
    }

    private void stopAdHandlers() {
        if (mBannerHandler != null) {
            mBannerHandler.removeCallbacksAndMessages(null);
            mBannerHandler = null;
        }
        if (mInterstitialHandler != null) {
            mInterstitialHandler.removeCallbacksAndMessages(null);
            mInterstitialHandler = null;
        }
    }

    void startInterstitialAd(int idx)
    {
        if (isScreenVisible() == false)
            return;
        if (canShowInterstitial() == false)
            return;
        if (interstitialAdNetwork != null) {
            interstitialAdNetwork.destroyInterstitial();
            interstitialAdNetwork = null;
        }
        isFetchingInterstitialAd = false;
        interstitialAdNetwork = null;
        for (; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            if (adNetwork.interstitialEnabled() && adNetwork.supportInterstitial()) {
                isFetchingInterstitialAd = true;
                interstitialAdNetwork = adNetwork;
                interstitialAdNetwork.fetchInterstitialAd();
                return;
            }
        }
    }

    void startBannerAd(int idx) {
        if (isScreenVisible() == false)
            return;
        for (; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            if (adNetwork.bannerEnabled() && adNetwork.supportBanner() && adNetwork != bannerAdNetwork) {
                //bannerAdNetwork = adNetwork;
                adNetwork.fetchBannerAd();
                return;
            }
        }
        // no banner found, we retry with current one
        if (bannerAdNetwork != null) {
            bannerAdNetwork.removeBannerViewInLoader();
            bannerAdNetwork.destroyBannerAd();
            bannerAdNetwork.fetchBannerAd();
            bannerAdNetwork = null;
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
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdFetched: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        interstitialAdNetwork = network;
        isFetchingInterstitialAd = false;
    }

    public void onInterstitialAdFailed(AppDeckAdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdFailed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        int idx = networks.indexOf(network);
        startInterstitialAd(idx + 1);
    }

    public void onInterstitialAdDisplayed(AppDeckAdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdDisplayed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
    }

    public void onInterstitialAdClicked(AppDeckAdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdClicked: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
    }

    public void onInterstitialAdClosed(AppDeckAdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdClosed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        if (interstitialAdNetwork != null)
            interstitialAdNetwork.destroyInterstitial();
        interstitialAdNetwork = null;
    }

    /* Api - Banner */

    public void onBannerAdFetched(AppDeckAdNetwork network, View adView)
    {
        // cleanup if needed
        if (bannerAdNetwork != null) {
            Log.d(TAG, "onBannerAdFetched: "+(network != null ? network.getName(): "(null)")+": Should remove previous one: "+bannerAdNetwork.getName());
            bannerAdNetwork.removeBannerViewInLoader();
            bannerAdNetwork.destroyBannerAd();
            bannerAdNetwork = null;
        } else {
            Log.d(TAG, "onBannerAdFetched: "+(network != null ? network.getName(): "(null)"));
        }
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onBannerAdFetched: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        bannerAdNetwork = network;
        bannerAdNetwork.setupBannerViewInLoader(adView);
        if (mBannerHandler != null) {
            mBannerHandler.removeCallbacks(mBannerRunnable);
            mBannerHandler.postDelayed(mBannerRunnable, bannerAdNetwork.getTimeBetweenBannerRefresh() * 1000);
        }
    }

    public void onBannerAdFailed(AppDeckAdNetwork network, View adView)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onBannerAdFailed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        network.destroyBannerAd();
        int idx = networks.indexOf(network);
        startBannerAd(idx + 1);
    }

    public void onBannerAdClosed(AppDeckAdNetwork network, View adView)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onBannerAdClosed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        network.removeBannerViewInLoader();
        network.destroyBannerAd();
        bannerAdNetwork = null;
    }

    public void onBannerAdClicked(AppDeckAdNetwork network, View adView)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onBannerAdClicked: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
    }

    /* interstitial */

    private boolean showInterstitial(int event) {
        if (event != EVENT_PUSH)
            return false;
        if (canShowInterstitial() == false)
            return false;
        if (interstitialAdNetwork != null) {
            Log.v(TAG, "Show interstitial from network "+interstitialAdNetwork.getName());
            // hide banner for a refresh time
            if (bannerAdNetwork != null) {
                bannerAdNetwork.removeBannerViewInLoader();
                bannerAdNetwork.destroyBannerAd();
                bannerAdNetwork = null;
                if (mBannerHandler != null) {
                    mBannerHandler.removeCallbacks(mBannerRunnable);
                    mBannerHandler.postDelayed(mBannerRunnable, timeBetweenBannerRefresh * 1000);
                }
            }
            boolean res = interstitialAdNetwork.showInterstitial();
            lastSeenInterstitial = System.currentTimeMillis()/1000;
            lastSeenInterstitialEver = lastSeenInterstitial;
            saveAdContext();
            return res;
        } else {
            Log.v(TAG, "No interstitial as interstitial is not loaded yet");
        }
        return false;
    }

    private boolean canShowInterstitial() {
        if (forceDebugInterstitial)
            return true;
        long currentTime = System.currentTimeMillis()/1000;
        if (lastSeenInterstitialEver == 0 && appLaunch + timeBeforeFirstInterstitialEver > currentTime) {
            Log.v(TAG, "No interstitial as we need to wait "+timeBeforeFirstInterstitialEver+" before first interstitial ever");
            return false;
        }
        if (lastSeenInterstitial == 0 && appLaunch + timeBeforeFirstInterstitial > currentTime) {
            Log.v(TAG, "No interstitial as we need to wait "+timeBeforeFirstInterstitial+" before first interstitial");
            return false;
        }
        if (lastSeenInterstitial != 0 && lastSeenInterstitial + timeBetweenInterstitial > currentTime) {
            Log.v(TAG, "No interstitial as we need to wait "+timeBeforeFirstInterstitial+" between two interstitials");
            return false;
        }
        return true;
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
        if (ready)
            startAdHandlers();
    }

    public void onActivityPause()
    {
        if (networks == null)
            return;
        for (int idx = 0; idx < networks.size(); idx++) {
            AppDeckAdNetwork adNetwork = networks.get(idx);
            adNetwork.onActivityPause();
        }
        stopAdHandlers();
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

    public boolean isScreenVisible() {
        PowerManager powerManager = (PowerManager)loader.getSystemService(Context.POWER_SERVICE);
        boolean result = Build.VERSION.SDK_INT>= Build.VERSION_CODES.KITKAT_WATCH&&powerManager.isInteractive()|| Build.VERSION.SDK_INT< Build.VERSION_CODES.KITKAT_WATCH&&powerManager.isScreenOn();
        return result;
    }

}
