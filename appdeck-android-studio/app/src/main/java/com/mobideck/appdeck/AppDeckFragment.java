package com.mobideck.appdeck;

import java.net.URI;
import java.net.URISyntaxException;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

public class AppDeckFragment extends Fragment {

	public static final String TAG = "AppDeckFragment";	
	
	public Loader loader;
	
	public AppDeck appDeck;
	public ScreenConfiguration screenConfiguration;

	public String previousPageUrl;
	public String currentPageUrl;
	public String nextPageUrl;
	
	boolean isMain;
	
	protected PageMenuItem[] menuItems;
	
	public FrameLayout rootView;
	
	public boolean enablePushAnimation = true;
	public boolean enablePopAnimation = true;
	
	AppDeckFragment()
	{
		
	}
	
	AppDeckFragment(Loader loader)
	{
		this.loader = loader;
	}
	
	/*
	@Override
	public onCreateAnimation(int transit, boolean enter, int nextAnim)
	{
		
	}
	*/
	
	@Override
	public void onCreate(Bundle savedInstanceState)
	{
    	super.onCreate(savedInstanceState);
        appDeck = AppDeck.getInstance();
	}
	
	public String resolveURL(String relativeUrl)
	{
		URI uri;
		try {
			uri = new URI(currentPageUrl);
			return uri.resolve(relativeUrl).toString();
		} catch (URISyntaxException e) {
			e.printStackTrace();
		}
		return relativeUrl;		
	}

	public void loadURLConfiguration(String absoluteURL)
	{
		if (screenConfiguration == null)
			screenConfiguration = appDeck.config.getConfiguration(absoluteURL);
		
		// configure action bar
        String actionBarTitle = appDeck.config.title;
        if (screenConfiguration.title != null)
        	actionBarTitle = screenConfiguration.title;
        
        String actionBarLogoUrl = null;
        if (appDeck.config.logoUrl != null)
        	actionBarLogoUrl = appDeck.config.logoUrl.toString();
        if (screenConfiguration.logo != null)
        	actionBarLogoUrl = screenConfiguration.logo;
        if (actionBarLogoUrl != null)
        {
        	Utils.downloadImage(actionBarLogoUrl, appDeck.actionBarHeight, new SimpleImageLoadingListener() {
            @Override
            public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
            	if (loader == null || imageUri == null || loadedImage == null)
            		return;
            	BitmapDrawable draw = new BitmapDrawable(loader.getResources(), loadedImage);
            	ActionBarActivity sa = (ActionBarActivity)AppDeckFragment.this.getActivity();
            	if (sa == null)
            		return;
            	ActionBar ac = sa.getSupportActionBar();
            	if (ac == null)
            		return;
           		ac.setDisplayShowTitleEnabled(false);
           		ac.setDisplayUseLogoEnabled(true);
           		ac.setIcon(draw);
           		Log.i(TAG, "logo have been set in action bar");
            	}
            
        	@Override
        	public void onLoadingStarted(String imageUri, View view) {
        		Log.i(TAG, "logo action bar onLoadingStarted");
        	}

        	@Override
        	public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
        		Log.i(TAG, "logo action bar onLoadingFailed");
        	}

        	@Override
        	public void onLoadingCancelled(String imageUri, View view) {
        		Log.i(TAG, "logo action bar onLoadingCancelled");
        	}            
        	}, getActivity());
        } else {
        	ActionBarActivity aba = (ActionBarActivity)AppDeckFragment.this.getActivity();
        	aba.getSupportActionBar().setTitle(actionBarTitle);
        }

	}
	
	public boolean isCurrentAppDeckPage()
	{
		if (isMain == false)
			return false;
		//TODO: implement this
		//if (pageSwipe == null)
		//	return true;
    	/*if (appDeck.loader.getSupportFragmentManager().getBackStackEntryCount() - 1 != backStackIndex)
    		return false;*/
    	//if (pageSwipe.currentPage != this)
    	//	return false;
    	return true;
	}
	
    public void setIsMain(boolean isMain)
    {
    	if (isMain && menuItems != null)
    		loader.setMenuItems(menuItems);
    	if (isMain)
    	{
    		//currentPageUrl
    		AppDeck.getInstance().ga.view(currentPageUrl);
    	}
    	this.isMain = isMain;
    }

    public boolean alwaysLoadRootPage = false;
    
    public void loadUrl(String absoluteURL)
    {    	
    	if (alwaysLoadRootPage)
    		loader.loadRootPage(absoluteURL);
    	else
    		loader.loadPage(absoluteURL);
    }    
    
    public void progressStart(View origin)
    {
    	if (isCurrentAppDeckPage() == false)
    		return;    	
    	loader.progressStart();
    }
    
    public void progressSet(View origin, int percent)
    {
    	if (isCurrentAppDeckPage() == false)
    		return;    	
    	loader.progressSet(percent);
    }
    
    public void progressStop(View origin)
    {
    	if (isCurrentAppDeckPage() == false)
    		return;    	
    	loader.progressStop();
    }

    public void progressFailed(View origin)
    {
    	if (isCurrentAppDeckPage() == false)
    		return;
    	loader.progressStop();
    }    
    
	public boolean apiCall(AppDeckApiCall call)
	{	
		return loader.apiCall(call);
		
	}    
	
	public void reload()
	{
		
	}
	
	public void clean()
	{
	}
	
	public boolean canGoBack()
	{
		return false;
	}
	
	public void goBack()
	{
		
	}

}
