package com.mobideck.appdeck;

import java.net.URI;

import android.app.Activity;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import com.mobideck.appdeck.R;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

public class PhotoBrowser extends AppDeckFragment {

	PhotoBrowser self;
	ViewPager viewPager;
	PhotoBrowserAdapter adapter;
	
   	PageMenuItem menuItemPrevious;
   	PageMenuItem menuItemNext;
   	PageMenuItem menuItemShare;
	
   	PageMenuItem menuItems[];
   	
   	//int nbPhoto;
	
   	//JsonNode images;
   	
	String url[];
	String thumbnail[];
	String caption[];   	
   	
   	String bgcolor;
   	int startIndex;
   	
   	AppDeckFragment origin;
   	
	public static PhotoBrowser newInstance(AppDeckJsonNode config, AppDeckFragment root)
	{
		PhotoBrowser fragment = new PhotoBrowser();
		
		AppDeckJsonArray images = config.getArray("images");
		String bgcolor = config.getString("bgcolor");
		int startIndex = config.getInt("startIndex");
		int nbPhoto = images.length();

		String url[] = new String[nbPhoto];
		String thumbnail[] = new String[nbPhoto];
		String caption[] = new String[nbPhoto];
		
		for (int i = 0; i < nbPhoto; i++)
		{
			AppDeckJsonNode image = images.getNode(i);
            String imageUrl = image.getString("url");
            String thumbnailUrl = image.getString("thumbnail");
            if (imageUrl != null && imageUrl != "")
                imageUrl = root.resolveURL(imageUrl);
            if (thumbnailUrl != null && thumbnailUrl != "")
                thumbnailUrl = root.resolveURL(thumbnailUrl);
			url[i] = imageUrl;
			thumbnail[i] = thumbnailUrl;
			caption[i] = image.getString("caption"); 		
		}
		
		Bundle args = new Bundle();
		//args.putString("absoluteURL", absoluteURL);
		args.putString("bgcolor", bgcolor);
		args.putInt("startIndex", startIndex);
		args.putInt("nbPhoto", startIndex);
		args.putStringArray("url", url);
		args.putStringArray("thumbnail", thumbnail);
		args.putStringArray("caption", caption);

		args.putString("parentUrl", root.currentPageUrl);
		
		fragment.setArguments(args);

		return fragment;
	}	

	@Override
	public void onAttach (Activity activity)
	{
		super.onAttach(activity);
		this.loader = (Loader)activity;
	}

	//boolean shouldRenderActionBar;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	
    	this.appDeck = this.loader.appDeck;
    	//currentPageUrl = getArguments().getString("absoluteURL");
    	//this.screenConfiguration = this.appDeck.config.getConfiguration(currentPageUrl);
    	
    	Bundle args = getArguments();
    	
    	bgcolor = args.getString("bgcolor");
    	startIndex = args.getInt("startIndex");
    	//nbPhoto = args.getInt("nbPhoto");
    	url = args.getStringArray("url");
    	thumbnail = args.getStringArray("thumbnail");
    	caption = args.getStringArray("caption");

		currentPageUrl = args.getString("parentUrl", null);

        //setHasOptionsMenu(true);
    	self = this;
    	//shouldRenderActionBar = true;
    	
		menuItemPrevious = new PageMenuItem(loader.getResources().getString(R.string.previous), "!previous", "button", "photobrowser:previous", null, null, this);
		menuItemNext = new PageMenuItem(loader.getResources().getString(R.string.next), "!next", "button", "photobrowser:next", null, null, this);
		menuItemShare = new PageMenuItem(loader.getResources().getString(R.string.action), "!action", "button", "photobrowser:share", null, null, this);

