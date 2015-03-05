package com.mobideck.appdeck;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.app.FragmentManager.OnBackStackChangedListener;
import android.util.Log;
import android.view.Display;
import android.view.DragEvent;
import android.view.Surface;
import android.view.View;
import android.view.View.OnDragListener;
import android.view.Window;
import android.widget.FrameLayout;
import com.mobideck.appdeck.R;

public class PopUp extends Loader {
	/*public final static String PAGE_URL = "com.mobideck.appdeck.URL";

	private AppDeck appDeck;
	
	private PopUp self;
	
	private String url;
	
	FrameLayout rootLayout;*/
	/*
	private ActionMode.Callback mActionModeCallback = new ActionMode.Callback(){

	    @Override 
	    public boolean onCreateActionMode(ActionMode mode, Menu menu) {
	          //MenuInflater inflater = mode.getMenuInflater();
	         // inflater.inflate(R.menu.actionbar_context_menu, menu);
	    	
	    	
	    	
	          return true;
	        }

	    @Override
	    public void onDestroyActionMode(ActionMode mode) {
	    	//self.getSupportActionBar().hide();
	    	self.finish();
	    }

	    @Override
	    public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
	        switch (item.getItemId()) {

	            default:
	            	self.finish();
	                //mode.finish();
	                return false;
	       }
	    }

		@Override
		public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
			// TODO Auto-generated method stub
			return false;
		}
	};	*/
	
    //@Override
    protected void onCreateOld(Bundle savedInstanceState) {
    	//setTheme(R.style.Theme_Sherlock);
    	//requestWindowFeature(Window.FEATURE_PROGRESS);
    	super.onCreate(savedInstanceState);
        appDeck = AppDeck.getInstance();
        setContentView(R.layout.activity_popup);
        FrameLayout rootLayout = (FrameLayout)findViewById(R.id.popup_container);
        /*getSupportActionBar().setDisplayHomeAsUpEnabled(false); // icon on the left of logo 
        getSupportActionBar().setDisplayShowHomeEnabled(false); // make icon + logo + title clickable
        getSupportActionBar().setDisplayShowTitleEnabled(false);
        getSupportActionBar().hide();*/
    	    	
    	//startActionMode(mActionModeCallback);
        
        
        
        //getSupportActionBar().setDisplayShowTitleEnabled(false);
        //getSupportActionBar().setIcon(new ColorDrawable(getResources().getColor(android.R.color.transparent))); 
        
        //getSupportActionBar().setDisplayUseLogoEnabled(false);
        //getSupportActionBar().setDisplayShowCustomEnabled(false);
        
        //setSupportProgressBarIndeterminateVisibility(false);
        //setSupportProgressBarVisibility(false);
        //setSupportProgress(33);
        /*
		if (appDeck.config.topbar_color != null)
			getSupportActionBar().setBackgroundDrawable(appDeck.config.topbar_color.getDrawable());        

		if (appDeck.config.title != null)
			getSupportActionBar().setTitle(appDeck.config.title);
		*/
        Intent intent = getIntent();
        String url = intent.getStringExtra(PAGE_URL);
		
        PageFragmentSwap fragment = PageFragmentSwap.newInstance(url);
    	FragmentManager fragmentManager = getSupportFragmentManager();
    	FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
    	//fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
    	//fragment.backStackIndex = fragmentManager.getBackStackEntryCount();    	
    	//PageSwipe pageSwipe = new PageSwipe(fragment);
    	fragmentTransaction.add(R.id.popup_container, fragment, "fragmentPageSwipe");
    	//fragmentTransaction.addToBackStack(null);
    	fragmentTransaction.commitAllowingStateLoss();   
        
        //loadRootPage(url);
    }
    
	public void initUI()
    {
    
    }
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
    	supportRequestWindowFeature(Window.FEATURE_PROGRESS);
    	onCreatePass(savedInstanceState);
    	//SherlockFragmentActivity.this. super.onCreate(savedInstanceState);
        appDeck = AppDeck.getInstance();
        //appDeck.glPopup = this;
        setContentView(R.layout.loader);

