package com.mobideck.appdeck;

import android.annotation.SuppressLint;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

@SuppressLint("SetJavaScriptEnabled")
public class PageWebViewMenu extends XSmartWebView {

	public static final int POSITION_LEFT = 1;
	public static final int POSITION_RIGHT = 2;
	
	Loader loader;
	String url;
	int position;
	
	
	public PageWebViewMenu(Loader loader, String url, int position) {
		super(new AppDeckFragment(loader));
		this.root.alwaysLoadRootPage = true;
		this.url = url;
		this.position = position;
/*
		// configure
		setHorizontalScrollBarEnabled(false);
        setHorizontalFadingEdgeEnabled(false);

        setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY); 
        
        setInitialScale(1);
        getSettings().setLoadWithOverviewMode(true);
        getSettings().setUseWideViewPort(true);
        getSettings().setJavaScriptEnabled(true);

        setWebViewClient(new MenuWebViewClient());
        setWebChromeClient(new MenuWebChromeClient());*/
        
        loadUrl(url); 		
		
	}
	
/*
	public class MenuWebViewClient extends WebViewClient {

	    @Override
	    public boolean shouldOverrideUrlLoading(WebView view, String absoluteUrl) {
	    	
	    	loader.loadRootPage(absoluteUrl);
	    	
	        return true;
	    }		
	}
	
	public class MenuWebChromeClient extends WebChromeClient {
		
		@Override
		public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, android.webkit.JsPromptResult result) {
			
			if (message.startsWith("appdeckapi:") == true)
			{
				AppDeckApiCall call = new AppDeckApiCall(message.substring(11), defaultValue, result);				
				Boolean res = loader.apiCall(call);
				call.sendResult(res);
				return true;
			}
			return super.onJsPrompt(view, url, message, defaultValue, result);
		}

	}	*/
	
}
