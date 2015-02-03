package com.mobideck.appdeck;

import com.mobideck.appdeck.R;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.CookieSyncManager;
import android.widget.FrameLayout;


public class WebBrowser extends AppDeckFragment {

	String url;

   	PageMenuItem menuItemPrevious;
   	PageMenuItem menuItemNext;
   	PageMenuItem menuItemShare;
   	PageMenuItem menuItemCancel;
   	PageMenuItem menuItemRefresh;
	
   	WebBrowserWebView webView;
   	
	public static WebBrowser newInstance(String absoluteURL)
	{
		WebBrowser fragment = new WebBrowser();	
		Bundle args = new Bundle();
		args.putString("url", absoluteURL);
		fragment.setArguments(args);
		return fragment;
	}	

	@Override
	public void onAttach (Activity activity)
	{
		super.onAttach(activity);
		this.loader = (Loader)activity;
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	
    	this.appDeck = this.loader.appDeck;
    	Bundle args = getArguments();
    	url = args.getString("url");
    	
		menuItemPrevious = new PageMenuItem(loader.getResources().getString(R.string.previous), "!previous", "previous", "webbrowser:previous", null, this);
		menuItemNext = new PageMenuItem(loader.getResources().getString(R.string.next), "!next", "next", "webbrowser:next", null, this);
		menuItemShare = new PageMenuItem(loader.getResources().getString(R.string.action), "!action", "share", "webbrowser:share", null, this);
		menuItemCancel = new PageMenuItem(loader.getResources().getString(R.string.cancel), "!cancel", "cancel", "webbrowser:cancel", null, this);
		menuItemRefresh = new PageMenuItem(loader.getResources().getString(R.string.refresh), "!refresh", "refresh", "webbrowser:refresh", null, this);
		menuItems = new PageMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare, menuItemCancel, menuItemRefresh};		
	}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
    	FrameLayout rootView = (FrameLayout)inflater.inflate(R.layout.web_browser_layout, container, false);

		webView = new WebBrowserWebView(this);
		rootView.addView(webView, new ViewGroup.LayoutParams(
		        ViewGroup.LayoutParams.MATCH_PARENT,
		        ViewGroup.LayoutParams.MATCH_PARENT));

        if (savedInstanceState != null)
        {
        	Log.i(TAG, "onCreateView with State");
        	//loader = (Loader)getActivity();
    		//loadURLConfiguration(null);
    		webView.restoreState(savedInstanceState);
        } else {
        	webView.loadUrl(url);
        }		
		
        return rootView;
    }    
    
    @Override
    public void onStart() {

    	super.onStart();
    	
    	loadURLConfiguration(null);
    	    	
    }
    
    @Override
    public void onPause() {
    	super.onPause();
    	CookieSyncManager.getInstance().sync();
    	webView.pause();
    }

    @Override
    public void onDestroy()
    {
    	super.onDestroy();
    }
	
    @Override
    public void onResume() {
    	super.onResume();
    	CookieSyncManager.getInstance().stopSync();
    	webView.resume();
    };

    @Override
    public void onSaveInstanceState(Bundle outState)
    {
    	super.onSaveInstanceState(outState);
    	if (webView != null)
    		webView.saveState(outState);
    }    
    
    public void loadUrl(String absoluteURL)
    {
    	if (absoluteURL.equalsIgnoreCase("webbrowser:previous"))
    		webView.goBack();
    	else if (absoluteURL.equalsIgnoreCase("webbrowser:next"))
    		webView.goForward();
    	else if (absoluteURL.equalsIgnoreCase("webbrowser:cancel"))
    		webView.stopLoading();
    	else if (absoluteURL.equalsIgnoreCase("webbrowser:refresh"))
    		webView.reload();
    	else if (absoluteURL.equalsIgnoreCase("webbrowser:share"))
    		loader.share(webView.getTitle(), webView.getUrl(), null);
    	else
    		webView.loadUrl(absoluteURL);
    }
    
    void syncMenu()
    {
    	menuItemPrevious.setAvailable(webView.canGoBack());
       	menuItemNext.setAvailable(webView.canGoForward());
       	menuItemShare.setAvailable(true);
       	menuItemCancel.setAvailable(true);
       	menuItemRefresh.setAvailable(true);
    }
    
    public void progressStart(View origin)
    {
       	menuItems = new PageMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare, menuItemCancel};       	
       	loader.setMenuItems(menuItems);
    	
    	menuItemPrevious.setAvailable(webView.canGoBack());
       	menuItemNext.setAvailable(webView.canGoForward());
       	menuItemShare.setAvailable(true);
       	menuItemCancel.setAvailable(true);
       	menuItemRefresh.setAvailable(true);
       	
    	super.progressStart(origin);
    }
    
    public void progressSet(View origin, int percent)
    {
    	menuItemPrevious.setAvailable(webView.canGoBack());
       	menuItemNext.setAvailable(webView.canGoForward());
       	menuItemShare.setAvailable(true);
       	menuItemCancel.setAvailable(true);
       	menuItemRefresh.setAvailable(true);
       	
    	super.progressSet(origin, percent);
    }
    
    public void progressStop(View origin)
    {
       	menuItems = new PageMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare, menuItemCancel, menuItemRefresh};
       	loader.setMenuItems(menuItems);

    	menuItemPrevious.setAvailable(webView.canGoBack());
       	menuItemNext.setAvailable(webView.canGoForward());
       	menuItemShare.setAvailable(true);
       	menuItemCancel.setAvailable(false);
       	menuItemRefresh.setAvailable(true);    	
       	
    	super.progressStop(origin);
    }    
    
	public boolean canGoBack()
	{
		return webView.canGoBack();
	}
	
	public void goBack()
	{
		webView.goBack();
	}    
}
