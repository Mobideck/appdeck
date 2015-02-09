package com.mobideck.appdeck;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import com.mobideck.appdeck.R;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Application;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Picture;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.text.InputFilter.LengthFilter;
import android.util.Log;
import android.view.Display;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.WebBackForwardList;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebSettings.ZoomDensity;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebSettings.LayoutAlgorithm;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebSettings.RenderPriority;
import android.webkit.WebViewDatabase;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.MediaController;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

public class SmartWebView extends WebView {
	static String TAG = "SmartWebView";
	
	static String appdeck_inject_js = "javascript:if (typeof(appDeckAPICall)  === 'undefined') { appDeckAPICall = ''; var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/fastclick.js'; document.getElementsByTagName('head')[0].appendChild(scr); var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/appdeck_1.10.js'; document.getElementsByTagName('head')[0].appendChild(scr);}";	
	
	static boolean prioritySet = false;
	
	AppDeck appDeck;
	public AppDeckFragment root;
	String url;
	Uri uri;
	
	private View								mCustomView;
	private FrameLayout							mCustomViewContainer;
	private WebChromeClient.CustomViewCallback 	mCustomViewCallback;
	
	private String cookie;	
	
	private boolean firstLoad = true; 

	public boolean shouldLoadFromCache = false;
	
    private long lastMoveEventTime = -1;
    private int eventTimeInterval = 10;	
    
    public boolean catchLink = true;
    
