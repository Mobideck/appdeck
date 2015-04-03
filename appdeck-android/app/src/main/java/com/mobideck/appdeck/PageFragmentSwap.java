package com.mobideck.appdeck;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;

import com.mobideck.appdeck.CacheManager.CacheResult;

/*import com.actionbarsherlock.internal.nineoldandroids.animation.Animator;
import com.actionbarsherlock.internal.nineoldandroids.animation.AnimatorListenerAdapter;
import com.actionbarsherlock.internal.nineoldandroids.view.animation.AnimatorProxy;*/
//import android.animation.Animator;
//import android.animation.AnimatorListenerAdapter;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.CookieSyncManager;
import android.widget.DatePicker;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.Toast;

public class PageFragmentSwap extends AppDeckFragment {
	
	public static final String TAG = "PageFragmentSwap";	
	
	public PageSwipe pageSwipe;
	
	//private SmartWebViewCrossWalk pageWebView;
	//private SmartWebViewCrossWalk pageWebViewAlt;

    private SmartWebView pageWebView;
    private SmartWebView pageWebViewAlt;

	private boolean pageWebViewReady = false;
	private boolean pageWebViewAltReady = false;	
	
	private SwipeRefreshLayout swipeView;
	private SwipeRefreshLayout swipeViewAlt;
	
	private long lastUrlLoad = 0;
	
	private FrameLayout wv_container;

    private ProgressBar preLoadingIndicator;
    private boolean isPreLoading = true;

	View adview;
	
	public URI uri;
	
	private boolean shouldAutoReloadInbackground;
	
	public static PageFragmentSwap newInstance(String absoluteURL)
	{
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
		this.appDeck = this.loader.appDeck;
    	currentPageUrl = getArguments().getString("absoluteURL");
    	this.screenConfiguration = this.appDeck.config.getConfiguration(currentPageUrl);
	}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
    	super.onCreateView(inflater, container, savedInstanceState);
        // Inflate the layout for this fragment
        rootView = (FrameLayout)inflater.inflate(R.layout.page_fragment_swap, container, false);
        rootView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        //if (appDeck.config.app_background_color != null)
        //    rootView.setBackground(appDeck.config.app_background_color.getDrawable());

        preLoadingIndicator = (ProgressBar)rootView.findViewById(R.id.preLoadingIndicator);

		//pageWebView = new SmartWebView(this);
		pageWebView = SmartWebViewFactory.createSmartWebView(this);// new SmartWebViewCrossWalk(this);

    	//pageWebViewAlt = new SmartWebView(this);
    	pageWebViewAlt = SmartWebViewFactory.createSmartWebView(this);//new SmartWebViewCrossWalk(this);
    			
		mAnimationDuration = getResources().getInteger(
                android.R.integer.config_shortAnimTime);
				
        swipeView = (SwipeRefreshLayout) rootView.findViewById(R.id.swipe);
        swipeView.setColorScheme(android.R.color.holo_blue_dark, android.R.color.holo_blue_light, android.R.color.holo_green_light, android.R.color.holo_green_light);
        swipeView.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
        	
