package net.mobideck.appdeck.core.ads;

import android.content.Context;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.util.Log;
import android.view.View;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckActivity;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.BuildConfig;
import net.mobideck.appdeck.core.ads.network.AdMob;
import net.mobideck.appdeck.util.Utils;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;

public class AdManager {

    static final String TAG = "AdManager";

    boolean ready = false;

    private boolean forceDebugInterstitial = false;

    static public final int EVENT_START = 0;
    static public final int EVENT_PUSH = 1;
    static public final int EVENT_POP = 2;
    static public final int EVENT_ROOT = 3;
    static public final int EVENT_SWIPE = 4;
    static public final int EVENT_WAKEUP = 5;

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

    HashMap<String, AdNetwork> networksByName;

    boolean isFetchingInterstitialAd = false;
    AdNetwork interstitialAdNetwork;

    AdNetwork bannerAdNetwork;

    AdNetwork nativeAdNetwork;

    ArrayList<AdNetwork> networks;

    public AdManager(AppDeck appDeck) {
        this.appLaunch = System.currentTimeMillis()/1000;
        fetchAdConf(appDeck);
    }

    public void fetchAdConf(AppDeck appDeck) {

        String url = "http://xad.appdeck.mobi/android2?";
        StringBuilder finalUrl = new StringBuilder(url);

        if (appDeck.deviceInfo.isTablet)
            finalUrl.append("type=androidtablet");
        else
            finalUrl.append("type=android");

        finalUrl.append("&apikey=");
        finalUrl.append(appDeck.appConfig.apiKey);

        finalUrl.append("&deviceuid=");
        finalUrl.append(appDeck.deviceInfo.uid);

        finalUrl.append("&appid=");
        finalUrl.append(appDeck.packageName);

        finalUrl.append("&lang=");
        finalUrl.append(Locale.getDefault().getLanguage());

        ConnectivityManager cm =
                (ConnectivityManager)AppDeckApplication.getContext().getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        boolean isConnected = activeNetwork != null && activeNetwork.isConnectedOrConnecting();

        boolean isWiFi = activeNetwork != null && activeNetwork.getType() == ConnectivityManager.TYPE_WIFI;
        if (isWiFi)
            finalUrl.append("&network=wifi");
        else
            finalUrl.append("&network=mobile");

        url = finalUrl.toString();

        Log.i(TAG, url);

        Request request = new Request.Builder()
                .url(url)
                .method("POST", RequestBody.create(null, new byte[0]))
                .build();

        appDeck.okHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e(TAG, "Error: " + e.getMessage());
                startAds(getAdConf());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {

                if (!response.isSuccessful()) {
                    Log.e(TAG, "Error: " + response.code());
                    startAds(getAdConf());
                } else {
                    String responseBody = Utils.streamGetContent(response.body().byteStream());
                    Log.i(TAG, "Response: "+responseBody);
                    setAdConf(responseBody);
                    startAds(responseBody);
                }
            }
        });

    }

    /* Ad Context */

    private void loadAdContext() {
        final SharedPreferences prefs = getAdPreferences(AppDeckApplication.getContext());
        lastSeenInterstitial = prefs.getLong("lastSeenInterstitial", 0);
        lastSeenInterstitialEver = prefs.getLong("lastSeenInterstitialEver."+ BuildConfig.VERSION_CODE, 0);
    }

    private void saveAdContext() {
        final SharedPreferences prefs = getAdPreferences(AppDeckApplication.getContext());
        SharedPreferences.Editor editor = prefs.edit();
        editor.putLong("lastSeenInterstitial", lastSeenInterstitial);
        editor.putLong("lastSeenInterstitialEver."+BuildConfig.VERSION_CODE, lastSeenInterstitialEver);
        editor.apply();
    }

    /* Ad Conf */

    private String getAdConf() {
        final SharedPreferences prefs = getAdPreferences(AppDeckApplication.getContext());
        return prefs.getString("adConf", "");
    }

    private void setAdConf(String adConf) {
        final SharedPreferences prefs = getAdPreferences(AppDeckApplication.getContext());
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

        networks = new ArrayList<AdNetwork>();
        networksByName = new HashMap<String, AdNetwork>(8);

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
                    AdNetwork network = null;
                    if (key.equalsIgnoreCase("admob"))
                        network = new AdMob(AdManager.this, netWorkConf);
                    /*else if (key.equalsIgnoreCase("mopub"))
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
                    else if (key.equalsIgnoreCase("aerserv"))
                        network = new AppDeckAdNetworkAerServ(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("mng"))
                        network = new AppDeckAdNetworkMng(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("inmobi"))
                        network = new AppDeckAdNetworkInMobi(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("mmedia"))
                        network = new AppDeckAdNetworkMMedia(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("applovin"))
                        network = new AppDeckAdNetworkAppLovin(AppDeckAdManager.this, netWorkConf);
                    else if (key.equalsIgnoreCase("grunt"))
                        Grunt.sharedInstance(loader, new WebView(loader)).start();
                    else if (key.equalsIgnoreCase("presage"))
                        network = new AppDeckAdNetworkPresage(AppDeckAdManager.this, netWorkConf);*/
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
        AppDeckApplication.getActivity().getViewContainer().post(new Runnable() {
            public void run() {
                loadAdContext();
                startAdHandlers();
                ready = true;
                showAds(EVENT_START);
            }
        });
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
            AdNetwork adNetwork = networks.get(idx);
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
            AdNetwork adNetwork = networks.get(idx);
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

    /*
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
    }*/

    public boolean showAds(int event) {
        if (ready == false)
            return false;
        if (showInterstitial(event))
            return true;
        return false;
    }

    /* Api - Interstitial */

    public void onInterstitialAdFetched(AdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdFetched: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        interstitialAdNetwork = network;
        isFetchingInterstitialAd = false;
    }

    public void onInterstitialAdFailed(AdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdFailed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        int idx = networks.indexOf(network);
        startInterstitialAd(idx + 1);
    }

    public void onInterstitialAdDisplayed(AdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdDisplayed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
    }

    public void onInterstitialAdClicked(AdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdClicked: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
    }

    public void onInterstitialAdClosed(AdNetwork network)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onInterstitialAdClosed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        if (interstitialAdNetwork != null)
            interstitialAdNetwork.destroyInterstitial();
        interstitialAdNetwork = null;
    }

    /* Api - Banner */

    public void onBannerAdFetched(AdNetwork network, View adView)
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

    public void onBannerAdFailed(AdNetwork network, View adView)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onBannerAdFailed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        network.destroyBannerAd();
        int idx = networks.indexOf(network);
        startBannerAd(idx + 1);
    }

    public void onBannerAdClosed(AdNetwork network, View adView)
    {
        if (Looper.myLooper() != Looper.getMainLooper())
            Log.e(TAG, "onBannerAdClosed: "+(network != null ? network.getName(): "(null)")+": Should be called on main thread");
        network.removeBannerViewInLoader();
        network.destroyBannerAd();
        bannerAdNetwork = null;
    }

    public void onBannerAdClicked(AdNetwork network, View adView)
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

    /*
    public AppDeckAdNative getNativeAd()
    {
        if (nativeAdNetwork != null)
            return nativeAdNetwork.getNativeAd();
        return null;
    }*/

    /* Activity Api */

    public void onActivityResume()
    {
        if (networks == null)
            return;
        for (int idx = 0; idx < networks.size(); idx++) {
            AdNetwork adNetwork = networks.get(idx);
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
            AdNetwork adNetwork = networks.get(idx);
            adNetwork.onActivityPause();
        }
        stopAdHandlers();
    }

    public void onActivitySaveInstanceState(Bundle outState) {
        if (networks == null)
            return;
        for (int idx = 0; idx < networks.size(); idx++) {
            AdNetwork adNetwork = networks.get(idx);
            adNetwork.onActivitySaveInstanceState(outState);
        }
    }

    public void onActivityRestoreInstanceState(Bundle outState) {
        if (networks == null)
            return;
        for (int idx = 0; idx < networks.size(); idx++) {
            AdNetwork adNetwork = networks.get(idx);
            adNetwork.onActivityRestoreInstanceState(outState);
        }
    }

    public boolean shouldEnableTestMode()
    {
        if (AppDeckApplication.getAppDeck().deviceInfo.isDebugBuild)
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
        PowerManager powerManager = (PowerManager)AppDeckApplication.getContext().getSystemService(Context.POWER_SERVICE);
        boolean result = Build.VERSION.SDK_INT>= Build.VERSION_CODES.KITKAT_WATCH&&powerManager.isInteractive()|| Build.VERSION.SDK_INT< Build.VERSION_CODES.KITKAT_WATCH&&powerManager.isScreenOn();
        return result;
    }

}
