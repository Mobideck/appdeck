package com.mobideck.appdeck;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

import com.mobideck.appdeck.R;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Picture;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.webkit.CookieSyncManager;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.WebBackForwardList;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebSettings.LayoutAlgorithm;
import android.webkit.WebSettings.ZoomDensity;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient.CustomViewCallback;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebSettings.RenderPriority;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

public class WebBrowserWebView extends WebView {

	AppDeck appDeck;
	public AppDeckFragment root;
	
	private View								mCustomView;
	private FrameLayout							mCustomViewContainer;
	private WebChromeClient.CustomViewCallback 	mCustomViewCallback;
	   
	
	public WebBrowserWebView(AppDeckFragment root) {
		//super(page.getBaseContext());
		super(root.loader);
		this.root = root;
		appDeck = AppDeck.getInstance();
		configureWebView();        
        //addJavascriptInterface(new PageJSInterface(root.getActivity()), "appdeck");        
        setWebViewClient(new WebBrowserWebViewClient());
        setWebChromeClient(new WebBrowserWebChromeClient());
	}
	
	@Override
	public void loadUrl(String url) {
		super.loadUrl(url);
	}
	
	@Override
	public void loadDataWithBaseURL(String baseUrl, String data,
			String mimeType, String encoding, String historyUrl) {
		super.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
	}
	
	
	@SuppressWarnings("deprecation")
	@SuppressLint("SetJavaScriptEnabled")
	private void configureWebView()
	{
		setPersistentDrawingCache(ViewGroup.PERSISTENT_SCROLLING_CACHE);
		
        WebSettings webSettings = getSettings();
        webSettings.setJavaScriptEnabled(true);

        File cachePath = new File(Environment.getExternalStorageDirectory(), ".appdeck");
        cachePath.mkdirs();
        
		String ua = webSettings.getUserAgentString();
		webSettings.setUserAgentString(ua + " AppDeckBrowser "+appDeck.packageName+"/"+appDeck.config.app_version);        
        
        webSettings.setGeolocationEnabled(true);
        webSettings.setJavaScriptEnabled(true);
        webSettings.setLightTouchEnabled(false);
        //webSettings.setNavDump(false);
        webSettings.setDefaultTextEncodingName(null);
        webSettings.setDefaultZoom(ZoomDensity.valueOf("MEDIUM"));
        webSettings.setMinimumFontSize(5);
        webSettings.setMinimumLogicalFontSize(5);
        webSettings.setPluginState(PluginState.valueOf("ON"));
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH)
	    {
			webSettings.setTextZoom(100);
	    }
        webSettings.setLayoutAlgorithm(LayoutAlgorithm.NORMAL);
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setLoadsImagesAutomatically(true);
        webSettings.setLoadWithOverviewMode(true);
        webSettings.setSavePassword(true);
        webSettings.setSaveFormData(true);
        webSettings.setUseWideViewPort(true);

        
        /*String ua = mCustomUserAgents.get(settings);
        if (ua != null) {
            settings.setUserAgentString(ua);
        } else {
            settings.setUserAgentString(USER_AGENTS[getUserAgent()]);
        }

        if (!(settings instanceof WebSettingsClassic)) return;

        WebSettingsClassic settingsClassic = (WebSettingsClassic) settings;
        settingsClassic.setHardwareAccelSkiaEnabled(isSkiaHardwareAccelerated());
        settingsClassic.setShowVisualIndicator(enableVisualIndicator());
        settingsClassic.setForceUserScalable(forceEnableUserScalable());
        settingsClassic.setDoubleTapZoom(getDoubleTapZoom());
        settingsClassic.setAutoFillEnabled(isAutofillEnabled());
        settingsClassic.setAutoFillProfile(getAutoFillProfile());

        boolean useInverted = useInvertedRendering();
        settingsClassic.setProperty(WebViewProperties.gfxInvertedScreen,
                useInverted ? "true" : "false");
        if (useInverted) {
          settingsClassic.setProperty(WebViewProperties.gfxInvertedScreenContrast,
                    Float.toString(getInvertedContrast()));
        }

        if (isDebugEnabled()) {
          settingsClassic.setProperty(WebViewProperties.gfxEnableCpuUploadPath,
                    enableCpuUploadPath() ? "true" : "false");
        }

        settingsClassic.setLinkPrefetchEnabled(mLinkPrefetchAllowed);     */   
        
        
        
