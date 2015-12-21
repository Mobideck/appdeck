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
import android.widget.ProgressBar;


public class WebBrowser extends AppDeckFragment {

	String url;

   	PageMenuItem menuItemPrevious;
   	PageMenuItem menuItemNext;
   	PageMenuItem menuItemShare;
   	PageMenuItem menuItemCancel;
   	PageMenuItem menuItemRefresh;
	
   	//WebBrowserWebView webView;
    private SmartWebView webView;

    private ProgressBar preLoadingIndicator;
    private boolean isPreLoading = true;

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
        this.screenConfiguration = this.appDeck.config.getConfiguration(currentPageUrl);
    	
		menuItemPrevious = new PageMenuItem(loader.getResources().getString(R.string.previous), "!previous", "previous", "webbrowser:previous", null, null, this);
		menuItemNext = new PageMenuItem(loader.getResources().getString(R.string.next), "!next", "next", "webbrowser:next", null, null, this);
		menuItemShare = new PageMenuItem(loader.getResources().getString(R.string.action), "!action", "share", "webbrowser:share", null, null, this);
		menuItemCancel = new PageMenuItem(loader.getResources().getString(R.string.cancel), "!cancel", "cancel", "webbrowser:cancel", null, null, this);
		menuItemRefresh = new PageMenuItem(loader.getResources().getString(R.string.refresh), "!refresh", "refresh", "webbrowser:refresh", null, null, this);
		menuItems = new PageMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare, menuItemCancel, menuItemRefresh};
	}

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        if (enablePushAnimation)
        {
            loader.pushFragmentAnimation(this);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
    	rootView = (FrameLayout)inflater.inflate(R.layout.web_browser_layout, container, false);
        //rootView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        preLoadingIndicator = (ProgressBar)rootView.findViewById(R.id.preLoadingIndicator);

        //if (appDeck.config.app_background_color != null)
        //    rootView.setBackground(appDeck.config.app_background_color.getDrawable());

        webView = SmartWebViewFactory.createSmartWebView(this);

        webView.view.setVisibility(View.GONE);

		rootView.addView(webView.view, new ViewGroup.LayoutParams(
		        ViewGroup.LayoutParams.MATCH_PARENT,
		        ViewGroup.LayoutParams.MATCH_PARENT));

        if (savedInstanceState != null)
        {
        	Log.i(TAG, "onCreateView with State");
        	//loader = (Loader)getActivity();
    		//loadURLConfiguration(null);
    		webView.ctl.smartWebViewRestoreState(savedInstanceState);
        } else {
        	webView.ctl.loadUrl(url);
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
    	webView.ctl.pause();
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
    	webView.ctl.resume();
    };

    @Override
    public void onSaveInstanceState(Bundle outState)
    {
    	super.onSaveInstanceState(outState);
    	if (webView != null)
    		webView.ctl.smartWebViewSaveState(outState);
    }    
    
    public void loadUrl(String absoluteURL)
    {
    	if (absoluteURL.equalsIgnoreCase("webbrowser:previous"))
    		webView.ctl.smartWebViewGoBack();
    	else if (absoluteURL.equalsIgnoreCase("webbrowser:next"))
    		webView.ctl.smartWebViewGoForward();
    	else if (absoluteURL.equalsIgnoreCase("webbrowser:cancel"))
    		webView.ctl.stopLoading();
    	else if (absoluteURL.equalsIgnoreCase("webbrowser:refresh"))
    		webView.ctl.reload();
    	else if (absoluteURL.equalsIgnoreCase("webbrowser:share"))
    		loader.share(webView.ctl.smartWebViewGetTitle(), webView.ctl.smartWebViewGetUrl(), null);
    	else
    		webView.ctl.loadUrl(absoluteURL);
    }
    
    void syncMenu()
    {
    	menuItemPrevious.setAvailable(webView.ctl.smartWebViewCanGoBack());
       	menuItemNext.setAvailable(webView.ctl.smartWebViewCanGoForward());
       	menuItemShare.setAvailable(true);
       	menuItemCancel.setAvailable(true);
       	menuItemRefresh.setAvailable(true);
    }
    
    public void progressStart(View origin)
    {
       	menuItems = new PageMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare, menuItemCancel};       	
       	loader.setMenuItems(menuItems);
    	
    	menuItemPrevious.setAvailable(webView.ctl.smartWebViewCanGoBack());
       	menuItemNext.setAvailable(webView.ctl.smartWebViewCanGoForward());
       	menuItemShare.setAvailable(true);
       	menuItemCancel.setAvailable(true);
       	menuItemRefresh.setAvailable(true);
       	
    	super.progressStart(origin);
    }
    
    public void progressSet(View origin, int percent)
    {
        if (percent > 50 && isPreLoading)
        {
            preLoadingIndicator.setVisibility(View.GONE);
            webView.view.setVisibility(View.VISIBLE);
            isPreLoading = false;
        }

    	menuItemPrevious.setAvailable(webView.ctl.smartWebViewCanGoBack());
       	menuItemNext.setAvailable(webView.ctl.smartWebViewCanGoForward());
       	menuItemShare.setAvailable(true);
       	menuItemCancel.setAvailable(true);
       	menuItemRefresh.setAvailable(true);
       	
    	super.progressSet(origin, percent);
    }
    
    public void progressStop(View origin)
    {
       	menuItems = new PageMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare, menuItemCancel, menuItemRefresh};
       	loader.setMenuItems(menuItems);

    	menuItemPrevious.setAvailable(webView.ctl.smartWebViewCanGoBack());
       	menuItemNext.setAvailable(webView.ctl.smartWebViewCanGoForward());
       	menuItemShare.setAvailable(true);
       	menuItemCancel.setAvailable(false);
       	menuItemRefresh.setAvailable(true);    	
       	
    	super.progressStop(origin);
    }    
    
	public boolean canGoBack()
	{
		return webView.ctl.smartWebViewCanGoBack();
	}
	
	public void goBack()
	{
		webView.ctl.smartWebViewGoBack();
	}    
}
