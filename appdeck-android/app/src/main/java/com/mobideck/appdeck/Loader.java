package com.mobideck.appdeck;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;
import com.crashlytics.android.Crashlytics;

import hotchemi.android.rate.AppRate;
import hotchemi.android.rate.OnClickButtonListener;
import io.fabric.sdk.android.Fabric;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URI;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.GregorianCalendar;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Queue;
import java.util.Set;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;

import org.json.JSONException;
import org.json.JSONObject;
import org.littleshoot.proxy.ChainedProxy;
import org.littleshoot.proxy.ChainedProxyAdapter;
import org.littleshoot.proxy.ChainedProxyManager;
import org.littleshoot.proxy.HttpProxyServerBootstrap;
import org.littleshoot.proxy.TransportProtocol;
import org.littleshoot.proxy.impl.DefaultHttpProxyServer;

import android.animation.Animator;
import android.animation.ValueAnimator;
import android.app.DatePickerDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.preference.PreferenceManager;
import android.provider.Telephony;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentManager.OnBackStackChangedListener;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.util.TypedValue;
import android.view.Display;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.DecelerateInterpolator;
import android.webkit.ValueCallback;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.mobideck.appdeck.plugin.PluginManager;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;
import com.facebook.FacebookSdk;
import com.twitter.sdk.android.core.Result;
import com.twitter.sdk.android.core.Twitter;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterConfig;
import com.twitter.sdk.android.core.TwitterException;
import com.twitter.sdk.android.core.TwitterSession;
import com.twitter.sdk.android.core.identity.TwitterAuthClient;

import io.netty.handler.codec.http.HttpRequest;
import me.zhanghai.android.materialprogressbar.MaterialProgressBar;

public class Loader extends AppCompatActivity {

    public final static String TAG = "LOADER";
    public final static String JSON_URL = "com.mobideck.appdeck.JSON_URL";

    public final static String POP_UP_URL = "com.mobideck.appdeck.POP_UP_URL";
    public final static String PAGE_URL = "com.mobideck.appdeck.URL";
    public final static String ROOT_PAGE_URL = "com.mobideck.appdeck.ROOT_URL";

    /* push */
    public final static String PUSH_URL = "com.mobideck.appdeck.PUSH_URL";
    public final static String PUSH_TITLE = "com.mobideck.appdeck.PUSH_TITLE";
    public final static String PUSH_IMAGE_URL = "com.mobideck.appdeck.PUSH_IMAGE_URL";

    public String proxyHost;
    public int proxyPort;
    String originalProxyHost = null;
    int originalProxyPort = -1;

    private String alternativeBootstrapURL = null;

    public AppDeckAdManager adManager;

    protected AppDeck appDeck;

    private SmartWebView leftMenuWebView;
    private SmartWebView rightMenuWebView;

    private DrawerLayout mDrawerLayout;
    private FrameLayout mDrawerLeftMenu;
    private FrameLayout mDrawerRightMenu;
    private ActionBarDrawerToggle mDrawerToggle;

    private PageMenuItem[] menuItems;

    public View nonVideoLayout;
    public ViewGroup videoLayout;

    private HttpProxyServerBootstrap proxyServerBootstrap;

    MaterialProgressBar mProgressBarDeterminate;
    MaterialProgressBar mProgressBarIndeterminate;

    Toolbar mToolbar;
    Drawable mUpArrow;

    private boolean historyInjected = false;
    public List<String> historyUrls = new ArrayList<String>();

    public boolean willShowActivity = false;

    Crashlytics crashlytics;

    CallbackManager callbackManager;
    TwitterAuthClient mTwitterAuthClient;

    PluginManager pluginManager;

    public SmartWebViewInterface smartWebViewRegiteredForActivityResult = null;

    // Google Cloud Messaging
    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;

    private BroadcastReceiver mRegistrationBroadcastReceiver;
    private boolean isReceiverRegistered;

    protected void onCreatePass(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        AppDeckApplication app = (AppDeckApplication) getApplication();

        crashlytics = new Crashlytics.Builder().disabled(BuildConfig.DEBUG).build();

        Log.d(TAG, "Use AppDeck version " + AppDeck.version);

        if (!app.isInitialLoading) {
            SmartWebViewFactory.setPreferences(this);
            app.isInitialLoading = true;
        }
        //setTheme(R.style.Theme_MyAppDeckTheme);
        super.onCreate(savedInstanceState);

        mRegistrationBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
                boolean sentToken = sharedPreferences.getBoolean(GCMRegistrationIntentService.SENT_TOKEN_TO_SERVER, false);
                if (sentToken) {
                    Log.d(TAG, "GCM token sent");
                } else {
                    Log.e(TAG, "GCM token not sent");
                }
            }
        };
        // Registering BroadcastReceiver
        registerReceiver();

        // run appdeck init in his own thread
        new Thread(new Runnable() {
            @Override
            public void run() {
                Intent intent = getIntent();
                String app_json_url = intent.getStringExtra(JSON_URL);
                appDeck = new AppDeck((AppDeckApplication) getApplication(), app_json_url);

                Handler mainHandler = new Handler(getMainLooper());
                Runnable myRunnable = new Runnable() {
                    @Override
                    public void run() {
                        mAppDeckReady = true;
                        preLoadLoading();
                    }
                };
                mainHandler.post(myRunnable);

                appDeck.cache.checkBeacon(Loader.this);
            }
        }, "appdeckInit").start();

        // run proxy in his own thread
        new Thread(new Runnable() {
            @Override
            public void run() {
                // original proxy host/port
                Proxy proxyConf = null;
                try {
                    URI uri = URI.create("http://www.appdeck.mobi");
                    Proxy currentProxy = Utils.getProxySelectorConfiguration(uri);
                    if (currentProxy != null) {
                        originalProxyHost = Utils.getProxyHost(currentProxy);
                        originalProxyPort = Utils.getProxyPort(currentProxy);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                proxyHost = "127.0.0.1";

                boolean isAvailable = false;
                proxyPort = 8081; // default port
                do {
                    isAvailable = Utils.isPortAvailable(proxyPort);
                    if (!isAvailable)
                        proxyPort = Utils.randInt(10000, 60000);
                }
                while (!isAvailable);

                Log.i(TAG, "filter registered at @" + proxyPort);

                CacheFiltersSource filtersSource = new CacheFiltersSource();

                //try {
                proxyServerBootstrap = DefaultHttpProxyServer
                        .bootstrap()
                        .withPort(proxyPort)
                        .withAllowLocalOnly(true)
                        .withTransparent(true)
                        //.withManInTheMiddle(new CertificateSniffingMitmManager())
                        .withTransportProtocol(TransportProtocol.TCP)
                        .withFiltersSource(filtersSource);

                if (originalProxyHost != null && originalProxyPort != -1) {
                    proxyServerBootstrap.withChainProxyManager(new ChainedProxyManager() {
                        @Override
                        public void lookupChainedProxies(HttpRequest httpRequest, Queue<ChainedProxy> chainedProxies) {
                            if (originalProxyHost != null && originalProxyPort != -1) {
                                chainedProxies.add(new ChainedProxyAdapter() {
                                    @Override
                                    public InetSocketAddress getChainedProxyAddress() {
                                        try {
                                            Log.d(TAG, "Cascading Proxy: " + Loader.this.originalProxyHost + ":" + Loader.this.originalProxyPort);
                                            return new InetSocketAddress(InetAddress.getByName(Loader.this.originalProxyHost), Loader.this.originalProxyPort);
                                        } catch (UnknownHostException uhe) {
                                            throw new RuntimeException(
                                                    "Unable to resolve " + Loader.this.originalProxyHost + "?!");
                                        }
                                    }
/*
                                    @Override
                                    public void filterRequest(HttpObject httpObject) {
                                        if (httpObject instanceof HttpRequest) {
                                            HttpRequest httpRequest = (HttpRequest) httpObject;

                                            //if (this.headers != null) {
                                            //    for (Map.Entry<String, String> header : this.headers.entrySet()) {
                                            //        httpRequest.headers().add(header.getKey(), header.getValue());
                                            //    }
                                            //}

                                            //httpRequest.headers().remove("Via");
                                        }
                                    }*/
                                });
                            }
                        }
                    });
                }
                proxyServerBootstrap.start();

                Handler mainHandler = new Handler(getMainLooper());
                Runnable myRunnable = new Runnable() {
                    @Override
                    public void run() {
                        mProxyReady = true;
                        loadLoading();
                    }
                };
                mainHandler.post(myRunnable);

            }
        }, "proxy").start();


/**********************/
        setContentView(R.layout.loader);

        // for video support
        nonVideoLayout = findViewById(R.id.loader_content); // Your own view, read class comments
        videoLayout = findViewById(R.id.videoLayout); // Your own view, read class comments

        mToolbar = findViewById(R.id.app_toolbar);
        setSupportActionBar(mToolbar);
        Objects.requireNonNull(getSupportActionBar()).setDisplayShowTitleEnabled(false);

        mProgressBarDeterminate = findViewById(R.id.progressBarDeterminate);
        mProgressBarIndeterminate = findViewById(R.id.progressBarIndeterminate);
        mProgressBarDeterminate.setMax(100);

        /*
        mProgressBarDeterminate = (ProgressBarDeterminate)findViewById(R.id.progressBarDeterminate);
        mProgressBarDeterminate.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        mProgressBarDeterminate.setMin(0);
        mProgressBarDeterminate.setMax(100);
        mProgressBarIndeterminate = (ProgressBarIndeterminate)findViewById(R.id.progressBarIndeterminate);*/

        mDrawerLayout = findViewById(R.id.drawer_layout);

        mDrawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout, R.string.app_name, R.string.app_name) {

            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {
                super.onDrawerSlide(drawerView, slideOffset);
                loadMenuWebviews();
            }

            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                if (leftMenuWebView != null && drawerView == mDrawerLeftMenu)
                    leftMenuWebView.ctl.sendJsEvent("disappear", "null");
                if (rightMenuWebView != null && drawerView == mDrawerRightMenu)
                    rightMenuWebView.ctl.sendJsEvent("disappear", "null");
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                loadMenuWebviews();
                if (leftMenuWebView != null && drawerView == mDrawerLeftMenu)
                    leftMenuWebView.ctl.sendJsEvent("appear", "null");
                if (rightMenuWebView != null && drawerView == mDrawerRightMenu)
                    rightMenuWebView.ctl.sendJsEvent("appear", "null");
            }
        };
        mDrawerLayout.setDrawerListener(mDrawerToggle);

        if (appDeck.config.leftMenuUrl == null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));

        if (appDeck.config.rightMenuUrl == null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));

        // configure action bar

        mUpArrow = ContextCompat.getDrawable(this, R.drawable.ic_arrow_back_white_24dp);
        //mUpArrow = ResourcesCompat.getDrawable(getResources(), R.drawable.ic_arrow_back_white_24dp, null);

        mUpArrow.setColorFilter(getResources().getColor(R.color.AppDeckColorTopBarText), PorterDuff.Mode.SRC_ATOP);
        mDrawerToggle.setHomeAsUpIndicator(mUpArrow);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true); // show icon on the left of logo
        getSupportActionBar().setDisplayShowHomeEnabled(true); // show logo
        getSupportActionBar().setHomeButtonEnabled(true); // ???

        setSupportProgressBarVisibility(false);
        setSupportProgressBarIndeterminate(false);

        getSupportFragmentManager().addOnBackStackChangedListener(new OnBackStackChangedListener() {
            public void onBackStackChanged() {
                AppDeckFragment fragment = getCurrentAppDeckFragment();

                if (fragment != null && mUIReady && mAppDeckReady && mProxyReady) fragment.setIsMain(true);
            }
        });

        pluginManager = PluginManager.getSharedInstance();

        // begin register plugins

        pluginManager.registerPlugin(new com.mobideck.appdeck.iap.AppDeckPluginIAP());

        // end register plugins

        pluginManager.onActivityCreate(this);

        mUIReady = true;

        preLoadLoading();
    }

    private boolean mUIReady = false;
    private boolean mAppDeckReady = false;
    private boolean mProxyReady = false;

    public boolean justLaunch = true;

    private void preLoadLoading() {

        if (!mUIReady || !mAppDeckReady) return;

        appDeck.actionBarHeight = getActionBarHeight();
        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        appDeck.actionBarWidth = size.x;

        FrameLayout debugLog = findViewById(R.id.debugLog);
        Button debugLogButton = findViewById(R.id.closeDebug);
        if (appDeck.isDebugBuild)
            new DebugLog(debugLog, debugLogButton);

        if (appDeck.config.topbar_color != null)
            Objects.requireNonNull(getSupportActionBar()).setBackgroundDrawable(appDeck.config.topbar_color.getDrawable());

        if (appDeck.config.title != null)
            Objects.requireNonNull(getSupportActionBar()).setTitle(appDeck.config.title);
// left menu
        if (appDeck.config.leftMenuUrl != null) {
            mDrawerLeftMenu = findViewById(R.id.left_drawer);
            if (appDeck.config.leftmenu_background_color != null)
                mDrawerLeftMenu.setBackground(appDeck.config.leftmenu_background_color.getDrawable());

            mDrawerLeftMenu.post(new Runnable() {
                @Override
                public void run() {
                    Resources resources = getResources();
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerLeftMenu.getLayoutParams();
                    params.width = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, appDeck.config.leftMenuWidth, resources.getDisplayMetrics());
                    mDrawerLeftMenu.setLayoutParams(params);
                }
            });
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.left_drawer));
        } else
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));

