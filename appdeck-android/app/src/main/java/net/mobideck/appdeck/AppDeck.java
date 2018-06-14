package net.mobideck.appdeck;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.Build;
import android.os.Vibrator;
import android.support.v4.util.LruCache;
import android.util.Log;
import android.view.Display;
import android.webkit.ValueCallback;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.Volley;
import com.facebook.CallbackManager;
import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;
import com.google.gson.Gson;
import com.mobideck.appdeck.plugin.PluginManager;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterCore;
import com.twitter.sdk.android.core.identity.TwitterAuthClient;

import net.mobideck.appdeck.config.AppConfig;
import net.mobideck.appdeck.config.ViewConfig;
import net.mobideck.appdeck.core.ApiCall;
import net.mobideck.appdeck.core.Cache;
import net.mobideck.appdeck.core.MenuManager;
import net.mobideck.appdeck.core.Navigation;
import net.mobideck.appdeck.core.RemoteAppCache;
import net.mobideck.appdeck.core.Share;
import net.mobideck.appdeck.core.Stats;
import net.mobideck.appdeck.core.ads.AdManager;
import net.mobideck.appdeck.core.plugins.ActionPlugin;
import net.mobideck.appdeck.core.plugins.DebugPlugin;
import net.mobideck.appdeck.core.plugins.InfoPlugin;
import net.mobideck.appdeck.core.plugins.MenuPlugin;
import net.mobideck.appdeck.core.plugins.NavigationPlugin;
import net.mobideck.appdeck.core.plugins.PagePlugin;
import net.mobideck.appdeck.core.plugins.PreferencePlugin;
import net.mobideck.appdeck.core.plugins.SharePlugin;
import net.mobideck.appdeck.core.plugins.UIPlugin;
import net.mobideck.appdeck.core.plugins.WebViewPlugin;
import net.mobideck.appdeck.push.Push;
import net.mobideck.appdeck.util.OkHttp3Stack;
import net.mobideck.appdeck.util.Utils;

import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import io.fabric.sdk.android.Fabric;
import okhttp3.OkHttpClient;

public class AppDeck {

    public static String TAG = "AppDeck";
    public static String VERSION = "2.0.0 alpha";

    public static String APPDECK_INJECT_JS = "if (typeof(appDeckAPICall)  === 'undefined') { appDeckAPICall = ''; var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'https://appdata.static.appdeck.mobi/js/appdeck.js'; scr.async = true; document.getElementsByTagName('head')[0].appendChild(scr); var result = true;} else { var result = false; }";

    public static int PERMISSION_SHARE = 1200;

    public String error_html, packageName;

    public Gson gson;

    public AppConfig appConfig;

    public Navigation navigation;

    public AssetManager assetManager;

    public Cache cache;

    public Push push;

    public Share share;

    public List<String> historyUrls = new ArrayList<String>();
    private boolean mHistoryInjected = false;

    private PluginManager mPluginManager;

    public Stats stats;

    public OkHttpClient okHttpClient;

    private OkHttp3Stack mOkHttpStack;
    private RequestQueue mRequestQueue;
    private ImageLoader mImageLoader;

    private RemoteAppCache mAppCache;

    public AdManager adManager;

    private ViewConfig mDefaultViewConfig;

    public boolean justLaunch = true;

    public static AppDeck getInstance()
    {
        return AppDeckApplication.getAppDeck();
    }

    // device info

    public class DeviceInfo {
        public boolean isTablet = false;
        public boolean isDebugBuild = false;
        public boolean isLowSystem = false;
        public boolean isAppDeckTestApp = false;
        public boolean adsEnabled = true;
        public String userAgent = null;

        public int topMenuIconSize;
        public int actionBarIconSize;
        public int floatingButtonIconSize;
        public int bottomNavigationIconSize;

        public int screenWidth;
        public int screenHeight;

        public File cacheDir;

        public String uid;

        DeviceInfo(Context context) {
            if (0 != (context.getApplicationInfo().flags &= ApplicationInfo.FLAG_DEBUGGABLE))
                isDebugBuild = true;
            uid = Utils.getUid(context.getApplicationContext());
            isTablet = Utils.isTabletDevice(context);
            isAppDeckTestApp = context.getPackageName().equalsIgnoreCase("com.mobideck.appdeck");

            topMenuIconSize = Utils.convertDpToPixels(24);
            actionBarIconSize = Utils.convertDpToPixels(24);
            floatingButtonIconSize = Utils.convertDpToPixels(24);
            bottomNavigationIconSize = Utils.convertDpToPixels(24);

            cacheDir = context.getCacheDir();

            Display display = AppDeckApplication.getActivity().getWindowManager().getDefaultDisplay();
            Point size = new Point();
            display.getSize(size);
            screenWidth = size.x;
            screenHeight = size.y;
        }
    }

