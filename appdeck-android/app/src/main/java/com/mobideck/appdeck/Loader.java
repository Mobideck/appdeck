package com.mobideck.appdeck;

import com.crashlytics.android.Crashlytics;
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
import java.util.Queue;

import org.apache.http.Header;
import org.littleshoot.proxy.ChainedProxy;
import org.littleshoot.proxy.ChainedProxyAdapter;
import org.littleshoot.proxy.ChainedProxyManager;
import org.littleshoot.proxy.HttpProxyServerBootstrap;
import org.littleshoot.proxy.TransportProtocol;
import org.littleshoot.proxy.impl.DefaultHttpProxyServer;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentManager.OnBackStackChangedListener;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;
import android.widget.ProgressBar;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

import com.widespace.AdInfo.AdType;
import com.widespace.AdSpace;
import com.widespace.adspace.PrefetchStatus;
import com.widespace.exception.ExceptionTypes;
import com.widespace.interfaces.AdErrorEventListener;
import com.widespace.interfaces.AdEventListener;

import io.netty.handler.codec.http.HttpRequest;

public class Loader extends ActionBarActivity {


	// widespace
    private static final String SPLASH_SID = "92a487d3-3bc5-4bbe-bdb0-efe6bffe64f3";

    private AdSpace adSpaceSplash;
	private AdSpace adSpacePanorama;

	public final static String TAG = "LOADER";
	public final static String JSON_URL = "com.mobideck.appdeck.JSON_URL";
	
	public final static String POP_UP_URL = "com.mobideck.appdeck.POP_UP_URL";
	public final static String PAGE_URL = "com.mobideck.appdeck.URL";
	public final static String ROOT_PAGE_URL = "com.mobideck.appdeck.ROOT_URL";
	
	/* push */
	public final static String PUSH_URL = "com.mobideck.appdeck.PUSH_URL";
	public final static String PUSH_TITLE = "com.mobideck.appdeck.PUSH_TITLE";
	
	public String proxyHost;
	public int proxyPort;
    String originalProxyHost = null;
    int originalProxyPort = -1;

	
	protected AppDeck appDeck;
	
	private SmartWebView leftMenuWebView;
	private SmartWebView rightMenuWebView;
	
    private DrawerLayout mDrawerLayout;
    private FrameLayout mDrawerLeftMenu;
    private FrameLayout mDrawerRightMenu;
    
	private PageMenuItem[] menuItems;

    public View nonVideoLayout;
    public ViewGroup videoLayout;

	//private jProxy jp;
	private HttpProxyServerBootstrap proxyServerBootstrap;

    //SmoothProgressBar mProgressBar;
    //ProgressBarIndeterminateDeterminate mProgressBar;
    ProgressBar mProgressBar;

    Toolbar mToolbar;

	@SuppressWarnings("unused")
	private GoogleCloudMessagingHelper gcmHelper;
	/*
	private int mProgress = 100;
	private int mTargetProgress = 0;
	
    Handler mHandler = new Handler();
    Runnable mProgressRunner = new Runnable() {
        @Override
        public void run() {
                    	
        	if (mProgress < mTargetProgress)
        		mProgress += 5;
        	
            //Normalize our progress along the progress bar's scale
            int progress = (Window.PROGRESS_END - Window.PROGRESS_START) / 100 * mProgress;
            //setSupportProgressBarIndeterminate(true);// ProgressBarIndeterminate
            setSupportProgress(progress);
            //setSupportSecondaryProgress((Window.PROGRESS_END - Window.PROGRESS_START) / 100 * 75);
            if (mProgress < 100) {
                mHandler.postDelayed(mProgressRunner, 100);
            }
        }
    };	*/
    
    protected void onCreatePass(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    }
    