// right menu
        if (appDeck.config.rightMenuUrl != null) {
            mDrawerRightMenu = findViewById(R.id.right_drawer);
            if (appDeck.config.rightmenu_background_color != null)
                mDrawerRightMenu.setBackground(appDeck.config.rightmenu_background_color.getDrawable());

            mDrawerRightMenu.post(new Runnable() {
                @Override
                public void run() {
                    Resources resources = getResources();
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerRightMenu.getLayoutParams();
                    params.width = (int) (TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, appDeck.config.rightMenuWidth, resources.getDisplayMetrics()));
                    mDrawerRightMenu.setLayoutParams(params);
                }
            });
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.right_drawer));
        } else
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));


        Intent intent = getIntent();
        Uri data = intent.getData();
        if (data != null) {
            alternativeBootstrapURL = data.toString();
            loadRootPage(alternativeBootstrapURL);
        }
        //else if (savedInstanceState == null)
        //{
        loadRootPage(appDeck.config.bootstrapUrl.toString());
        //}
        //android.os.Debug.stopMethodTracing();

        // Push Notification
        Bundle extras = intent.getExtras();
        if (extras != null) {
            String url = extras.getString(PUSH_URL);
            if (url != null && !url.isEmpty()) {
                String title = extras.getString(PUSH_TITLE);
                Log.i(TAG, "Auto Open Push on Create: " + title + " url: " + url);
                //handlePushNotification(title, url, imageUrl);
                try {
                    url = appDeck.config.app_base_url.resolve(url).toString();
                    loadPage(url);
                } catch (Exception ignored) {}
            }
        }

        loadLoading();
    }

    private void loadLoading() {
        if (!mUIReady || !mAppDeckReady || !mProxyReady) return;

        appDeck.proxyHost = proxyHost;
        appDeck.proxyPort = proxyPort;

        AppDeckFragment fragment = getCurrentAppDeckFragment();
        if (fragment != null && !fragment.isMain) fragment.setIsMain(true);
    }

    boolean mPostLoadLoadingCalled = false;

    private void postLoadLoading() {

        if (mPostLoadLoadingCalled) return;
        mPostLoadLoadingCalled = true;

        AppDeckApplication app = (AppDeckApplication) getApplication();
        if (appDeck.config.twitter_consumer_key != null && appDeck.config.twitter_consumer_secret != null &&
                appDeck.config.twitter_consumer_key.length() > 0 && appDeck.config.twitter_consumer_secret.length() > 0
                ) {
            TwitterConfig config = new TwitterConfig.Builder(this)
                    .twitterAuthConfig(new TwitterAuthConfig(appDeck.config.twitter_consumer_key, appDeck.config.twitter_consumer_secret))
                    .build();
            Twitter.initialize(config);
            Fabric.with(app, crashlytics);
            mTwitterAuthClient = new TwitterAuthClient();
        } else
            Fabric.with(app, crashlytics);

        FacebookSdk.sdkInitialize(getApplicationContext());
        AppEventsLogger.activateApp(this);
        callbackManager = CallbackManager.Factory.create();

        adManager = new AppDeckAdManager(this);
        adManager.showAds(AppDeckAdManager.EVENT_START);

        if (checkPlayServices()) {
            // Start IntentService to register this application with GCM.
            Intent intent = new Intent(this, GCMRegistrationIntentService.class);
            startService(intent);
        }

        // Show a dialog if meets conditions
        AppRate.with(this)
                .setInstallDays(10) // default 10, 0 means install day.
                .setLaunchTimes(10) // default 10
                .setRemindInterval(1) // default 1
                .setShowLaterButton(true) // default true
                //.setDebug(true) // default false
                .setOnClickButtonListener(new OnClickButtonListener() { // callback listener.
                    @Override
                    public void onClickButton(int which) {
                        Log.d(Loader.class.getName() + " AppRater Click", Integer.toString(which));
                    }
                })
                .monitor();
        AppRate.showRateDialogIfMeetsConditions(this);

        if (appDeck.config.prefetch_url != null && !appDeck.isLowSystem) {
            //ArchiveExtractCallback.extractDir = this.cacheDir;
            appDeck.remote = new RemoteAppCache(appDeck.config.prefetch_url.toString(), appDeck.config.prefetch_ttl);
            appDeck.remote.downloadAppCache();
        }

        loadMenuWebviews();
    }

    private boolean mMenuLoaded = false;

    private void loadMenuWebviews() {
        if (mMenuLoaded) return;
        mMenuLoaded = true;
// load left menu
        if (appDeck.config.leftMenuUrl != null) {
            leftMenuWebView = SmartWebViewFactory.createMenuSmartWebView(this, appDeck.config.leftMenuUrl.toString(), SmartWebViewFactory.POSITION_LEFT);
            if (appDeck.config.leftmenu_background_color != null)
                leftMenuWebView.view.setBackground(appDeck.config.leftmenu_background_color.getDrawable());
            //mDrawerLeftMenu = (FrameLayout) findViewById(R.id.left_drawer);
            /***!!!***/
            mDrawerLeftMenu.post(new Runnable() {
                @Override
                public void run() {
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerLeftMenu.getLayoutParams();
                    params.width = (int) (TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, appDeck.config.leftMenuWidth, getResources().getDisplayMetrics()));
                    mDrawerLeftMenu.setLayoutParams(params);
                    mDrawerLeftMenu.addView(leftMenuWebView.view);
                }
            });
        }

