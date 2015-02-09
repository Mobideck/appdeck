package com.mobideck.appdeck;

import android.util.Log;
import android.webkit.JavascriptInterface;

public class AppDeckJSApi {

	public static String TAG = "AppDeckJSApi";
	SmartWebView webview;
	
	AppDeckJSApi(SmartWebView webview)
	{
		this.webview = webview;
		webview.jsLock.lock();
	}
	
	@JavascriptInterface
	public String init()
	{
		Log.i(TAG, "init appdeck JS OK ... unlock!");
		webview.jsLock.unlock();
		return null;
	}

	
	//public String addTopMenuButton
	
	
}