	@Override
    protected void onCreate(Bundle savedInstanceState) {
        //supportRequestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
        //supportRequestWindowFeature(Window.FEATURE_PROGRESS);

        //Debug.startMethodTracing("calc");

//        String test = Utils.md5("app.jeuxvideo-live.com%2Fappdeck%2Fmenu%2Fmenu_178.html");
//        Log.d(TAG, test);

		AppDeckApplication app = (AppDeckApplication) getApplication();
		
		if (app.isInitialLoading == false)
		{
            SmartWebViewFactory.setPreferences(this);
			//SmartWebViewCrossWalk.setPreferences();// XWalkPreferences.setValue(XWalkPreferences.ANIMATABLE_XWALK_VIEW, true);
			app.isInitialLoading = true;
		}

		Crashlytics.start(this);
        //Crashlytics.getInstance().setDebugMode(true);

		Intent intent = getIntent();
        String app_json_url = intent.getStringExtra(JSON_URL);
        appDeck = new AppDeck(getBaseContext(), app_json_url);
    	super.onCreate(savedInstanceState);

        // original proxy host/port
        Proxy proxyConf = null;
        try {
            URI uri = URI.create("http://www.appdeck.mobi");
            Proxy currentProxy = Utils.getProxySelectorConfiguration(uri);
            originalProxyHost = Utils.getProxyHost(currentProxy);
            originalProxyPort = Utils.getProxyPort(currentProxy);
        } catch (Exception e) {
            e.printStackTrace();
        }


    	this.proxyHost = "127.0.0.1";
    	
    	boolean isAvailable = false;
    	this.proxyPort = 8081; // default port
    	do
    	{
    		isAvailable = Utils.isPortAvailable(this.proxyPort);
    		if (isAvailable == false)
    			this.proxyPort = Utils.randInt(10000, 60000);	
    	}
    	while (isAvailable == false);
    	
    	Log.i(TAG, "filter registered at @"+this.proxyPort);


        System.setProperty("http.proxyHost", this.proxyHost);
        System.setProperty("http.proxyPort", this.proxyPort + "");
        System.setProperty("https.proxyHost", this.proxyHost);
        System.setProperty("https.proxyPort", this.proxyPort + "");

    	CacheFiltersSource filtersSource = new CacheFiltersSource();
    	
    	proxyServerBootstrap = DefaultHttpProxyServer
                .bootstrap()
                .withPort(this.proxyPort)
                .withAllowLocalOnly(true)
                .withTransportProtocol(TransportProtocol.TCP)
                .withFiltersSource(filtersSource);

        if (originalProxyHost != null && originalProxyPort != -1)
        {
            proxyServerBootstrap.withChainProxyManager(new ChainedProxyManager() {
                @Override
                public void lookupChainedProxies(HttpRequest httpRequest, Queue<ChainedProxy> chainedProxies) {

                    chainedProxies.add(new ChainedProxyAdapter() {
                        @Override
                        public InetSocketAddress getChainedProxyAddress() {
                            try {
                                return new InetSocketAddress(InetAddress.getByName(Loader.this.originalProxyHost), Loader.this.originalProxyPort);
                            } catch (UnknownHostException uhe) {
                                throw new RuntimeException(
                                        "Unable to resolve "+Loader.this.originalProxyHost+"?!");
                            }
                        }

                    });

                };
            });
        }
    	    	
    	proxyServerBootstrap.start();

        setContentView(R.layout.loader);

        // for video support
        nonVideoLayout = (View)findViewById(R.id.loader_content); // Your own view, read class comments
        videoLayout = (ViewGroup)findViewById(R.id.videoLayout); // Your own view, read class comments

        mToolbar = (Toolbar) findViewById(R.id.app_toolbar);
        setSupportActionBar(mToolbar);

        mProgressBar = (ProgressBar)findViewById(R.id.progressBar);

        mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        
        if (appDeck.config.leftMenuUrl != null) {
            leftMenuWebView = SmartWebViewFactory.createMenuSmartWebView(this, appDeck.config.leftMenuUrl.toString(), SmartWebViewFactory.POSITION_LEFT);

            //leftMenuWebView = new PageWebViewMenuOld(this, appDeck.config.leftMenuUrl.toString(), PageWebViewMenuOld.POSITION_LEFT);
        	if (appDeck.config.leftmenu_background_color != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
        		leftMenuWebView.view.setBackground(appDeck.config.leftmenu_background_color.getDrawable());
        	mDrawerLeftMenu = (FrameLayout) findViewById(R.id.left_drawer);
            //mDrawerLeftMenu.setVisibility(View.VISIBLE);
            //mDrawerLeftMenu.setMinimumWidth(appDeck.config.leftMenuWidth);
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

        } else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));
            //mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, mDrawerLeftMenu);
            //mDrawerLayout.removeView(mDrawerLeftMenu);
            //mDrawerLeftMenu = null;
        }
        
        if (appDeck.config.rightMenuUrl != null) {
            rightMenuWebView = SmartWebViewFactory.createMenuSmartWebView(this, appDeck.config.rightMenuUrl.toString(), SmartWebViewFactory.POSITION_RIGHT);
            //rightMenuWebView = new PageWebViewMenuOld(this, appDeck.config.rightMenuUrl.toString(), PageWebViewMenuOld.POSITION_RIGHT);
        	if (appDeck.config.rightmenu_background_color != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
        		rightMenuWebView.view.setBackground(appDeck.config.rightmenu_background_color.getDrawable());
        	mDrawerRightMenu = (FrameLayout) findViewById(R.id.right_drawer);
            //mDrawerRightMenu.setVisibility(View.VISIBLE);
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
        } else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));
            //mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, mDrawerRightMenu);
            //mDrawerLayout.removeView(mDrawerRightMenu);
            //mDrawerRightMenu = null;
        }