// load right menu
        if (appDeck.config.rightMenuUrl != null) {
            rightMenuWebView = SmartWebViewFactory.createMenuSmartWebView(this, appDeck.config.rightMenuUrl.toString(), SmartWebViewFactory.POSITION_RIGHT);
            if (appDeck.config.rightmenu_background_color != null)
                rightMenuWebView.view.setBackground(appDeck.config.rightmenu_background_color.getDrawable());
            //mDrawerRightMenu = (FrameLayout) findViewById(R.id.right_drawer);
            mDrawerRightMenu.post(new Runnable() {
                @Override
                public void run() {
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerRightMenu.getLayoutParams();
                    params.width = (int) (TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, appDeck.config.rightMenuWidth, getResources().getDisplayMetrics()));
                    mDrawerRightMenu.setLayoutParams(params);
                    mDrawerRightMenu.addView(rightMenuWebView.view);
                }
            });
        }
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        if (mDrawerToggle != null)
            mDrawerToggle.syncState();
    }

    public FrameLayout getBannerAdViewContainer() {
        return (FrameLayout) findViewById(R.id.bannerContainer);
    }

    boolean isForeground = true;

    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver();
        if (pluginManager != null) pluginManager.onActivityResume(this);
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        isForeground = true;
        if (!willShowActivity) SmartWebViewFactory.onActivityResume(this);
        willShowActivity = false; // always set it to false

        enableProxy();
        // Logs 'install' and 'app activate' App Events.
        if (mPostLoadLoadingCalled) AppEventsLogger.activateApp(this);
        if (adManager != null) adManager.onActivityResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        isForeground = false;
        if (!willShowActivity) SmartWebViewFactory.onActivityPause(this);

        try {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(mRegistrationBroadcastReceiver);
            isReceiverRegistered = false;
        } catch (Exception ignored) {}

        if (appDeck != null && appDeck.noCache) Utils.killApp(true);
        disableProxy();
        // Logs 'app deactivate' App Event.
        AppEventsLogger.deactivateApp(this);
        if (adManager != null) adManager.onActivityPause();
        if (pluginManager != null) pluginManager.onActivityPause(this);
    }

    private void registerReceiver() {
        if (!isReceiverRegistered) {
            LocalBroadcastManager.getInstance(this).registerReceiver(
                    mRegistrationBroadcastReceiver,
                    new IntentFilter(GCMRegistrationIntentService.REGISTRATION_COMPLETE));

            isReceiverRegistered = true;
        }
    }

    /**
     * Check the device to make sure it has the Google Play Services APK. If
     * it doesn't, display a dialog that allows users to download the APK from
     * the Google Play Store or enable it in the device's system settings.
     */
    private boolean checkPlayServices() {
        GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = apiAvailability.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (apiAvailability.isUserResolvableError(resultCode))
                apiAvailability.getErrorDialog(this, resultCode, PLAY_SERVICES_RESOLUTION_REQUEST).show();
            else {
                Log.i(TAG, "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        outState.putString("WORKAROUND_FOR_BUG_19917_KEY", "WORKAROUND_FOR_BUG_19917_VALUE");
        super.onSaveInstanceState(outState);
        SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);

        // only keep maxHistoryUrlsSize URLS
        int maxHistoryUrlsSize = 5;
        if (historyUrls.size() > maxHistoryUrlsSize)
            historyUrls = historyUrls.subList(historyUrls.size() - maxHistoryUrlsSize - 1, historyUrls.size() - 1);

        //Set<String> hs = prefs.getStringSet("set", new HashSet<String>());
        Set<String> in = new HashSet<>(historyUrls);
        //in.add(String.valueOf(hs.size() + 1));
        prefs.edit().putStringSet("historyUrls", in).commit(); // brevity

        if (adManager != null)
            adManager.onActivitySaveInstanceState(outState);

        Log.i(TAG, "onSaveInstanceState");
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        if (adManager != null)
            adManager.onActivityRestoreInstanceState(savedInstanceState);
        Log.i(TAG, "onRestoreInstanceState");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        isForeground = false;
        SmartWebViewFactory.onActivityDestroy(this);
        if (pluginManager != null) pluginManager.onActivityDestroy(this);
    }

    // Sliding Menu API

    public void toggleMenu() {
        if (isMenuOpen()) closeMenu(); else openMenu();
    }

    public void toggleLeftMenu() {
        if (isMenuOpen()) closeMenu(); else openLeftMenu();
    }

    public void toggleRightMenu() {
        if (isMenuOpen()) closeMenu(); else openRightMenu();
    }

    public boolean isMenuOpen() {
        return mDrawerLayout != null && (mDrawerLeftMenu != null && mDrawerLayout.isDrawerOpen(mDrawerLeftMenu) || mDrawerRightMenu != null && mDrawerLayout.isDrawerOpen(mDrawerRightMenu));
    }

    public boolean isLeftMenuOpen() {
        return mDrawerLayout != null && mDrawerLeftMenu != null && mDrawerLayout.isDrawerOpen(mDrawerLeftMenu);
    }

    public boolean isRightMenuOpen() {
        return mDrawerLayout != null && mDrawerRightMenu != null && mDrawerLayout.isDrawerOpen(mDrawerRightMenu);
    }

    public void openLeftMenu() {
        closeMenu();
        if (!menuEnabled || mDrawerLayout == null) return;
        if (mDrawerLeftMenu != null) mDrawerLayout.openDrawer(mDrawerLeftMenu);
    }

    public void openRightMenu() {
        closeMenu();
        if (!menuEnabled || mDrawerLayout == null) return;
        if (mDrawerRightMenu != null) mDrawerLayout.openDrawer(mDrawerRightMenu);
    }

    public void openMenu() {
        closeMenu();
        if (!menuEnabled || mDrawerLayout == null) return;
        if (mDrawerLeftMenu != null) {
            mDrawerLayout.openDrawer(mDrawerLeftMenu);
            return;
        }
        if (mDrawerRightMenu != null) mDrawerLayout.openDrawer(mDrawerRightMenu);
    }

    public void closeMenu() {
        if (mDrawerLayout != null) mDrawerLayout.closeDrawers();
    }

    private boolean menuEnabled = true;

    public void disableMenu() {
        menuEnabled = false;
        closeMenu();
        if (mDrawerLayout == null) return;

        if (appDeck.config.leftMenuUrl != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));

        if (appDeck.config.rightMenuUrl != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));

        Objects.requireNonNull(getSupportActionBar()).setDisplayHomeAsUpEnabled(false); // show icon on the left of logo
        getSupportActionBar().setDisplayShowHomeEnabled(true); // show logo
        getSupportActionBar().setHomeButtonEnabled(true); // ???
    }

    public void enableMenu() {
        menuEnabled = true;
        if (mDrawerLayout == null) return;
        if (appDeck.config.leftMenuUrl != null) mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.left_drawer));
        if (appDeck.config.rightMenuUrl != null) mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.right_drawer));

        Objects.requireNonNull(getSupportActionBar()).setDisplayHomeAsUpEnabled(true); // show icon on the left of logo
        getSupportActionBar().setDisplayShowHomeEnabled(true); // make icon + logo + title clickable
    }

    boolean menuArrowIsShown = false;

    public void setMenuArrow(boolean show) {
        if (menuArrowIsShown == show) return;

        menuArrowIsShown = show;
        float start = show ? 0 : 1;
        float end = show ? 1 : 0;

        ValueAnimator anim = ValueAnimator.ofFloat(start, end);
        anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator valueAnimator) {
                float slideOffset = (Float) valueAnimator.getAnimatedValue();
                mDrawerToggle.onDrawerSlide(mDrawerLayout, slideOffset);
            }
        });
        anim.setInterpolator(new DecelerateInterpolator());
        // You can change this duration to more closely match that of the default animation.
        anim.setDuration(500);
        anim.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                if (!menuArrowIsShown) mDrawerToggle.setDrawerIndicatorEnabled(true);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                if (menuArrowIsShown) mDrawerToggle.setDrawerIndicatorEnabled(false);
                else mDrawerToggle.setDrawerIndicatorEnabled(true);
            }

            @Override
            public void onAnimationCancel(Animator animation) {}

            @Override
            public void onAnimationRepeat(Animator animation) {}
        });
        anim.start();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mDrawerToggle.onConfigurationChanged(newConfig);
    }

    ArrayList<WeakReference<AppDeckFragment>> fragList = new ArrayList<>();

    @SuppressWarnings({"unchecked", "rawtypes"})
    @Override
    public void onAttachFragment(Fragment fragment) {
        if (fragment == null) return;

        String tag = fragment.getTag();
        if (tag != null && tag.equalsIgnoreCase("AppDeckFragment")) fragList.add(new WeakReference(fragment));
    }

    public void onDettachFragment(Fragment fragment) {
        if (fragment == null) return;

        for (int i = 0; i < fragList.size(); i++)
            if (fragList.get(i).get() == fragment) {
                fragList.remove(i);
                return;
            }
    }

    public AppDeckFragment getPreviousAppDeckFragment(AppDeckFragment current) {
        if (current == null) return null;

        for (int i = 0; i < fragList.size(); i++)
            if (fragList.get(i).get() == current && i > 0)
                return fragList.get(i-1).get();

        return null;
    }


    public AppDeckFragment getCurrentAppDeckFragment() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        return (AppDeckFragment) fragmentManager.findFragmentByTag("AppDeckFragment");
    }

    public AppDeckFragment getRootAppDeckFragment() {
        return fragList != null ? fragList.get(0).get() : null;
    }

    boolean mProgressBarIsHiding = false;

    public void progressStart() {
        mProgressBarIndeterminate.setVisibility(View.VISIBLE);
        mProgressBarIndeterminate.setAlpha(0f);
        mProgressBarIndeterminate.animate().alpha(1f).start();
        mProgressBarDeterminate.setProgress(0);
        mProgressBarDeterminate.setVisibility(View.GONE);

        mProgressBarIsHiding = false;
    }

    public void progressSet(int percent) {
        if (percent < 50) return;
        if (mProgressBarIsHiding) return;

        mProgressBarIsHiding = true;
        mProgressBarIndeterminate.animate().alpha(0f).start();
    }

    public void progressStop() {
        if (!mPostLoadLoadingCalled) postLoadLoading();
        mProgressBarIndeterminate.setVisibility(View.GONE);
    }

    protected void prepareRootPage() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        fragmentManager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);

        // remove all current menu items
        setMenuItems(new PageMenuItem[0]);

        // make sure user see content
        closeMenu();
    }

    public boolean loadSpecialURL(String absoluteURL) {
        if (absoluteURL.startsWith("tel:")) {
            try {
                Intent intent = new Intent(Intent.ACTION_DIAL);
                intent.setData(Uri.parse(absoluteURL));
                startActivity(intent);
            } catch (Exception ignored) {}

            return true;
        }

        if (absoluteURL.startsWith("mailto:")) {
            Intent i = new Intent(Intent.ACTION_SEND);
            i.setType("message/rfc822");
            i.putExtra(Intent.EXTRA_EMAIL, new String[]{ absoluteURL.substring("mailto:".length()) });
            startActivity(Intent.createChooser(i, ""));
            return true;
        }
        return false;
    }

    public boolean loadExternalURL(String absoluteURL, boolean force) {
        Uri uri = Uri.parse(absoluteURL);
        if (uri != null) {
            String host = uri.getHost();
            if (force || (host != null && !isSameDomain(host))) {
                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW, uri);

                    // enable custom tab for chrome
                    String EXTRA_CUSTOM_TABS_SESSION = "android.support.customtabs.extra.SESSION";
                    Bundle extras = new Bundle();
                    extras.putBinder(EXTRA_CUSTOM_TABS_SESSION, null/*sessionICustomTabsCallback.asBinder() Set to null for no session */);
                    String EXTRA_CUSTOM_TABS_TOOLBAR_COLOR = "android.support.customtabs.extra.TOOLBAR_COLOR";
                    extras.putInt(EXTRA_CUSTOM_TABS_TOOLBAR_COLOR, R.color.AppDeckColorApp);

                    intent.putExtras(extras);

                    startActivity(intent);
                } catch (Exception e) {
                    Toast.makeText(
                            this,
                            "No application can handle this request. Please install a web browser",
                            Toast.LENGTH_LONG
                    ).show();
                }
                return true;
            }
        }
        return false;
    }

    public int findUnusedId(int fID) {
        fID++; while (this.findViewById(android.R.id.content).findViewById(fID) != null) fID++;
        return fID;
    }

    int rootTransactionCommit = 0;

    public void loadRootPage(String absoluteURL) {
        fragList = new ArrayList<>();
        // if we don't have focus get it before load page
        if (!isForeground) {
            createIntent(ROOT_PAGE_URL, absoluteURL);
            return;
        }

        if (loadSpecialURL(absoluteURL) || loadExternalURL(absoluteURL, false)) return;
        prepareRootPage();
        AppDeckFragment fragment = initPageFragment(absoluteURL);
        rootTransactionCommit = pushFragment(fragment);
        setMenuArrow(false);
    }

    public boolean isSameDomain(String domain) {
        if (domain.equalsIgnoreCase(this.appDeck.config.bootstrapUrl.getHost())) return true;
        Pattern otherDomainRegexp[] = AppDeck.getInstance().config.other_domain;

        if (otherDomainRegexp == null) return false;

        for (Pattern p : otherDomainRegexp) if (p.matcher(domain).find()) return true;

        return false;
    }

    public void loadPage(String absoluteURL) {

        if (loadSpecialURL(absoluteURL) || loadExternalURL(absoluteURL, false)) return;

        if (!isForeground) {
            createIntent(PAGE_URL, absoluteURL);
            return;
        }

        AppDeckFragment fragment = initPageFragment(absoluteURL);

        fragment.event = AppDeckAdManager.EVENT_PUSH;
        if (adManager != null) adManager.showAds(AppDeckAdManager.EVENT_PUSH);

        setMenuArrow(true);
        pushFragment(fragment);
    }

    public int replacePage(String absoluteURL) {
        AppDeckFragment fragment = initPageFragment(absoluteURL);

        fragment.enablePushAnimation = false;

        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        //fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);

        AppDeckFragment oldFragment = (AppDeckFragment) fragmentManager.findFragmentByTag("AppDeckFragment");
        if (oldFragment != null) {
            oldFragment.setIsMain(false);
            fragmentTransaction.remove(oldFragment);
            onDettachFragment(oldFragment);
        }

        fragmentTransaction.add(R.id.loader_container, fragment, "AppDeckFragment");

        //fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
        return fragmentTransaction.commitAllowingStateLoss();
    }

    public AppDeckFragment initPageFragment(String absoluteURL) {
        return initPageFragment(absoluteURL, false, false);
    }

    public AppDeckFragment initPageFragment(String absoluteURL, boolean forcePopUp, boolean forceBrowser) {

        ScreenConfiguration config = appDeck.config.getConfiguration(absoluteURL);

        AppDeckFragment fragment;

        // popup to external URL MUST be browser
        Uri uri = Uri.parse(absoluteURL);
        if (uri != null) {
            String host = uri.getHost();
            if (host != null && !host.equalsIgnoreCase(this.appDeck.config.bootstrapUrl.getHost()) && forcePopUp) forceBrowser = true;
        }

        if (forceBrowser || (config != null && config.type != null && config.type.equalsIgnoreCase("browser")))
            fragment = WebBrowser.newInstance(absoluteURL);
        else {
            fragment = PageSwipe.newInstance(absoluteURL);
            fragment.setRetainInstance(true);
        }

        fragment.loader = this;
        fragment.screenConfiguration = config;//appDeck.config.getConfiguration(absoluteURL);
        if (fragment.screenConfiguration != null && fragment.screenConfiguration.isPopUp != null && fragment.screenConfiguration.isPopUp)
            fragment.isPopUp = true;
        if (forcePopUp)
            fragment.isPopUp = true;
        return fragment;
    }

    public int pushFragment(AppDeckFragment fragment) {
        disableMenuItem();
        setSupportProgressBarVisibility(false);

        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();

        AppDeckFragment oldFragment = getCurrentAppDeckFragment();
        if (oldFragment != null) {
            oldFragment.setIsMain(false);
        }

        fragmentTransaction.add(R.id.loader_container, fragment, "AppDeckFragment");
        fragmentTransaction.addToBackStack("AppDeckFragment");

        int ret = fragmentTransaction.commitAllowingStateLoss();

        layoutSubViews();

        return ret;
    }

    public void pushFragmentAnimation(AppDeckFragment fragment) {
        AppDeckFragment current = getCurrentAppDeckFragment();
        AppDeckFragment previous = getPreviousAppDeckFragment(current);

        if (current == null || previous == null || fragment != current) return;

        if (fragment.isPopUp) (new AppDeckFragmentUpAnimation(previous, current)).start();
        else (new AppDeckFragmentPushAnimation(previous, current)).start();
    }

    public boolean popFragment() {
        AppDeckFragment current = getCurrentAppDeckFragment();
        AppDeckFragment previous = getPreviousAppDeckFragment(current);

        if (current == null || previous == null) return false;

        setSupportProgressBarVisibility(false);

        onDettachFragment(current);

        if (current.isPopUp) (new AppDeckFragmentDownAnimation(current, previous)).start();
        else if (current.enablePopAnimation) (new AppDeckFragmentPopAnimation(current, previous)).start();

        //previous.event = AppDeckAdManager.EVENT_POP;
        if (adManager != null) adManager.showAds(AppDeckAdManager.EVENT_POP);

        // check if we pop to root
        previous = getPreviousAppDeckFragment(previous);
        if (previous == null) setMenuArrow(false);

        return true;
    }

    public void popRootFragment() {
        AppDeckFragment current = getCurrentAppDeckFragment();
        AppDeckFragment previous = getRootAppDeckFragment();

        if (current == null || previous == null || current == previous) return;

        if (rootTransactionCommit == 0) {
            loadRootPage(appDeck.config.bootstrapUrl.toString());
            return;
        }

        //setSupportProgressBarVisibility(false);

        // remove other fragments
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();

        for (WeakReference<AppDeckFragment> ref : fragList) {
            AppDeckFragment f = ref.get();
            if (f != current && f != previous) fragmentTransaction.remove(f);
        }

        fragmentTransaction.commitAllowingStateLoss();

        if (current.isPopUp) (new AppDeckFragmentDownAnimation(current, previous)).start();
        else if (current.enablePopAnimation) (new AppDeckFragmentPopAnimation(current, previous)).start();

        // reset fragment list
        fragList.clear();
        fragList.add(new WeakReference(current));

        // make sure user see content
        closeMenu();
        setMenuArrow(false);

        if (adManager != null) adManager.showAds(AppDeckAdManager.EVENT_ROOT);

    }

    public void layoutSubViews() {
        if (mProgressBarDeterminate != null) mProgressBarDeterminate.bringToFront();
        if (mProgressBarIndeterminate != null) mProgressBarIndeterminate.bringToFront();
    }

    public void reload(boolean forceReload) {
        this.appDeck.cache.clear();
        for (WeakReference<AppDeckFragment> ref : fragList) {
            AppDeckFragment f = ref.get();
            Log.d(TAG, "reload:" + f.currentPageUrl);
            f.reload(forceReload);
        }
    }

    public void evaluateJavascript(String js) {
        if (leftMenuWebView != null) leftMenuWebView.ctl.evaluateJavascript(js, null);
        if (rightMenuWebView != null) rightMenuWebView.ctl.evaluateJavascript(js, null);
        for (WeakReference<AppDeckFragment> ref : fragList) ref.get().evaluateJavascript(js);
    }

    /**********/
    public Boolean apiCall(final AppDeckApiCall call) {
        if (call.command.equalsIgnoreCase("ready")) {
            Log.i("API", "**READY**");

            if (!historyInjected) {
                historyInjected = true;

                SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
                Set<String> hs = prefs.getStringSet("historyUrls", new HashSet<String>());

                String js = "var appdeckCurrentHistoryURL = Location.href;\r\n";
                for (String historyUrl : hs) {
                    js += "history.pushState(null, null, '" + historyUrl + "');\r\n";
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

        if (call.command.equalsIgnoreCase("share")) {
            Log.i("API", "**SHARE**");

            String shareTitle = call.param.getString("title");
            String shareUrl = call.param.getString("url");
            String shareImageUrl = call.param.getString("imageurl");

            share(shareTitle, shareUrl, shareImageUrl);

            return true;
        }

        if (call.command.equalsIgnoreCase("preferencesget")) {
            Log.i("API", "**PREFERENCES GET**");

            String name = call.param.getString("name");
            String defaultValue = call.param.optString("value", "");

            SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);

            String key = "appdeck_preferences_json1_" + name;
            String finalValueJson = prefs.getString(key, null);

            if (finalValueJson == null) call.setResult(defaultValue);
            else call.setResult(finalValueJson);

            return true;
        }

        if (call.command.equalsIgnoreCase("preferencesset")) {
            Log.i("API", "**PREFERENCES SET**");

            String name = call.param.getString("name");
            String finalValue = call.param.optString("value", "");

            SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            String key = "appdeck_preferences_json1_" + name;
            editor.putString(key, finalValue);
            editor.apply();

            call.setResult(finalValue);

            return true;
        }

        if (call.command.equalsIgnoreCase("photobrowser")) {
            Log.i("API", "**PHOTO BROWSER**");
            // only show image browser if there are images
            AppDeckJsonArray images = call.param.getArray("images");
            if (images.length() > 0) {
                PhotoBrowser photoBrowser = PhotoBrowser.newInstance(call.param, call.appDeckFragment);
                photoBrowser.loader = this;
                photoBrowser.appDeck = appDeck;
                photoBrowser.currentPageUrl = "photo://browser";
                //photoBrowser.screenConfiguration = ScreenConfiguration.defaultConfiguration();
                pushFragment(photoBrowser);
            }

            return true;
        }

        if (call.command.equalsIgnoreCase("barcode")) {
            Log.i("API", "**BARCODE**");

            BarCodeReader barCodeReader = BarCodeReader.newInstance(call.param, call.appDeckFragment);
            barCodeReader.loader = this;
            barCodeReader.appDeck = appDeck;
            barCodeReader.currentPageUrl = "barcode://reader";
            barCodeReader.apiCall = call;

            pushFragment(barCodeReader);
            return true;
        }

        if (call.command.equalsIgnoreCase("barcodehide")) {
            Log.i("API", "**BARCODE HIDE**");

            AppDeckFragment top = this.getCurrentAppDeckFragment();
            if (top.getClass() == BarCodeReader.class) {
                this.popFragment();
            }
            return true;
        }

        if (call.command.equalsIgnoreCase("loadapp")) {
            Log.i("API", "**LOAD APP**");

            String jsonUrl = call.param.getString("url");
            boolean clearCache = call.param.getBoolean("cache");

            // clear cache if asked
            if (clearCache) this.appDeck.cache.clear();

            // dowload json data, put it in cache, lauch app
            AsyncHttpClient client = new AsyncHttpClient();
            client.get(jsonUrl, new AsyncHttpResponseHandler() {
                @Override
                public void onSuccess(int statusCode, Header[] headers, byte[] content) {
                    if (statusCode == 200) {
                        appDeck.cache.storeInCache(this.getRequestURI().toString(), headers, content);
                        Intent i = new Intent(Loader.this, Loader.class);
                        i.putExtra(JSON_URL, this.getRequestURI().toString());
                        startActivity(i);
                    }
                    else Log.e(TAG, "failed to fetch config: " + this.getRequestURI().toString());
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, byte[] errorResponse, Throwable e) {
                    // called when response HTTP status is "4XX" (eg. 401, 403, 404)
                    Log.e(TAG, "Error: " + statusCode);
                }
            });

            return true;
        }

        if (call.command.equalsIgnoreCase("reload")) {
            reload(false);
            call.appDeckFragment.reload(true);
            return true;
        }

        if (call.command.equalsIgnoreCase("pageroot")) {
            Log.i("API", "**PAGE ROOT**");
            String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
            this.loadRootPage(absoluteURL);
            return true;
        }

        if (call.command.equalsIgnoreCase("pagerootreload")) {
            Log.i("API", "**PAGE ROOT RELOAD**");
            String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
            this.loadRootPage(absoluteURL);

            if (leftMenuWebView != null) leftMenuWebView.ctl.reload();
            if (rightMenuWebView != null) rightMenuWebView.ctl.reload();

            return true;
        }

        if (call.command.equalsIgnoreCase("pagepush")) {
            Log.i("API", "**PAGE PUSH**");
            String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
            this.loadPage(absoluteURL);
            return true;
        }

        if (call.command.equalsIgnoreCase("popup")) {
            Log.i("API", "**PAGE POPUP**");
            String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
            this.showPopUp(call.appDeckFragment, absoluteURL);
            return true;
        }

        if (call.command.equalsIgnoreCase("pagepop")) {
            Log.i("API", "**PAGE POP**");
            this.popFragment();
            return true;
        }

        if (call.command.equalsIgnoreCase("pagepoproot")) {
            Log.i("API", "**PAGE POP ROOT**");
            popRootFragment();
            return true;
        }

        if (call.command.equalsIgnoreCase("loadextern")) {
            Log.i("API", "**LOAD EXTERN**");
            String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
            this.loadExternalURL(absoluteURL, true);
            return true;
        }

        if (call.command.equalsIgnoreCase("slidemenu")) {
            String command = call.param.getString("command");
            String position = call.param.getString("position");

            if (command.equalsIgnoreCase("toggle")) {
                if (position.equalsIgnoreCase("left")) openLeftMenu();
                if (position.equalsIgnoreCase("right")) openRightMenu();
                if (position.equalsIgnoreCase("main")) toggleMenu();
            } else if (command.equalsIgnoreCase("open")) {
                if (position.equalsIgnoreCase("left")) openLeftMenu();
                if (position.equalsIgnoreCase("right")) openRightMenu();
                if (position.equalsIgnoreCase("main")) closeMenu();
            }
            else closeMenu();


            if (call.command.equalsIgnoreCase("select")) {
                String title = call.param.getString("title");
                AppDeckJsonArray values = call.param.getArray("values");
                String[] t = new String[values.length()];

                for (int i = 0; i < values.length(); i++) t[i] = values.getString(i);

                new MaterialDialog.Builder(this)
                        .title(title)
                        .items(t)
                        .cancelable(false)
                        .itemsCallbackSingleChoice(-1, new MaterialDialog.ListCallbackSingleChoice() {
                            @Override
                            public boolean onSelection(MaterialDialog dialog, View view, int which, CharSequence text) {
                                if (text != null) call.sendCallbackWithResult("success", text.toString());
                                else call.sendCallBackWithError("cancel");
                                call.sendPostponeResult(true);
                                return true;
                            }
                        })
                        .positiveText(android.R.string.ok)
                        .show();

                call.postponeResult();

                return true;
            }


            if (call.command.equalsIgnoreCase("selectdate")) {
                // Log.i("API", uri.getPath()+" **SELECT DATE**");

                String title = call.param.getString("title");
                String year = call.param.getString("year");
                String month = call.param.getString("month");
                String day = call.param.getString("day");

                //call.postponeResult();

                DatePickerDialog.OnDateSetListener d = new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, final int year, final int monthOfYear,
                                          final int dayOfMonth) {

                        Log.d("Date", "selected");
                        JSONObject result = new JSONObject();
                        try {
                            result.put("year", String.valueOf(year));
                            result.put("month", String.valueOf(monthOfYear + 1));
                            result.put("day", String.valueOf(dayOfMonth));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        call.sendCallbackWithResult("success", result);
                    }
                };

                int yearValue = call.param.getInt("year");
                int monthValue = call.param.getInt("month");
                int dayValue = call.param.getInt("day");
                Calendar cal = GregorianCalendar.getInstance();
                cal.set(yearValue, monthValue - 1, dayValue);
                //if (yearValue == 0)
                yearValue = cal.get(Calendar.YEAR);
                //if (monthValue == 0)
                monthValue = cal.get(Calendar.MONTH);
                //if (dayValue == 0)
                dayValue = cal.get(Calendar.DAY_OF_MONTH);
                final DatePickerDialogCustom datepicker = new DatePickerDialogCustom(this, d, yearValue, monthValue, dayValue);
                datepicker.setOnCancelListener(
                        new DialogInterface.OnCancelListener() {
                            public void onCancel(DialogInterface dialog) {
                                //call.sendPostponeResult(false);
                                call.sendCallbackWithResult("error", "cancel");
                            }
                        });
                datepicker.setOnDismissListener(new DialogInterface.OnDismissListener() {
                    @Override
                    public void onDismiss(DialogInterface dialog) {
                        //call.sendPostponeResult(false);
                        call.sendCallbackWithResult("error", "cancel");
                    }
                });

                if (year.length() > 0) datepicker.setYearEnabled(false);
                if (month.length() > 0) datepicker.setMonthEnabled(false);
                if (day.length() > 0) datepicker.setDayEnabled(false);

                datepicker.setTitle(title);
                datepicker.show();

                return true;
            }

            return true;
        }

        if (call.command.startsWith("is")) {
            Log.i("API", "** IS [" + call.command + "] **");

            boolean result = false;

            if (call.command.equalsIgnoreCase("istablet")) result = this.appDeck.isTablet;
            else if (call.command.equalsIgnoreCase("isphone")) result = !this.appDeck.isTablet;
            else if (call.command.equalsIgnoreCase("isios")) result = false;
            else if (call.command.equalsIgnoreCase("isandroid")) result = true;
            else if (call.command.equalsIgnoreCase("islandscape"))
                result = getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE;
            else if (call.command.equalsIgnoreCase("isportrait"))
                result = getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT;

            call.setResult(result);

            return true;
        }

        if (call.command.equalsIgnoreCase("facebooklogin")) {
            Log.i("API", "** FACEBOOK LOGIN **");

            Collection permissions = Arrays.asList("publish_actions");

            AppDeckJsonArray values = call.param.getArray("permissions");
            if (values != null && values.length() > 0) {
                List<String> var = new ArrayList<>();
                for (int i = 0; i < values.length(); i++) {
                    var.add(values.getString(i));
                }
                permissions = var;
            }

            LoginManager.getInstance().registerCallback(callbackManager,
                    new FacebookCallback<LoginResult>() {
                        @Override
                        public void onSuccess(LoginResult loginResult) {
                            // App code
                            Log.d(TAG, "facebook login ok");

                            JSONObject result = new JSONObject();
                            try {
                                result.put("appID", loginResult.getAccessToken().getApplicationId());
                                result.put("token", loginResult.getAccessToken().getToken());
                                result.put("userID", loginResult.getAccessToken().getUserId());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            call.sendCallbackWithResult("success", result);
                        }

                        @Override
                        public void onCancel() {
                            // App code
                            Log.d(TAG, "facebook login cancel");
                            call.sendCallBackWithError("cancel");
                        }

                        @Override
                        public void onError(FacebookException exception) {
                            // App code
                            Log.d(TAG, "facebook login error");
                            call.sendCallBackWithError(exception.getMessage());
                        }
                    });
            //call.postponeResult();

            call.setResult(true);

            willShowActivity = true;
            LoginManager.getInstance().logInWithReadPermissions(this, permissions);

            return true;

        }

        if (call.command.equalsIgnoreCase("twitterlogin")) {
            Log.i("API", "** TWITTER LOGIN **");

            if (mTwitterAuthClient == null) {
                Toast.makeText(getApplicationContext(), "Twitter is not configured for this app", Toast.LENGTH_LONG).show();
                return true;
            }

            //call.postponeResult();
            call.setResultJSON("true");

            willShowActivity = true;

            final AppDeckApiCall mycall = call;
            mTwitterAuthClient.authorize(this, new com.twitter.sdk.android.core.Callback<TwitterSession>() {

                @Override
                public void success(final Result<TwitterSession> twitterSessionResult) {
                    // Success
                    Log.d(TAG, "Twitter login ok");

                    JSONObject result = new JSONObject();
                    try {
                        result.put("userName", twitterSessionResult.data.getUserName());
                        result.put("authToken", twitterSessionResult.data.getAuthToken().token);
                        result.put("authTokenSecret", twitterSessionResult.data.getAuthToken().secret);
                        result.put("userID", twitterSessionResult.data.getUserId() + "");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    mycall.sendCallbackWithResult("success", result);
                }

                @Override
                public void failure(TwitterException e) {
                    Log.d(TAG, "twitter login failed");
                    mycall.sendCallBackWithError(e.getMessage());
                    e.printStackTrace();
                }
            });

            //call.setResult(Boolean.valueOf(true));

            return true;

        }

        if (call.command.equalsIgnoreCase("postmessage")) {
            Log.i("API", " **POST MESSAGE**");

            String js = "try {app.receiveMessage(" + call.inputJSON + ".param);} catch (e) {}";
            evaluateJavascript(js);
            return true;
        }

        if (call.command.equalsIgnoreCase("clearcookies")) {
            Log.i("API", " **CLEAR COOKIES**");

            evaluateJavascript("document.cookie.split(\";\").forEach(function(c) { document.cookie = c.replace(/^ +/, \"\").replace(/=.*/, \"=;expires=\" + new Date().toUTCString() + \";path=/\"); });");

            call.smartWebView.clearCookies();

            return true;
        }

        /*Please call CookieSyncManager.getInstance().sync() immediately after CookieManager.getInstance().removeAllCookie() call.*/
        if (call.command.equalsIgnoreCase("debug")) {
            String msg = call.input.getString("param");
            Log.i("API", "**DEBUG** " + msg);
            DebugLog.debug("JS", msg);
            return true;
        }
        if (call.command.equalsIgnoreCase("info")) {
            String msg = call.input.getString("param");
            Log.i("API", "**INFO** " + msg);
            DebugLog.info("JS", msg);
            return true;
        }
        if (call.command.equalsIgnoreCase("warning")) {
            String msg = call.input.getString("param");
            Log.i("API", "**WARNING** " + msg);
            DebugLog.warning("JS", msg);
            return true;
        }
        if (call.command.equalsIgnoreCase("error")) {
            String msg = call.input.getString("param");
            Log.i("API", "**ERROR** " + msg);
            DebugLog.error("JS", msg);
            return true;
        }
        if (call.command.equalsIgnoreCase("sendsms")) {
            String to = call.param.getString("address");
            String message = call.param.getString("body");
            Log.i("API", "**SENDSMS** " + to + ": " + message);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                String defaultSmsPackageName = Telephony.Sms.getDefaultSmsPackage(this);
                Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:" + to));
                intent.putExtra("sms_body", message);
                if (defaultSmsPackageName != null) {
                    intent.setPackage(defaultSmsPackageName);
                }
                startActivity(intent);
            } else {
                Uri smsUri = Uri.parse("tel:" + to);
                Intent intent = new Intent(Intent.ACTION_VIEW, smsUri);
                intent.putExtra("address", to);
                intent.putExtra("sms_body", message);
                intent.setType("vnd.android-dir/mms-sms");
                startActivity(intent);
            }
            return true;
        }
        if (call.command.equalsIgnoreCase("sendemail")) {
            String to = call.param.getString("to");
            String subject = call.param.getString("subject");
            String message = call.param.getString("message");
            Log.i("API", "**SENDEMAIL** " + to + ": " + subject + ": " + message);

            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setType("message/rfc822");
            intent.putExtra(Intent.EXTRA_EMAIL, new String[]{to});
            intent.putExtra(Intent.EXTRA_SUBJECT, subject);
            intent.putExtra(Intent.EXTRA_TEXT, message);
            startActivity(intent);

            return true;
        }
        if (call.command.equalsIgnoreCase("openlink")) {
            String url = call.param.getString("url");

            Log.i("API", "**OPENLINK** " + url);

            if (!url.contains("://")) url = "http://" + url;

            /*Intent intent = new Intent();
            intent.setAction(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(url));
            startActivity(intent);*/

            this.loadExternalURL(url, true);

            return true;
        }

        if (call.command.equalsIgnoreCase("snackbar")) {
            Log.i("API", "** SNACKBAR **");

            String message = call.param.getString("message");
            String action = call.param.getString("action");

            if (action == null || action.isEmpty()) action = getString(android.R.string.ok);

            call.setResultJSON("true");

            Snackbar snackbar = Snackbar
                    .make(findViewById(R.id.loader), message, Snackbar.LENGTH_LONG)
                    .setAction(action, new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            call.sendCallbackWithResult("success", new JSONObject());
                        }
                    })
                    .setCallback(new Snackbar.Callback() {
                        @Override
                        public void onDismissed(Snackbar snackbar, int event) {
                            call.sendCallBackWithError("dissmissed");
                        }
                    });
/*
            // Changing message text color
            snackbar.setActionTextColor(Color.RED);

            // Changing action button text color
            View sbView = snackbar.getView();
            TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
            textView.setTextColor(Color.YELLOW);*/
            snackbar.show();

            return true;

        }

        if (call.command.startsWith("getuserid")) {
            Log.i("API", "** GET USER ID **");

            call.setResult(AppDeck.getInstance().uid);

            return true;
        }

        /* **********************vibrate********************** */

        if (call.command.equalsIgnoreCase("vibrate")) {
            Vibrator v = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                assert v != null;
                v.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE));
            } else {
                assert v != null;
                v.vibrate(500);
            }


            return true;
        }
        /***************************************************/

        if (call.command.equalsIgnoreCase("mylocation")) { /* nouveau composant */ /* local position */

             GpsTracker gpsTracker;

            try {
                if (ContextCompat.checkSelfPermission(getApplicationContext(), android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED )
                    ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION}, 101);
                else {
                    double latitude = 0, longitude = 0 ;
                    gpsTracker = new GpsTracker(Loader.this);

                    if(gpsTracker.canGetLocation()){
                        latitude = gpsTracker.getLatitude();
                        longitude = gpsTracker.getLongitude();
                    }
                    else gpsTracker.showSettingsAlert();

                    // Create a Uri from an intent string. Use the result to create an Intent.
                    Uri gmmIntentUri = Uri.parse("google.streetview:cbll="+latitude+","+longitude);

                    // Create an Intent from gmmIntentUri. Set the action to ACTION_VIEW
                    Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
                    // Make the Intent explicit by setting the Google Maps package
                    mapIntent.setPackage("com.google.android.apps.maps");

                    // Attempt to start an activity that can handle the Intent
                    startActivity(mapIntent);
                }
            } catch (Exception e){
                e.printStackTrace();
            }

            return true;
        }
        /***********************************************************/

        if (call.command.equalsIgnoreCase("geolocation")) {

            String latitude = call.param.getString("latitude");
            String longitude = call.param.getString("longitude");

            // Create a Uri from an intent string. Use the result to create an Intent.
            Uri gmmIntentUri = Uri.parse("google.streetview:cbll="+latitude+","+longitude);

            // Create an Intent from gmmIntentUri. Set the action to ACTION_VIEW
            Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
            // Make the Intent explicit by setting the Google Maps package
            mapIntent.setPackage("com.google.android.apps.maps");

            // Attempt to start an activity that can handle the Intent
            startActivity(mapIntent);

            return true;

        }

        /***********************************************************/

        if (call.command.equalsIgnoreCase("phone")) {

            String phone = call.param.getString("phone");

            Intent intent = new Intent(Intent.ACTION_CALL, Uri.parse("tel:"+phone));
            startActivity(intent);
        }
        /***********************************************************/


        if (pluginManager.handleCall(call))
            return true;

        Log.i("API ERROR", call.command);
        return false;
    }

    @Override
    public void onBackPressed() {

        // close menu ?
        if (isLeftMenuOpen())
        {
            closeMenu();
            return;
        }
        if (isRightMenuOpen())
        {
            closeMenu();
            return;
        }

        // current fragment can go back ?
        AppDeckFragment currentFragment = getCurrentAppDeckFragment();
        if (currentFragment != null && currentFragment.canGoBack())
        {
            currentFragment.goBack();
            return;
        }

        // try to pop a fragment if possible
        if (popFragment()) {
            return;
        }

        // current fragment is home ?
        if (alternativeBootstrapURL == null)
            if (currentFragment != null && currentFragment.currentPageUrl != null)
                if (/*currentFragment == null || currentFragment.currentPageUrl == null ||*/ currentFragment.currentPageUrl.compareToIgnoreCase(appDeck.config.bootstrapUrl.toString()) != 0)
                {
                    //        	Debug.stopMethodTracing();
                    loadRootPage(appDeck.config.bootstrapUrl.toString());
                    return;
                }

        /*new AlertDialog.Builder(this)
                .setTitle("Really Exit?")
                .setMessage("Are you sure you want to exit?")
                .setNegativeButton(android.R.string.no, null)
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface arg0, int arg1) {
                        Loader.super.onBackPressed();
                    }
                }).create().show();*/

        // this will go back one time too many, we finish manually
        //Loader.super.onBackPressed();
        finish();
    }

    // Full Screen API
    public void enableFullScreen()
    {
        //getActivity().getWindow().setFlags(android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN, android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN);
        ActionBar actionBar = getSupportActionBar();
        //actionBar.setShowHideAnimationEnabled(false);
        assert actionBar != null;
        actionBar.hide();
    }

    public void disableFullScreen()
    {
        ActionBar actionBar = getSupportActionBar();
        //actionBar.setShowHideAnimationEnabled(false);
        assert actionBar != null;
        actionBar.show();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_MENU) {
            toggleMenu();
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

    public int getActionBarHeight() {
        int actionBarHeight = 0;
        TypedValue tv = new TypedValue();
        if (getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true))
            actionBarHeight = TypedValue.complexToDimensionPixelSize(tv.data,getResources().getDisplayMetrics());

        if (actionBarHeight != 0) return actionBarHeight;

        //OR as stated by @Marina.Eariel
        //TypedValue tv = new TypedValue();
        if (getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true))
            actionBarHeight = TypedValue.complexToDimensionPixelSize(tv.data,getResources().getDisplayMetrics());

        return actionBarHeight;
    }

    public void disableMenuItem() {
        if (menuItems != null) for (PageMenuItem item : menuItems) item.cancel();
    }

    public void setMenuItems(PageMenuItem[] newMenuItems) {
        // hide previous menu
        if (this.menuItems != null) for (PageMenuItem item : this.menuItems) item.cancel();
        this.menuItems = newMenuItems;
        supportInvalidateOptionsMenu();
    }

    //ShareActionProvider mShareActionProvider;

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        if (menuItems == null) return true;
        if (menuItems.length == 0) return true;

        for (PageMenuItem item : menuItems) {
            MenuItem menuItem = menu.add("button");
            item.setMenuItem(menuItem, this, menu);
        }

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        // topbar button
        if (menuItems != null) {
            for (PageMenuItem pageMenuItem : menuItems)
                if (pageMenuItem.menuItem == item) {
                    pageMenuItem.fire();
                    return true;
                }
        }

        int idx = item.getItemId();
        if (idx == android.R.id.home && !isMenuOpen() && menuArrowIsShown && popFragment()) return true;

        //if (mDrawerToggle.onOptionsItemSelected(item))
        //    return true;

        if (idx == android.R.id.home)
        {
            toggleMenu();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void share(String title, String url, String imageURL)
    {
        // add stats
        appDeck.ga.event("action", "share", (url != null && !url.isEmpty() ? url : title), 1);

        // create share intent
        Intent sharingIntent = new Intent(android.content.Intent.ACTION_SEND);

        // trim title if needed
        if (title != null) title = title.trim();

        sharingIntent.setType("text/plain");
        if (title != null && !title.isEmpty()) sharingIntent.putExtra(Intent.EXTRA_SUBJECT, title);
        if (url != null && !url.isEmpty()) sharingIntent.putExtra(Intent.EXTRA_TEXT, url);

        // not an image ?
        if (imageURL == null || imageURL.isEmpty())
        {
            startActivity(Intent.createChooser(sharingIntent, "Share via"));
            return;
        }

        // image ?
        DisplayImageOptions options = new DisplayImageOptions.Builder()
                .cacheInMemory(true)
                .cacheOnDisc(true)
                .build();

        // patch image URL
        if (imageURL.startsWith("//")) imageURL = "http:" + imageURL;

        // Load image, decode it to Bitmap and return Bitmap to callback
        appDeck.imageLoader.loadImage(imageURL, options, new sharingImageLoadingListener(imageURL, sharingIntent));
    }

    private class sharingImageLoadingListener extends SimpleImageLoadingListener
    {
        @SuppressWarnings("unused")
        String imageURL;
        Intent sharingIntent;

        sharingImageLoadingListener(String imageURL, Intent sharingIntent)
        {
            this.imageURL = imageURL;
            this.sharingIntent = sharingIntent;
        }

        @Override
        public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
            Log.e("image Sharing", failReason.toString());
        };

        @Override
        public void onLoadingComplete(String imageUri, View view,
                                      Bitmap loadedImage) {
            super.onLoadingComplete(imageUri, view, loadedImage);

            ByteArrayOutputStream bytes = new ByteArrayOutputStream();
            loadedImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
            File f = new File(Environment.getExternalStorageDirectory() + File.separator + "image.jpg");
            try {
                f.createNewFile();
                FileOutputStream fo = new FileOutputStream(f);
                fo.write(bytes.toByteArray());
                fo.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            sharingIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse("file://" + Environment.getExternalStorageDirectory().getPath()  + "image.jpg"));
            startActivity(Intent.createChooser(sharingIntent, "Share via"));
        }
    }

    // cancel popup, popover, dialog from current page
    public void cancelSubViews()
    {
		/*if (appDeck.glPopup != null)
		{
			appDeck.glPopup.finish();
			appDeck.glPopup = null;
		}*/
        if (!isForeground)
            return;
        FragmentManager fragmentManager = getSupportFragmentManager();
        if (fragmentManager == null)
            return;
        Fragment popover = fragmentManager.findFragmentByTag("fragmentPopOver");
        if (popover != null)
        {
            FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
            //fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
            fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
            fragmentTransaction.remove(popover);
            fragmentTransaction.commitAllowingStateLoss();
        }
        Fragment popup = fragmentManager.findFragmentByTag("fragmentPopUp");
        if (popup != null)
        {
            Objects.requireNonNull(getSupportActionBar()).show();
            FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
            fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_CLOSE);
            fragmentTransaction.remove(popup);
            fragmentTransaction.commitAllowingStateLoss();
        }
    }

    /************************************************/
    public void showPopOver(AppDeckFragment origin, AppDeckApiCall call, String url)
    {

        AppDeckFragment fragment = initPageFragment(url, true, false);
        pushFragment(fragment);

        /************************/
//        AlertDialog.Builder alert = new AlertDialog.Builder(Loader.this);
//        WebView wv = new WebView(Loader.this);
//        wv.loadUrl(url);
//        wv.setWebViewClient(new WebViewClient() {
//            @Override
//            public boolean shouldOverrideUrlLoading(WebView view, String url) {
//                view.loadUrl(url);
//
//                return true;
//            }
//        });
//        alert.setView(wv);
//        alert.setNegativeButton("Close", new DialogInterface.OnClickListener() {
//            @Override
//            public void onClick(DialogInterface dialog, int id) {
//                dialog.dismiss();
//            }
//        });
//        alert.show();
        /***********************/


//		if (origin != null)
//			origin.loader.cancelSubViews();

	    // rather create this as a instance variable of your class
//        PopOverFragment  popover = new PopOverFragment(origin, call);
//		popover.loader = this;
//		//popover.setRetainInstance(true);
//		//popover.screenConfiguration = appDeck.config.getConfiguration(popover.currentPageUrl);
//
//		FragmentManager fm = getSupportFragmentManager();
//		FragmentTransaction ft = fm.beginTransaction();
//		ft.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
//		//ft.add(popover, "fragmentPopOver");
//		ft.add(R.id.loader_container, popover, "fragmentPopOver");
//		ft.commitAllowingStateLoss();


//		Dialog popUpDialog = new Dialog(getBaseContext(),
//                android.R.style.Theme_Translucent_NoTitleBar);
//		popUpDialog.setCanceledOnTouchOutside(true);
//		popUpDialog.setContentView(popover.getView());
    }

    public void showPopUp(AppDeckFragment origin, String absoluteURL)
    {
        //Log.w(TAG, "PopUp not suported on Android Platform, use push instead");
        //loadPage(url);

        AppDeckFragment fragment = initPageFragment(absoluteURL, true, false);
        pushFragment(fragment);

/*        PopUpFragment popupfragment = PopUpFragment.newInstance(absoluteURL);

        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        //fragmentTransaction.setTransitionStyle(1);
        //fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        //fragmentTransaction.setCustomAnimations(android.R.anim.fade_in,android.R.anim.fade_out,android.R.anim.fade_in,android.R.anim.fade_out);

        //fragmentTransaction.setCustomAnimations(R.anim.slide_in_left, R.anim.slide_out_left);

        //fragmentTransaction.setCustomAnimations(R.anim.slide_in_right, R.anim.slide_out_left, R.anim.slide_in_left, R.anim.slide_out_right);
        //fragmentTransaction.setCustomAnimations(R.anim.exit, R.anim.enter);

        AppDeckFragment oldFragment = getCurrentAppDeckFragment();
        if (oldFragment != null)
        {
            oldFragment.setIsMain(false);

            //fragmentTransaction.hide(oldFragment);
            //fragmentTransaction.setCustomAnimations(R.anim.slide_in_right, R.anim.slide_out_left, R.anim.slide_in_left, R.anim.slide_out_right);
            //fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        }


        fragmentTransaction.add(R.id.loader_container, popupfragment, "fragmentPopUp");
        //fragmentTransaction.replace(R.id.loader_container, fragment, "AppDeckFragment");
        //fragmentTransaction.addToBackStack("AppDeckFragment");

        fragmentTransaction.addToBackStack("fragmentPopUp");

        //fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        //fragmentTransaction.setTransitionStyle()

        //fragmentTransaction.setCustomAnimations(android.R.anim.fade_in,android.R.anim.fade_out);
        //Animations(android.R.anim.fade_in,android.R.anim.fade_out,android.R.anim.fade_in,android.R.anim.fade_out);

        fragmentTransaction.commitAllowingStateLoss();*/


    }

    /*
    public void showPopUp(AppDeckFragment origin, String url)
    {
        if (origin != null)
            origin.loader.cancelSubViews();
        Intent intent = new Intent(this, PopUp.class);
        //intent.setFlags(Intent.FLAG_ACTIVITY_TASK_ON_HOME | Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_NO_ANIMATION);
//    			|Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
        intent.putExtra(PopUp.POP_UP_URL, (origin != null ? origin.resolveURL(url) : url));
        startActivity(intent);
        //overridePendingTransition(android.R.anim.slide_in_left, android.R.anim.slide_out_right);
        Display display = ((android.view.WindowManager)
                getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
        if ((display.getRotation() == Surface.ROTATION_0) ||
            (display.getRotation() == Surface.ROTATION_180)) {
            //overridePendingTransition(R.anim.slide_up, R.anim.slide_down);
            overridePendingTransition(R.anim.slide_up, android.R.anim.fade_out);
        } else if ((display.getRotation() == Surface.ROTATION_90) ||
                   (display.getRotation() == Surface.ROTATION_270)) {
            //overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_left);
            overridePendingTransition(R.anim.slide_in_left, android.R.anim.fade_out);

        }
        //getActivity().getWindow().setFlags(android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN, android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN);

    }
    */
    protected void createIntent(String type, String absoluteURL)
    {
        cancelSubViews();
        Intent i = new Intent(this, Loader.class);
        i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        //i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        i.putExtra(type, absoluteURL);
        startActivity(i);
    }

    @Override
    protected void onNewIntent(Intent intent)
    {
        super.onNewIntent(intent);
        this.setIntent(intent); // update Activity Intent

        Log.d(TAG, "onNewIntent");

        SmartWebViewFactory.onActivityNewIntent(this, intent);

/*        if (mUIReady == false || mAppDeckReady == false || mProxyReady == false) {
            mShouldResendIntent = true;
            Log.d(TAG, "mShouldResendIntent");
            return;
        }*/

        isForeground = true;
        Bundle extras = intent.getExtras();
        if (extras == null)
            return;

        // loadUrl intent
        String url = extras.getString(PAGE_URL);
        if (url != null && !url.isEmpty())
        {
            loadPage(url);
            return;
        }

        // root url
        url = extras.getString(ROOT_PAGE_URL);
        if (url != null && !url.isEmpty())
        {
            loadRootPage(url);
            return;
        }

        // Push Notification
        url = extras.getString(PUSH_URL);
        if (url != null && !url.isEmpty())
        {
            String title = extras.getString(PUSH_TITLE);
            String imageUrl = extras.getString(PUSH_IMAGE_URL);
            Log.i(TAG, "Auto Open Push: "+title+" url: "+url);
            //handlePushNotification(title, url, imageUrl);
            try {
                url = appDeck.config.app_base_url.resolve(url).toString();
                loadPage(url);
            } catch (Exception ignored) {}
        }
    }

    @Override
    public  void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        if (smartWebViewRegiteredForActivityResult != null) {
            smartWebViewRegiteredForActivityResult.onActivityResult(this, requestCode, resultCode, data);
            smartWebViewRegiteredForActivityResult = null;
        } else {
            SmartWebViewFactory.onActivityResult(this, requestCode, resultCode, data);
        }
        if (callbackManager != null)
            callbackManager.onActivityResult(requestCode, resultCode, data);
        if (mTwitterAuthClient != null)
            mTwitterAuthClient.onActivityResult(requestCode, resultCode, data);
        if (pluginManager != null)
            pluginManager.onActivityResult(this, requestCode, resultCode, data);
    }



    boolean pushDialogInProgress = false;

    public void handlePushNotification(String title, String url, String imageUrl)
    {
        if (url != null)
            url = appDeck.config.app_base_url.resolve(url).toString();
        if (imageUrl != null)
            imageUrl = appDeck.config.app_base_url.resolve(imageUrl).toString();
        if (title == null || title.equalsIgnoreCase(""))
            return;
        new PushDialog(url, title, imageUrl).show();
    }

    public class PushDialog
    {
        String url;
        String title;
        String imageUrl;

        public PushDialog(String url, String title, String imageUrl)
        {
            this.url = url;
            this.title = title;
            this.imageUrl = imageUrl;
        }

        public void show()
        {
            if (pushDialogInProgress) return;

            pushDialogInProgress = true;

            new MaterialDialog.Builder(Loader.this)
                    .content(title)
                    .positiveText(android.R.string.ok)
                    .negativeText(android.R.string.cancel)
                    .cancelable(false)
                    .onPositive(new MaterialDialog.SingleButtonCallback() {
                        @Override
                        public void onClick(@NonNull MaterialDialog materialDialog, @NonNull DialogAction dialogAction) {
                            loadPage(url);
                            pushDialogInProgress = false;
                        }
                    })
                    .onNegative(new MaterialDialog.SingleButtonCallback() {
                        @Override
                        public void onClick(@NonNull MaterialDialog materialDialog, @NonNull DialogAction dialogAction) {
                            pushDialogInProgress = false;
                        }
                    }).show();
        }
    }

    boolean shouldRenderActionBar = true;
    public void toggleActionBar()
    {
        shouldRenderActionBar = !shouldRenderActionBar;

        if (shouldRenderActionBar)
            getSupportActionBar().show();
        else
            getSupportActionBar().hide();
    }

    void enableProxy()
    {
        if (this.proxyHost != null) {
            System.setProperty("http.proxyHost", this.proxyHost);
            System.setProperty("http.proxyPort", this.proxyPort + "");
            System.setProperty("https.proxyHost", this.proxyHost);
            System.setProperty("https.proxyPort", this.proxyPort + "");
        }
    }

    void disableProxy()
    {
        if (this.originalProxyHost != null) {
            System.setProperty("http.proxyHost", this.originalProxyHost);
            System.setProperty("http.proxyPort", this.originalProxyPort + "");
            System.setProperty("https.proxyHost", this.originalProxyHost);
            System.setProperty("https.proxyPort", this.originalProxyPort + "");
        } else {
            System.setProperty("http.proxyHost", "");
            System.setProperty("http.proxyPort", "");
            System.setProperty("https.proxyHost", "");
            System.setProperty("https.proxyPort", "");

        }
    }
}