	private void prepareWebView()
	{
		if (Build.VERSION.SDK_INT <= 11) {
			eventTimeInterval = 80;
		}
		if (Build.VERSION.SDK_INT >= 11){
		    //setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		}
	}
	
	
	// hack for keyboard hidden on loadUrl: http://stackoverflow.com/questions/8016430/prevent-buttons-from-hiding-soft-keyboard-on-android/18776064#18776064
	//public EditText mFocusDistraction;
	
	public Lock jsLock = new ReentrantLock();;
	
	private GestureDetector gestureDetector;
    private AtomicBoolean mPreventAction = new AtomicBoolean(false);
    private AtomicLong mPreventActionTime = new AtomicLong(0);
	
	public SmartWebView(AppDeckFragment root) {
		//super(page.getBaseContext());
		super(root.loader);
		this.root = root;
		appDeck = AppDeck.getInstance();
		//self = this;
		//setOverScrollMode(OVER_SCROLL_ALWAYS);
		prepareWebView();
		configureWebView();        
        //addJavascriptInterface(new PageJSInterface(root.getActivity()), "appdeck");
        //addJavascriptInterface(new AppDeckJSApi(this), "appdeck");
        //loadData("", "text/html", null);		
        setWebViewClient(new SmartWebViewClient());
        setWebChromeClient(new SmartWebChromeClient());
        gestureDetector = new GestureDetector(root.loader, new GestureListener());
        //mFocusDistraction = new EditText(root.loader);
        //addView(mFocusDistraction);
	}
	
	public void clean()
	{
		super.loadDataWithBaseURL("", "<!DOCTYPE html><html><head><title></title></head><body></body></html>",
				"text/html", "utf-8", "");
		destroy();
	}
	
	@Override
	public void loadUrl(String url)
	{
		//mFocusDistraction.requestFocus();		
		if (url.startsWith("javascript:") == false)
		{
			CookieManager cookieManager = CookieManager.getInstance();
			if (cookieManager != null)
				cookie = cookieManager.getCookie(url);
			else
				cookie = null;			
			this.url = url;
			uri = Uri.parse(url);
			firstLoad = true;
			onNewPictureCalled = false;
		}
		super.loadUrl(url);
		//this.requestFocus();
		//root.setProgress(this, true, 0);
		//super.loadUrl("javascript:window.addEventListener('DOMContentLoaded', function(e) {    alert('ok'); });");
	}
	
	public String resolve(String relativeURL)
	{
		URI master;
		try {
			master = new URI(this.url);
			return master.resolve(relativeURL).toString();
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	@Override
	public void loadDataWithBaseURL(String baseUrl, String data,
			String mimeType, String encoding, String historyUrl) {
		if (baseUrl.startsWith("javascript:") == false)
		{
			CookieManager cookieManager = CookieManager.getInstance();
			if (cookieManager != null)
				cookie = cookieManager.getCookie(url);
			else
				cookie = null;			
			this.url = baseUrl;
			uri = Uri.parse(baseUrl);
			firstLoad = true;
			onNewPictureCalled = false;
		}		
		super.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
	}
	
	@Override
	public void loadData(String data, String mimeType, String encoding)
	{
		super.loadData(data, mimeType, encoding);
	}
	
	
	@SuppressWarnings("deprecation")
	@SuppressLint("SetJavaScriptEnabled")
	private void configureWebView()
	{
		// hack to avoid flickering when scroll in Android ICS
		if (Build.VERSION.SDK_INT == Build.VERSION_CODES.ICE_CREAM_SANDWICH)
			setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		// hardware acceleration is not operational with Android <= 3.0
		else if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.HONEYCOMB)
			setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		// use hardware acceleration if possible
		else
			setLayerType(View.LAYER_TYPE_HARDWARE, null);
		

		//if (Build.VERSION.SDK_INT == Build.VERSION_CODES.ICE_CREAM_SANDWICH)
		//	setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		//setBackgroundColor(Color.argb(1, 0, 0, 0));
		
		CookieManager.getInstance().setAcceptCookie(true);
		
		setAnimationCacheEnabled(true);
		setDrawingCacheEnabled(true);
		
		setPersistentDrawingCache(ViewGroup.PERSISTENT_SCROLLING_CACHE);
		
        WebSettings webSettings = getSettings();
        webSettings.setJavaScriptEnabled(true);

		String ua = webSettings.getUserAgentString();
		webSettings.setUserAgentString(ua + " AppDeck "+appDeck.packageName+"/"+appDeck.config.app_version);
        
        String databasePath = root.loader.getBaseContext().getDir("databases", Context.MODE_PRIVATE).getPath();
        webSettings.setDatabasePath(databasePath);
        webSettings.setGeolocationDatabasePath(databasePath);

        File cachePath = new File(Environment.getExternalStorageDirectory(), ".appdeck");
        cachePath.mkdirs();        
        
        webSettings.setAppCacheEnabled(true);
        webSettings.setAppCachePath(cachePath.getAbsolutePath());
        Log.i(TAG, "appCache:"+cachePath.getAbsolutePath().toString());
        webSettings.setAppCacheMaxSize(Long.MAX_VALUE);
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setDatabaseEnabled(true);
        //webSettings.setPluginsEnabled(true);
        //webSettings.setUseDoubleTree(false);
        webSettings.setPluginState(PluginState.ON);
        webSettings.setRenderPriority(RenderPriority.HIGH);
        //webSettings.setEnableSmoothTransition(true);
		setHorizontalScrollBarEnabled(false);
        
		
		webSettings.setSupportMultipleWindows(true);
		setLongClickable(true);
		setDrawingCacheEnabled(true);
		
	    // Initialize the WebView
		webSettings.setSupportZoom(false);
		//webSettings.setSupportZoom(false);
		webSettings.setBuiltInZoomControls(false);
		//webSettings.setBuiltInZoomControls(true);
		setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
		setScrollbarFadingEnabled(true);
		webSettings.setLoadsImagesAutomatically(true);		

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
	    {
	        // This is added as a work-around for the flicker which occurs in Android 3.0+
	        // when hardware acceleration is enabled:
	        // http://stackoverflow.com/questions/9476151/webview-flashing-with-white-background-if-hardware-acceleration-is-enabled-an
	        //webview.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
	    }
		
        // fix viewport
		//setInitialScale(1);
		//setPadding(0, 0, 0, 0);
        //pageWebView.setInitialScale(getScale());
        //webSettings.setLoadWithOverviewMode(true);
        //webSettings.setUseWideViewPort(true);
        // fit the width of screen
        // webSettings.setLayoutAlgorithm(LayoutAlgorithm.NARROW_COLUMNS); 
        
        //webSettings.setDefaultZoom(WebSettings.ZoomDensity.FAR);
        //webview.setLayerType(WebView.LAYER_TYPE_HARDWARE, null);
        setPictureListener(new MyPictureListener());
        
        if (appDeck.noCache)
        {
        	webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        	webSettings.setAppCacheEnabled(false);
        	webSettings.setAppCacheMaxSize(0);
        }
        /*
        requestFocus(View.FOCUS_DOWN);
        setOnTouchListener(new View.OnTouchListener()
        {
            @Override
            public boolean onTouch(View v, MotionEvent event)
            {
                switch (event.getAction())
                {
                    case MotionEvent.ACTION_DOWN:
                    case MotionEvent.ACTION_UP:
                        if (!v.hasFocus())
                        {
                            v.requestFocus();
                        }
                        break;
                }
                return false;
            }
        });
        requestFocusFromTouch();*/
        
        //webSettings.setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
        //webSettings.setCacheMode(WebSettings.LOAD_CACHE_ONLY);
        
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true);
        }        
        
		try {
			
			WebkitProxy2.setProxy(this, root.loader.proxyHost, root.loader.proxyPort, Application.class.getCanonicalName());
			//WebkitProxy.setProxy("AppDeckApplication", root.loader, root.loader.proxyHost, root.loader.proxyPort);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}        
	}
	
	public void setForceCache(boolean forceCache)
	{
		shouldLoadFromCache = forceCache;
		
		if (shouldLoadFromCache == false)
		{
			getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
		} else {
			getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
			//getSettings().setCacheMode(WebSettings.LOAD_CACHE_ONLY);
		}		
	}
	
	/*
	private int getCalculatedScale(){
	    Display display = ((WindowManager) root.loader.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay(); 
	    int width = display.getWidth(); 
	    Double val = new Double(width)/new Double(PIC_WIDTH);
	    val = val * 100d;
	    return val.intValue();
	}*/	
	
	public class SmartWebViewClient extends WebViewClient {

		
		public SmartWebViewClient() {
			stableScaleCalculationStart = System.currentTimeMillis();
		}
		
	      /**
	       * it will always be call.
	       */
		@Override
	      public void onPageStarted(WebView view, String url, Bitmap favicon){
	    	  if (firstLoad)
	    	  {
		    		//Log.i("SmartWebView", "**onPageStarted**");
		            // force inject of appdeck.js if needed
		            //view.loadUrl("javascript:appdeck.init();");
//		            String js = "javascript:if (typeof(appDeckAPICall)  === 'undefined') { var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://testapp.appdeck.mobi/appdeck.js'; document.getElementsByTagName('head')[0].appendChild(scr); }";
//		            view.loadUrl(js);
	              //String js = "javascript:if (typeof(appDeckAPICall)  === 'undefined') { var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://testapp.appdeck.mobi/appdeck.js'; document.getElementsByTagName('head')[0].appendChild(scr); }";
	              //view.loadUrl(js);
	    		  /*
	    		  root.loader.runOnUiThread(new Runnable() {

	    	            public void run() {
	    	            	//String js = appdeck_inject_js;
//	    	            	String js = "javascript:if (typeof(appDeckAPICall)  === 'undefined') { var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/fastclick.js'; document.getElementsByTagName('head')[0].appendChild(scr);  var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/appdeck_dev.js'; document.getElementsByTagName('head')[0].appendChild(scr); }";
	    		            loadUrl(appdeck_inject_js);
	    	            }
	    	        });*/
	    		  firstLoad = false;
	    		  return;
	    	  }
	    	  Log.d("SmartWebView", "OnPageStarted (not firstLoad) :"+url);
	    	  /*view.stopLoading();
	    	  view.goBack();
	    	  root.loadUrl(url);*/
	      }		
		
		//@Override
		public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg)
		{
			root.loadUrl(url);
			return false;
		}
	      
	    @Override
	    public boolean shouldOverrideUrlLoading(WebView view, String url) {

	    	if (catchLink == false)
	    		return false;
	    	
	    	/*if (Uri.parse(url).getHost().equals(uri.getHost())) {
	            // This is my web site, so do not override; let my WebView load the page

	        	appDeck.loader.loadPage(url);
	        	
	            return true;
	        }
	        // Otherwise, the link is not for a page on my site, so launch another Activity that handles URLs
	        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
	        root.startActivity(intent);
	    
	        return true;*/
	    	
	    	root.loadUrl(url);
	    	return true;
	    }
	    
	    
	    @Override
	    public WebResourceResponse shouldInterceptRequest(final WebView view, String absoluteURL) {

	    	//if (true)
	    	//	return null;
	    	
	    	if (absoluteURL.indexOf("data:") == 0)
	    		return null;

	    	if (absoluteURL.indexOf("_appdeck_is_form") != -1)
	    		return null;
	    	
	    	if (prioritySet == false)
	    	{
	    		prioritySet = true;
	    		android.os.Process.setThreadPriority(19);
	    	}
	    	
	    	/*if (absoluteURL.equalsIgnoreCase(url) == false)
	    	{
	    		Log.i("SmartWebView", "**shouldInterceptRequest**");
	            // force inject of appdeck.js if needed
	            //view.loadUrl("javascript:appdeck.init();");
	    		jsLock.lock();
	    		jsLock.unlock();
	    	}*/
	    	
	    	if (appDeck.noCache)
	    		return null;
	    	
	    	/*if (absoluteURL.equals("http://www.play3-live.com/__appli/iphone/js/fastclick.js"))
	    	{
	    		return appDeck.cache.responseFromData(new byte[0]);
	    	}
	    	if (absoluteURL.equals("http://www.play3-live.com/__appli2.2/iphone/js/fastclick.js"))
	    	{
	    		return appDeck.cache.responseFromData(new byte[0]);
	    	}*/	    	
	    	
	    	// resource is in embed resources
	    	WebResourceResponse response = appDeck.cache.getEmbedResource(absoluteURL);
	    	if (response != null)
	    	{
	    		Log.i(TAG, "FROM EMBED: "+absoluteURL);
	    		return response;
	    	}

	    	if (appDeck.cache.shouldCache(absoluteURL) || shouldLoadFromCache)
	    	{
	    		response = appDeck.cache.getCachedResource(absoluteURL);
	    		if (response != null)
	    		{
	    			Log.i(TAG, "FROM CACHE: "+absoluteURL);
	    			return response;
	    		}
	    	}
	    	
	    	return null;
	    }	    
	    
	    
        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            Log.i("SmartWebView", "**onPageFinished**");
            
            // force inject of appdeck.js if needed
            view.loadUrl(appdeck_inject_js);
                       
            SmartWebView.this.invalidateHack(100);            

            root.progressStop(view);
            
            //view.loadUrl("javascript:document.body.style.zoom = window.innerHeight / 320;");
            CookieSyncManager.getInstance().sync();
            
            String c = CookieManager.getInstance().getCookie(url);
            Log.i(TAG, "Cookie: "+c);
			// set the cookie on the "root" class thats managing the 
			// entire application
			//MyApplication.getInstance().
			//CookieSyncManager.getInstance().sync();            
            
            //page.onPageFinished(view, url);
            //root.setProgress(view, false, 100);   
        }
        
        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl)
        {
        	// this is the main url that is falling
        	if (failingUrl.equalsIgnoreCase(url) && shouldLoadFromCache == true)
        	{
        		Toast.makeText(getContext(), "Not in cache: " + failingUrl, Toast.LENGTH_LONG).show();
        		view.setVisibility(View.INVISIBLE);
        	}
        	else
        	{
        		Toast.makeText(getContext(), "" + failingUrl+ ": ("+url+") " +description, Toast.LENGTH_LONG).show();
        	}
        	
        }        
        
        
        private static final String LOG_TAG = "NoZoomedWebViewClient";
        private static final long STABLE_SCALE_CALCULATION_DURATION = 2 * 1000;

        private long   stableScaleCalculationStart;
        private String stableScale = "";  // Avoid comparing floats
        private long   restoringScaleStart;

