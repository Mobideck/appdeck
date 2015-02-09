package com.mobideck.appdeck;

import com.mobideck.appdeck.R;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.webkit.WebChromeClient.CustomViewCallback;
import android.widget.RelativeLayout;
import android.widget.VideoView;


public class CustomViewFragment extends AppDeckFragment {

	AppDeckFragment origin;
   	View customView;
   	CustomViewCallback callback;
   	
   	/*CustomViewFragment(AppDeckFragment origin, View customView, CustomViewCallback callback)
	{
		this.origin = origin;
		this.customView = customView;
		this.callback = callback;
	}*/
		
	@Override
	public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);

    	menuItems = new PageMenuItem[] {};		
    	
	}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
    	RelativeLayout rootView = (RelativeLayout)inflater.inflate(R.layout.customview_fragment, container, false);

    	rootView.addView(customView, new ViewGroup.LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT));
        
        return rootView;
    }    
    
    @Override
    public void onStart() {

    	super.onStart();
    	loader.getSupportActionBar().hide();
    	
    	if (customView instanceof VideoView)
    	{
    		VideoView videoView = (VideoView)customView;
    		videoView.start();
    	}
    	
    }
    
    @Override
    public void onPause() {
    	super.onPause();
    	loader.getSupportActionBar().show();
    }

    
	
}