    public DeviceInfo deviceInfo;

    public AppDeck(Context context) {

        gson = new Gson();

        navigation = new Navigation();

        deviceInfo = new DeviceInfo(context);

        packageName = context.getPackageName();

        assetManager = context.getAssets();

        cache = new Cache(this);

        stats = new Stats(context);

        share = new Share();

        mPluginManager = PluginManager.getSharedInstance();

        mPluginManager.registerPlugin(new ActionPlugin());
        mPluginManager.registerPlugin(new DebugPlugin());
        mPluginManager.registerPlugin(new InfoPlugin());
        mPluginManager.registerPlugin(new MenuPlugin());
        mPluginManager.registerPlugin(new NavigationPlugin());
        mPluginManager.registerPlugin(new PreferencePlugin());
        mPluginManager.registerPlugin(new SharePlugin());
        mPluginManager.registerPlugin(new UIPlugin());
        mPluginManager.registerPlugin(new WebViewPlugin());
        mPluginManager.registerPlugin(new PagePlugin());

        mPluginManager.onActivityCreate(AppDeckApplication.getActivity());

        error_html = "<html><head><meta name=viewport content=\"width=device-width,user-scalable=no\"><meta http-equiv=\"cache-control\" content=\"max-age=0\" />\n" +
                "<meta http-equiv=\"cache-control\" content=\"no-cache\" />\n" +
                "<meta http-equiv=\"expires\" content=\"0\" />\n" +
                "<meta http-equiv=\"expires\" content=\"Tue, 01 Jan 1980 1:00:00 GMT\" />\n" +
                "<meta http-equiv=\"pragma\" content=\"no-cache\" /><style>html{-webkit-font-smoothing:antialiased}body{font-family:HelveticaNeue-Light,\"Helvetica Neue Light\",\"Helvetica Neue\",Helvetica,Arial,\"Lucida Grande\",sans-serif;font-weight:300;color:#BAC1C8}body{margin:0;padding:0;overflow:hidden}.mark{font-size:120px;text-align:center}.title{font-size:40px;text-align:center}</style><body><div class=mark>!</div><div class=title>&lt;"+context.getString(R.string.network_error)+"/&gt;</div></body></html>";


        //Volley volley = Volley.s
        OkHttpClient.Builder builder = new OkHttpClient.Builder();
        int cacheSize = 100 * 1024 * 1024; // 100 MiB
        okhttp3.Cache cache = new okhttp3.Cache(deviceInfo.cacheDir, cacheSize);
        builder.cache(cache);
        mOkHttpStack = new OkHttp3Stack(builder);
        okHttpClient = mOkHttpStack.client;
        mRequestQueue = Volley.newRequestQueue(AppDeckApplication.getContext(), mOkHttpStack);
        mImageLoader = new ImageLoader(mRequestQueue,
                new ImageLoader.ImageCache() {
                    private final LruCache<String, Bitmap>
                            cache = new LruCache<String, Bitmap>(20);

                    @Override
                    public Bitmap getBitmap(String url) {
                        return cache.get(url);
                    }

                    @Override
                    public void putBitmap(String url, Bitmap bitmap) {
                        cache.put(url, bitmap);
                    }
                });

        // read app config
        InputStream appConfigInputStream = context.getResources().openRawResource(
                context.getResources().getIdentifier("app_config",
                        "raw", context.getPackageName()));
        Reader reader = null;
        try {
            reader = new InputStreamReader(appConfigInputStream, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return;
        }

        appConfig = gson.fromJson(reader, AppConfig.class);
        appConfig.configure(this);
        mDefaultViewConfig = appConfig.getDefaultConfiguration();

        Log.i(TAG, "init with app "+appConfig.title + " ("+appConfig.apiKey+" - AppDeck Framework v"+AppDeck.VERSION+") ");

        if (appConfig.ga != null)
            stats.addTracker(appConfig.ga);

        push = new Push();

        adManager = new AdManager(this);

        mAppCache = new RemoteAppCache(this);

    }

    public void start(AppDeckActivity appDeckActivity) {

        if (appConfig.twitterConsumerKey != null && appConfig.twitterConsumerSecret != null &&
                appConfig.twitterConsumerKey.length() > 0 && appConfig.twitterConsumerSecret.length() > 0
                ) {
            TwitterAuthConfig authConfig = new TwitterAuthConfig(appConfig.twitterConsumerKey, appConfig.twitterConsumerSecret);
            Fabric.with(appDeckActivity, appDeckActivity.crashlytics, new TwitterCore(authConfig));
            appDeckActivity.twitterAuthClient = new TwitterAuthClient();
        } else {
            Fabric.with(appDeckActivity, appDeckActivity.crashlytics);
        }

        FacebookSdk.sdkInitialize(appDeckActivity.getApplicationContext());
        AppEventsLogger.activateApp(appDeckActivity);
        appDeckActivity.callbackManager = CallbackManager.Factory.create();

        navigation.loadRootURL(appConfig.resolveURL(appConfig.bootstrap.url));
    }

    public RequestQueue getRequestQueue() {
        if (mRequestQueue == null) {
            // getApplicationContext() is key, it keeps you from leaking the
            // Activity or BroadcastReceiver if someone passes one in.
            mRequestQueue = Volley.newRequestQueue(AppDeckApplication.getContext(), mOkHttpStack);
        }
        return mRequestQueue;
    }

/*    public boolean isAppdeckTestApp() {
        return AppDeckApplication.getContext().getPackageName().equalsIgnoreCase("com.mobideck.appdeck");
    }*/

    public <T> void addToRequestQueue(Request<T> req) {
        getRequestQueue().add(req);
    }

    public ImageLoader getImageLoader() {
        return mImageLoader;
    }

    public boolean apiCall(final ApiCall call) {

        Log.i("call-", "2 "+call.command);

        if (call.command.equalsIgnoreCase("ready")) {
            Log.i("API", "**READY**");

            if (mHistoryInjected == false) {
                mHistoryInjected = true;

                SharedPreferences prefs = AppDeckApplication.getContext().getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
                Set<String> hs = prefs.getStringSet("historyUrls", new HashSet<String>());

                String js = "var appdeckCurrentHistoryURL = Location.href;\r\n";
                for (String historyUrl : hs) {
                    js += "history.pushState(null, null, '"+historyUrl+"');\r\n";
                }
                js += "history.pushState(null, null, appdeckCurrentHistoryURL);\r\n";

                call.smartWebView.evaluateJavascript(js, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {
                        Log.i(TAG, "onReadyFinishedJSResult: " + value);
                    }
                });
            }

            //historyUrls.add(call.smartWebView.getUrl());
        }


        if (mPluginManager.handleCall(call))
            return true;

        Log.i("API ERROR", call.command);
        return false;
    }

