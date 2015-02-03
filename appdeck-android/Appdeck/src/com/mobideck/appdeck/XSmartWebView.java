package com.mobideck.appdeck;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URISyntaxException;

import org.xwalk.core.XWalkJavascriptResult;
import org.xwalk.core.XWalkResourceClient;
import org.xwalk.core.XWalkUIClient;
import org.xwalk.core.XWalkView;
import org.xwalk.core.internal.XWalkSettings;
import org.xwalk.core.internal.XWalkViewBridge;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Application;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Proxy;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Parcelable;
import android.util.ArrayMap;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class XSmartWebView extends XWalkView {
		
	static String TAG = "XSmartWebView";
	
	static String appdeck_inject_js = "javascript:if (typeof(appDeckAPICall)  === 'undefined') { appDeckAPICall = ''; var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/fastclick.js'; document.getElementsByTagName('head')[0].appendChild(scr); var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/appdeck_1.10.js'; document.getElementsByTagName('head')[0].appendChild(scr);}";	
	
	static boolean prioritySet = false;
	
	AppDeck appDeck;
	public AppDeckFragment root;
	String url;
	Uri uri;
		
	private String cookie;	
	
	private String userAgent = null;
	
	private boolean firstLoad = true; 

//	private boolean initialized = false;
	
	public boolean shouldLoadFromCache = false;
	
    public boolean catchLink = true;
		   
	public XSmartWebView(AppDeckFragment root) {
		super(root.loader, root.loader);
		this.root = root;
		appDeck = AppDeck.getInstance();
		//evaluateJavascript("document.head.innerHTML = document.body.innerHTML = '';", null);
		configureWebView();
		setResourceClient(new XSmartResourceClient(this));
		setUIClient(new XSmartUIClient(this));
	}
	
	public void unloadPage()
	{
		evaluateJavascript("document.head.innerHTML = document.body.innerHTML = '';", null);		
	}
	
	public void clean()
	{
		super.load("", "<!DOCTYPE html><html><head><title></title></head><body></body></html>");
		onDestroy();
	}
	
	public void reload()
	{
		//this.reload(RELOAD_NORMAL);
		loadUrl(url);
	}
	
	public void loadUrl(String url)
	{
		if (url.startsWith("javascript:") == false && url.startsWith("data:") == false)
		{
			Log.i(TAG, "loadUrl: "+url);
			CookieManager cookieManager = CookieManager.getInstance();
			if (cookieManager != null)
				cookie = cookieManager.getCookie(url);
			else
				cookie = null;			
			this.url = url;
			uri = Uri.parse(url);
			firstLoad = true;
		}
		super.load(url, null);
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

	private void setWebViewUserAgent(XWalkView webView, String userAgent)
	{
	    try
	    {
	        Method ___getBridge = XWalkView.class.getDeclaredMethod("getBridge");
	        ___getBridge.setAccessible(true);
	        XWalkViewBridge xWalkViewBridge = null;
	        xWalkViewBridge = (XWalkViewBridge)___getBridge.invoke(webView);
	        XWalkSettings xWalkSettings = xWalkViewBridge.getSettings();
	        xWalkSettings.setUserAgentString(userAgent);
	    }
	    catch (Exception e)
	    {
	        // Could not set user agent
	        e.printStackTrace();
	    }
	}	

	private String getWebViewUserAgent(XWalkView webView)
	{
	    try
	    {
	        Method ___getBridge = XWalkView.class.getDeclaredMethod("getBridge");
	        ___getBridge.setAccessible(true);
	        XWalkViewBridge xWalkViewBridge = null;
	        xWalkViewBridge = (XWalkViewBridge)___getBridge.invoke(webView);
	        XWalkSettings xWalkSettings = xWalkViewBridge.getSettings();
	        return xWalkSettings.getUserAgentString();
	    }
	    catch (Exception e)
	    {
	        // Could not set user agent
	        e.printStackTrace();
	    }
	    return "";
	}	
	
	
	
	@SuppressWarnings("deprecation")
	@SuppressLint("SetJavaScriptEnabled")
	private void configureWebView()
	{
		setLayerType(View.LAYER_TYPE_HARDWARE, null);
		
		//XWalkPreferences.setValue(XWalkPreferences.ANIMATABLE_XWALK_VIEW, true);
						
		CookieManager.getInstance().setAcceptCookie(true);
		
		setAnimationCacheEnabled(true);
		setDrawingCacheEnabled(true);
		
		userAgent = getWebViewUserAgent(this);
//		userAgent = userAgent + " AppDeck "+appDeck.packageName+"/"+appDeck.config.app_version;
		userAgent = userAgent + " AppDeck"+(appDeck.isTablet? "-tablet" : "-phone" )+" "+appDeck.packageName+"/"+appDeck.config.app_version;
		setWebViewUserAgent(this, userAgent);
		
		
/*		
		//setPersistentDrawingCache(ViewGroup.PERSISTENT_SCROLLING_CACHE);

        XWalkSettings webSettings = getSettings();
        webSettings.setJavaScriptEnabled(true);

		String ua = webSettings.getUserAgentString();
		webSettings.setUserAgentString(ua + " AppDeck "+appDeck.packageName+"/"+appDeck.config.app_version);
        
        String databasePath = root.loader.getBaseContext().getDir("databases", Context.MODE_PRIVATE).getPath();
        //webSettings.setDatabasePath(databasePath);
        //webSettings.setGeolocationDatabasePath(databasePath);

        File cachePath = new File(Environment.getExternalStorageDirectory(), ".appdeck");
        cachePath.mkdirs();        
        
        webSettings.setAppCacheEnabled(true);
        webSettings.setAppCachePath(cachePath.getAbsolutePath());
        Log.i(TAG, "appCache:"+cachePath.getAbsolutePath().toString());
        //webSettings.setAppCacheMaxSize(Long.MAX_VALUE);
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setDatabaseEnabled(true);
        //webSettings.setPluginState(PluginState.ON);
        //webSettings.setRenderPriority(RenderPriority.HIGH);
		setHorizontalScrollBarEnabled(false);
        
		
		webSettings.setSupportMultipleWindows(true);
		setLongClickable(true);
		setDrawingCacheEnabled(true);
		
	    // Initialize the WebView
		//webSettings.setSupportZoom(false);
		//webSettings.setBuiltInZoomControls(false);
		setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
		setScrollbarFadingEnabled(true);
		webSettings.setLoadsImagesAutomatically(true);		

        //setPictureListener(new MyPictureListener());
        
        if (appDeck.noCache)
        {
        	webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        	webSettings.setAppCacheEnabled(false);
        	clearCache(true);
        	//webSettings.setAppCacheMaxSize(0);
        }

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true);
        }*/        
        
		try {
			XSmartWebView.setProxyKK(this, root.loader.proxyHost, root.loader.proxyPort, Application.class.getCanonicalName());
			//WebkitProxy2.setProxy(this, root.loader.proxyHost, root.loader.proxyPort, Application.class.getCanonicalName());
		} catch (Exception e) {
			e.printStackTrace();
		}        
	}
	
	// from https://stackoverflow.com/questions/19979578/android-webview-set-proxy-programatically-kitkat
	@SuppressLint("NewApi")
	@SuppressWarnings("all")
	private static boolean setProxyKK(XWalkView webView, String host, int port, String applicationClassName) {
	    Log.d(TAG, "Setting proxy with >= 4.4 API.");

	    Context appContext = webView.getContext().getApplicationContext();
	    System.setProperty("http.proxyHost", host);
	    System.setProperty("http.proxyPort", port + "");
	    System.setProperty("https.proxyHost", host);
	    System.setProperty("https.proxyPort", port + "");
	    try {
	        Class applictionCls = Class.forName(applicationClassName);
	        Field loadedApkField = applictionCls.getField("mLoadedApk");
	        loadedApkField.setAccessible(true);
	        Object loadedApk = loadedApkField.get(appContext);
	        Class loadedApkCls = Class.forName("android.app.LoadedApk");
	        Field receiversField = loadedApkCls.getDeclaredField("mReceivers");
	        receiversField.setAccessible(true);
	        ArrayMap receivers = (ArrayMap) receiversField.get(loadedApk);
	        for (Object receiverMap : receivers.values()) {
	            for (Object rec : ((ArrayMap) receiverMap).keySet()) {
	                Class clazz = rec.getClass();
	                if (clazz.getName().contains("ProxyChangeListener")) {
	                    Method onReceiveMethod = clazz.getDeclaredMethod("onReceive", Context.class, Intent.class);
	                    Intent intent = new Intent(Proxy.PROXY_CHANGE_ACTION);

	                    // *********** optional, may be need in future ************
	                    final String CLASS_NAME = "android.net.ProxyProperties";
	                    Class cls = Class.forName(CLASS_NAME);
	                    Constructor constructor = cls.getConstructor(String.class, Integer.TYPE, String.class);
	                    constructor.setAccessible(true);
	                    Object proxyProperties = constructor.newInstance(host, port, null);
	                    intent.putExtra("proxy", (Parcelable) proxyProperties);
	                    // *********** optional, may be need in future *************

	                    onReceiveMethod.invoke(rec, appContext, intent);
	                }
	            }
	        }

	        Log.d(TAG, "Setting proxy with >= 4.4 API successful!");
	        return true;
	    } catch (ClassNotFoundException e) {
	        StringWriter sw = new StringWriter();
	        e.printStackTrace(new PrintWriter(sw));
	        String exceptionAsString = sw.toString();
	        Log.v(TAG, e.getMessage());
	        Log.v(TAG, exceptionAsString);
	    } catch (NoSuchFieldException e) {
	        StringWriter sw = new StringWriter();
	        e.printStackTrace(new PrintWriter(sw));
	        String exceptionAsString = sw.toString();
	        Log.v(TAG, e.getMessage());
	        Log.v(TAG, exceptionAsString);
	    } catch (IllegalAccessException e) {
	        StringWriter sw = new StringWriter();
	        e.printStackTrace(new PrintWriter(sw));
	        String exceptionAsString = sw.toString();
	        Log.v(TAG, e.getMessage());
	        Log.v(TAG, exceptionAsString);
	    } catch (IllegalArgumentException e) {
	        StringWriter sw = new StringWriter();
	        e.printStackTrace(new PrintWriter(sw));
	        String exceptionAsString = sw.toString();
	        Log.v(TAG, e.getMessage());
	        Log.v(TAG, exceptionAsString);
	    } catch (NoSuchMethodException e) {
	        StringWriter sw = new StringWriter();
	        e.printStackTrace(new PrintWriter(sw));
	        String exceptionAsString = sw.toString();
	        Log.v(TAG, e.getMessage());
	        Log.v(TAG, exceptionAsString);
	    } catch (InvocationTargetException e) {
	        StringWriter sw = new StringWriter();
	        e.printStackTrace(new PrintWriter(sw));
	        String exceptionAsString = sw.toString();
	        Log.v(TAG, e.getMessage());
	        Log.v(TAG, exceptionAsString);
	    } catch (InstantiationException e) {
	        StringWriter sw = new StringWriter();
	        e.printStackTrace(new PrintWriter(sw));
	        String exceptionAsString = sw.toString();
	        Log.v(TAG, e.getMessage());
	        Log.v(TAG, exceptionAsString);
	    }
	    return false;
	}	
	
	public void setForceCache(boolean forceCache)
	{
		shouldLoadFromCache = forceCache;
		
		if (shouldLoadFromCache == false)
		{
			setWebViewUserAgent(this, userAgent);
			//getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
		} else {
			setWebViewUserAgent(this, userAgent+" FORCE_CACHE");
			//getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
		}		
	}
	
	private void checkLoading()
	{
		/*if (loadingDone)
		{
			Log.e(TAG, "checkLoading call twice ...");
			return;
		}*/
        String jsTestIfOK = "(document.body.innerHTML.indexOf('Bad Gateway') == 0 || document.body.innerHTML.indexOf('Gateway Timeout') == 0 || document.body.innerHTML.length == 0 ? 'ko' : document.body.innerHTML)";
        
        evaluateJavascript(jsTestIfOK, new android.webkit.ValueCallback<java.lang.String> () {

			@Override
			public void onReceiveValue(String value) {
		
				Log.i(TAG, "**onLoadFinished status:"+value+" **");
				
				// loading of webview was OK
				if (value != null && !value.equalsIgnoreCase("\"ko\""))
				{
					loadingSuccess();
				} else {
					// or not
					loadingFailed(500, value);						
				}
			}
		}); 		
	}
	
	private void loadingSuccess()
	{
		//loadingDone = true;
		root.progressSet(this,  100);
		// force inject of appdeck.js if needed
        load(appdeck_inject_js, null);            
        
        root.progressStop(this);
        
        CookieSyncManager.getInstance().sync();
        
        String c = CookieManager.getInstance().getCookie(url);
        Log.i(TAG, "Cookie: "+c);
		
	}
	
	private void loadingFailed(int errorCode, String description)
	{
		//loadingDone = true;
		root.progressFailed(this);
/*		Toast.makeText(getContext(), "Error: " + url + ": " + errorCode + ": " + description, Toast.LENGTH_LONG).show();
		setVisibility(View.INVISIBLE);*/
	}
	
	public class XSmartResourceClient extends XWalkResourceClient {

		
		public XSmartResourceClient(XWalkView view) {
			super(view); 
			//stableScaleCalculationStart = System.currentTimeMillis();
		}
		
		private int lastProgressInPercent = -1;
		
        @Override
        public void onProgressChanged(XWalkView view, int progressInPercent) {
        	if (view != XSmartWebView.this)
        	{
        		Log.e(TAG, "not the right one ...");
        		return;
        	}
        	if (progressInPercent == lastProgressInPercent)
        		return;
        	lastProgressInPercent = progressInPercent;
            //page.setSupportProgressBarIndeterminateVisibility(false);
            if (progressInPercent == 100)
            {
            	checkLoading();
            } else {
            	root.progressSet(view, progressInPercent);
            }
        }		
		
	    //it will always be call.
		@Override
	      public void onLoadStarted(XWalkView view, String url) {
	    	  /*if (firstLoad)
	    	  {
	    		  firstLoad = false;
	    		  return;
	    	  }
	    	  Log.i(TAG, "OnLoadStarted (not firstLoad) :"+url);*/
	      }		
			      
	    @Override
	    public boolean shouldOverrideUrlLoading(XWalkView view, String url) {

	    	// this is a form ?
	    	if (url.indexOf("_appdeck_is_form=1") != -1)
	    		return false;
	    	
	    	  if (firstLoad)
	    	  {
	    		  Log.i(TAG, "shouldOverrideUrlLoading (firstload) :"+url);
	    		  firstLoad = false;
	    		  return false;
	    	  }	    	
	    	
	    	  Log.i(TAG, "shouldOverrideUrlLoading (not firstLoad) :"+url);
	    	  
	    	if (catchLink == false)
	    		return false;
	    	
/*	    	if (XSmartWebView.this.url == url)
	    		return false;
	    	
	    	if (true)
	    		return false;*/
	    	
	    	root.loadUrl(url);
	    	return true;
	    }
	    
	    
	    @Override
	    public WebResourceResponse shouldInterceptLoadRequest(XWalkView view, String absoluteURL) {
	    	
	    	if (absoluteURL.indexOf("data:") == 0)
	    		return null;

	    	if (absoluteURL.indexOf("_appdeck_is_form") != -1)
	    		return null;
	    	
	    	if (appDeck.noCache)
	    		return null;
	    	
	    	if (true)
	    		return null;
	    	
	    	// resource is in embed resources
	    	WebResourceResponse response = appDeck.cache.getEmbedResource(absoluteURL);
	    	if (response != null)
	    	{
	    		Log.i(TAG, "FROM EMBED: "+absoluteURL);
	    		return response;
	    	}

	    	if (true)
	    		return null;
	    	
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
        public void onLoadFinished(XWalkView view, String url) {
            //super.onPageFinished(view, url);
            Log.i(TAG, "**onLoadFinished "+url+"**");
            
            //checkLoading();
                        
        }
        
        @Override
        public void onReceivedLoadError(XWalkView view, int errorCode, String description, String failingUrl)
        {
        	Log.i(TAG, "**onReceivedLoadError "+failingUrl+": "+errorCode+": "+description+" **");
/*
        	// this is the main url that is falling
        	if (failingUrl.equalsIgnoreCase(url) && shouldLoadFromCache == true)
        	{
        		loadingFailed(errorCode, description);
        	}
        	else
        	{
        		Toast.makeText(getContext(), "" + failingUrl+ ": ("+url+") " +description, Toast.LENGTH_LONG).show();
        	}
*/
        }
        
	}
        
        	
	public class XSmartUIClient  extends XWalkUIClient {
		
		private Bitmap 		mDefaultVideoPoster;
		private View 		mVideoProgressView;
		
		XSmartUIClient(XWalkView view)
		{
			super(view);
		}
		
		@Override
		public boolean onJavascriptModalDialog(XWalkView view,
                XWalkUIClient.JavascriptMessageType type,
                java.lang.String url,
                java.lang.String message,
                java.lang.String defaultValue,
                final XWalkJavascriptResult result)
		{
			if (message.startsWith("appdeckapi:") == true)
			{
				AppDeckApiCall call = new AppDeckApiCall(message.substring(11), defaultValue, result);
				call.webview = view;
				call.smartWebView = XSmartWebView.this;
				call.appDeckFragment = root;
				Boolean res = apiCall(call); //root.apiCall(call);
				call.sendResult(res);
				return true;
			}        	
            final LayoutInflater factory = LayoutInflater.from(root.loader);
            final View v = factory.inflate(R.layout.javascript_prompt_dialog, null);
            ((TextView)v.findViewById(R.id.prompt_message_text)).setText(message);
            //((EditText)v.findViewById(R.id.prompt_input_field)).setText(defaultValue);

            new AlertDialog.Builder(root.loader)
                .setTitle("javaScript dialog")
                .setView(v)
                .setPositiveButton(android.R.string.ok,
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int whichButton) {
                                //String value = ((EditText)v.findViewById(R.id.prompt_input_field)).getText()
                                //        .toString();
                                //result.confirmWithResult(value);
                            	result.confirm();
                            }
                        })
                .setNegativeButton(android.R.string.cancel,
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int whichButton) {
                                result.confirm();
                            }
                        })
                .setOnCancelListener(
                        new DialogInterface.OnCancelListener() {
                            public void onCancel(DialogInterface dialog) {
                                result.confirm();
                            }
                        })
                .show();
            
            return true;

		}
		// TODO: import code from SmartWebView
	}
	
	public void pause() {
		Log.i(TAG, "hide: "+this.url);
		this.onHide();
	}
	
	public void resume() {
		Log.i(TAG, "show: "+this.url);
		this.onShow();
	}

	public boolean touchDisabled = false;

	@Override
    public boolean onTouchEvent(MotionEvent event) {
    
    	if (touchDisabled)
    		return true;
    
    	return super.onTouchEvent(event);
    	
    }
        
    public void copyScrollTo(XSmartWebView target)
    {
    	computeScroll();
    	int x = computeHorizontalScrollOffset();
    	int y = computeVerticalScrollOffset();
    	target.scrollTo(x, y);
    }

    public void sendJsEvent(String eventName, String eventDetailJSon)
    {
    	String js = null;
    	//if (false && Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
    	//{
    	//	js = "document.dispatchEvent(new CustomEvent('"+eventName+"', "+eventDetailJSon+"));";
    	//} else {
    		js = "var evt = document.createEvent('Event');evt.initEvent('"+eventName+"',true,true); evt.detail = "+eventDetailJSon+"; document.dispatchEvent(evt);";	        
    	//}
    	loadUrl("javascript:"+js);
    }

    public boolean apiCall(final AppDeckApiCall call)
	{
		if (call.command.equalsIgnoreCase("disable_catch_link"))
		{
			Log.i("API", uri.getPath()+" **DISABLE CATCH LINK**");
			
			boolean value = call.input.getBoolean("param");
			((XSmartWebView)call.smartWebView).catchLink = value;
			
			return true;
		}
		
		if (root != null)
			return root.apiCall(call);
		else
			return false;
	}
    
    int currentScrollY = 0;
    boolean getScrollY = false;
    
    // this help refreshSwipe to know if he need to show refresh or not
    @Override
    public boolean canScrollVertically(int direction) {
    	
    	if (getScrollY == false)
    	{
    		getScrollY = true;
    		this.evaluateJavascript("window.pageYOffset", new android.webkit.ValueCallback<java.lang.String> () {

				@Override
				public void onReceiveValue(String value) {
					if (value != null)
						currentScrollY = Integer.parseInt(value);
					getScrollY = false;
				}
    			
    		});    				
    	}    	
    	//Log.i(TAG, "canScrollVertically: direction:" + direction + " currentScrollY: "+ currentScrollY+" getScrollY:"+getScrollY);
   	
    	if (direction == -1 && currentScrollY <= 0)
    		return false;
    	if (direction == -1 && currentScrollY > 0)
    		return true;
    	
    	return super.canScrollVertically(direction);
    }
    
}
