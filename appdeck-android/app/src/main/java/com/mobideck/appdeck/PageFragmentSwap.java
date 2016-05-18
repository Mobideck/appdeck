package com.mobideck.appdeck;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;

//import com.gc.materialdesign.views.ProgressBarCircularIndeterminate;
import com.afollestad.materialdialogs.MaterialDialog;
import com.mobideck.appdeck.CacheManager.CacheResult;

//import com.mopub.mobileads.MoPubErrorCode;
//import com.mopub.mobileads.MoPubView;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.LayoutTransition;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.design.widget.Snackbar;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.CookieSyncManager;
import android.widget.DatePicker;
import android.widget.FrameLayout;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

public class PageFragmentSwap extends AppDeckFragment {
	
	public static final String TAG = "PageFragmentSwap";	
	
	public PageSwipe pageSwipe;
	
    private SmartWebView pageWebView;
    private SmartWebView pageWebViewAlt;

	private boolean pageWebViewReady = false;
	private boolean pageWebViewAltReady = false;	
	
	private SwipeRefreshLayout swipeView;
	private SwipeRefreshLayout swipeViewAlt;
	
	private long lastUrlLoad = 0;

    //private ProgressBarCircularIndeterminate preLoadingIndicator;
    private boolean isPreLoading = true;

	public URI uri;
	
	private boolean shouldReloadFromBackgrounfOnError = false;

    private HashMap<String, AppDeckAdNative> nativeAds = null;

	// loadPage not called
	private boolean shouldCallLoadPage = false;

	MaterialDialog currentProgress = null;

	public static PageFragmentSwap newInstance(String absoluteURL)
	{
		//android.os.Debug.startMethodTracing("page");
		PageFragmentSwap fragment = new PageFragmentSwap();

		Bundle args = new Bundle();
	    args.putString("absoluteURL", absoluteURL);
	    fragment.setArguments(args);
	    fragment.currentPageUrl = absoluteURL;
	    
	    return fragment;
	}	
	