    public void evaluateJavascript(String js) {
        AppDeckApplication.getActivity().evaluateJavascript(js);
        navigation.evaluateJavascript(js);
    }


    public RemoteAppCache fetchRemoteAppCache() {
        return new RemoteAppCache(this);
    }

    public ViewConfig getDefaultConfiguration() {
        return mDefaultViewConfig;
    }

    public String resolveSpecialURL(String url) {
        if (url == null || !url.startsWith("!"))
            return url;
        if (url.isEmpty())
            url = "!action";
        else if (url.equalsIgnoreCase("!action"))
            url = appConfig.iconAction;
        else if (url.equalsIgnoreCase("!ok"))
            url = appConfig.iconOk;
        else if (url.equalsIgnoreCase("!cancel"))
            url = appConfig.iconCancel;
        else if (url.equalsIgnoreCase("!close"))
            url = appConfig.iconClose;
        else if (url.equalsIgnoreCase("!config"))
            url = appConfig.iconConfig;
        else if (url.equalsIgnoreCase("!info"))
            url = appConfig.iconInfo;
        else if (url.equalsIgnoreCase("!menu"))
            url = appConfig.iconMenu;
        else if (url.equalsIgnoreCase("!next"))
            url = appConfig.iconNext;
        else if (url.equalsIgnoreCase("!previous"))
            url = appConfig.iconPrevious;
        /*else if (url.equalsIgnoreCase("!refresh"))
        {
            url = appConfig.iconRefresh;
            rotateOnRefresh = true;
        }*/
        else if (url.equalsIgnoreCase("!search"))
            url = appConfig.iconSearch;
        else if (url.equalsIgnoreCase("!up"))
            url = appConfig.iconUp;
        else if (url.equalsIgnoreCase("!down"))
            url = appConfig.iconDown;
        else if (url.equalsIgnoreCase("!user"))
            url = appConfig.iconUser;
        else
            url = appConfig.iconAction;
        return url;
    }
}