        webSettings.setDefaultFontSize(16);
        webSettings.setDefaultFixedFontSize(13);

        // WebView inside Browser doesn't want initial focus to be set.
        webSettings.setNeedInitialFocus(false);
        // enable smooth transition for better performance during panning or
        // zooming
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
	    {
			webSettings.setEnableSmoothTransition(true);
			webSettings.setAllowContentAccess(false);
	    }
        // disable content url access
        

        // HTML5 API flags
        webSettings.setAppCacheEnabled(true);
        webSettings.setDatabaseEnabled(true);
        webSettings.setDomStorageEnabled(true);

        // HTML5 configuration parametersettings.

        webSettings.setDatabasePath(root.loader.getBaseContext().getDir("databases", Context.MODE_PRIVATE).getPath());
        webSettings.setGeolocationEnabled(true);
        webSettings.setGeolocationDatabasePath(root.loader.getBaseContext().getDir("databases", Context.MODE_PRIVATE).getPath());
        
        // origin policy for file access
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
	    {
			webSettings.setAllowUniversalAccessFromFileURLs(false);
			webSettings.setAllowFileAccessFromFileURLs(false);
	    }

/*        if (!(webSettings instanceof WebSettingsClassic)) return;

        WebSettingsClassic settingsClassic = (WebSettingsClassic) settings;
        webSettings.setPageCacheCapacity(7);
        // WebView should be preserving the memory as much as possible.
        // However, apps like browser wish to turn on the performance mode which
        // would require more memory.
        // TODO: We need to dynamically allocate/deallocate temporary memory for
        // apps which are trying to use minimal memory. Currently, double
        // buffering is always turned on, which is unnecessary.
        settingsClassic.setProperty(WebViewProperties.gfxUseMinimalMemory, "false");
        settingsClassic.setWorkersEnabled(true);  // This only affects V8.      */ 
        
        
        
        webSettings.setAppCacheEnabled(true);
        webSettings.setAppCachePath(cachePath.getAbsolutePath());
        webSettings.setAppCacheMaxSize(Long.MAX_VALUE);
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDatabaseEnabled(true);
        webSettings.setDomStorageEnabled(true);
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
		//setMapTrackballToArrowKeys(false); // use trackball directly
		webSettings.setSupportZoom(true);
		//webSettings.setSupportZoom(false);
        final PackageManager pm = root.loader.getPackageManager();
        boolean supportsMultiTouch =
                pm.hasSystemFeature(PackageManager.FEATURE_TOUCHSCREEN_MULTITOUCH)
                || pm.hasSystemFeature(PackageManager.FEATURE_FAKETOUCH_MULTITOUCH_DISTINCT);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
	    {
			webSettings.setDisplayZoomControls(!supportsMultiTouch);
	    }
		//webSettings.setBuiltInZoomControls(true);
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
		setInitialScale(1);
		setPadding(0, 0, 0, 0);
        //pageWebView.setInitialScale(getScale());
        //webSettings.setLoadWithOverviewMode(true);
        //webSettings.setUseWideViewPort(true);
        // fit the width of screen
        // webSettings.setLayoutAlgorithm(LayoutAlgorithm.NARROW_COLUMNS); 
        