	@Override
	public void onAttach(Activity activity)
	{
		super.onAttach(activity);
		previousPageUrl = currentPageUrl = nextPageUrl = "";
		this.loader = (Loader)activity;
	}
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
		if (this.loader != null)
			this.appDeck = this.loader.appDeck;
    	currentPageUrl = getArguments().getString("absoluteURL");
    	if (this.appDeck != null)
			this.screenConfiguration = this.appDeck.config.getConfiguration(currentPageUrl);
	}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
    	super.onCreateView(inflater, container, savedInstanceState);

        rootView = (FrameLayout)inflater.inflate(R.layout.page_fragment_swap, container, false);
        //rootView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        LayoutTransition lt = new LayoutTransition();
		if (Build.VERSION.SDK_INT >= 16) {
			lt.disableTransitionType(LayoutTransition.DISAPPEARING);
		}
        rootView.setLayoutTransition(lt);

        //preLoadingIndicator = (ProgressBarCircularIndeterminate)rootView.findViewById(R.id.preLoadingIndicator);

		pageWebView = SmartWebViewFactory.createSmartWebView(this);
    	pageWebViewAlt = SmartWebViewFactory.createSmartWebView(this);
    			
		mAnimationDuration = getResources().getInteger(android.R.integer.config_shortAnimTime);
				
        swipeView = (SwipeRefreshLayout) rootView.findViewById(R.id.swipe);
        swipeView.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {

            @Override
            public void onRefresh() {
                swipeViewAlt.setRefreshing(true);
                swipeView.setRefreshing(true);
                reloadInBackground();
            }
        });
        swipeView.addView(pageWebView.view);
        swipeView.setColorSchemeResources(R.color.AppDeckColorApp, R.color.AppDeckColorTopBarBg1, R.color.AppDeckColorApp, R.color.AppDeckColorTopBarBg2);
        
        swipeViewAlt = (SwipeRefreshLayout) rootView.findViewById(R.id.swipeAlt);
        swipeViewAlt.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
			@Override
			public void onRefresh() {
				swipeViewAlt.setRefreshing(true);
				swipeView.setRefreshing(true);
				reloadInBackground();
			}
		});
        swipeViewAlt.addView(pageWebViewAlt.view);
        swipeViewAlt.setVisibility(View.GONE);
        swipeViewAlt.setColorSchemeResources(R.color.AppDeckColorApp, R.color.AppDeckColorTopBarBg1, R.color.AppDeckColorApp, R.color.AppDeckColorTopBarBg2);
        
        rootView.bringChildToFront(swipeView);
        //rootView.bringChildToFront(preLoadingIndicator);

        if (savedInstanceState != null)
        {
        	Log.i(TAG, "onCreateView with State");
        	loader = (Loader)getActivity();
    		try {
    			uri = new URI(currentPageUrl);
    		} catch (URISyntaxException e) {
    			e.printStackTrace();
    		}    		
    		loadURLConfiguration(currentPageUrl);
    		if (screenConfiguration != null)
				menuItems = screenConfiguration.getDefaultPageMenuItems(uri, this);
    		this.loader.setMenuItems(menuItems);
        	pageWebView.ctl.smartWebViewRestoreState(savedInstanceState);
        } else {
			if (isMain)
	        	loadPage(currentPageUrl);
			else
				shouldCallLoadPage = true;
        }

        mHandler = new Handler();
        mHandler.postDelayed(myTask, 150);

        return rootView;
    }

	public void setIsOnScreen(boolean isOnScreen) {
		if (isOnScreen) {
			if (shouldCallLoadPage)
				loadPage(currentPageUrl);
		} else {
		}
	}

    public void setIsMain(boolean isMain)
    {
        super.setIsMain(isMain);
        if (isMain) {
			if (shouldCallLoadPage)
				loadPage(currentPageUrl);
			else if (forceReload) {
				this.forceReload = false;
				reloadInBackground();
			} else if (pageWebView != null)
                pageWebView.ctl.sendJsEvent("appear", "null");
        } else {
            if (pageWebView != null)
                pageWebView.ctl.sendJsEvent("disappear", "null");
        }
    }

    private Handler mHandler;
    Runnable myTask = new Runnable() {
        @Override
        public void run() {
            hidePreloading();
            mHandler.removeCallbacks(myTask);
        }
    };



    @Override
    public void onStart() {
    	super.onStart();
    	
    }

	private boolean wasPaused = false;

    @Override
    public void onResume() {
    	super.onResume();
    	CookieSyncManager.getInstance().stopSync();
		if (wasPaused == false) {
			return;
		}
		if (pageWebView != null && pageWebView.ctl != null)
			pageWebView.ctl.resume();
		if (pageWebViewAlt != null && pageWebViewAlt.ctl != null)
			pageWebViewAlt.ctl.resume();

    	long now = System.currentTimeMillis();
		if (forceReload) {
			forceReload = false;
			reloadInBackground();
		} else if (screenConfiguration != null && screenConfiguration.ttl > 0 && lastUrlLoad != 0) {
			if (screenConfiguration.ttl > ((now - lastUrlLoad) / 1000))
			{
				Log.v(TAG, "Should NOT AutoRealod SCREEN:["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " cache ttl: "+lastUrlLoad + " now: " + now + " diff: " + (now - lastUrlLoad)/1000);				
			} else {
				Log.v(TAG, "Should AutoRealod SCREEN:["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " cache ttl: "+lastUrlLoad + " now: " + now + "diff: " + (now - lastUrlLoad)/1000);
				reloadInBackground();
			}
		} else {
			Log.v(TAG, "AutoRealod DISABLED :["+(screenConfiguration != null ? screenConfiguration.title : "null")+"] ttl: "+(screenConfiguration != null ? screenConfiguration.ttl : "null") + " cache ttl: "+lastUrlLoad + " now: " + now + "diff: " + (now - lastUrlLoad)/1000);
		}
    }
    
    @Override
    public void onPause() {
		wasPaused = true;
        CookieSyncManager.getInstance().sync();
    	if (pageWebView != null && pageWebView.ctl != null)
			pageWebView.ctl.pause();
		if (pageWebViewAlt != null && pageWebViewAlt.ctl != null)
			pageWebViewAlt.ctl.pause();
        super.onPause();
    };

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    	if (pageWebView != null)
    		pageWebView.ctl.smartWebViewSaveState(outState);
    }
    
    @Override
    public void onDestroyView()
    {
		if (currentProgress != null) {
			currentProgress.dismiss();
			currentProgress = null;
		}
    	super.onDestroyView();
        SmartWebViewFactory.recycleSmartWebView(pageWebView);
        SmartWebViewFactory.recycleSmartWebView(pageWebViewAlt);
        swipeView.removeAllViews();
        swipeViewAlt.removeAllViews();
        pageWebView = null;
        pageWebViewAlt = null;
    }
    
    @Override
    public void onDestroy()
    {
        super.onDestroy();
    }
    
    @Override
    public void onDetach ()
    {
        super.onDetach();
    }

    public boolean shouldOverrideUrlLoading(String absoluteURL)
    {
        if (absoluteURL.startsWith("javascript:"))
        {
            //pageWebView.ctl.loadUrl(absoluteURL);
            return false;
        }
        if (screenConfiguration.isRelated(absoluteURL))
        {
            //loader.replacePage(absoluteURL);
			currentPageUrl = absoluteURL;
            return false;
        }
        return true;
    }

    public void loadUrl(String absoluteURL)
    {
		if (absoluteURL.startsWith("javascript:"))
		{
			if (pageWebView != null && pageWebView.ctl != null)
				pageWebView.ctl.loadUrl(absoluteURL);
			return;
        }
        if (absoluteURL.startsWith("appdeckapi:refresh"))
		{
			reloadInBackground();
			return;
		}
		if (screenConfiguration.isRelated(absoluteURL))
    	{
			if (pageWebView != null && pageWebView.ctl != null)
            	pageWebView.ctl.loadUrl(absoluteURL);
			//loader.replacePage(absoluteURL);
			return;
    	}
		super.loadUrl(absoluteURL);
    }
    
	public void loadPage(String absoluteUrl)
	{
		if (pageWebView == null)
			return;

		shouldCallLoadPage = false;
		currentPageUrl = absoluteUrl;
		try {
			uri = new URI(currentPageUrl);
		} catch (URISyntaxException e) {
			e.printStackTrace();
		}
		
		loadURLConfiguration(absoluteUrl);

		if (screenConfiguration != null)
			menuItems = screenConfiguration.getDefaultPageMenuItems(uri, this);
		
		Log.v(TAG, "SCREEN: "+screenConfiguration.title+" TTL: "+screenConfiguration.ttl);
				
		progressStart(pageWebView.view);

		//boolean loadFromCache = false;
		//boolean reloadInBackground = false;

		/*// if app just launch AND data in cache AND up to date
		if (loader.justLaunch) {
			Log.v("CACHE", "App just launch we skip cacheCache MISS SCREEN:["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " page IS NOT IN CACHE");
		} else {
			// does page is in cache ?*/

		String toast;
		int toast_color;

		if (screenConfiguration.ttl == -1)
		{
			toast = "Cache DISABLED ttl: "+screenConfiguration.ttl +" sec";
			pageWebView.ctl.setCacheMode(SmartWebViewInterface.LOAD_NO_CACHE);
			toast_color = Utils.dangerColor();
		} else {
			CacheManager.CacheResult cacheResult = appDeck.cache.isInCache(currentPageUrl);
			if (cacheResult.isInCache) {
				long now = System.currentTimeMillis();
				long ttl = screenConfiguration.ttl;
				if (loader.justLaunch) {
                    ttl = ttl / 10;
                    loader.justLaunch = false;
                }
				if (ttl > ((now - cacheResult.lastModified) / 1000)) {
					toast = "Cache HIT ttl: " + screenConfiguration.ttl + " sec " + (loader.justLaunch ? "(app just start, shorten to:" + ttl + ")" : "") + " age: " + (now - cacheResult.lastModified) / 1000 + " sec ";
					pageWebView.ctl.setCacheMode(SmartWebViewInterface.LOAD_CACHE_ELSE_NETWORK);
					toast_color = Utils.successColor();
				} else {
					toast = "Cache MISS (DEPRECATED) ttl: " + screenConfiguration.ttl + " sec " + (loader.justLaunch ? "(app just start, shorten to:" + ttl + ")" : "") + " age: " + (now - cacheResult.lastModified) / 1000 + " sec ";
					pageWebView.ctl.setCacheMode(SmartWebViewInterface.LOAD_DEFAULT);
					shouldReloadFromBackgrounfOnError = true;
					toast_color = Utils.infoBlueColor();
				}
			} else {
				toast = "Cache MISS (NOT IN CACHE) ttl: " + screenConfiguration.ttl + " sec ";
				pageWebView.ctl.setCacheMode(SmartWebViewInterface.LOAD_DEFAULT);
				shouldReloadFromBackgrounfOnError = true;
				toast_color = Utils.warningColor();
			}
		}
		if (screenConfiguration.isDefault)
			toast_color = Utils.antiqueWhiteColor();
		if (appDeck.isDebugBuild) {
			Snackbar
					.make(loader.findViewById(android.R.id.content)
					, toast, Snackbar.LENGTH_LONG)
					.setAction((screenConfiguration.title == null || screenConfiguration.title.isEmpty() ? "(no title)" : screenConfiguration.title), new View.OnClickListener() {
						@Override
						public void onClick(View v) {
							new MaterialDialog.Builder(loader)
									.content("Url: " + currentPageUrl + "\n\n" + screenConfiguration.getDescription())
									.positiveText(android.R.string.ok)
									.show();
						}
					})
					.setActionTextColor(toast_color)
					.show(); // Don’t forget to show!
			//Toast.makeText(loader, toast, Toast.LENGTH_SHORT).show();
			DebugLog.info(screenConfiguration.title, toast);
		} else {
			Log.i(TAG, screenConfiguration.title + ": "+ toast);
		}
		pageWebView.ctl.loadUrl(absoluteUrl);
		lastUrlLoad = System.currentTimeMillis();
	}
    public void progressStart(View origin)
    {
    	super.progressStart(origin);
    }

    void hidePreloading()
    {
        //preLoadingIndicator.setVisibility(View.GONE);
        //swipeView.setVisibility(View.VISIBLE);
        //swipeViewAlt.setVisibility(View.VISIBLE);
        isPreLoading = false;
    }

    public void progressSet(View origin, int percent)
    {
        if (percent > 25 && isPreLoading)
        {
            hidePreloading();
        }
        //progressStop(origin);
        super.progressSet(origin, percent);

    }
    
    public void progressStop(View origin)
    {
    	super.progressStop(origin);

        hidePreloading();

    	swipeView.setRefreshing(false);
    	swipeViewAlt.setRefreshing(false);
		/*if (origin == pageWebView.view && shouldAutoReloadInbackground == true)
		{
			Log.i(TAG, "+++ Reload In Background +++");
			shouldAutoReloadInbackground = false;
			reloadInBackground();
		}*/

		if (origin == pageWebViewAlt.view)
			swapWebView();
		//android.os.Debug.stopMethodTracing();
    }
    
    public void progressFailed(View origin)
    {
    	super.progressFailed(origin);

        hidePreloading();
        swipeView.setRefreshing(false);
        swipeViewAlt.setRefreshing(false);



/*    	if (origin == pageWebView && pageWebViewReady == false)
    	{
    		pageWebViewReady = true;
    		if (pageWebViewReady && pageWebViewAltReady)
    			loadPage(currentPageUrl);
    		return;
    	}
    	if (origin == pageWebViewAlt && pageWebViewAltReady == false)
    	{
    		pageWebViewAltReady = true;
    		if (pageWebViewReady && pageWebViewAltReady)
    			loadPage(currentPageUrl);    		
    		return;
    	}*/

    	if (origin == pageWebView.view)
    	{
            CacheResult cacheResult = appDeck.cache.isInCache(currentPageUrl);

            if (cacheResult.isInCache) {
                swipeViewAlt.setVisibility(View.VISIBLE);
                rootView.bringChildToFront(swipeViewAlt);
                //rootView.bringChildToFront(preLoadingIndicator);
                pageWebViewAlt.ctl.setCacheMode(SmartWebViewInterface.LOAD_CACHE_ELSE_NETWORK);
				pageWebViewAlt.ctl.loadUrl(currentPageUrl);
                //pageWebViewAlt.ctl.loadUrl("http://appdeck/error");
            } else {
                //pageWebView.ctl.stopLoading();
                //pageWebView.view.setVisibility(View.INVISIBLE);
                swipeViewAlt.setVisibility(View.VISIBLE);
                rootView.bringChildToFront(swipeViewAlt);
                //rootView.bringChildToFront(preLoadingIndicator);
                pageWebViewAlt.ctl.loadUrl("http://appdeck/error");
                //pageWebViewAlt.ctl.loadDataWithBaseURL("file:///android_asset/", AppDeck.error_html, "text/html", "UTF-8", null);
                //pageWebView.ctl.evaluateJavascript("document.head.innerHTML = ''; document.body.innerHTML = \"<style>body { background-color: "+loader.appDeck.config.image_network_error_background_color+"; background-image: url('"+loader.appDeck.config.image_network_error_url+"'); background-repeat:no-repeat; background-position:top center; }</style>\";", null);
            }
    	}
    	else if (origin == pageWebViewAlt.view)
    	{
			swipeViewAlt.setVisibility(View.VISIBLE);
			rootView.bringChildToFront(swipeViewAlt);
			pageWebViewAlt.ctl.loadUrl("http://appdeck/error");

/*    		Toast.makeText(origin.getContext(), "Network Error", Toast.LENGTH_LONG).show();
			pageWebViewAlt.ctl.stopLoading();
    		//setVisibility(View.INVISIBLE);*/
    		reloadInProgress = false;
    	}

    }
	
	private boolean reloadInProgress = false;
    public void reloadInBackground()
    {    	
    	if (reloadInProgress)
    		return;
		if (pageWebView == null || pageWebView.ctl == null || pageWebViewAlt == null || pageWebViewAlt.ctl == null)
			return;
/*    	if (appDeck.isLowSystem)
    	{
    		loadPage(currentPageUrl);
    		return;
    	}*/
    	reloadInProgress = true;

    	pageWebView.ctl.stopLoading();
    	pageWebViewAlt.ctl.stopLoading();
    	pageWebViewAlt.ctl.setCacheMode(SmartWebViewInterface.LOAD_DEFAULT);
    	
    	rootView.bringChildToFront(swipeView);
        //rootView.bringChildToFront(preLoadingIndicator);

//    	swipeViewAlt.setVisibility(View.VISIBLE);
    	
    	//page_layout_alt.removeAllViews();
    	//etSupportProgressBarIndeterminateVisibility(true);
    	//pageWebViewAlt.stopLoading();
    	progressStart(pageWebViewAlt.view);
    	pageWebViewAlt.ctl.loadUrl(currentPageUrl);
		lastUrlLoad = System.currentTimeMillis();
    }
    
	@Override
	public void reload(boolean forceReload)
	{
		super.reload(forceReload);
		if (forceReload)
			reloadInBackground();
		else
			this.forceReload = true;
	}    
	
    private int mAnimationDuration;
    private boolean swapInProgress = false;
    
    public void swapWebView()
    {
    	if (swapInProgress)
    		return;
    	
    	swapInProgress = true;

    	pageWebView.ctl.setTouchDisabled(true);
    	pageWebViewAlt.ctl.setTouchDisabled(true);
    	pageWebViewAlt.view.setVerticalScrollBarEnabled(false);


        int x = pageWebView.ctl.fetchHorizontalScrollOffset();
        int y = pageWebView.ctl.fetchVerticalScrollOffset();
        pageWebViewAlt.ctl.scrollTo(x, y);
    	//pageWebView.copyScrollTo(pageWebViewAlt);
    	swipeViewAlt.setAlpha(0f);
    	swipeViewAlt.setVisibility(View.VISIBLE);
    	rootView.bringChildToFront(swipeViewAlt);
        //rootView.bringChildToFront(preLoadingIndicator);

    	final Runnable r = new Runnable()
    	{
    	    public void run() 
    	    {
    	        // Animate the content view to 100% opacity, and clear any animation
    	        // listener set on the view.
    	    	swipeViewAlt.animate()
    	                .alpha(1f)
    	                .setDuration(250)
    	                .setListener(new AnimatorListenerAdapter() {
    	                    @Override
    	                    public void onAnimationEnd(Animator animation) {
    	                    	swipeView.setVisibility(View.GONE);

                                if (pageWebView == null || pageWebViewAlt == null)
                                    return;

    	            			pageWebView.ctl.stopLoading();
    	            			
    	            			pageWebView.ctl.setTouchDisabled(false);
    	            	    	pageWebViewAlt.ctl.setTouchDisabled(false);
    	            	    	pageWebViewAlt.view.setVerticalScrollBarEnabled(true);
    	            	    	
    	            	    	// swap webview and layout
    	            	    	//SmartWebView tmpWebView = pageWebView;
    	            	    	SmartWebView tmpWebView = pageWebView;
    	            	    	pageWebView = pageWebViewAlt;
    	            	    	pageWebViewAlt = tmpWebView;

    	            	    	pageWebViewAlt.ctl.unloadPage();
    	            	    	
    	            	    	SwipeRefreshLayout tmp = swipeView;
    	            	    	swipeView = swipeViewAlt;
    	            	    	swipeViewAlt = tmp;
    	            	    	
    	            	    	rootView.bringChildToFront(swipeView);
                                //rootView.bringChildToFront(preLoadingIndicator);

    	            	    	swapInProgress = false;
    	            	    	reloadInProgress = false;    	            	   
    	                    }
    	                });    	    	
    	    }
    	};

    	
    	new Handler().postDelayed(r, 250);
    	    	
    }

    public String resolveURL(String relativeUrl)
    {
        return pageWebView.ctl.resolve(relativeUrl);
    }

    public String evaluateJavascript(String js)
    {
        if (pageWebView != null)
            pageWebView.ctl.evaluateJavascript(js, null);
        if (pageWebViewAlt != null)
            pageWebViewAlt.ctl.evaluateJavascript(js, null);
        return "";
    }

    public boolean apiCall(final AppDeckApiCall call)
	{
        /*
        if (call.command.equalsIgnoreCase("share"))
        {
            // get the center for the clipping circle
            int cx = (rootView.getLeft() + rootView.getRight()) / 2;
            int cy = (rootView.getTop() + rootView.getBottom()) / 2;

            // get the initial radius for the clipping circle
            int initialRadius = rootView.getWidth();

            // create the animation (the final radius is zero)
            Animator anim = ViewAnimationUtils.createCircularReveal(rootView, cx, cy,
                    initialRadius, 0);
            anim.setDuration(500);

            // make the view invisible when the animation is done
            anim.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    super.onAnimationEnd(animation);
                    rootView.setVisibility(View.INVISIBLE);
                }
            });


            // start the animation
            anim.start();
            return true;
        }*/

		if (call.command.equalsIgnoreCase("load"))
		{
			Log.i("API", uri.getPath()+" **LOAD**");
						
			return true;
		}
		
		if (call.command.equalsIgnoreCase("ready"))
		{
			Log.i("API", uri.getPath()+" **READY**");
			
	    	if (call.smartWebView == pageWebViewAlt)
	        {	    		
	    		//swapWebView();
	        }
			return true;
		}

        if (call.command.equalsIgnoreCase("disable_pulltorefresh"))
        {
            Log.i("API", uri.getPath()+" **DISABLE PULLTOREFRESH**");
            this.swipeView.setEnabled(false);
            this.swipeViewAlt.setEnabled(false);
            return true;
        }

        if (call.command.equalsIgnoreCase("enable_pulltorefresh"))
        {
            Log.i("API", uri.getPath()+" **ENABLE PULLTOREFRESH**");
            this.swipeView.setEnabled(true);
            this.swipeViewAlt.setEnabled(true);
            return true;
        }


        if (call.command.equalsIgnoreCase("nativead"))
        {
            Log.i("API", uri.getPath()+" **NATIVE AD**");

            String divId = call.param.getString("id");
            if (nativeAds == null)
                nativeAds = new HashMap<String, AppDeckAdNative>();
            AppDeckAdNative nativeAd = nativeAds.get(divId);
            if (nativeAd == null && loader.adManager != null)
            {
                nativeAd = loader.adManager.getNativeAd();//new NativeAd(loader);
                nativeAds.put(divId, nativeAd);
            }
            if (nativeAd != null)
                nativeAd.addApiCall(call);
            return true;
        }

        if (call.command.equalsIgnoreCase("nativeadclick"))
        {
            Log.i("API", uri.getPath()+" **NATIVE AD CLICK**");

            String divId = call.param.getString("id");
            AppDeckAdNative nativeAd = nativeAds.get(divId);
            if (nativeAd != null)
            {
                nativeAd.click(call);
            }
            return true;
        }

		if (call.command.equalsIgnoreCase("inhistory"))
		{
			Log.i("API", uri.getPath()+" **IN HISTORY**");
			
			boolean isInCache = false;
			String relativeURL = call.input.getString("param");
			URI url = this.uri.resolve(relativeURL);
			if (url != null)
			{
				String absoluteURL = url.toString();
				CacheResult value = this.appDeck.cache.isInCache(absoluteURL);
				isInCache = value.isInCache;
			}
			Boolean result = Boolean.valueOf(isInCache);
			
			call.setResult(result);
			
			return true;
		}		
		
		if (call.command.equalsIgnoreCase("menu"))
		{
			Log.i("API", uri.getPath()+" **MENU**");
			
			// menu entries
			AppDeckJsonArray entries = call.input.getArray("param");
			if (entries.length() > 0)
			{
				PageMenuItem defaultMenu[] = screenConfiguration.getDefaultPageMenuItems(uri, this); 
				menuItems = new PageMenuItem[entries.length() + defaultMenu.length];
				
				int i;
				for (i = 0; i < entries.length(); i++)
				{
					AppDeckJsonNode entry = entries.getNode(i);
					String title = entry.getString("title");
					String content = entry.getString("content");
					String icon = entry.getString("icon");
					String type = entry.getString("type");
                    String badge = entry.getString("badge");
					
			        //UIImage *iconImage = self.child.loader.conf.icon_action.image;
					PageMenuItem item = new PageMenuItem(title, icon, type, content, badge, uri, this);
					menuItems[i] = item;
				}
				for (int j = 0; j < defaultMenu.length; j++, i++) {
					menuItems[i] = defaultMenu[j];
				}
				//appDeck.loader.invalidateOptionsMenu();
				if (isCurrentAppDeckPage())
					loader.setMenuItems(menuItems);
			} else {
				menuItems = screenConfiguration.getDefaultPageMenuItems(uri, this);
				loader.setMenuItems(menuItems);
			}
			
			return true;
		}
		
		if (call.command.equalsIgnoreCase("previousnext"))
		{
			Log.i("API", uri.getPath()+" **PREVIOUSNEXT**");
			
			previousPageUrl = call.param.getString("previous_page");
			if (previousPageUrl.isEmpty() == false)
				previousPageUrl = uri.resolve(previousPageUrl).toString();
			nextPageUrl = call.param.getString("next_page");
			if (nextPageUrl.isEmpty() == false)
				nextPageUrl = uri.resolve(nextPageUrl).toString();			
			if (pageSwipe != null)
				pageSwipe.updatePreviousNext(this);
			
			return true;
		}
		
		if (call.command.equalsIgnoreCase("popover"))
		{
			Log.i("API", uri.getPath()+" **POPOVER**");

			String url = call.param.getString("url");
			
			if (url != null && !url.isEmpty())
			{
				loader.showPopOver(this, call);
			}
			
			return true;
		}		
		
		if (call.command.equalsIgnoreCase("popup"))
		{
			Log.i("API", uri.getPath()+" **POPUP**");

            String absoluteURL = uri.resolve(call.input.getString("param")).toString();
            //String absoluteURL = call.smartWebView.resolve(call.input.getString("param"));
			loader.showPopUp(this, absoluteURL);
			
			return true;
		}
		
		if (call.command.equalsIgnoreCase("select"))
		{
			Log.i("API", uri.getPath()+" **SELECT**");
			
			//call.postponeResult();
			
			String title = call.param.getString("title");
			AppDeckJsonArray values = call.param.getArray("values");
        	CharSequence[] items = new CharSequence[values.length()];
			String[] t = new String[values.length()];
        	for (int i = 0; i < values.length(); i++) {
				items[i] = values.getString(i);
				t[i] = values.getString(i);
			}

			new MaterialDialog.Builder(getContext())
					.title(title)
					.items(t)
					.cancelable(false)
					.itemsCallbackSingleChoice(-1, new MaterialDialog.ListCallbackSingleChoice() {
						@Override
						public boolean onSelection(MaterialDialog dialog, View view, int which, CharSequence text) {
							if (text != null)
								call.sendCallbackWithResult("success", text.toString());
							else
								call.sendCallBackWithError("cancel");
							call.sendPostponeResult(true);
							return true;
						}
					})
					.positiveText(android.R.string.ok)
					.show();

			call.postponeResult();

            return true;
		}

		if (call.command.equalsIgnoreCase("selectdate"))
		{
			Log.i("API", uri.getPath()+" **SELECT DATE**");
			
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
			final DatePickerDialogCustom datepicker = new DatePickerDialogCustom(loader, d, yearValue, monthValue, dayValue);
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
			  
			  if (year.length() > 0)
				  datepicker.setYearEnabled(false);
			  if (month.length() > 0)
				  datepicker.setMonthEnabled(false);
			  if (day.length() > 0)
				  datepicker.setDayEnabled(false);			  
			  datepicker.setTitle(title);
			  datepicker.show();

            return true;
		}

        if (call.command.equalsIgnoreCase("loadingshow") || call.command.equalsIgnoreCase("loadingset"))
        {
			currentProgress = new LightLoader(getContext());
			/*
			currentProgress = new MaterialDialog.Builder(getContext())
					//.title(R.string.progress_dialog)
					//.content(R.string.please_wait)
					.progress(true, 0)
					.autoDismiss(false)
					.show();*/
            /*preLoadingIndicator.setVisibility(View.VISIBLE);
            preLoadingIndicator.bringToFront();*/
            return true;
        }
        if (call.command.equalsIgnoreCase("loadinghide"))
        {
            //preLoadingIndicator.setVisibility(View.GONE);
			if (currentProgress != null) {
				currentProgress.dismiss();
				currentProgress = null;
			}
            return true;
        }
		return super.apiCall(call);
		
	}
	
	public class customDialogOnClickListener implements DialogInterface.OnClickListener
	{
		AppDeckApiCall call;
		CharSequence[] items;
		
		customDialogOnClickListener(AppDeckApiCall call, CharSequence[] items)
		{
			this.call = call;
			this.items = items;
		}
		
		@Override
		public void onClick(DialogInterface dialog, int which) {
			String result = (String) items[which];
			//call.setResult(result);
			//call.sendPostponeResult(true);

            call.sendCallbackWithResult("success", result);
		}
		
	}
	
	@Override
	public void onHiddenChanged(boolean hidden)
	{
		if (pageWebView != null)
		{
			if (hidden)
				pageWebView.ctl.pause();
			else
				pageWebView.ctl.resume();
		}
	}
	
}
