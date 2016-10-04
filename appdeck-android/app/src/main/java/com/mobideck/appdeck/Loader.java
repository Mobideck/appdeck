package com.mobideck.appdeck;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;
import com.crashlytics.android.Crashlytics;

import hotchemi.android.rate.AppRate;
import hotchemi.android.rate.OnClickButtonListener;
/*import io.branch.indexing.BranchUniversalObject;
import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.SharingHelper;
import io.branch.referral.util.LinkProperties;
import io.branch.referral.util.ShareSheetStyle;*/
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
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.littleshoot.proxy.ChainedProxy;
import org.littleshoot.proxy.ChainedProxyAdapter;
import org.littleshoot.proxy.ChainedProxyManager;
import org.littleshoot.proxy.HttpProxyServerBootstrap;
import org.littleshoot.proxy.TransportProtocol;
import org.littleshoot.proxy.impl.DefaultHttpProxyServer;
//import org.littleshoot.proxy.mitm.CertificateSniffingMitmManager;
//import org.littleshoot.proxy.mitm.RootCertificateException;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.app.AlertDialog;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.provider.Telephony;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentManager.OnBackStackChangedListener;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v4.content.res.ResourcesCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.ShareActionProvider;
import android.support.v7.widget.Toolbar;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.Display;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.DecelerateInterpolator;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
/*import com.gc.materialdesign.views.ProgressBarCircularIndeterminate;
import com.gc.materialdesign.views.ProgressBarDeterminate;
import com.gc.materialdesign.views.ProgressBarIndeterminate;
import com.gc.materialdesign.views.ProgressBarIndeterminateDeterminate;*/
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.mobideck.appdeck.plugin.PluginManager;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;
import com.facebook.FacebookSdk;
//import com.twitter.sdk.android.Twitter;
import com.twitter.sdk.android.core.IntentUtils;
import com.twitter.sdk.android.core.Result;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterCore;
import com.twitter.sdk.android.core.TwitterException;
import com.twitter.sdk.android.core.TwitterSession;
import com.twitter.sdk.android.core.identity.TwitterAuthClient;