        getSupportActionBar().setDisplayHomeAsUpEnabled(false); // icon on the left of logo 
        getSupportActionBar().setDisplayShowHomeEnabled(true); // make icon + logo + title clickable
        
        setSupportProgressBarVisibility(true);
        
		if (appDeck.config.topbar_color != null)
			getSupportActionBar().setBackgroundDrawable(appDeck.config.topbar_color.getDrawable());        

		if (appDeck.config.title != null)
			getSupportActionBar().setTitle(appDeck.config.title);
				
		initUI();
		
        Intent intent = getIntent();
        String url = intent.getStringExtra(PAGE_URL);
        if (url == null)
        	return;
    	prepareRootPage();
    	//prepareRootPage();
    	if (loadSpecialURL(url))
    		return;
		AppDeckFragment fragment = initPageFragment(url);
    	pushFragment(fragment);    	
        //super.loadPage(url);
        
    }    
    /*
    public void loadRootPage(String absoluteURL)
    {
    	Intent i = new Intent(this, Loader.class);
    	i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
    	i.putExtra(ROOT_PAGE_URL, absoluteURL);
    	startActivity(i);
    }
    
    public int loadPage(String absoluteURL)
    {
    	Intent i = new Intent(this, Loader.class);
    	i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
    	i.putExtra(POP_UP_URL, absoluteURL);
    	startActivity(i);
    	return 0;
    }*/
    
/*    public void pushFragment(AppDeckFragment fragment)
    {    	
    	FragmentManager fragmentManager = getSupportFragmentManager();
    	FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
    	fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
    	
    	//fragment.backStackIndex = fragmentManager.getBackStackEntryCount();    	
    	//PageSwipe pageSwipe = new PageSwipe(fragment);
    	fragmentTransaction.add(R.id.popup_container, fragment, "fragmentPageSwipe");
    	//fragmentTransaction.addToBackStack(null);
    	fragmentTransaction.commit();    	
    }*/

	public Boolean apiCall(AppDeckApiCall call)
	{		/*
		if (call.command.equalsIgnoreCase("share"))
		{
			Log.i("API", "**SHARE**");
					
			String shareTitle = call.param.path("title").textValue();
			String shareUrl = call.param.path("url").textValue();;
			String shareImageUrl = call.param.path("imageurl").textValue();;

			appDeck.loader.share(shareTitle, shareUrl, shareImageUrl);
			
			return true;
		}
		
		if (call.command.equalsIgnoreCase("photobrowser"))
		{
			Log.i("API", "**PHOTO BROWSER**");
			// only show image browser if there are images
			JsonNode images = call.param.path("images");
			if (images.isArray() && images.size() > 0)
			{
				PhotoBrowser photoBrowser = new PhotoBrowser(call.param);
				pushFragment(photoBrowser);
			}
			
			return true;
		}		*/
		
		Log.i("API ERROR", call.command);
		return false;
	}

	protected void createIntent(String type, String absoluteURL)
	{
		super.createIntent(type, absoluteURL);
		finish();
	}
	
    @Override
    protected void onPause() {
    	super.onPause();
    	//finish();
    }
    	
    @Override
    public void onBackPressed() {
    	super.onBackPressed();
    	//overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_left);
        Display display = ((android.view.WindowManager) 
                getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
        if ((display.getRotation() == Surface.ROTATION_0) || 
            (display.getRotation() == Surface.ROTATION_180)) {
        	//overridePendingTransition(R.anim.slide_up, R.anim.slide_down);
        	overridePendingTransition(R.anim.slide_down, android.R.anim.fade_in);
        	
        } else if ((display.getRotation() == Surface.ROTATION_90) ||
                   (display.getRotation() == Surface.ROTATION_270)) {
        	//overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_left);
        	overridePendingTransition(android.R.anim.fade_in, R.anim.slide_out_left);
        }
    }
    
}
