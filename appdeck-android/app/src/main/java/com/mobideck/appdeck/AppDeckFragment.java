package com.mobideck.appdeck;

import java.net.URI;
import java.net.URISyntaxException;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
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
import android.widget.ImageView;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;
//import com.squareup.picasso.Picasso;
//import com.squareup.picasso.Target;

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

	public boolean forceReload = false;

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

/*			if (loader.mClose != null) {
				loader.mDrawerToggle.setHomeAsUpIndicator(loader.mClose);
				loader.getSupportActionBar().setDisplayHomeAsUpEnabled(false); // show icon on the left of logo
			}*/

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
        appDeck = AppDeck.getInstance(); // bug sometime singleton is gone !?
        if (appDeck == null)
            return;
		// configure action bar
		String actionBarTitle = appDeck.config.title;
		if (screenConfiguration!= null && screenConfiguration.title != null)
			actionBarTitle = screenConfiguration.title;

		String actionBarLogoUrl = null;
		if (appDeck.config.logoUrl != null)
			actionBarLogoUrl = appDeck.config.logoUrl.toString();
		if (screenConfiguration!= null && screenConfiguration.logo != null)
			actionBarLogoUrl = screenConfiguration.logo;
		if (actionBarLogoUrl != null)
		{
			//if (loader.actionBarContent == actionBarLogoUrl)
			//	return;
			/*
			Picasso.with(loader)
					.load(actionBarLogoUrl)
					.resize(0, appDeck.actionBarHeight)
					.into(new Target()
					{
						@Override
						public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom from)
						{
							Drawable d = new BitmapDrawable(loader.getResources(), bitmap);
							ActionBar actionBar = loader.getSupportActionBar();
							if (actionBar == null)
								return;
							actionBar.setTitle(null);
							actionBar.setIcon(d);
							actionBar.setDisplayOptions(ActionBar.DISPLAY_HOME_AS_UP|ActionBar.DISPLAY_SHOW_HOME);
							//loader.actionBarContent = actionBarLogoUrl;
						}

						@Override
						public void onBitmapFailed(Drawable errorDrawable)
						{
						}

						@Override
						public void onPrepareLoad(Drawable placeHolderDrawable)
						{
						}
					});
			if (true)
				return;*/
			Utils.downloadImage(actionBarLogoUrl, appDeck.actionBarWidth, appDeck.actionBarHeight, new SimpleImageLoadingListener() {
				@Override
				public void onLoadingComplete(String imageUri, View view, final Bitmap loadedImage) {
					if (loader == null || imageUri == null || loadedImage == null)
						return;
					/*
					ImageView imageView = new ImageView(loader);
					//imageView.getLayoutParams().height = appDeck.actionBarHeight;
					imageView.setImageBitmap(loadedImage);
					imageView.setLayoutParams(
							new ViewGroup.LayoutParams(
									// or ViewGroup.LayoutParams.WRAP_CONTENT
									ViewGroup.LayoutParams.MATCH_PARENT,
									// or ViewGroup.LayoutParams.WRAP_CONTENT,
									ViewGroup.LayoutParams.MATCH_PARENT ) );

					ActionBar actionBar = loader.getSupportActionBar();
					if (actionBar == null)
						return;
					actionBar.setTitle(null);
					actionBar.setCustomView(imageView);
					actionBar.setDisplayOptions(ActionBar.DISPLAY_HOME_AS_UP|ActionBar.DISPLAY_SHOW_HOME|ActionBar.DISPLAY_SHOW_CUSTOM);
					Log.i(TAG, "logo have been set in action bar");*/

/*					BitmapDrawable draw = new BitmapDrawable(loader.getResources(), loadedImage);
					ActionBar actionBar = loader.getSupportActionBar();
					if (actionBar == null)
						return;
					actionBar.setTitle(null);
					actionBar.setIcon(draw);
					actionBar.setDisplayOptions(ActionBar.DISPLAY_HOME_AS_UP|ActionBar.DISPLAY_SHOW_HOME);
					Log.i(TAG, "logo have been set in action bar");*/

					// run appdeck init in his own thread
					new Thread(new Runnable() {
						@Override
						public void run() {
							final BitmapDrawable draw = new BitmapDrawable(loader.getResources(), loadedImage);
							//draw.setAntiAlias(true);
							Handler mainHandler = new Handler(loader.getMainLooper());
							Runnable myRunnable = new Runnable() {
								@Override
								public void run() {
                                    ActionBar actionBar = loader.getSupportActionBar();
									if (actionBar == null)
										return;
                                    actionBar.setTitle(null);
                                    actionBar.setIcon(draw);
									actionBar.setDisplayShowHomeEnabled(true); // show logo
									actionBar.setDisplayShowTitleEnabled(false); // hide String title
									Log.i(TAG, "logo have been set in action bar");
								}
							};
							mainHandler.post(myRunnable);

						}
					}, "topbaricon").start();
				}

				@Override
				public void onLoadingStarted(String imageUri, View view) {
					Log.i(TAG, "logo action bar onLoadingStarted");
				}

				@Override
				public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
					Log.i(TAG, "logo action bar onLoadingFailed:"+failReason);
				}

				@Override
				public void onLoadingCancelled(String imageUri, View view) {
					Log.i(TAG, "logo action bar onLoadingCancelled");
				}
			}, loader);
		} else {
			//if (loader.actionBarContent == actionBarTitle)
			//	return;
			//loader.actionBarContent = actionBarTitle;
            ActionBar actionBar = loader.getSupportActionBar();
            if (actionBar == null)
                return;
            actionBar.setIcon(null);
            actionBar.setTitle(actionBarTitle);
            //actionBar.setDisplayOptions(ActionBar.DISPLAY_HOME_AS_UP|ActionBar.DISPLAY_SHOW_TITLE);
			actionBar.setDisplayShowHomeEnabled(false); // show logo
			actionBar.setDisplayShowTitleEnabled(true); // hide String title

		}
	}

	public void loadURLConfiguration(String absoluteURL)
	{
		if (appDeck != null && screenConfiguration == null)
			screenConfiguration = appDeck.config.getConfiguration(absoluteURL);
		if (screenConfiguration == null)
			screenConfiguration = ScreenConfiguration.defaultConfiguration();

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
	
	public void reload(boolean forceReload)
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