import io.netty.handler.codec.http.HttpObject;
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

    /*ProgressBarDeterminate mProgressBarDeterminate;
    ProgressBarIndeterminate mProgressBarIndeterminate;*/

    Toolbar mToolbar;
    Drawable mUpArrow;
    Drawable mClose;

    private boolean historyInjected = false;
    public List<String> historyUrls = new ArrayList<String>();

    public boolean willShowActivity = false;

    public String actionBarContent = null;

    Crashlytics crashlytics;

    CallbackManager callbackManager;
    TwitterAuthClient mTwitterAuthClient;

    PluginManager pluginManager;

    public SmartWebViewInterface smartWebViewRegiteredForActivityResult = null;

	@SuppressWarnings("unused")
	//private GoogleCloudMessagingHelper gcmHelper;
    //private AppDeckBroadcastReceiver appDeckBroadcastReceiver;

    // Google Cloud Messaging
    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;

    private BroadcastReceiver mRegistrationBroadcastReceiver;
    private boolean isReceiverRegistered;


    protected void onCreatePass(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    }

	@Override
    protected void onCreate(Bundle savedInstanceState) {
        //Debug.startMethodTracing("calc");
		AppDeckApplication app = (AppDeckApplication) getApplication();

        crashlytics = new Crashlytics.Builder().disabled(BuildConfig.DEBUG).build();

        Log.d(TAG, "Use AppDeck version "+AppDeck.version);

        if (app.isInitialLoading == false)
        {
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
                appDeck = new AppDeck((AppDeckApplication)getApplication(), app_json_url);

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
                do
                {
                    isAvailable = Utils.isPortAvailable(proxyPort);
                    if (isAvailable == false)
                        proxyPort = Utils.randInt(10000, 60000);
                }
                while (isAvailable == false);

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
                /*} catch (Exception e) {
                    e.printStackTrace();
                }*/

                if (originalProxyHost != null && originalProxyPort != -1)
                {
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


        setContentView(R.layout.loader);

        // for video support
        nonVideoLayout = (View)findViewById(R.id.loader_content); // Your own view, read class comments
        videoLayout = (ViewGroup)findViewById(R.id.videoLayout); // Your own view, read class comments

        mToolbar = (Toolbar) findViewById(R.id.app_toolbar);
        setSupportActionBar(mToolbar);
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        //

        mProgressBarDeterminate = (MaterialProgressBar) findViewById(R.id.progressBarDeterminate);
        mProgressBarIndeterminate = (MaterialProgressBar) findViewById(R.id.progressBarIndeterminate);
        //mProgressBar.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        //mProgressBar.setMi
        mProgressBarDeterminate.setMax(100);

        /*
        mProgressBarDeterminate = (ProgressBarDeterminate)findViewById(R.id.progressBarDeterminate);
        mProgressBarDeterminate.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        mProgressBarDeterminate.setMin(0);
        mProgressBarDeterminate.setMax(100);
        mProgressBarIndeterminate = (ProgressBarIndeterminate)findViewById(R.id.progressBarIndeterminate);*/

        mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);

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

        //if (appDeck.config.leftMenuUrl != null) {
        //} else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));
        //}
        
        //if (appDeck.config.rightMenuUrl != null) {
        //} else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));
        //}

        // configure action bar

        mUpArrow = ContextCompat.getDrawable(this, R.drawable.ic_arrow_back_white_24dp);
        //mUpArrow = ResourcesCompat.getDrawable(getResources(), R.drawable.ic_arrow_back_white_24dp, null);

        mUpArrow.setColorFilter(getResources().getColor(R.color.AppDeckColorTopBarText), PorterDuff.Mode.SRC_ATOP);
        mDrawerToggle.setHomeAsUpIndicator(mUpArrow);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true); // show icon on the left of logo
        getSupportActionBar().setDisplayShowHomeEnabled(true); // show logo
        getSupportActionBar().setHomeButtonEnabled(true); // ???

        // status bar
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            //getWindow().setStatusBarColor(getResources().getColor(R.color.AppDeckColorPrimary));
            //getWindow().setTitleColor(getResources().getColor(R.color.AppDeckColorPrimary));
        /*if (appDeck.config.icon_theme.equalsIgnoreCase("light"))
            getSupportActionBar().setHomeAsUpIndicator(R.drawable.ic_navigation_drawer_light);
        else
            getSupportActionBar().setHomeAsUpIndicator(R.drawable.ic_navigation_drawer);*/
        }

		setSupportProgressBarVisibility(false);
		setSupportProgressBarIndeterminate(false);

		getSupportFragmentManager().addOnBackStackChangedListener(new OnBackStackChangedListener() {
            public void onBackStackChanged() {
                AppDeckFragment fragment = getCurrentAppDeckFragment();

                if (fragment != null) {
                    if (mUIReady && mAppDeckReady && mProxyReady )
                        fragment.setIsMain(true);
                }
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
    //private boolean mShouldResendIntent = false;

    public boolean justLaunch = true;

    private void preLoadLoading() {

        if (mUIReady == false || mAppDeckReady == false /*|| mProxyReady == false*/)
            return;

        appDeck.actionBarHeight = getActionBarHeight();
        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        appDeck.actionBarWidth = size.x;

        FrameLayout debugLog = (FrameLayout)findViewById(R.id.debugLog);
        Button debugLogButton = (Button) findViewById(R.id.closeDebug);
        if (appDeck.isDebugBuild) {
            new DebugLog(debugLog, debugLogButton);
        } else {

        }
/*        Utils.downloadIcon(appDeck.config.icon_close.toString(), appDeck.actionBarHeight, new SimpleImageLoadingListener() {
            @Override
            public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
                mClose = new BitmapDrawable(loadedImage);
            }
        }, this);*/

        if (appDeck.config.topbar_color != null)
            getSupportActionBar().setBackgroundDrawable(appDeck.config.topbar_color.getDrawable());

        if (appDeck.config.title != null)
            getSupportActionBar().setTitle(appDeck.config.title);

        if (appDeck.config.leftMenuUrl != null) {
            mDrawerLeftMenu = (FrameLayout) findViewById(R.id.left_drawer);
            if (appDeck.config.leftmenu_background_color != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
                mDrawerLeftMenu.setBackground(appDeck.config.leftmenu_background_color.getDrawable());
            mDrawerLeftMenu.post(new Runnable() {
                @Override
                public void run() {
                    Resources resources = getResources();
                    float width = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, appDeck.config.leftMenuWidth, resources.getDisplayMetrics());
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerLeftMenu.getLayoutParams();
                    params.width = (int) (width);
                    mDrawerLeftMenu.setLayoutParams(params);
                }
            });
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.left_drawer));
        } else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));
        }
        if (appDeck.config.rightMenuUrl != null) {
            mDrawerRightMenu = (FrameLayout) findViewById(R.id.right_drawer);
            if (appDeck.config.rightmenu_background_color != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
                mDrawerRightMenu.setBackground(appDeck.config.rightmenu_background_color.getDrawable());
            mDrawerRightMenu.post(new Runnable() {
                @Override
                public void run() {
                    Resources resources = getResources();
                    float width = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, appDeck.config.rightMenuWidth, resources.getDisplayMetrics());
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerRightMenu.getLayoutParams();
                    params.width = (int) (width);
                    mDrawerRightMenu.setLayoutParams(params);
                }
            });
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.right_drawer));
        } else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));
        }

        Intent intent = getIntent();
        String action = intent.getAction();
        Uri data = intent.getData();
        if (data != null)
        {
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
                String imageUrl = extras.getString(PUSH_IMAGE_URL);
                Log.i(TAG, "Auto Open Push on Create: " + title + " url: " + url);
                //handlePushNotification(title, url, imageUrl);
                try {
                    url = appDeck.config.app_base_url.resolve(url).toString();
                    loadPage(url);
                } catch (Exception e) {

                }
            }
        }

        loadLoading();
    }

    private void loadLoading() {
        if (mUIReady == false || mAppDeckReady == false || mProxyReady == false)
            return;
        appDeck.proxyHost = proxyHost;
        appDeck.proxyPort = proxyPort;

        AppDeckFragment fragment = getCurrentAppDeckFragment();
        if (fragment != null) {
            if (fragment.isMain == false)
                fragment.setIsMain(true);
        }

        /*if (mShouldResendIntent) {
            mShouldResendIntent = false;
            onNewIntent(getIntent());
        }*/
    }

    boolean mPostLoadLoadingCalled = false;

    private void postLoadLoading() {

        if (mPostLoadLoadingCalled)
            return;
        mPostLoadLoadingCalled = true;

        //android.os.Debug.stopMethodTracing();

        AppDeckApplication app = (AppDeckApplication) getApplication();
        if (appDeck.config.twitter_consumer_key != null && appDeck.config.twitter_consumer_secret != null &&
                appDeck.config.twitter_consumer_key.length() > 0 && appDeck.config.twitter_consumer_secret.length() > 0
                ) {
            TwitterAuthConfig authConfig = new TwitterAuthConfig(appDeck.config.twitter_consumer_key, appDeck.config.twitter_consumer_secret);
            Fabric.with(app, crashlytics, new TwitterCore(authConfig));
            mTwitterAuthClient = new TwitterAuthClient();
        } else {
            Fabric.with(app, crashlytics);
        }

        FacebookSdk.sdkInitialize(getApplicationContext());
        AppEventsLogger.activateApp(this);
        callbackManager = CallbackManager.Factory.create();

        adManager = new AppDeckAdManager(this);
        adManager.showAds(AppDeckAdManager.EVENT_START);

        /*
        gcmHelper = new GoogleCloudMessagingHelper(getBaseContext());
        appDeckBroadcastReceiver = new AppDeckBroadcastReceiver(this);
        appDeckBroadcastReceiver.loaderActivity = this;
        IntentFilter filter = new IntentFilter("com.google.android.c2dm.intent.RECEIVE");
        filter.setPriority(1);
        registerReceiver(appDeckBroadcastReceiver, filter);*/


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
                        Log.d(Loader.class.getName()+" AppRater Click", Integer.toString(which));
                    }
                })
                .monitor();
        AppRate.showRateDialogIfMeetsConditions(this);

        if (appDeck.config.prefetch_url != null && !appDeck.isLowSystem)
        {
            //ArchiveExtractCallback.extractDir = this.cacheDir;
            appDeck.remote = new RemoteAppCache(appDeck.config.prefetch_url.toString(), appDeck.config.prefetch_ttl);
            appDeck.remote.downloadAppCache();
        }

        loadMenuWebviews();

    }

    private boolean mMenuLoaded = false;

    private void loadMenuWebviews() {
        if (mMenuLoaded)
            return;
        mMenuLoaded = true;

        if (appDeck.config.leftMenuUrl != null) {
            leftMenuWebView = SmartWebViewFactory.createMenuSmartWebView(this, appDeck.config.leftMenuUrl.toString(), SmartWebViewFactory.POSITION_LEFT);
            if (appDeck.config.leftmenu_background_color != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
                leftMenuWebView.view.setBackground(appDeck.config.leftmenu_background_color.getDrawable());
            //mDrawerLeftMenu = (FrameLayout) findViewById(R.id.left_drawer);
            mDrawerLeftMenu.post(new Runnable() {
                @Override
                public void run() {
                    Resources resources = getResources();
                    float width = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, appDeck.config.leftMenuWidth, resources.getDisplayMetrics());
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerLeftMenu.getLayoutParams();
                    params.width = (int) (width);
                    mDrawerLeftMenu.setLayoutParams(params);
                    mDrawerLeftMenu.addView(leftMenuWebView.view);
                }
            });
        }/* else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));
        }*/

        if (appDeck.config.rightMenuUrl != null) {
            rightMenuWebView = SmartWebViewFactory.createMenuSmartWebView(this, appDeck.config.rightMenuUrl.toString(), SmartWebViewFactory.POSITION_RIGHT);
            if (appDeck.config.rightmenu_background_color != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
                rightMenuWebView.view.setBackground(appDeck.config.rightmenu_background_color.getDrawable());
            //mDrawerRightMenu = (FrameLayout) findViewById(R.id.right_drawer);
            mDrawerRightMenu.post(new Runnable() {
                @Override
                public void run() {
                    Resources resources = getResources();
                    float width = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, appDeck.config.rightMenuWidth, resources.getDisplayMetrics());
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerRightMenu.getLayoutParams();
                    params.width = (int) (width);
                    mDrawerRightMenu.setLayoutParams(params);
                    mDrawerRightMenu.addView(rightMenuWebView.view);
                }
            });
        }/* else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));
        }*/
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        if (mDrawerToggle != null)
            mDrawerToggle.syncState();
    }

    public FrameLayout getBannerAdViewContainer()
    {
        return (FrameLayout)findViewById(R.id.bannerContainer);
    }
    public FrameLayout getInterstitialAdViewContainer()
    {
        return (FrameLayout)findViewById(R.id.app_container);
    }

    /*
    @Override
    public void onStart() {
        super.onStart();

        Branch branch = Branch.getInstance();

        branch.initSession(new Branch.BranchReferralInitListener(){
            @Override
            public void onInitFinished(JSONObject referringParams, BranchError error) {
                if (error == null) {
                    // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                    // params will be empty if no data found
                    // ... insert custom logic here ...
                    String url = referringParams.optString("url", null);
                    String title = referringParams.optString("title", null);
                    String imageUrl = referringParams.optString("imageUrl", null);
                    handlePushNotification(url, title, imageUrl);
                } else {
                    Log.i("MyApp", error.getMessage());
                }
            }
        }, this.getIntent().getData(), this);
    }*/

	boolean isForeground = true;

    @Override
    protected void onResume()
    {
    	super.onResume();
        registerReceiver();
        if (pluginManager != null)
            pluginManager.onActivityResume(this);
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        isForeground = true;
        if (willShowActivity == false)
            SmartWebViewFactory.onActivityResume(this);
        willShowActivity = false; // always set it to false
        //IntentFilter filter = new IntentFilter("com.google.android.c2dm.intent.RECEIVE");
        //filter.setPriority(1);
        /*if (appDeckBroadcastReceiver != null) {
            appDeckBroadcastReceiver.loaderActivity = this;
            registerReceiver(appDeckBroadcastReceiver, filter);
        }*/
        // Logs 'install' and 'app activate' App Events.
        if (mPostLoadLoadingCalled)
            AppEventsLogger.activateApp(this);
        enableProxy();
        if (adManager != null)
            adManager.onActivityResume();
    }

    @Override
    protected void onPause()
    {
        super.onPause();
    	isForeground = false;
        if (willShowActivity == false)
            SmartWebViewFactory.onActivityPause(this);
        try {
            //appDeckBroadcastReceiver.clean();
            //unregisterReceiver(appDeckBroadcastReceiver);
            LocalBroadcastManager.getInstance(this).unregisterReceiver(mRegistrationBroadcastReceiver);
            isReceiverRegistered = false;
        } catch (Exception e) {

        }
    	if (appDeck!= null && appDeck.noCache)
    		Utils.killApp(true);
        disableProxy();
        // Logs 'app deactivate' App Event.
        AppEventsLogger.deactivateApp(this);
        if (adManager != null)
            adManager.onActivityPause();
        if (pluginManager != null)
            pluginManager.onActivityPause(this);
    }

    private void registerReceiver(){
        if(!isReceiverRegistered) {
            LocalBroadcastManager.getInstance(this).registerReceiver(mRegistrationBroadcastReceiver,
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
            if (apiAvailability.isUserResolvableError(resultCode)) {
                apiAvailability.getErrorDialog(this, resultCode, PLAY_SERVICES_RESOLUTION_REQUEST)
                        .show();
            } else {
                Log.i(TAG, "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }

    @Override
    protected void onSaveInstanceState(Bundle outState)
    {
    	outState.putString("WORKAROUND_FOR_BUG_19917_KEY", "WORKAROUND_FOR_BUG_19917_VALUE");    	
    	super.onSaveInstanceState(outState);
        SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);

        // only keep maxHistoryUrlsSize URLS
        int maxHistoryUrlsSize = 5;
        if (historyUrls.size() > maxHistoryUrlsSize)
            historyUrls = historyUrls.subList(historyUrls.size() - maxHistoryUrlsSize - 1, historyUrls.size() - 1);

        //Set<String> hs = prefs.getStringSet("set", new HashSet<String>());
        Set<String> in = new HashSet<String>(historyUrls);
        //in.add(String.valueOf(hs.size() + 1));
        prefs.edit().putStringSet("historyUrls", in).commit(); // brevity

        if (adManager != null)
            adManager.onActivitySaveInstanceState(outState);

        Log.i(TAG, "onSaveInstanceState");
    }
    
    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState)
    {
      super.onRestoreInstanceState(savedInstanceState);
      if (adManager != null)
         adManager.onActivityRestoreInstanceState(savedInstanceState);
      Log.i(TAG, "onRestoreInstanceState");
    }
    
    @Override
    protected void onDestroy()
    {
    	super.onDestroy();
        isForeground = false;
        SmartWebViewFactory.onActivityDestroy(this);
        if (pluginManager != null)
            pluginManager.onActivityDestroy(this);
    }    

    // Sliding Menu API
    
    public void toggleMenu()
    {
    	if (isMenuOpen())
    		closeMenu();
    	else
    		openMenu();
    }

    public void toggleLeftMenu()
    {
    	if (isMenuOpen())
    		closeMenu();
    	else
    		openLeftMenu();
    }

    public void toggleRightMenu()
    {
    	if (isMenuOpen())
    		closeMenu();
    	else
    		openRightMenu();
    }    
    
    public boolean isMenuOpen()
    {
    	if (mDrawerLayout == null)
    		return false;
    	if (mDrawerLeftMenu != null && mDrawerLayout.isDrawerOpen(mDrawerLeftMenu))
    		return true;
    	if (mDrawerRightMenu != null && mDrawerLayout.isDrawerOpen(mDrawerRightMenu))
    		return true;
    	return false;
    }
    
    public boolean isLeftMenuOpen()
    {
    	if (mDrawerLayout == null)
    		return false;
    	if (mDrawerLeftMenu != null && mDrawerLayout.isDrawerOpen(mDrawerLeftMenu))
    		return true;
    	return false;    	
    }

    public boolean isRightMenuOpen()
    {
    	if (mDrawerLayout == null)
    		return false;
    	if (mDrawerRightMenu != null && mDrawerLayout.isDrawerOpen(mDrawerRightMenu))
    		return true;
    	return false;
    }    
    
    public void openLeftMenu()
    {
    	closeMenu();
        if (menuEnabled == false)
            return;
    	if (mDrawerLayout == null)
    		return;
    	if (mDrawerLeftMenu != null)
			mDrawerLayout.openDrawer(mDrawerLeftMenu);
    }
    
    public void openRightMenu()
    {
    	closeMenu();
        if (menuEnabled == false)
            return;
    	if (mDrawerLayout == null)
    		return;
		if (mDrawerRightMenu != null)
			mDrawerLayout.openDrawer(mDrawerRightMenu);
    }

    public void openMenu()
    {
        closeMenu();
        if (menuEnabled == false)
            return;
    	if (mDrawerLayout == null)
    		return;
    	if (mDrawerLeftMenu != null)
    	{
			mDrawerLayout.openDrawer(mDrawerLeftMenu);
			return;
    	}
    	if (mDrawerRightMenu != null)
    	{
			mDrawerLayout.openDrawer(mDrawerRightMenu);
			return;
    	}
    }    
    
    public void closeMenu()
    {
       	if (mDrawerLayout == null)
       		return;
       	mDrawerLayout.closeDrawers();   	
    }

    private boolean menuEnabled = true;

    public void disableMenu()
    {
        menuEnabled = false;
    	closeMenu();
       	if (mDrawerLayout == null)
       		return;

        if (appDeck.config.leftMenuUrl != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));
        if (appDeck.config.rightMenuUrl != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));

       	//mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);

        //getSupportActionBar().setDisplayHomeAsUpEnabled(false); // icon on the left of logo
        //getSupportActionBar().setDisplayShowHomeEnabled(false); // make icon + logo + title clickable

        getSupportActionBar().setDisplayHomeAsUpEnabled(false); // show icon on the left of logo
        getSupportActionBar().setDisplayShowHomeEnabled(true); // show logo
        getSupportActionBar().setHomeButtonEnabled(true); // ???



    }

    public void enableMenu()
    {
        menuEnabled = true;
       	if (mDrawerLayout == null)
       		return;
        if (appDeck.config.leftMenuUrl != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.left_drawer));
        if (appDeck.config.rightMenuUrl != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.right_drawer));

       	//mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true); // show icon on the left of logo
        getSupportActionBar().setDisplayShowHomeEnabled(true); // make icon + logo + title clickable
        /*if (appDeck.config.icon_theme.equalsIgnoreCase("light"))
            getSupportActionBar().setHomeAsUpIndicator(R.drawable.ic_navigation_drawer_light);
        else
            getSupportActionBar().setHomeAsUpIndicator(R.drawable.ic_navigation_drawer);*/
    }

    boolean menuArrowIsShown = false;
    public void setMenuArrow(boolean show)
    {
        if (menuArrowIsShown == show)
            return;
        menuArrowIsShown = show;
        float start = (show ? 0 : 1);
        float end = (show ? 1 : 0);
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
                if (menuArrowIsShown == false)
                    mDrawerToggle.setDrawerIndicatorEnabled(true);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                if (menuArrowIsShown)
                    mDrawerToggle.setDrawerIndicatorEnabled(false);
                else
                    mDrawerToggle.setDrawerIndicatorEnabled(true);
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        anim.start();
    }
    
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mDrawerToggle.onConfigurationChanged(newConfig);
    }
    
    ArrayList<WeakReference<AppDeckFragment>> fragList = new ArrayList<WeakReference<AppDeckFragment>>();
    @SuppressWarnings({ "unchecked", "rawtypes" })
	@Override
    public void onAttachFragment (Fragment fragment) {
    	
    	if (fragment != null)
    	{
    		String tag = fragment.getTag();
    		if (tag != null && tag.equalsIgnoreCase("AppDeckFragment"))
    		{
    			fragList.add(new WeakReference(fragment));
    		}
    	}
    }
    
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public void onDettachFragment (Fragment fragment) {
    	ArrayList<WeakReference<AppDeckFragment>> newlist = new ArrayList<WeakReference<AppDeckFragment>>();    	
        for(WeakReference<AppDeckFragment> ref : fragList) {
        	AppDeckFragment f = ref.get();
            if (f != fragment) {
            	newlist.add(new WeakReference(f));
            }
        }    	
        fragList = newlist;
    }
    
    public ArrayList<AppDeckFragment> getActiveFragments() {
        ArrayList<AppDeckFragment> ret = new ArrayList<AppDeckFragment>();
        for(WeakReference<AppDeckFragment> ref : fragList) {
        	AppDeckFragment f = ref.get();
            if(f != null) {
                //if(f.isActive()) {
                    ret.add(f);
                //}
            }
        }
        return ret;
    }    

    public AppDeckFragment getPreviousAppDeckFragment(AppDeckFragment current)
    {
    	AppDeckFragment previous = null;

        for(WeakReference<AppDeckFragment> ref : fragList) {
        	AppDeckFragment f = ref.get();
        	if (f == current)
        		return previous;
        	previous = f;
        }

        return null;
    }
    
    
    public AppDeckFragment getCurrentAppDeckFragment()
    {
    	FragmentManager fragmentManager = getSupportFragmentManager();
    	return (AppDeckFragment)fragmentManager.findFragmentByTag("AppDeckFragment");
    }
    
    public AppDeckFragment getRootAppDeckFragment()
    {
    	WeakReference<AppDeckFragment> ref = fragList.get(0);
        return ref.get();
    }
    
    public void progressStart()
    {
        //mProgressBar.setVisibility(View.VISIBLE);
        mProgressBarIndeterminate.setVisibility(View.VISIBLE);
        mProgressBarIndeterminate.setAlpha(0f);
        mProgressBarIndeterminate.animate().alpha(1f).start();
        mProgressBarDeterminate.setProgress(0);
        mProgressBarDeterminate.setVisibility(View.GONE);

        mProgressBarIsHiding = false;

        /*mProgressBarDeterminate.setVisibility(View.GONE);
        mProgressBarIndeterminate.setVisibility(View.VISIBLE);*/
        /*setSupportProgress(0);
        setSupportProgressBarVisibility(true);
        setSupportProgressBarIndeterminateVisibility(true);
    	setSupportProgressBarIndeterminate(true);*/
    }

    boolean mProgressBarIsHiding = false;

    public void progressSet(int percent)
    {
        if (percent < 50)
            return;

        if (mProgressBarIsHiding)
            return;

        mProgressBarIsHiding = true;
        mProgressBarIndeterminate.animate().alpha(0f).start();

/*        if (percent > 75) {
            mProgressBarIsHiding = true;
            mProgressBarDeterminate.setProgress(100);
            mProgressBarDeterminate.animate().alpha(0f)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            mProgressBarDeterminate.setProgress(0);
                            mProgressBarDeterminate.setVisibility(View.GONE);
                        }
                    })
                    .start();
            mProgressBarIndeterminate.setVisibility(View.GONE);
            return;
        }*/
//        mProgressBar.setVisibility(View.VISIBLE);
        //mProgressBar.setIndeterminate(false);
        //mProgressBar.setProgress(percent);
/*
        mProgressBarDeterminate.setVisibility(View.VISIBLE);
        mProgressBarIndeterminate.setVisibility(View.GONE);
        mProgressBarDeterminate.setAlpha(1f);
        mProgressBarDeterminate.setProgress(percent);*/
/*

        if (percent < 25)
            return;
    	setSupportProgressBarIndeterminate(false);
        //int progress = (Window.PROGRESS_END - Window.PROGRESS_START) / 100 * percent;
        setSupportProgress(percent);*/
    }
    
    public void progressStop()
    {
        if (mPostLoadLoadingCalled == false)
            postLoadLoading();

//        mProgressBar.setVisibility(View.GONE);
//        mProgressBar.setProgress(100);
//        mProgressBar.animate().alpha(0f).start();
/*
        mProgressBarDeterminate.setProgress(100);
        mProgressBarDeterminate.animate().alpha(0f)
                .setListener(new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationEnd(Animator animation) {
                        mProgressBarDeterminate.setProgress(0);
                        mProgressBarDeterminate.setVisibility(View.GONE);
                    }
                })
                .start();*/
        mProgressBarIndeterminate.setVisibility(View.GONE);

        /*
        setSupportProgressBarVisibility(false);
        setSupportProgressBarIndeterminateVisibility(false);
    	setSupportProgressBarIndeterminate(false);
    	
        int progress = (Window.PROGRESS_END - Window.PROGRESS_START);
        progress = 100;
        setSupportProgress(progress);*/
        
    }
    
    protected void prepareRootPage()
    {
    	FragmentManager fragmentManager = getSupportFragmentManager();
    	fragmentManager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE); 
    	
    	// remove all current menu items
    	setMenuItems(new PageMenuItem[0]);
    	
    	// make sure user see content
    	closeMenu();
    }
    
    public boolean loadSpecialURL(String absoluteURL)
    {
		if (absoluteURL.startsWith("tel:"))
		{
			try{
				Intent intent = new Intent(Intent.ACTION_DIAL);
				intent.setData(Uri.parse(absoluteURL));
				startActivity(intent);
			}catch (Exception e) {
				e.printStackTrace();
			}
			return true;
		}
		
		if (absoluteURL.startsWith("mailto:")){
			Intent i = new Intent(Intent.ACTION_SEND);  
			i.setType("message/rfc822") ;
			i.putExtra(Intent.EXTRA_EMAIL, new String[]{absoluteURL.substring("mailto:".length())});  
			startActivity(Intent.createChooser(i, ""));
			return true;
		}      	
    	return false;
    }

    public boolean loadExternalURL(String absoluteURL, boolean force)
    {
        Uri uri = Uri.parse(absoluteURL);
        if (uri != null)
        {
            String host = uri.getHost();
            if (force || (host != null && isSameDomain(host) == false))
            {
                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW, uri);

                    // enable custom tab for chrome
                    String EXTRA_CUSTOM_TABS_SESSION = "android.support.customtabs.extra.SESSION";
                    Bundle extras = new Bundle();
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                        extras.putBinder(EXTRA_CUSTOM_TABS_SESSION, null/*sessionICustomTabsCallback.asBinder() Set to null for no session */);
                    }
                    String EXTRA_CUSTOM_TABS_TOOLBAR_COLOR = "android.support.customtabs.extra.TOOLBAR_COLOR";
                    //intent.putExtra(EXTRA_CUSTOM_TABS_TOOLBAR_COLOR, R.color.AppDeckColorAccent);
                    //intent.putExtra(EXTRA_CUSTOM_TABS_TOOLBAR_COLOR, R.color.AppDeckColorPrimary);
                    extras.putInt(EXTRA_CUSTOM_TABS_TOOLBAR_COLOR, R.color.AppDeckColorApp);

                    intent.putExtras(extras);

                    startActivity(intent);
                } catch (Exception e) {
                    Toast.makeText(this, "No application can handle this request."
                            + " Please install a webbrowser",  Toast.LENGTH_LONG).show();

                    e.printStackTrace();
                }
                return true;
            }
        }
        return false;
    }

	public int findUnusedId(int fID) {
	    while( this.findViewById(android.R.id.content).findViewById(++fID) != null );
	    return fID;
	}    

    int rootTransactionCommit = 0;

    public void loadRootPage(String absoluteURL)
    {
    	fragList = new ArrayList<WeakReference<AppDeckFragment>>();
    	// if we don't have focus get it before load page
    	if (isForeground == false)
    	{
    		createIntent(ROOT_PAGE_URL, absoluteURL);
    		return;
    	}
        if (loadSpecialURL(absoluteURL))
            return;
        if (loadExternalURL(absoluteURL, false))
            return;
    	prepareRootPage();
		AppDeckFragment fragment = initPageFragment(absoluteURL);
        rootTransactionCommit = pushFragment(fragment);
        setMenuArrow(false);
        //adManager.showAds(AppDeckAdManager.EVENT_ROOT);
    }

    public boolean isSameDomain(String domain)
    {
        if (domain.equalsIgnoreCase(this.appDeck.config.bootstrapUrl.getHost()))
            return true;
        Pattern otherDomainRegexp[] = AppDeck.getInstance().config.other_domain;

        if (otherDomainRegexp == null)
            return false;

        for (int i = 0; i < otherDomainRegexp.length; i++) {
            Pattern p = otherDomainRegexp[i];

            if (p.matcher(domain).find())
                return true;

        }

        return false;
    }

    public int loadPage(String absoluteURL)
    {
    	if (loadSpecialURL(absoluteURL))
    		return -1;
        if (loadExternalURL(absoluteURL, false))
            return -1;

    	if (isForeground == false)
    	{
    		createIntent(PAGE_URL, absoluteURL);
    		return -1;
    	}		
		AppDeckFragment fragment = initPageFragment(absoluteURL);
    	
    	/*if (fragment.screenConfiguration != null && fragment.screenConfiguration.isPopUp)
    	{
       		//createIntent(POP_UP_URL, fragment.currentPageUrl);
    		showPopUp(null, absoluteURL);
       		return -1;
    	}*/

        fragment.event = AppDeckAdManager.EVENT_PUSH;
        if (adManager != null)
            adManager.showAds(AppDeckAdManager.EVENT_PUSH);
        setMenuArrow(true);
    	return pushFragment(fragment);
    }
    
    public int replacePage(String absoluteURL)
    {
		AppDeckFragment fragment = initPageFragment(absoluteURL);
    	
		fragment.enablePushAnimation = false;
		
    	FragmentManager fragmentManager = getSupportFragmentManager();
    	FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
    	//fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
    	    	
    	AppDeckFragment oldFragment = (AppDeckFragment)fragmentManager.findFragmentByTag("AppDeckFragment");
    	if (oldFragment != null)
    	{
    		oldFragment.setIsMain(false);
    		fragmentTransaction.remove(oldFragment);
    		onDettachFragment(oldFragment);
    	}
    	
    	fragmentTransaction.add(R.id.loader_container, fragment, "AppDeckFragment");
    	
    	//fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
    	return fragmentTransaction.commitAllowingStateLoss();
    }

    public AppDeckFragment initPageFragment(String absoluteURL)
    {
        return initPageFragment(absoluteURL, false, false);
    }

    public AppDeckFragment initPageFragment(String absoluteURL, boolean forcePopUp, boolean forceBrowser)
    {
    	ScreenConfiguration config = appDeck.config.getConfiguration(absoluteURL);

        AppDeckFragment fragment;

        // popup to external URL MUST be browser
        Uri uri = Uri.parse(absoluteURL);
        if (uri != null)
        {
            String host = uri.getHost();
            if (host != null && !host.equalsIgnoreCase(this.appDeck.config.bootstrapUrl.getHost()))
            {
                if (forcePopUp)
                    forceBrowser = true;
            }
        }

    	if (forceBrowser || (config != null && config.type != null && config.type.equalsIgnoreCase("browser")))
    	{
    		fragment = WebBrowser.newInstance(absoluteURL);
    	} else {
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
    
    public int pushFragment(AppDeckFragment fragment)
    {
        disableMenuItem();
        setSupportProgressBarVisibility(false);

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

        fragmentTransaction.add(R.id.loader_container, fragment, "AppDeckFragment");
    	//fragmentTransaction.replace(R.id.loader_container, fragment, "AppDeckFragment");
    	//fragmentTransaction.addToBackStack("AppDeckFragment");

    	fragmentTransaction.addToBackStack("AppDeckFragment");
    	
    	//fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
    	//fragmentTransaction.setTransitionStyle()
    	
    	//fragmentTransaction.setCustomAnimations(android.R.anim.fade_in,android.R.anim.fade_out);
    	//Animations(android.R.anim.fade_in,android.R.anim.fade_out,android.R.anim.fade_in,android.R.anim.fade_out);
    	    	
    	int ret = fragmentTransaction.commitAllowingStateLoss();
    	
        layoutSubViews();

    	return ret;
    }

    public boolean pushFragmentAnimation(AppDeckFragment fragment)
    {
    	AppDeckFragment current = getCurrentAppDeckFragment();
    	AppDeckFragment previous = getPreviousAppDeckFragment(current);

    	if (current == null || previous == null)
    		return false;
    	
    	if (fragment != current)
    		return false;

        if (fragment.isPopUp)
        {
            AppDeckFragmentUpAnimation anim = new AppDeckFragmentUpAnimation(previous, current);
            anim.start();
        } else {
            AppDeckFragmentPushAnimation anim = new AppDeckFragmentPushAnimation(previous, current);
            anim.start();
        }
    	
    	
    	return true;
    }
    
    public boolean popFragment()
    {
    	AppDeckFragment current = getCurrentAppDeckFragment();
    	AppDeckFragment previous = getPreviousAppDeckFragment(current);
    	
    	if (current == null || previous == null)
    		return false;

        setSupportProgressBarVisibility(false);

    	onDettachFragment(current);

        if (current.isPopUp)
        {
            AppDeckFragmentDownAnimation anim = new AppDeckFragmentDownAnimation(current, previous);
            anim.start();
        } else if (current.enablePopAnimation)
    	{
    		AppDeckFragmentPopAnimation anim = new AppDeckFragmentPopAnimation(current, previous);
    		anim.start();
    	}
        //previous.event = AppDeckAdManager.EVENT_POP;
        if (adManager != null)
            adManager.showAds(AppDeckAdManager.EVENT_POP);

        // check if we pop to root
        previous = getPreviousAppDeckFragment(previous);
        if (previous == null) {
            setMenuArrow(false);
        }

    	return true;
    }

    public boolean popRootFragment()
    {
        AppDeckFragment current = getCurrentAppDeckFragment();
        AppDeckFragment previous = getRootAppDeckFragment();

        if (current == null || previous == null)
            return false;

        if (current == previous)
            return false;

        if (rootTransactionCommit == 0)
        {
            loadRootPage(appDeck.config.bootstrapUrl.toString());
            return true;
        }

        setSupportProgressBarVisibility(false);

        // remove other fragments
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        for(WeakReference<AppDeckFragment> ref : fragList) {
            AppDeckFragment f = ref.get();
            if (f != current && f != previous) {
                fragmentTransaction.remove(f);
            }
        }
        fragmentTransaction.commitAllowingStateLoss();

        if (current.isPopUp)
        {
            AppDeckFragmentDownAnimation anim = new AppDeckFragmentDownAnimation(current, previous);
            anim.start();
        } else if (current.enablePopAnimation)
        {
            AppDeckFragmentPopAnimation anim = new AppDeckFragmentPopAnimation(current, previous);
            anim.start();
        }

        // reset fragment list
        ArrayList<WeakReference<AppDeckFragment>> fragList = new ArrayList<WeakReference<AppDeckFragment>>();
        fragList.add(new WeakReference(current));

        // make sure user see content
        closeMenu();
        setMenuArrow(false);

        if (adManager != null)
            adManager.showAds(AppDeckAdManager.EVENT_ROOT);

        return true;
    }

    public void layoutSubViews()
    {
        if (mProgressBarDeterminate != null)
            mProgressBarDeterminate.bringToFront();
        if (mProgressBarIndeterminate != null)
            mProgressBarIndeterminate.bringToFront();
    }
    
    public void reload(boolean forceReload)
    {
        this.appDeck.cache.clear();
        for(WeakReference<AppDeckFragment> ref : fragList) {
        	AppDeckFragment f = ref.get();
        	Log.d(TAG, "reload:"+f.currentPageUrl);
            f.reload(forceReload);
        }
/*        if (leftMenuWebView != null)
        	leftMenuWebView.ctl.reload();
        if (rightMenuWebView != null)
        	rightMenuWebView.ctl.reload();*/
    }

    public void evaluateJavascript(String js)
    {
        if (leftMenuWebView != null)
            leftMenuWebView.ctl.evaluateJavascript(js, null);
        if (rightMenuWebView != null)
            rightMenuWebView.ctl.evaluateJavascript(js, null);
        for(WeakReference<AppDeckFragment> ref : fragList) {
            AppDeckFragment f = ref.get();
            f.evaluateJavascript(js);
        }
    }

    public Boolean apiCall(AppDeckApiCall call)
	{
        if (call.command.equalsIgnoreCase("ready")) {
            Log.i("API", "**READY**");

            if (historyInjected == false) {
                historyInjected = true;

                SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
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

        if (call.command.equalsIgnoreCase("share"))
		{
			Log.i("API", "**SHARE**");
					
			String shareTitle = call.param.getString("title");
			String shareUrl = call.param.getString("url");
			String shareImageUrl = call.param.getString("imageurl");

			share(shareTitle, shareUrl, shareImageUrl);
						
			return true;
		}		

		if (call.command.equalsIgnoreCase("preferencesget"))
		{
			Log.i("API", "**PREFERENCES GET**");
					
			String name = call.param.getString("name");
			String defaultValue = call.param.optString("value", "");

		    SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
		    
		    String key = "appdeck_preferences_json1_" + name;
		    String finalValueJson = prefs.getString(key, null);
		    
		    if (finalValueJson == null)
		    	call.setResult(defaultValue);
		    else
		    	call.setResult(finalValueJson);
		    /*{
				try {
					ObjectMapper mapper = new ObjectMapper();
					JsonNode json = mapper.readValue(finalValueJson, JsonNode.class);
					call.setResult(json);
				} catch (JsonParseException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (JsonMappingException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
		    }*/			
			return true;
		}		
		
		if (call.command.equalsIgnoreCase("preferencesset"))
		{
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
		
		if (call.command.equalsIgnoreCase("photobrowser"))
		{
			Log.i("API", "**PHOTO BROWSER**");
			// only show image browser if there are images
			AppDeckJsonArray images = call.param.getArray("images");
			if (images.length() > 0)
			{
				PhotoBrowser photoBrowser = PhotoBrowser.newInstance(call.param, call.appDeckFragment);
				photoBrowser.loader = this;
				photoBrowser.appDeck = appDeck;
				photoBrowser.currentPageUrl = "photo://browser";
				//photoBrowser.screenConfiguration = ScreenConfiguration.defaultConfiguration();
				pushFragment(photoBrowser);
			}
			
			return true;
		}		
		
		if (call.command.equalsIgnoreCase("loadapp"))
		{
			Log.i("API", "**LOAD APP**");
			
			String jsonUrl = call.param.getString("url");
			boolean clearCache = call.param.getBoolean("cache");
			
			// clear cache if asked
			if (clearCache)
				this.appDeck.cache.clear();
			
			// dowload json data, put it in cache, lauch app
			AsyncHttpClient client = new AsyncHttpClient();
			client.get(jsonUrl, new AsyncHttpResponseHandler() {
				
				@Override
				public void onSuccess(int statusCode, Header[] headers, byte[] content) {
			    	if (statusCode == 200)
			    	{
						appDeck.cache.storeInCache(this.getRequestURI().toString(), headers, content);
				    	Intent i = new Intent(Loader.this, Loader.class);
				    	i.putExtra(JSON_URL, this.getRequestURI().toString());
				    	startActivity(i);
			    	}
			    	else
			    		Log.e(TAG, "failed to fetch config: "+this.getRequestURI().toString());
				}

                @Override
                public void onFailure(int statusCode, Header[] headers, byte[] errorResponse, Throwable e) {
                    // called when response HTTP status is "4XX" (eg. 401, 403, 404)
                    Log.e(TAG, "Error: "+statusCode);
                }
			});
			
			return true;
		}	

		if (call.command.equalsIgnoreCase("reload"))
		{
			reload(false);
            call.appDeckFragment.reload(true);
			return true;
		}
		
		if (call.command.equalsIgnoreCase("pageroot"))
		{
			Log.i("API", "**PAGE ROOT**");
			String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
			this.loadRootPage(absoluteURL);			
			return true;
		}

		if (call.command.equalsIgnoreCase("pagerootreload"))
		{
			Log.i("API", "**PAGE ROOT RELOAD**");
			String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
			this.loadRootPage(absoluteURL);
	        if (leftMenuWebView != null)
	        	leftMenuWebView.ctl.reload();
	        if (rightMenuWebView != null)
	        	rightMenuWebView.ctl.reload();
			return true;
		}		
		
		if (call.command.equalsIgnoreCase("pagepush"))
		{
			Log.i("API", "**PAGE PUSH**");
			String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
			this.loadPage(absoluteURL);			
			return true;
		}

        if (call.command.equalsIgnoreCase("popup"))
        {
            Log.i("API", "**PAGE POPUP**");
            String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
            this.showPopUp(call.appDeckFragment, absoluteURL);
            return true;
        }

		if (call.command.equalsIgnoreCase("pagepop"))
		{
			Log.i("API", "**PAGE POP**");
			this.popFragment();			
			return true;
		}

		if (call.command.equalsIgnoreCase("pagepoproot"))
		{
			Log.i("API", "**PAGE POP ROOT**");
			popRootFragment();
			return true;
		}

        if (call.command.equalsIgnoreCase("loadextern"))
        {
            Log.i("API", "**LOAD EXTERN**");
            String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
            this.loadExternalURL(absoluteURL, true);
            return true;
        }

		if (call.command.equalsIgnoreCase("slidemenu"))
		{
			String command = call.param.getString("command");
			String position = call.param.getString("position");

			if (command.equalsIgnoreCase("toggle"))
			{
				if (position.equalsIgnoreCase("left"))
					openLeftMenu();
				if (position.equalsIgnoreCase("right"))
					openRightMenu();
				if (position.equalsIgnoreCase("main"))
					toggleMenu();
			} else if (command.equalsIgnoreCase("open"))
			{
				if (position.equalsIgnoreCase("left"))
					openLeftMenu();
				if (position.equalsIgnoreCase("right"))
					openRightMenu();
				if (position.equalsIgnoreCase("main"))
					closeMenu();
			} else {
				closeMenu();
			}
			return true;
		}	
		
		if (call.command.startsWith("is"))
		{
			Log.i("API", "** IS ["+call.command+"] **");
			
			boolean result = false;
			
			if (call.command.equalsIgnoreCase("istablet"))
				result = this.appDeck.isTablet;
			else if (call.command.equalsIgnoreCase("isphone"))
				result = !this.appDeck.isTablet;
			else if (call.command.equalsIgnoreCase("isios"))
				result = false;
			else if (call.command.equalsIgnoreCase("isandroid"))
				result = true;
			else if (call.command.equalsIgnoreCase("islandscape"))
				result = getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE;
			else if (call.command.equalsIgnoreCase("isportrait"))
				result = getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT;

			call.setResult(Boolean.valueOf(result));
			
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
            final AppDeckApiCall mycall = call;

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
                            mycall.sendCallbackWithResult("success", result);
                        }

                        @Override
                        public void onCancel() {
                            // App code
                            Log.d(TAG, "facebook login cancel");
                            mycall.sendCallBackWithError("cancel");
                        }

                        @Override
                        public void onError(FacebookException exception) {
                            // App code
                            Log.d(TAG, "facebook login error");
                            mycall.sendCallBackWithError(exception.getMessage());
                        }
                    });
            //call.postponeResult();

            call.setResult(Boolean.valueOf(true));

            willShowActivity = true;
            LoginManager.getInstance().logInWithReadPermissions(this, permissions);

            return true;

        }

        if (call.command.equalsIgnoreCase("twitterlogin")) {
            Log.i("API", "** TWITTER LOGIN **");

            if (mTwitterAuthClient == null)
            {
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

        if (call.command.equalsIgnoreCase("postmessage"))
        {
            Log.i("API", " **POST MESSAGE**");

            String js = "try {app.receiveMessage("+call.inputJSON+".param);} catch (e) {}";
            evaluateJavascript(js);
            return true;
        }

        if (call.command.equalsIgnoreCase("clearcookies"))
        {
            Log.i("API", " **CLEAR COOKIES**");

            evaluateJavascript("document.cookie.split(\";\").forEach(function(c) { document.cookie = c.replace(/^ +/, \"\").replace(/=.*/, \"=;expires=\" + new Date().toUTCString() + \";path=/\"); });");

            call.smartWebView.clearCookies();

            return true;
        }

        /*Please call CookieSyncManager.getInstance().sync() immediately after CookieManager.getInstance().removeAllCookie() call.*/
        if (call.command.equalsIgnoreCase("debug"))
        {
            String msg = call.input.getString("param");
            Log.i("API", "**DEBUG** "+msg);
            DebugLog.debug("JS", msg);
            return true;
        }
        if (call.command.equalsIgnoreCase("info"))
        {
            String msg = call.input.getString("param");
            Log.i("API", "**INFO** "+msg);
            DebugLog.info("JS", msg);
            return true;
        }
        if (call.command.equalsIgnoreCase("warning"))
        {
            String msg = call.input.getString("param");
            Log.i("API", "**WARNING** "+msg);
            DebugLog.warning("JS", msg);
            return true;
        }
        if (call.command.equalsIgnoreCase("error"))
        {
            String msg = call.input.getString("param");
            Log.i("API", "**ERROR** "+msg);
            DebugLog.error("JS", msg);
            return true;
        }
        if (call.command.equalsIgnoreCase("sendsms"))
        {
            String to = call.param.getString("address");
            String message = call.param.getString("body");
            Log.i("API", "**SENDSMS** "+to+": "+message);

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
        if (call.command.equalsIgnoreCase("sendemail"))
        {
            String to = call.param.getString("to");
            String subject = call.param.getString("subject");
            String message = call.param.getString("message");
            Log.i("API", "**SENDEMAIL** "+to+": "+subject+": "+message);

            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setType("message/rfc822");
            intent.putExtra(Intent.EXTRA_EMAIL, new String[]{to});
            intent.putExtra(Intent.EXTRA_SUBJECT, subject);
            intent.putExtra(Intent.EXTRA_TEXT, message);
            startActivity(intent);

            return true;
        }
        if (call.command.equalsIgnoreCase("openlink"))
        {
            String url = call.param.getString("url");

            Log.i("API", "**OPENLINK** "+url);

            if (!url.contains("://")) {
                url = "http://" + url;
            }

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

            if (action == null || action.isEmpty())
                action = getString(android.R.string.ok);

            call.setResultJSON("true");

            final AppDeckApiCall mycall = call;
            Snackbar snackbar = Snackbar
                    .make(findViewById(R.id.loader), message, Snackbar.LENGTH_LONG)
                    .setAction(action, new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mycall.sendCallbackWithResult("success", new JSONObject());
                        }
                    })
                    .setCallback(new Snackbar.Callback() {
                        @Override
                        public void onDismissed(Snackbar snackbar, int event) {
                            mycall.sendCallBackWithError("dissmissed");
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
        actionBar.hide();
    }

    public void disableFullScreen()
    {
        ActionBar actionBar = getSupportActionBar();
        //actionBar.setShowHideAnimationEnabled(false);
        actionBar.show();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

    	if (keyCode == KeyEvent.KEYCODE_MENU)
    	{
    		toggleMenu();
    		return true;
    	}

        return super.onKeyDown(keyCode, event);
    }
/*
    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_MENU)
        {
            toggleMenu();
            return true;

        }
        return super.dispatchKeyEvent(event);
    }
*/

    public int getActionBarHeight()
    {
    	int actionBarHeight = 0;
        TypedValue tv = new TypedValue();
        if (getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true))
            actionBarHeight = TypedValue.complexToDimensionPixelSize(tv.data,getResources().getDisplayMetrics());
        
        if (actionBarHeight != 0)
        	return actionBarHeight;

       //OR as stated by @Marina.Eariel
       //TypedValue tv = new TypedValue();
       if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.HONEYCOMB){
          if (getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true))
            actionBarHeight = TypedValue.complexToDimensionPixelSize(tv.data,getResources().getDisplayMetrics());
       }

       return actionBarHeight;
    }

    public void disableMenuItem()
    {
        if (menuItems != null)
            for (int i = 0; i < menuItems.length; i++) {
                PageMenuItem item = menuItems[i];
                item.cancel();
            }
    }
    
    public void setMenuItems(PageMenuItem[] newMenuItems)
    {/*
        // does new Menu is compatible with old menu ? (meaning we only remove or add things)
        if (newMenuItems != null && menuItems != null && menu != null && newMenuItems.length > 0 && menuItems.length > 0) {
            int newIdx = newMenuItems.length - 1;
            int oldIdx = menuItems.length - 1;
            PageMenuItem newItem = newMenuItems[newIdx];
            PageMenuItem oldItem = menuItems[oldIdx];
            if (newItem.icon.equalsIgnoreCase(oldItem.icon)) {
                while (newIdx >= 0 && oldIdx >= 0) {
                    newItem = newMenuItems[newIdx];
                    oldItem = menuItems[oldIdx];

                    if (!newItem.icon.equalsIgnoreCase(oldItem.icon))
                        return;

                    oldItem.title = newItem.title;
                    oldItem.content = newItem.content;
                    oldItem.badge = newItem.badge;
                    oldItem.type = newItem.type;
                    oldItem.badgeDrawable.setCount(oldItem.badge);
                    Log.d("setMenuItems", newItem.icon);

                    newIdx--;
                    oldIdx--;
                }
                return;
            }
        }*/

        // hide previous menu
    	if (this.menuItems != null)
    		for (int i = 0; i < this.menuItems.length; i++) {
    			PageMenuItem item = this.menuItems[i];
    			item.cancel();
    		}
    	this.menuItems = newMenuItems;
    	supportInvalidateOptionsMenu();
    }

    //ShareActionProvider mShareActionProvider;

    private Menu menu = null;

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        this.menu = menu;

    	if (menuItems == null)
    		return true;

        if (menuItems.length == 0)
            return true;

        for (int i = 0; i < menuItems.length; i++) {
			PageMenuItem item = menuItems[i];

            MenuItem menuItem = menu.add("button");

			item.setMenuItem(menuItem, this, menu);

		}


/*
        // Get the provider and hold onto it to set/change the share intent.
        mShareActionProvider = (ShareActionProvider) menuItem.getActionProvider();
        // Set history different from the default before getting the action
        // view since a call to MenuItem.getActionView() calls
        // onCreateActionView() which uses the backing file name. Omit this
        // line if using the default share history file is desired.
        mShareActionProvider.setShareHistoryFileName("custom_share_history.xml");*/
        return true;
    }


    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        // topbar button
        if (menuItems != null) {
            for (int i = 0; i < menuItems.length; i++) {
                PageMenuItem pageMenuItem = menuItems[i];
                if (pageMenuItem.menuItem == item) {
                    pageMenuItem.fire();
                    return true;
                }
            }
        }

        int idx = item.getItemId();

        if (idx == android.R.id.home) {
            if (isMenuOpen() == false) {
                if (menuArrowIsShown) {
                    // try to pop a fragment if possible
                    if (popFragment()) {
                        return true;
                    }
                }
            }
        }

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
        String identifier = (url != null ? url : imageURL);
        if (identifier != null)
            identifier = title;
        /*
        BranchUniversalObject branchUniversalObject = new BranchUniversalObject();
        if (identifier != null)
            branchUniversalObject.setCanonicalIdentifier(identifier);
        if (title != null)
            branchUniversalObject.setTitle(title);
        if (imageURL != null)
            branchUniversalObject.setContentImageUrl(imageURL);

        branchUniversalObject.setContentIndexingMode(BranchUniversalObject.CONTENT_INDEX_MODE.PUBLIC);
        if (title != null)
            branchUniversalObject.addContentMetadata("title", title);
        if (url != null)
            branchUniversalObject.addContentMetadata("url", url);

        LinkProperties linkProperties = new LinkProperties()
                .setChannel("facebook")
                .setFeature("sharing")
                .addControlParameter("$desktop_url", url);
                //.addControlParameter("$ios_url", "http://example.com/ios");

        ShareSheetStyle shareSheetStyle = new ShareSheetStyle(this, title, url)
                .setCopyUrlStyle(getResources().getDrawable(android.R.drawable.ic_menu_send), "Copy", "Added to clipboard")
                .setMoreOptionStyle(getResources().getDrawable(android.R.drawable.ic_menu_search), "Show more")
                .addPreferredSharingOption(SharingHelper.SHARE_WITH.FACEBOOK)
                .addPreferredSharingOption(SharingHelper.SHARE_WITH.TWITTER)
                .addPreferredSharingOption(SharingHelper.SHARE_WITH.EMAIL)
                .addPreferredSharingOption(SharingHelper.SHARE_WITH.MESSAGE);

        branchUniversalObject.showShareSheet(this,
                linkProperties,
                shareSheetStyle,
                new Branch.BranchLinkShareListener() {
                    @Override
                    public void onShareLinkDialogLaunched() {
                    }
                    @Override
                    public void onShareLinkDialogDismissed() {
                    }
                    @Override
                    public void onLinkShareResponse(String sharedLink, String sharedChannel, BranchError error) {
                    }
                    @Override
                    public void onChannelSelected(String channelName) {
                    }
                });*/
        /*
        branchUniversalObject.generateShortUrl(this, linkProperties, new Branch.BranchLinkCreateListener() {
            @Override
            public void onLinkCreate(String url, BranchError error) {
                if (error == null) {
                    Log.i("MyApp", "got my Branch link to share: " + url);
                }
            }
        });*/
/*
        if (true)
            return;*/


        android.support.v7.widget.ShareActionProvider shareProvider = null;

//		ShareActionProvider shareAction = null;	
//		shareAction = new ShareActionProvider(this);
		
		// add stats
		appDeck.ga.event("action", "share", (url != null && !url.isEmpty() ? url : title), 1);
		
		// create share intent
		Intent sharingIntent = new Intent(android.content.Intent.ACTION_SEND);

        // trim title if needed
        if (title != null)
            title = title.trim();

		sharingIntent.setType("text/plain");
		if (title != null && !title.isEmpty())
			sharingIntent.putExtra(Intent.EXTRA_SUBJECT, title);
		if (url != null && !url.isEmpty())
			sharingIntent.putExtra(Intent.EXTRA_TEXT, url);
		
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
        if (imageURL.startsWith("//"))
        	imageURL = "http:"+imageURL;
        
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
			getSupportActionBar().show();
	    	FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
	    	fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_CLOSE);		    	
	    	fragmentTransaction.remove(popup);
	    	fragmentTransaction.commitAllowingStateLoss();			
		}
	}
	
	public void showPopOver(AppDeckFragment origin, AppDeckApiCall call)
	{
        /*
		if (origin != null)
			origin.loader.cancelSubViews();
		
	    // rather create this as a instance variable of your class		
		PopOverFragment popover = new PopOverFragment(origin, call);
		popover.loader = this;
		//popover.setRetainInstance(true);
		//popover.screenConfiguration = appDeck.config.getConfiguration(popover.currentPageUrl);		
		
		FragmentManager fm = getSupportFragmentManager();
		FragmentTransaction ft = fm.beginTransaction();
		ft.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
		//ft.add(popover, "fragmentPopOver");
		ft.add(R.id.loader_container, popover, "fragmentPopOver");
		ft.commitAllowingStateLoss();
			*/
		/*
		Dialog popUpDialog = new Dialog(getBaseContext(),
                android.R.style.Theme_Translucent_NoTitleBar);
		popUpDialog.setCanceledOnTouchOutside(true);
		popUpDialog.setContentView(popover.getView());*/
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
            } catch (Exception e) {

            }
            return;
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
            if (pushDialogInProgress)
                return;
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
                    })
                    .show();
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