/*
        mDrawerLayout.setDrawerListener(new DrawerLayout.DrawerListener() {

            @Override
            public void onDrawerStateChanged(int arg0) {

            }

            @Override
            public void onDrawerSlide(View view, float arg1) {

            }

            @Override
            public void onDrawerOpened(View view) {
                if(view == rightDrawerView) {
                    drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, leftDrawerView);
                } else if(view == leftDrawerView) {
                    drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, rightDrawerView);
                }
            }

            @Override
            public void onDrawerClosed(View view) {
                if(view == rightDrawerView) {
                    drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, leftDrawerView);
                } else if(view == leftDrawerView) {
                    drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, rightDrawerView);
                }
            }
        });*/

        // configure action bar
        appDeck.actionBarHeight = getActionBarHeight();
        
        
        getSupportActionBar().setDisplayHomeAsUpEnabled(true); // icon on the left of logo 
        getSupportActionBar().setDisplayShowHomeEnabled(true); // make icon + logo + title clickable
        if (appDeck.config.icon_theme.equalsIgnoreCase("light"))
            getSupportActionBar().setHomeAsUpIndicator(R.drawable.ic_navigation_drawer_light);
        else
            getSupportActionBar().setHomeAsUpIndicator(R.drawable.ic_navigation_drawer);
        
		if (appDeck.config.topbar_color != null)
			getSupportActionBar().setBackgroundDrawable(appDeck.config.topbar_color.getDrawable());

		if (appDeck.config.title != null)
			getSupportActionBar().setTitle(appDeck.config.title);
		
		setSupportProgressBarVisibility(false);
		setSupportProgressBarIndeterminate(false);


        /*if (appDeck.config.topbar_color != null)
            mProgressBar.setSmoothProgressDrawableBackgroundDrawable(appDeck.config.topbar_color.getDrawable());*/

        /*mProgressBar.setIndeterminateDrawable(new SmoothProgressDrawable.Builder(this)
                .color(0xff0000)
                .interpolator(new DecelerateInterpolator())
                .sectionsCount(4)
                .separatorLength(8)         //You should use Resources#getDimensionPixelSize
                .strokeWidth(8f)            //You should use Resources#getDimension
                .speed(2f)                 //2 times faster
                .progressiveStartSpeed(2)
                .progressiveStopSpeed(3.4f)
                .reversed(false)
                .mirrorMode(false)
                .progressiveStart(true)
                //.progressiveStopEndedListener(mListener) //called when the stop animation is over
                .build());*/


		getSupportFragmentManager().addOnBackStackChangedListener(new OnBackStackChangedListener()
        {
            public void onBackStackChanged() 
            {                   
            	AppDeckFragment fragment = getCurrentAppDeckFragment();
                
                if (fragment != null)
                {
                	fragment.setIsMain(true);
                }          
            }
        });
		
		initUI();
		
		gcmHelper = new GoogleCloudMessagingHelper(getBaseContext());
		
		if (savedInstanceState == null)
		{
			loadRootPage(appDeck.config.bootstrapUrl.toString());
            //loadRootPage("http://www.appdeck.mobi/extra/test");
		}


		// widespace
		
        // Let's listen to some events and run Splash Ad
		initWideSpaceAds();		

    }

	// widespace
    private void initWideSpaceAds() {
    	
    	// Splash

        // Please use Auto Update and Auto Start false for the splash ad;
    	adSpaceSplash = new AdSpace(this, SPLASH_SID, false, false);
    	
    	adSpaceSplash.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT));
        
    	adSpaceSplash.setAdEventListener(new AdEventListener() {

			@Override
			public void onAdClosed(AdSpace adSpace, AdType adType) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAdClosing(AdSpace adSpace, AdType adType) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAdLoaded(AdSpace adSpace, AdType adType) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAdLoading(AdSpace adSpace) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onNoAdRecieved(AdSpace adSpace) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onPrefetchAd(AdSpace adSpace, PrefetchStatus prefetchStatus) {
				// TODO Auto-generated method stub
				adSpace.runAd();
				
			}

			@Override
			public void onAdDismissed(AdSpace arg0, boolean arg1, AdType arg2) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAdDismissing(AdSpace arg0, boolean arg1, AdType arg2) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAdPresented(AdSpace arg0, boolean arg1, AdType arg2) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAdPresenting(AdSpace arg0, boolean arg1, AdType arg2) {
				// TODO Auto-generated method stub
				
			}

    });
        
    	adSpaceSplash.setAdErrorEventListener(adErrorListener);
        
    	// panorama

    	//adSpacePanorama = (AdSpace) findViewById(R.id.adPanorama);
    	//adSpacePanorama.setAdErrorEventListener(adErrorListener);

    	
        //adSpace.setAdEventListener(adEventListener);
        //adSpace.setAdErrorEventListener(adErrorListener);
        //adSpace.setAdAnimationEventListener(adAnimationListener);
        //adSpace.setAdMediaEventListener(adMediaEventListener);
        // It is better to pre-fetch the ad and then on the onPrefetchAd event
        // call the runAd method of the adSpace. Please explore the advanced
        // demo to see the varieties of implementations of Splash Ad.
        // For this basic demo we are going to use runAd method.
        //adSpace.runAd();
    }	
    
    // Please implement this event listener while you are in development mode,
    // so that you get notification if there is any errors.
    private AdErrorEventListener adErrorListener = new AdErrorEventListener() {

        @Override
        public void onFailedWithError(Object sender, ExceptionTypes type, String message,
                Exception exeception) {
            Log.d(TAG, "onFailedWithError : error message # " + message);
        }
    };

	boolean isForeground = true;
    @Override
    protected void onResume()
    {
    	super.onResume();
    	isForeground = true;
    }

    @Override
    protected void onPause()
    {
    	isForeground = false;
    	super.onPause();
    	if (appDeck.noCache)
    		Utils.killApp(true);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState)
    {
    	outState.putString("WORKAROUND_FOR_BUG_19917_KEY", "WORKAROUND_FOR_BUG_19917_VALUE");    	
    	super.onSaveInstanceState(outState);
    	Log.i(TAG, "onSaveInstanceState");
    }
    
    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState)
    {
      super.onRestoreInstanceState(savedInstanceState);
      Log.i(TAG, "onRestoreInstanceState");
    }
    
    @Override
    protected void onDestroy()
    {        
    	isForeground = false;
    	super.onDestroy();
    }    
    /*
    public void forceFullRedraw()
    {
		FrameLayout frameLayout = (FrameLayout)findViewById (R.id.loader_container);
		if (frameLayout != null)
		{
			frameLayout.invalidate();
			frameLayout.refreshDrawableState();
			this.getWindow().getDecorView().invalidate();
		}    	
    }*/
    
    @SuppressWarnings("deprecation")
	public void initUI()
    {
    	/*
    	// enable hardware layer type
    	slidingMenu.forceLayerType(View.LAYER_TYPE_HARDWARE);
   	
    	// for smartphone
    	Display display = getWindowManager().getDefaultDisplay();
    	float width = (float)display.getWidth();
    	float height = (float)display.getHeight();
    	float screen_width = (width > height ? height : width);
    	float virtual_menu_width = appDeck.config.leftMenuWidth;
    	if (virtual_menu_width > 280)
    		virtual_menu_width = 280;
    	if (virtual_menu_width < 0)
    		virtual_menu_width = 0;
    	float menu_width = 0;
    	if (appDeck.isTablet)
    	{
    		float base_width = getResources().getDimension(R.dimen.slidingmenu_base_width);    		
    		menu_width = virtual_menu_width * base_width / 280;
    	} else {
    		menu_width = screen_width * virtual_menu_width / (appDeck.isTablet ? 768 : 320);
    	}
    	
    	//float density = getResources().getDisplayMetrics().density;
    	//float width = density *  menu_width;
    	Log.d("Loader", "virtual menu: " + appDeck.config.leftMenuWidth);
    	Log.d("Loader", "screen_width: " + screen_width);
    	Log.d("Loader", "menu width: " + menu_width);
    	
    	//slidingMenu.setSideNavigationWidth((int)menu_width);
    	
    	// test set in pixel directly
    	float density = getResources().getDisplayMetrics().density;
    	slidingMenu.setSideNavigationWidth((int)(appDeck.config.leftMenuWidth * density));
    	//slidingMenu.setSideNavigationWidth(280);
    	*/
    	//slidingMenu.setBehindWidth((int)menu_width);

    	//forceFullRedraw();
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

        getSupportActionBar().setDisplayHomeAsUpEnabled(false); // icon on the left of logo
        getSupportActionBar().setDisplayShowHomeEnabled(false); // make icon + logo + title clickable


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
        getSupportActionBar().setDisplayHomeAsUpEnabled(true); // icon on the left of logo
        getSupportActionBar().setDisplayShowHomeEnabled(true); // make icon + logo + title clickable
        if (appDeck.config.icon_theme.equalsIgnoreCase("light"))
            getSupportActionBar().setHomeAsUpIndicator(R.drawable.ic_navigation_drawer_light);
        else
            getSupportActionBar().setHomeAsUpIndicator(R.drawable.ic_navigation_drawer);
    }
    
    
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        initUI();
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
        setSupportProgress(0);
        setSupportProgressBarVisibility(true);
        setSupportProgressBarIndeterminateVisibility(true);
    	setSupportProgressBarIndeterminate(true);
    	//mProgress = 100;
    }
    
    public void progressSet(int percent)
    {
        if (percent < 25)
            return;
    	setSupportProgressBarIndeterminate(false);
        //Normalize our progress along the progress bar's scale
        int progress = (Window.PROGRESS_END - Window.PROGRESS_START) / 100 * percent;
        //setSupportProgressBarIndeterminate(true);// ProgressBarIndeterminate
        setSupportProgress(percent);
    }
    
    public void progressStop()
    {
        setSupportProgressBarVisibility(false);
        setSupportProgressBarIndeterminateVisibility(false);
    	setSupportProgressBarIndeterminate(false);
    	
        int progress = (Window.PROGRESS_END - Window.PROGRESS_START);
        //setSupportProgressBarIndeterminate(true);// ProgressBarIndeterminate
        progress = 100;
        setSupportProgress(progress);
        
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
    
	public int findUnusedId(int fID) {
	    while( this.findViewById(android.R.id.content).findViewById(++fID) != null );
	    return fID;
	}    
    
    public void loadRootPage(String absoluteURL)
    {
    	fragList = new ArrayList<WeakReference<AppDeckFragment>>();
    	// if we don't have focus get it before load page
    	if (isForeground == false)
    	{
    		createIntent(ROOT_PAGE_URL, absoluteURL);
    		return;
    	}
    	prepareRootPage();
    	if (loadSpecialURL(absoluteURL))
    		return;
		AppDeckFragment fragment = initPageFragment(absoluteURL);
    	pushFragment(fragment);
    }
    
    public int loadPage(String absoluteURL)
    {
    	if (loadSpecialURL(absoluteURL))
    		return -1;

        Uri uri = Uri.parse(absoluteURL);
        if (uri != null)
        {
            String host = uri.getHost();
            if (host != null && !host.equalsIgnoreCase(this.appDeck.config.bootstrapUrl.getHost()))
            {
                Intent i = new Intent(Intent.ACTION_VIEW, uri);
                startActivity(i);
                return -1;
            }
        }

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
    	    	
    	fragmentTransaction.commitAllowingStateLoss();
    	
        layoutSubViews();

    	return 0;
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
    	return true;
    }

    public boolean popRootFragment()
    {
    	//AppDeckFragment root = getRootAppDeckFragment();

    	FragmentManager fragmentManager = getSupportFragmentManager();
    	
    	fragmentManager.popBackStack();
    	
    	//todo: a faire
    	//fragmentManager.popBackStack(root, FragmentManager.POP_BACK_STACK_INCLUSIVE); 
    	
    	/*prepareRootPage();
    	pushFragment(root);*/    	
    	return true;
    }

    public void layoutSubViews()
    {
        // widespace
        if (adSpaceSplash != null)
        {
            adSpaceSplash.bringToFront();
            adSpaceSplash.requestLayout();
        }
        if (adSpacePanorama != null)
        {
            adSpacePanorama.bringToFront();
            adSpacePanorama.requestLayout();
        }
        if (mProgressBar != null)
            mProgressBar.bringToFront();

    }
    
    public void reload()
    {
        for(WeakReference<AppDeckFragment> ref : fragList) {
        	AppDeckFragment f = ref.get();
        	f.reload();
        }
        if (leftMenuWebView != null)
        	leftMenuWebView.ctl.reload();
        if (rightMenuWebView != null)
        	rightMenuWebView.ctl.reload();
    }
    
    public Boolean apiCall(AppDeckApiCall call)
	{		
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
			AppDeckJsonNode defaultValue = call.param.get("value");

		    SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
		    
		    String key = "appdeck_preferences_json1_" + name;
		    String finalValueJson = prefs.getString(key, null);
		    
		    if (finalValueJson == null)
		    	call.setResult(defaultValue.toJsonString());
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
			AppDeckJsonNode finalValue = call.param.get("value");
			
		    SharedPreferences prefs = getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
		    SharedPreferences.Editor editor = prefs.edit();
		    String key = "appdeck_preferences_json1_" + name;
		    editor.putString(key, finalValue.toJsonString());
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
				photoBrowser.screenConfiguration = ScreenConfiguration.defaultConfiguration();				
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
			});
			
			return true;
		}	

		if (call.command.equalsIgnoreCase("reload"))
		{
			reload();
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
        if (currentFragment.canGoBack())
        {
        	currentFragment.goBack();
        	return;
        }
        
        // try to pop a fragment if possible
        if (popFragment())
        	return;

        // current fragment is home ?
        if (currentFragment == null || currentFragment.currentPageUrl == null || currentFragment.currentPageUrl.compareToIgnoreCase(appDeck.config.bootstrapUrl.toString()) != 0)
        {
//        	Debug.stopMethodTracing();
        	loadRootPage(appDeck.config.bootstrapUrl.toString());
        	return;
        }
        
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

    
    public void setMenuItems(PageMenuItem[] menuItems)
    {
    	if (menuItems != null)
    		for (int i = 0; i < menuItems.length; i++) {
    			PageMenuItem item = menuItems[i];
    			item.cancel();
    		}
    	this.menuItems = menuItems;
    	supportInvalidateOptionsMenu();
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

    	if (menuItems == null)
    		return true;
    	
		for (int i = 0; i < menuItems.length; i++) {
			PageMenuItem item = menuItems[i];
			
			item.setMenuItem(menu.add("button"), getBaseContext());
			
			//item.setMenuItem(menu.add(0, i, 0, null));
		}
        return true;
    }


    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

    	int idx = item.getItemId();

    	if (idx == android.R.id.home)
    	{
   			toggleMenu();
   			return true;	
    	}
    	
    	if (menuItems == null)
    		return false;    	

		for (int i = 0; i < menuItems.length; i++)
		{
			PageMenuItem pageMenuItem = menuItems[i];
			if (pageMenuItem.menuItem == item)
			{
				pageMenuItem.fire();
	    		return true;				
			}
		}
		return super.onOptionsItemSelected(item);
    }    
	
	public void share(String title, String url, String imageURL)
	{

        android.support.v7.widget.ShareActionProvider shareProvider = null;

//		ShareActionProvider shareAction = null;	
//		shareAction = new ShareActionProvider(this);
		
		// add stats
		appDeck.ga.event("action", "share", (url != null && !url.isEmpty() ? url : title), 1);
		
		// create share intent
		Intent sharingIntent = new Intent(android.content.Intent.ACTION_SEND);

		sharingIntent.setType("text/plain");
		if (title != null && !title.isEmpty())
			sharingIntent.putExtra(Intent.EXTRA_SUBJECT, title);
		if (url != null && !url.isEmpty() == false)
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
	    	fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);		    	
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
    protected void onNewIntent (Intent intent)
    {
    	super.onNewIntent(intent);
    	
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
    		new PushDialog(url, title).show();
            return;
    	}
    	