/*
        @Override
        public void onScaleChanged(final WebView view, float oldScale, float newScale) {
            Log.d(LOG_TAG, "onScaleChanged: " + oldScale + " -> " + newScale);

            if (view != null) {
                view.invalidate();
            }            
            
            long now = System.currentTimeMillis();
            boolean calculating = (now - stableScaleCalculationStart) < STABLE_SCALE_CALCULATION_DURATION;
            if (calculating) {
                stableScale = "" + newScale;
            } else if (!stableScale.equals("" + newScale)) {
                boolean zooming = (now - restoringScaleStart) < STABLE_SCALE_CALCULATION_DURATION;
                if (!zooming) {
                    Log.d(LOG_TAG, "Zoom out to stableScale: " + stableScale);
                    restoringScaleStart = now;
                    view.zoomOut();

                    // Just to make sure, do it one more time
                    view.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            view.zoomOut();
                        }
                    }, STABLE_SCALE_CALCULATION_DURATION);
                }
            }
        }   */     
		
	}
	
	public class SmartWebChromeClient extends WebChromeClient /*implements OnCompletionListener, OnErrorListener*/ {
		
		private Bitmap 		mDefaultVideoPoster;
		private View 		mVideoProgressView;
		
        @Override
        public void onProgressChanged(WebView view, int newProgress) {          
            //WebViewActivity.this.setValue(newProgress);
            super.onProgressChanged(view, newProgress);
            
            //page.setSupportProgressBarIndeterminateVisibility(false);
            root.progressSet(view, newProgress);
            
        }		
		
        @Override
        public boolean onJsAlert(WebView view, String url, String message, final JsResult result) 
        {
        	
            new AlertDialog.Builder(root.loader)
                .setTitle("javaScript dialog")
                .setMessage(message)
                .setPositiveButton(android.R.string.ok,
                        new AlertDialog.OnClickListener() 
                        {
                            public void onClick(DialogInterface dialog, int which) 
                            {
                                result.confirm();
                            }
                        })
                .setCancelable(false)
                .create()
                .show();
            return true;
        };
        
        @Override
        public boolean onJsConfirm(WebView view, String url, String message, final JsResult result) 
        {
            new AlertDialog.Builder(root.loader)
                .setTitle("javaScript dialog")
                .setMessage(message)
                .setPositiveButton(android.R.string.ok, 
                        new DialogInterface.OnClickListener() 
                        {
                            public void onClick(DialogInterface dialog, int which) 
                            {
                                result.confirm();
                            }
                        })
                .setNegativeButton(android.R.string.cancel, 
                        new DialogInterface.OnClickListener() 
                        {
                            public void onClick(DialogInterface dialog, int which) 
                            {
                                result.cancel();
                            }
                        })
            .create()
            .show();
        
            return true;
        };
        
        @Override
        public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, final JsPromptResult result) 
        {
        	/*
			if (message.startsWith("appdeckapi:") == true)
			{
				AppDeckApiCall call = new AppDeckApiCall(message.substring(11), defaultValue, result);
				call.webview = view;
				call.smartWebView = SmartWebView.this;
				call.appDeckFragment = root;
				Boolean res = apiCall(call); //root.apiCall(call);
				call.sendResult(res);
				return true;
			}        	
            final LayoutInflater factory = LayoutInflater.from(root.loader);
            final View v = factory.inflate(R.layout.javascript_prompt_dialog, null);
            ((TextView)v.findViewById(R.id.prompt_message_text)).setText(message);
            ((EditText)v.findViewById(R.id.prompt_input_field)).setText(defaultValue);

            new AlertDialog.Builder(root.loader)
                .setTitle("javaScript dialog")
                .setView(v)
                .setPositiveButton(android.R.string.ok,
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int whichButton) {
                                String value = ((EditText)v.findViewById(R.id.prompt_input_field)).getText()
                                        .toString();
                                result.confirm(value);
                            }
                        })
                .setNegativeButton(android.R.string.cancel,
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int whichButton) {
                                result.cancel();
                            }
                        })
                .setOnCancelListener(
                        new DialogInterface.OnCancelListener() {
                            public void onCancel(DialogInterface dialog) {
                                result.cancel();
                            }
                        })
                .show();
            */
            return true;
        };

		
		/*
		public CustomViewCallback mCustomViewCallback;

		@Override
		public void onShowCustomView(View view, CustomViewCallback callback) {
		    super.onShowCustomView(view, callback);
		    if (view instanceof FrameLayout) {
		        FrameLayout customViewContainer = (FrameLayout) view;
		        mCustomViewCallback = callback;
		        View instance = customViewContainer.getFocusedChild();
		        if (instance instanceof VideoView) {
		            VideoView customVideoView = (VideoView) customViewContainer.getFocusedChild();
		            try {
		                Field mUriField = VideoView.class.getDeclaredField("mUri");
		                mUriField.setAccessible(true);
		                Uri uri = (Uri) mUriField.get(customVideoView);
		                Intent intent = new Intent(Intent.ACTION_VIEW);
		                intent.setDataAndType(uri, "video/*");
		                appDeck.loader.startActivity(intent);
		                new Handler().post(new Runnable() {
		                    @Override
		                    public void run() {
		                        mCustomViewCallback.onCustomViewHidden();
		                    }
		                });
		            } catch (Exception e) {
		            }
		        }
		    }
		}	*/
		
		
        /*FrameLayout.LayoutParams COVER_SCREEN_GRAVITY_CENTER = new FrameLayout.LayoutParams(  
                ViewGroup.LayoutParams.WRAP_CONTENT,  
                ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER);*/  
       
            @Override  
            public void onShowCustomView(View view, CustomViewCallback callback) {
            	//super.onShowCustomView(view, callback);
        		if (Build.VERSION.SDK_INT > Build.VERSION_CODES.ICE_CREAM_SANDWICH)
        	    {
        			setLayerType(WebView.LAYER_TYPE_HARDWARE, null);
        	    }
            	//callback.onCustomViewHidden();
            	
    	        // if a view already exists then immediately terminate the new one
    	        if (mCustomView != null) {
    	            callback.onCustomViewHidden();
    	            return;
    	        }
    	        
            	//if (mCustomViewCallback != null)
            	//	return;
            	
            	mCustomView = view;
            	mCustomViewCallback = callback;
            	
            	/*CustomViewFragment fragment = new CustomViewFragment(root, view, callback);
            	appDeck.loader.pushFragment(fragment);
            	if (true)
            		return;*/
            	
            	android.net.Uri mUri = null;

    		    if (view instanceof FrameLayout) {
    		        FrameLayout customViewContainer = (FrameLayout) view;
    		        mCustomViewCallback = callback;
    		        View instance = customViewContainer.getFocusedChild();
    		        if (instance instanceof VideoView) {
    		            VideoView customVideoView = (VideoView) customViewContainer.getFocusedChild();
    		            try {
    		                Field mUriField = VideoView.class.getDeclaredField("mUri");
    		                mUriField.setAccessible(true);
    		                mUri = (Uri) mUriField.get(customVideoView);
    		            } catch (Exception e) {
    		            }
    		        }
    		    }
    		    if (mUri == null)
    		    {
	            	try
	            	{
	            	    @SuppressWarnings("rawtypes")
	            	    Class _VideoSurfaceView_Class_ = Class.forName("android.webkit.HTML5VideoFullScreen$VideoSurfaceView");
	
	            	    java.lang.reflect.Field _HTML5VideoFullScreen_Field_ = _VideoSurfaceView_Class_.getDeclaredField("this$0");
	
	            	    _HTML5VideoFullScreen_Field_.setAccessible(true);
	
	            	    Object _HTML5VideoFullScreen_Instance_ = _HTML5VideoFullScreen_Field_.get(((FrameLayout) view).getFocusedChild());
	
	            	    @SuppressWarnings("rawtypes")
	            	    Class _HTML5VideoView_Class_ = _HTML5VideoFullScreen_Field_.getType().getSuperclass();
	
	            	    java.lang.reflect.Field _mUri_Field_ = _HTML5VideoView_Class_.getDeclaredField("mUri");
	            	    _mUri_Field_.setAccessible(true);
	            	    mUri =  (Uri) _mUri_Field_.get(_HTML5VideoFullScreen_Instance_);
	            	    
	            	    /*MediaPlayer mPlayer = null;
	            	    _mUri_Field_ = _HTML5VideoView_Class_.getDeclaredField("mPlayer");
	            	    _mUri_Field_.setAccessible(true);
	            	    mPlayer =  (MediaPlayer) _mUri_Field_.get(_HTML5VideoFullScreen_Instance_);

	            	    mPlayer.stop();
	            	    mPlayer.release();
	            	    //mPlayer.reset();
	            	    
	            	    Method m = _HTML5VideoView_Class_.getDeclaredMethod("release", null);
	    	            m.setAccessible(true);
	    	            Object res = m.invoke(_HTML5VideoFullScreen_Instance_);
	            	    */
	            	    
	            	    //callback.onCustomViewHidden();
	            	    //return;

	            	}
	            	catch (Exception ex)
	            	{   
	            	}
            	}
            	if (mUri != null)
            	{
            		//callback.onCustomViewHidden();
            	    // There you have, mUri is the URI of the video
            		mCustomViewCallback = callback;
            		Intent intent = new Intent(Intent.ACTION_VIEW);
	                intent.setDataAndType(mUri, "video/*");
	                root.loader.startActivity(intent);
	                new Handler().postDelayed(new Runnable() {
	                    @Override
	                    public void run() {
	                        //mCustomViewCallback.onCustomViewHidden();
	                    	onHideCustomView();
	                    }
	                }, 100);
	                return;
            	}            	
            	
            	super.onShowCustomView(view, callback);
            	//CustomViewFragment fragment = new CustomViewFragment(root, view, callback);
            	//appDeck.loader.pushFragment(fragment);
            	//root.rootView.addView(view);
              /*if (view instanceof FrameLayout) {  

                mCustomViewContainer = (FrameLayout) view;  
                mCustomViewCallback = callback;  

                // mainLayout is the root layout that (ex. the layout that contains the webview)
                //mContentView = (RelativeLayout)findViewById(R.id.mainLayout);  
                if (mCustomViewContainer.getFocusedChild() instanceof VideoView) {  
                  mVideoView = (VideoView) mCustomViewContainer.getFocusedChild();  
                  // frame.removeView(video);  
                  //mContentView.setVisibility(View.GONE);  
                  mCustomViewContainer.setVisibility(View.VISIBLE);  
                  //setContentView(mCustomViewContainer);  
                  mVideoView.setOnCompletionListener(this);  
                  mVideoView.setOnErrorListener(this);  
                  mVideoView.start();  
                  
                  root.rootView.addView(view);
       
                }  
              }  */
            }  
       
            public void onHideCustomView() {  
            	super.onHideCustomView();
            	
            	if (mCustomView != null && mCustomView instanceof FrameLayout) {
    		        FrameLayout customViewContainer = (FrameLayout) mCustomView;
    		        View instance = customViewContainer.getFocusedChild();
    		        if (instance instanceof VideoView) {
    		            VideoView customVideoView = (VideoView) customViewContainer.getFocusedChild();
    		            customVideoView.stopPlayback();
    		            customVideoView.suspend();
    		        }
    		    }
            	if (mCustomView != null)
            	{
                	try
                	{
                	    @SuppressWarnings("rawtypes")
                	    Class _VideoSurfaceView_Class_ = Class.forName("android.webkit.HTML5VideoFullScreen$VideoSurfaceView");

                	    java.lang.reflect.Field _HTML5VideoFullScreen_Field_ = _VideoSurfaceView_Class_.getDeclaredField("this$0");

                	    _HTML5VideoFullScreen_Field_.setAccessible(true);

                	    Object _HTML5VideoFullScreen_Instance_ = _HTML5VideoFullScreen_Field_.get(((FrameLayout) mCustomView).getFocusedChild());

                	    @SuppressWarnings("rawtypes")
                	    Class _HTML5VideoView_Class_ = _HTML5VideoFullScreen_Field_.getType().getSuperclass();

                	    MediaPlayer mPlayer = null;
                	    java.lang.reflect.Field _mPlayer_Field_ = _HTML5VideoView_Class_.getDeclaredField("mPlayer");
                	    _mPlayer_Field_.setAccessible(true);
                	    mPlayer =  (MediaPlayer) _mPlayer_Field_.get(_HTML5VideoFullScreen_Instance_);

                	    mPlayer.stop();
                	    mPlayer.reset();
                	    mPlayer.release();
                	    
                	    Method m = _HTML5VideoView_Class_.getDeclaredMethod("release", null);
        	            m.setAccessible(true);
        	            Object res = m.invoke(_HTML5VideoFullScreen_Instance_);
                	    
                	    //callback.onCustomViewHidden();
                	    //return;

                	}
                	catch (Exception ex)
                	{   
                	}
            	}            	
            	
            	
            	if (mCustomView != null)
            		mCustomView.setVisibility(View.GONE);
            	if (mCustomViewCallback != null)
            		mCustomViewCallback.onCustomViewHidden();
            	mCustomView = null;
            	mCustomViewCallback = null;
/*              if (mVideoView == null){  
                return;  
              }else{  
              // Hide the custom view.  
              mVideoView.setVisibility(View.GONE);  
              // Remove the custom view from its container.  
              mCustomViewContainer.removeView(mVideoView);  
              mVideoView = null;  
              mCustomViewContainer.setVisibility(View.GONE);  
              mCustomViewCallback.onCustomViewHidden();  
              // Show the content view.  
              mContentView.setVisibility(View.VISIBLE);  
              }  */
            }  
       
       /*     public void onCompletion(MediaPlayer mp) {  
              mp.stop();  
              //mCustomViewContainer.setVisibility(View.GONE);  
              onHideCustomView();  
              //setContentView(mContentView);  
            }  
       
            public boolean onError(MediaPlayer arg0, int arg1, int arg2) {  
              //setContentView(mContentView);  
              return true;  
            }*/
            
    		@Override
    		public Bitmap getDefaultVideoPoster() {
    			//Log.i(LOGTAG, "here in on getDefaultVideoPoster");	
    			if (mDefaultVideoPoster == null) {
    				mDefaultVideoPoster = BitmapFactory.decodeResource(
    						getResources(), R.drawable.default_video_poster);
    		    }
    			return mDefaultVideoPoster;
    		}
    		
    		@Override
    		public View getVideoLoadingProgressView() {
    			//Log.i(LOGTAG, "here in on getVideoLoadingPregressView");
    			
    	        if (mVideoProgressView == null) {
    	            LayoutInflater inflater = LayoutInflater.from(getContext());
    	            mVideoProgressView = inflater.inflate(R.layout.video_loading_progress, null);
    	        }
    	        return mVideoProgressView; 
    		}            

	}
	
	public void pause() {
		try {
			Class.forName("android.webkit.WebView").getMethod("onPause", (Class[]) null).invoke(this, (Object[]) null);
			//pauseTimers();
			//if (mCustomViewCallback != null)
			//	mCustomViewCallback.onCustomViewHidden();  
			
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}
	
	public void resume(){
		try {
			Class.forName("android.webkit.WebView").getMethod("onResume", (Class[]) null).invoke(this, (Object[]) null);
			//resumeTimers();
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}
	
	/*
	private synchronized boolean hideCustomView(){
		if(mPlayingVideo && mPlayingCallback!=null){
			mPlayingVideo = false;
			mPlayingVideoView.stopPlayback();
			if(mUiFrameContent!=null){
				mUiFrameContent.removeView(mPlayingFrame);
			}
			mPlayingCallback.onCustomViewHidden();
			mPlayingVideoView = null;
			mPlayingCallback = null;
			mPlayingFrame = null;
			return true;
		}else{
			return false;
		}
	}*/
	
	/*
    public boolean onBackPressed() {  
          if(mCustomViewContainer != null){ 
               
               mVideoView.stopPlayback();  
               mCustomViewContainer.setVisibility(View.GONE);  
          
               if (mVideoView == null){  
            
                    return true;  
               }else{  
                    
                    // Hide the custom view.  
                    mVideoView.setVisibility(View.GONE);  
                    // Remove the custom view from its container.  
                    mCustomViewContainer.removeView(mVideoView);  
                    mVideoView = null;  
                    mCustomViewContainer.setVisibility(View.GONE);  
                    mCustomViewCallback.onCustomViewHidden();  
                    // Show the content view.  
                    //mContentView.setVisibility(View.VISIBLE);  
                    //setContentView(mContentView);  
                    //mCustomViewContainer = null; 
               }  
          }
          return false; 
    }	*/

    private class GestureListener extends GestureDetector.SimpleOnGestureListener {
        @Override
        public boolean onDoubleTap(MotionEvent e) {
            mPreventAction.set(true);
            mPreventActionTime.set(System.currentTimeMillis());
            return true;
        }
        @Override
        public boolean onDoubleTapEvent(MotionEvent e) {
            mPreventAction.set(true);
            mPreventActionTime.set(System.currentTimeMillis());
            return true;
        }
    }	
	
	public boolean touchDisabled = false;
	
    @Override
    public boolean onTouchEvent(MotionEvent event) {
    
    	if (touchDisabled)
    		return true;
    	
    	if (gestureDetector == null || event == null || mPreventAction == null)
    		return super.onTouchEvent(event);
    	
        int index = (event.getAction() & MotionEvent.ACTION_POINTER_INDEX_MASK) >> MotionEvent.ACTION_POINTER_INDEX_SHIFT;
        int pointId = event.getPointerId(index);

        // just use one(first) finger, prevent double tap with two and more fingers
        if (pointId == 0){
            gestureDetector.onTouchEvent(event);

            if (mPreventAction.get()){
                if (System.currentTimeMillis() - mPreventActionTime.get() > ViewConfiguration.getDoubleTapTimeout()){
                    mPreventAction.set(false);
                } else {
                    return true;
                }
            }

            return super.onTouchEvent(event);
        } else {
            return true;
        }    	

    }
/*
    @Override
    public boolean onTouchEvent(MotionEvent ev) {

    	final int action = ev.getAction();
    	
		// Enable / disable zoom support in case of multiple pointer, e.g. enable zoom when we have two down pointers, disable with one pointer or when pointer up.
		// We do this to prevent the display of zoom controls, which are not useful and override over the right bubble.
		if ((action == MotionEvent.ACTION_DOWN) ||
				(action == MotionEvent.ACTION_POINTER_DOWN) ||
				(action == MotionEvent.ACTION_POINTER_1_DOWN) ||
				(action == MotionEvent.ACTION_POINTER_2_DOWN) ||
				(action == MotionEvent.ACTION_POINTER_3_DOWN)) {
			if (ev.getPointerCount() > 1) {
				this.getSettings().setBuiltInZoomControls(true);
				this.getSettings().setSupportZoom(true);				
			} else {
				this.getSettings().setBuiltInZoomControls(false);
				this.getSettings().setSupportZoom(false);
			}
		} else if ((action == MotionEvent.ACTION_UP) ||
				(action == MotionEvent.ACTION_POINTER_UP) ||
				(action == MotionEvent.ACTION_POINTER_1_UP) ||
				(action == MotionEvent.ACTION_POINTER_2_UP) ||
				(action == MotionEvent.ACTION_POINTER_3_UP)) {
			this.getSettings().setBuiltInZoomControls(false);
			this.getSettings().setSupportZoom(false);			
		}    	
    	
        long eventTime = ev.getEventTime();
        //int action = ev.getAction();

        switch (action){
            case MotionEvent.ACTION_MOVE: {
                if ((eventTime - lastMoveEventTime) > eventTimeInterval){
                    lastMoveEventTime = eventTime;
                    return super.onTouchEvent(ev);
                }
                break;
            }
            case MotionEvent.ACTION_DOWN:
            case MotionEvent.ACTION_UP: {
                return super.onTouchEvent(ev);
            }
        }
        return true;
    }*/
    /*
    @Override
    public void invalidate()
    {
    	Log.i(TAG, "invalidate");
    	super.invalidate();
    }
    */
    
    @Override
    protected void onDraw(Canvas canvas) {
    	if (!appDeck.isLowSystem)
    		invalidate();
    	super.onDraw(canvas);
    }
	
	/*
    @Override
    protected void onScrollChanged(final int l, final int t, final int oldl, final int oldt)
    {
        super.onScrollChanged(l, t, oldl, oldt);
        
    }*/
    
    
    private Handler handler=new Handler(); // you might already have a handler
    private Runnable mInvalidater=new Runnable() {

        @Override
        public void run() {
            SmartWebView.this.invalidate();
            // force inject of appdeck.js if needed
            //SmartWebView.this.loadUrl(appdeck_inject_js);

        }

    };
    
    public void invalidateHack(int delay)
    {
    	handler.postDelayed(mInvalidater, delay);
        handler.postDelayed(mInvalidater, 2*delay); // just in case
        handler.postDelayed(mInvalidater, 4*delay);     	
    }
    
    public void copyScrollTo(SmartWebView target)
    {
    	computeScroll();
    	int x = computeHorizontalScrollOffset();
    	int y = computeVerticalScrollOffset();
    	//target.shouldSrollTo(x, y);
    	target.scrollTo(x, y);
    }
    
/*    protected void onLayout(boolean changed, int l, int t, int r, int b) {
    	 // set initial scroll to
    	 scrollTo(0,403);
    	 super.onLayout(changed, l, t, r, b);
    	 }*/    
    
    private int shouldSrollToX = -1;
    private int shouldSrollToY = -1;
    
    public void shouldSrollTo(int x, int y)
    {
    	shouldSrollToX = x;
    	shouldSrollToY = y;
    }
    
    boolean onNewPictureCalled = false;
    
    class MyPictureListener implements PictureListener {

        @Override
        public void onNewPicture(WebView view, Picture arg1)
        {
        	// put code here that needs to run when the page has finished loading and
        	// a new "picture" is on the webview.      

        	if (shouldSrollToX != -1 && shouldSrollToX != -1)
        	{
        		view.scrollTo(shouldSrollToX, shouldSrollToY);
        		shouldSrollToX = -1;
        		shouldSrollToY = -1;
        	}
        	
        	if (onNewPictureCalled == false)
        	{
        		root.progressSet(view, 101);
        		onNewPictureCalled = true;
        	}
        	//root.webviewIsReady(this);
        	
        }    
    }
    
    public void sendJsEvent(String eventName, String eventDetailJSon)
    {
    	String js = null;
    	if (false && Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
    	{
    		js = "document.dispatchEvent(new CustomEvent('"+eventName+"', "+eventDetailJSon+"));";
    	} else {
    		js = "var evt = document.createEvent('Event');evt.initEvent('"+eventName+"',true,true); evt.detail = "+eventDetailJSon+"; document.dispatchEvent(evt);";	        
    	}
    	loadUrl("javascript:"+js);
    }
    
    int page_height = -1;
    long lastScrollToBottomEventTime = -1;
    int lastScrollToBottomEventContentHeight = -1;
    private int scrollToBottomEventTimeInterval = 500;
    
    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt)
    {
    	super.onScrollChanged(l, t, oldl, oldt);
    	int content_height = (int)(getContentHeight() * getScale());
    	int content_height_limit = content_height - page_height - page_height / 2;
    	if (true)
    	{
    		if (t > content_height_limit && content_height_limit > 0)
    		{
    			long scrollToBottomEventTime = System.currentTimeMillis();
    			long scrollEventTimeDiff = scrollToBottomEventTime - lastScrollToBottomEventTime; 
    			
    			 if (scrollEventTimeDiff > scrollToBottomEventTimeInterval && lastScrollToBottomEventContentHeight != content_height)
    			 {
    				 lastScrollToBottomEventTime = scrollToBottomEventTime;
    				 lastScrollToBottomEventContentHeight = content_height;
    				 sendJsEvent("scrollToBottom", "null");
                 }
    		}
    	}
    }

    @Override
    protected void onSizeChanged (int w, int h, int ow, int oh)
    {
    	super.onSizeChanged(w, h, ow, oh);
    	page_height = h;
    }
    
    @Override
    public WebBackForwardList saveState(Bundle outState) {
    	outState.putString("url", url);
    	return super.saveState(outState);
    }
    
    @Override
    public WebBackForwardList restoreState(Bundle inState) {
    	url = inState.getString("url");
    	uri = Uri.parse(url);
    	//appDeck = AppDeck.getInstance();
    	return super.restoreState(inState);
    }
    
	public boolean apiCall(final AppDeckApiCall call)
	{
		if (call.command.equalsIgnoreCase("disable_catch_link"))
		{
			Log.i("API", uri.getPath()+" **DISABLE CATCH LINK**");
			
			boolean value = call.input.getBoolean("param");
			((SmartWebView)call.smartWebView).catchLink = value;
			
			return true;
		}
		
		
		if (root != null)
			return root.apiCall(call);
		else
			return false;
	}
    
}