        webSettings.setDefaultZoom(WebSettings.ZoomDensity.FAR);
        //webview.setLayerType(WebView.LAYER_TYPE_HARDWARE, null);
        
        
        if (appDeck.noCache)
        {
        	webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        	webSettings.setAppCacheEnabled(false);
        	webSettings.setAppCacheMaxSize(0);
        }
        
	}
	
	public class WebBrowserWebViewClient extends WebViewClient {

		
		public WebBrowserWebViewClient() {
			
		}
		
	      /**
	       * it will always be call.
	       */
		@Override
	      public void onPageStarted(WebView view, String url, Bitmap favicon) { 
	      }		
		
		//@Override
		public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg)
		{
			return true;
		}
	      
	    @Override
	    public boolean shouldOverrideUrlLoading(WebView view, String url) {

	    	
	    	return false;
	    }
	    
	    @Override
	    public WebResourceResponse shouldInterceptRequest(final WebView view, String absoluteURL) {
	    	
	    	if (appDeck.noCache)
	    		return null;
	    		    	
	    	if (true)
	    		return null;
	    	
	    	// resource is in embed resources
	    	WebResourceResponse response = appDeck.cache.getEmbedResource(absoluteURL);
	    	if (response != null)
	    		return response;
	    	
	    	// resources is in httpcache
	    	if (appDeck.cache.shouldCache(absoluteURL))
	    	{
	    		response = appDeck.cache.getEmbedResource(absoluteURL);
	    		if (response != null)
	    			return response;
	    	}
	    	
	    	return null;
	    }	    
	    
	    
        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            Log.i("SmartWebView", "**onPageFinished**");
            // force inject of appdeck.js if needed
            //String js = "javascript:if (typeof(appDeckAPICall)  === 'undefined') { var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://testapp.appdeck.mobi/appdeck.js'; document.getElementsByTagName('head')[0].appendChild(scr); }";
            //view.loadUrl(js);
            
            WebBrowserWebView.this.invalidateHack(100);
            
            root.progressStop(view);
            
            CookieSyncManager.getInstance().sync();
                        
        }
        
        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl)
        {
        	Toast.makeText(getContext(), "" + failingUrl+ ": " +description, Toast.LENGTH_LONG);
        }        
        
//        private static final String LOG_TAG = "NoZoomedWebViewClient";
//        private static final long STABLE_SCALE_CALCULATION_DURATION = 2 * 1000;
//
//        private long   stableScaleCalculationStart;
//        private String stableScale = "";  // Avoid comparing floats
//        private long   restoringScaleStart;
//
//
//        @Override
//        public void onScaleChanged(final WebView view, float oldScale, float newScale) {
//            Log.d(LOG_TAG, "onScaleChanged: " + oldScale + " -> " + newScale);
//
//            if (view != null) {
//                view.invalidate();
//            }            
//            
//            long now = System.currentTimeMillis();
//            boolean calculating = (now - stableScaleCalculationStart) < STABLE_SCALE_CALCULATION_DURATION;
//            if (calculating) {
//                stableScale = "" + newScale;
//            } else if (!stableScale.equals("" + newScale)) {
//                boolean zooming = (now - restoringScaleStart) < STABLE_SCALE_CALCULATION_DURATION;
//                if (!zooming) {
//                    Log.d(LOG_TAG, "Zoom out to stableScale: " + stableScale);
//                    restoringScaleStart = now;
//                    view.zoomOut();
//
//                    // Just to make sure, do it one more time
//                    view.postDelayed(new Runnable() {
//                        @Override
//                        public void run() {
//                            view.zoomOut();
//                        }
//                    }, STABLE_SCALE_CALCULATION_DURATION);
//                }
//            }
//        }        
		
	}
	
	public class WebBrowserWebChromeClient extends WebChromeClient /*implements OnCompletionListener, OnErrorListener*/ {
		
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
        {/*
			if (message.startsWith("appdeckapi:") == true)
			{
				AppDeckApiCall call = new AppDeckApiCall(message.substring(11), defaultValue, result);
				call.webview = view;
				call.appDeckFragment = root;
				Boolean res = root.apiCall(call);
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
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}
	
	public void resume(){
		try {
			Class.forName("android.webkit.WebView").getMethod("onResume", (Class[]) null).invoke(this, (Object[]) null);
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}

    @Override
    public boolean onTouchEvent(MotionEvent event) {

       return super.onTouchEvent(event);

    }
    
    @Override
    protected void onDraw(Canvas canvas) {
    	if (!appDeck.isLowSystem)
    		invalidate();
    	super.onDraw(canvas);
    }
	
    private Handler handler=new Handler(); // you might already have a handler
    private Runnable mInvalidater=new Runnable() {

        @Override
        public void run() {
        	WebBrowserWebView.this.invalidate();
        }

    };
    
    public void invalidateHack(int delay)
    {
    	handler.postDelayed(mInvalidater, delay);
        handler.postDelayed(mInvalidater, 2*delay); // just in case
        handler.postDelayed(mInvalidater, 4*delay);     	
    }
    
    @Override
    public WebBackForwardList saveState(Bundle outState) {
    	return super.saveState(outState);
    }
    
    @Override
    public WebBackForwardList restoreState(Bundle inState) {
    	return super.restoreState(inState);
    }
	
	
}