        	@Override
            public void onRefresh() {
                swipeViewAlt.setRefreshing(true);
                swipeView.setRefreshing(true);
                reloadInBackground();
            }
        });
        swipeView.addView(pageWebView.view);
        
        swipeViewAlt = (SwipeRefreshLayout) rootView.findViewById(R.id.swipeAlt);
        swipeViewAlt.setColorScheme(android.R.color.holo_blue_dark, android.R.color.holo_blue_light, android.R.color.holo_green_light, android.R.color.holo_green_light);
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
        
        rootView.bringChildToFront(swipeView);
        		
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
    		menuItems = screenConfiguration.getDefaultPageMenuItems(uri, this);
    		this.loader.setMenuItems(menuItems);
        	pageWebView.ctl.smartWebViewRestoreState(savedInstanceState);
        } else {
        	loadPage(currentPageUrl);
        	//pageWebView.load("blank", "<!DOCTYPE html><html><head><title></title></head><body></body></html>");
        	//pageWebViewAlt.load("blank", "<!DOCTYPE html><html><head><title></title></head><body></body></html>");
        }

        mHandler = new Handler();
        mHandler.postDelayed(myTask, 150);

        return rootView;
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

    @Override
    public void onResume() {
    	super.onResume();
    	CookieSyncManager.getInstance().stopSync();
    	pageWebView.ctl.resume();
    	pageWebViewAlt.ctl.resume();
    	/*if (adview != null)
    		adview.resume();*/

    	long now = System.currentTimeMillis();
    	if (screenConfiguration != null && screenConfiguration.ttl > 0 && lastUrlLoad != 0)
    	{
			if (screenConfiguration.ttl > ((now - lastUrlLoad) / 1000))
			{
				Log.v(TAG, "Should NOT AutoRealod SCREEN:["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " cache ttl: "+lastUrlLoad + " now: " + now + " diff: " + (now - lastUrlLoad)/1000);				
			} else {
				Log.v(TAG, "Should AutoRealod SCREEN:["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " cache ttl: "+lastUrlLoad + " now: " + now + "diff: " + (now - lastUrlLoad)/1000);
				reloadInBackground();
			}
		} else {
			Log.v(TAG, "AutoRealod DISABLED :["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " cache ttl: "+lastUrlLoad + " now: " + now + "diff: " + (now - lastUrlLoad)/1000);
		}
    	
    };
    
    @Override
    public void onPause() {
    	super.onPause();
    	CookieSyncManager.getInstance().sync();
    	pageWebView.ctl.pause();
    	pageWebViewAlt.ctl.pause();
    	/*if (adview != null)
    		adview.pause();*/
    };

    @Override
    public void onSaveInstanceState(Bundle outState)
    {
    	super.onSaveInstanceState(outState);
    	if (pageWebView != null)
    		pageWebView.ctl.smartWebViewSaveState(outState);
    }
    
    @Override
    public void onDestroyView()
    {
    	super.onDestroyView();
    }
    
    @Override
    public void onDestroy()
    {
    	if (pageWebView != null)
    		pageWebView.ctl.clean();
    	if (pageWebViewAlt != null)
    		pageWebViewAlt.ctl.clean();
    	super.onDestroy();
    }
    
    @Override
    public void onDetach ()
    {
    	super.onDetach();
    }
    
    public void loadUrl(String absoluteURL)
    {
		if (absoluteURL.startsWith("javascript:"))
		{
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
			loader.replacePage(absoluteURL);
			return;
    	}
		super.loadUrl(absoluteURL);
    }
    
	public void loadPage(String absoluteUrl)
	{		
		currentPageUrl = absoluteUrl;
		try {
			uri = new URI(currentPageUrl);
		} catch (URISyntaxException e) {
			e.printStackTrace();
		}
		
		loadURLConfiguration(absoluteUrl);
		
		menuItems = screenConfiguration.getDefaultPageMenuItems(uri, this);			
		
		Log.v(TAG, "SCREEN: "+screenConfiguration.title+" TTL: "+screenConfiguration.ttl);
				
		progressStart(pageWebView.view);
		
		// does page is in cache ?
		CacheManager.CacheResult cacheResult = appDeck.cache.isInCache(currentPageUrl);		
		
		boolean loadFromCache = false;
		boolean reloadInBackground = false;
		
		if (cacheResult.isInCache)
		{
			long now = System.currentTimeMillis();					
			
			if (screenConfiguration.ttl > ((now - cacheResult.lastModified) / 1000))
			{
				Log.v(TAG, "Cache HIT SCREEN:["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " cache ttl: "+cacheResult.lastModified + " now: " + now + " diff: " + (now - cacheResult.lastModified)/1000);				
				//pageWebView.setForceCache(true);
				loadFromCache = true;
			} else {
				Log.v(TAG, "Cache HIT DEPRECATED SCREEN:["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " cache ttl: "+cacheResult.lastModified + " now: " + now + "diff: " + (now - cacheResult.lastModified)/1000);
				loadFromCache = true;
				reloadInBackground = true;
			}
		} else {
			Log.v("CACHE", "Cache MISS SCREEN:["+screenConfiguration.title+"] ttl: "+screenConfiguration.ttl + " page IS NOT IN CACHE");
		}
		
		if (loadFromCache)
		{
			pageWebView.ctl.setForceCache(true);
			if (reloadInBackground)
				shouldAutoReloadInbackground = true;
		} else {
			pageWebView.ctl.setForceCache(false);
		}
		
		pageWebView.ctl.loadUrl(absoluteUrl);
		lastUrlLoad = System.currentTimeMillis();
		loader.invalidateOptionsMenu();
	}
    public void progressStart(View origin)
    {
    	super.progressStart(origin);
    }

    void hidePreloading()
    {
        preLoadingIndicator.setVisibility(View.GONE);
        swipeView.setVisibility(View.VISIBLE);
        swipeViewAlt.setVisibility(View.VISIBLE);
        isPreLoading = false;
    }

    public void progressSet(View origin, int percent)
    {
        if (percent > 50 && isPreLoading /*&& loader.getPreviousAppDeckFragment(this.pageSwipe) == null*/)
        {
            hidePreloading();
        }
    	super.progressSet(origin, percent);

    }
    
    public void progressStop(View origin)
    {
    	super.progressStop(origin);

    	swipeView.setRefreshing(false);
    	swipeViewAlt.setRefreshing(false);
		if (origin == pageWebView.view && shouldAutoReloadInbackground == true)
		{
			Log.i(TAG, "+++ Reload In Background +++");
			shouldAutoReloadInbackground = false;
			reloadInBackground();
		}
		
		if (origin == pageWebViewAlt.view)
			swapWebView();
				
    }
    
    public void progressFailed(View origin)
    {
    	super.progressFailed(origin);
    	
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
    		//pageWebView.load(uri.toString(), "Check Your Network ...");
    		//Toast.makeText(origin.getContext(), "Check your network", Toast.LENGTH_LONG).show();    		
    		pageWebView.ctl.evaluateJavascript("document.head.innerHTML = ''; document.body.innerHTML = \"<style>body { background-color: "+loader.appDeck.config.image_network_error_background_color+"; background-image: url('"+loader.appDeck.config.image_network_error_url+"'); background-repeat:no-repeat; background-position:top center; }</style>\";", null);
    		
    	}
    	if (origin == pageWebViewAlt.view)
    	{
    		Toast.makeText(origin.getContext(), "Network Error", Toast.LENGTH_LONG).show();
    		//setVisibility(View.INVISIBLE);
    		reloadInProgress = false;
    	}

    }
	
	private boolean reloadInProgress = false;
    public void reloadInBackground()
    {    	
    	if (reloadInProgress)
    		return;
/*    	if (appDeck.isLowSystem)
    	{
    		loadPage(currentPageUrl);
    		return;
    	}*/
    	reloadInProgress = true;

    	pageWebView.ctl.stopLoading();
    	pageWebViewAlt.ctl.stopLoading();
    	pageWebViewAlt.ctl.setForceCache(false);
    	
    	rootView.bringChildToFront(swipeView);
    	if (adview != null)
    		rootView.bringChildToFront(adview);
//    	swipeViewAlt.setVisibility(View.VISIBLE);
    	
    	//page_layout_alt.removeAllViews();
    	//etSupportProgressBarIndeterminateVisibility(true);
    	//pageWebViewAlt.stopLoading();
    	progressStart(pageWebViewAlt.view);
    	pageWebViewAlt.ctl.loadUrl(currentPageUrl);
		lastUrlLoad = System.currentTimeMillis();
    }
    
	@Override
	public void reload()
	{
		super.reload();
		reloadInBackground();		
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
    	if (adview != null)
    		rootView.bringChildToFront(adview);
    	
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
    	            	    	if (adview != null)
    	            	    		rootView.bringChildToFront(adview);
    	            	    	    	            	    	
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
    
	public boolean apiCall(final AppDeckApiCall call)
	{
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
					
			        //UIImage *iconImage = self.child.loader.conf.icon_action.image;
					PageMenuItem item = new PageMenuItem(title, icon, type, content, uri, this);
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
        	for (int i = 0; i < values.length(); i++) {
				items[i] = values.getString(i);
			}

        	AlertDialog.Builder builder = new AlertDialog.Builder(loader);
        	if (title != null && !title.isEmpty())
        		builder.setTitle(title);

            builder.setPositiveButton(R.string.dialog_ok, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {
                    //call.setResult("Z");
                    //call.sendPostponeResult(true);
                    call.sendCallbackWithResult("error", "cancel");
                }
            })
            .setNegativeButton(R.string.dialog_cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        //call.sendPostponeResult(false);
                        call.sendCallbackWithResult("error", "cancel");
                    }
                });

        	builder.setOnCancelListener(
                    new DialogInterface.OnCancelListener() {
                        public void onCancel(DialogInterface dialog) {
                            call.sendCallbackWithResult("error", "cancel");
                        }
                    });
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.JELLY_BEAN_MR1)
            	builder.setOnDismissListener(new DialogInterface.OnDismissListener() {
					
				@Override
				public void onDismiss(DialogInterface dialog) {
					call.sendPostponeResult(false);
				}
			});
        	builder.setItems(items, new customDialogOnClickListener(call, items));
        	AlertDialog alert = builder.create();        	
        	//The above line didn't show the dialog i added this line:
        	alert.show();

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
		        	 HashMap<String,String> result = new HashMap<String, String>() {
		        	     {
		        	      put("year", String.valueOf(year));
		        	      put("month", String.valueOf(monthOfYear + 1));
		        	      put("day", String.valueOf(dayOfMonth));
		        	     }
		        	 };
					//call.setResult(result);
					//call.sendPostponeResult(true);
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
            preLoadingIndicator.setVisibility(View.VISIBLE);
            preLoadingIndicator.bringToFront();
            return true;
        }
        if (call.command.equalsIgnoreCase("loadinghide"))
        {
            preLoadingIndicator.setVisibility(View.GONE);
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