/*
    	// popup url
    	url = extras.getString(POP_UP_URL);
    	if (url != null && !url.isEmpty())
    	{
    		showPopUp(null, url);
    		return;
    	}*/
    	
    }	
	
    public class PushDialog
    {
    	String url;
    	String title;
    	
    	public PushDialog(String url, String title)
    	{
			this.url = url;
			this.title = title;
		}
    	
    	public void show()
    	{
            new AlertDialog.Builder(Loader.this)
            //.setTitle("javaScript dialog")
            .setMessage(title)
            .setPositiveButton(android.R.string.ok, 
                    new DialogInterface.OnClickListener() 
                    {
                        public void onClick(DialogInterface dialog, int which) 
                        {
                        	loadPage(url);
                        }
                    })
            .setNegativeButton(android.R.string.cancel, 
                    new DialogInterface.OnClickListener() 
                    {
                        public void onClick(DialogInterface dialog, int which) 
                        {
                            
                        }
                    })
            .create()
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

    // Progress Bar
    @Override
    public void setSupportProgressBarVisibility(boolean visibility)
    {
        if (mProgressBar == null)
            return;
        if (visibility)
            mProgressBar.setVisibility(View.VISIBLE);
        else
            mProgressBar.setVisibility(View.GONE);
    }

    @Override
    public void setSupportProgressBarIndeterminateVisibility(boolean visibility)
    {
        if (mProgressBar == null)
            return;
        //setSupportProgressBarVisibility(visibility);
        //mProgressBar.setIndeterminate(visibility);
    }

    @Override
    public void setSupportProgressBarIndeterminate(boolean indeterminate)
    {
        if (mProgressBar == null)
            return;
        mProgressBar.setIndeterminate(indeterminate);

        //mProgressBar.setProgress();
    }

    @Override
    public void setSupportProgress(int progress)
    {
        if (mProgressBar == null)
            return;
        //mProgressBar.setIndeterminate(false);
        mProgressBar.setProgress(progress);
    }

}