		menuItems = new PageMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare};		
    	
	}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.photo_browser, container, false);
        adapter = new PhotoBrowserAdapter(getChildFragmentManager());
                
        viewPager = (ViewPager)rootView.findViewById(R.id.photo_browser_pager);
        viewPager.setAdapter(adapter);
        viewPager.setCurrentItem(startIndex);

		try {
			viewPager.setBackgroundColor(Color.parseColor(bgcolor));
		} catch (IllegalArgumentException e) {

		}


        
        viewPager.setOnPageChangeListener(new OnPageChangeListener() {
			
			@Override
			public void onPageSelected(int position) {
				// enable/disable previous
				menuItemPrevious.setAvailable(position != 0);
				//Utils.setMenuItemAvailable(menuItemPrevious.me, position != 0);
				// enable/disable previous
				menuItemNext.setAvailable(position != (url.length - 1));
				//Utils.setMenuItemAvailable(menuItemNext, position != (nbPhoto - 1));
			}
			
			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {
			}
			
			@Override
			public void onPageScrollStateChanged(int arg0) {
			}
		});
        

        
        return rootView;
    }    
    
    @Override
    public void onStart() {

    	super.onStart();
    	
    	//loader.disableMenu();
    	loadURLConfiguration(currentPageUrl);
    	
    	//getActivity().invalidateOptionsMenu();
    	
    }
    
    @Override
    public void onPause() {
    	super.onPause();
    	
    	//loader.enableMenu();
    	
    	loader.getSupportActionBar().show();
    }

	@Override
	public void onHiddenChanged(boolean hidden)
	{
		FragmentManager fragmentManager = getChildFragmentManager();
		FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
		
		for (int i = 0; i < adapter.getCount(); i++)
		{
			PhotoBrowserImage image = (PhotoBrowserImage)adapter.getItem(i);
			if (image != null)
			{
				if (hidden)
					fragmentTransaction.hide(image);
				else
					fragmentTransaction.show(image);
			}
		}
  		fragmentTransaction.commitAllowingStateLoss();		
	}      
    
    @Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
    	super.onViewCreated(view, savedInstanceState);
        
    	loader.pushFragmentAnimation(this);
        
    }	
	
    @Override
    public void onDestroy()
    {
    	super.onDestroy();
    }
    
    
   private class PhotoBrowserAdapter extends FragmentStatePagerAdapter {

       public PhotoBrowserAdapter(FragmentManager fm) {
           super(fm);
       }

       @Override
       public Fragment getItem(int i) {
			String imageUrl = url[i];
			String imageThumbnail = thumbnail[i];
			String imageCaption = caption[i];    	   
           Fragment fragment = PhotoBrowserImage.newInstance(imageUrl, imageThumbnail, imageCaption);
           return fragment;
       }    	
   	
   	@Override
   	public int getCount() {
           return url.length;
       }
   	
       @Override
       public CharSequence getPageTitle(int position) {
           return "OBJECT " + (position + 1);
       }
          
   }
   /*
   @Override
   public void onCreateOptionsMenu (Menu menu, MenuInflater inflater) {    
   //public boolean onCreateOptionsMenu(Menu menu) {

	   menuItemPrevious = new PageMenuItem(appDeck.config.icon_previous.toString(), "button", "photobrowser:previous", null, this);
	   menuItemNext = new PageMenuItem(appDeck.config.icon_next.toString(), "button", "photobrowser:next", null, this);
	   menuItemShare = new PageMenuItem(appDeck.config.icon_action.toString(), "button", "photobrowser:share", null, this);
	   
	   menuItems = new PageMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare};
	   
   	if (isCurrentAppDeckPage() == false)
   		return;
   }    

   @Override
   public boolean onOptionsItemSelected(MenuItem item) {    

   	if (isCurrentAppDeckPage() == false)
   		return false;
   	
   	int idx = item.getItemId(); 
   	
   	if (idx == 0)
   	{
   		viewPager.setCurrentItem(viewPager.getCurrentItem() - 1, true);
   	} else if (idx == 1) {
   		viewPager.setCurrentItem(viewPager.getCurrentItem() + 1, true);   		
   	} else {
   		PhotoBrowserImage image = (PhotoBrowserImage)adapter.getItem(viewPager.getCurrentItem());
		String shareImageUrl = image.url;
		loader.share(null, null, shareImageUrl);
   	}		
	return true;
   	
   }     */  
   
   public class SimpleMenuItemImageLoadingListener extends SimpleImageLoadingListener
   {
   	public MenuItem menuItem;
   	
   	public SimpleMenuItemImageLoadingListener(MenuItem menuItem)
   	{
   		this.menuItem = menuItem;
   	}
   }
   
}
