package com.mobideck.appdeck;

import java.net.URI;
import java.net.URISyntaxException;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

public class AppDeckFragment extends Fragment {

	public static final String TAG = "AppDeckFragment";	

	public int event = -1;

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

    public boolean isPopUp = false;

//	public View bannerAdView = null;

	public AppDeckFragment()
	{
		
	}


	public static AppDeckFragment fragmentWithLoader(Loader loader)
	{
        AppDeckFragment fragment = new AppDeckFragment();
        fragment.loader = loader;
		return fragment;
	}


    public void animationInDidEnd()
    {

    }

    public void animationOutDidEnd()
    {

    }

	/*
	@Override
	public onCreateAnimation(int transit, boolean enter, int nextAnim)
	{
		
	}
	*/

    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        this.loader = (Loader)activity;
        if (isPopUp) {
            this.loader.disableMenu();
            //this.loader.enableFullScreen();
        }

    }

    @Override
    public void onDetach() {
        super.onDetach();

    }


    @Override
	public void onCreate(Bundle savedInstanceState)
	{
    	super.onCreate(savedInstanceState);
        appDeck = AppDeck.getInstance();
	}

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View ret = super.onCreateView(inflater, container, savedInstanceState);

        return ret;
    }

    @Override
    public void onDestroyView()
    {
        super.onDestroyView();
        if (isPopUp) {
            this.loader.enableMenu();
            //this.loader.disableFullScreen();
        }
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

	private void refreshConfiguration()
	{
		if (screenConfiguration == null)
			return;
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
				public void onLoadingComplete(String imageUri, View view, final Bitmap loadedImage) {
					if (loader == null || imageUri == null || loadedImage == null)
						return;
					// run appdeck init in his own thread
					new Thread(new Runnable() {
						@Override
						public void run() {
							final BitmapDrawable draw = new BitmapDrawable(loader.getResources(), loadedImage);
							Handler mainHandler = new Handler(getActivity().getMainLooper());
							Runnable myRunnable = new Runnable() {
								@Override
								public void run() {
									AppCompatActivity sa = (AppCompatActivity)AppDeckFragment.this.getActivity();
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
							};
							mainHandler.post(myRunnable);

						}
					}, "appdeckInit").start();
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
			}, loader);
		} else {
			AppCompatActivity aba = (AppCompatActivity)AppDeckFragment.this.getActivity();
			aba.getSupportActionBar().setTitle(actionBarTitle);
			aba.getSupportActionBar().setDisplayShowTitleEnabled(false);
		}
	}

	public void loadURLConfiguration(String absoluteURL)
	{
		if (screenConfiguration == null)
			screenConfiguration = appDeck.config.getConfiguration(absoluteURL);

		refreshConfiguration();
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
            if (isCurrentAppDeckPage()) {
                if (progressStart && progress == -1)
                    loader.progressStart();
                else if (progressStart)
                    loader.progressSet(progress);
                else
                    loader.progressStop();
            }
    		//currentPageUrl
    		AppDeck.getInstance().ga.view(currentPageUrl);
			refreshConfiguration();
    	}
    	this.isMain = isMain;
    }

    public boolean alwaysLoadRootPage = false;

    public boolean shouldOverrideUrlLoading(String absoluteURL)
    {
        return true;
    }

    public void loadUrl(String absoluteURL)
    {    	
    	if (alwaysLoadRootPage)
    		loader.loadRootPage(absoluteURL);
    	else
    		loader.loadPage(absoluteURL);
    }

    boolean progressStart = false;
    int progress = -1;
    
    public void progressStart(View origin)
    {
        progressStart = true;
        progress = -1;
    	if (isCurrentAppDeckPage() == false)
    		return;
    	loader.progressStart();
    }
    
    public void progressSet(View origin, int percent)
    {
        progressStart = true;
        progress = percent;
    	if (isCurrentAppDeckPage() == false)
    		return;    	
    	loader.progressSet(percent);
    }
    
    public void progressStop(View origin)
    {
        progressStart = false;
        progress = -1;
    	if (isCurrentAppDeckPage() == false)
    		return;    	
    	loader.progressStop();
    }

    public void progressFailed(View origin)
    {
        progressStart = false;
        progress = -1;
    	if (isCurrentAppDeckPage() == false)
    		return;
    	loader.progressStop();
    }

	public String evaluateJavascript(String js)
	{
		return "";
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
