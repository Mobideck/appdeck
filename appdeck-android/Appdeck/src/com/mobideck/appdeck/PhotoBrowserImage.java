package com.mobideck.appdeck;

import uk.co.senab.photoview.PhotoViewAttacher;
import uk.co.senab.photoview.PhotoViewAttacher.OnViewTapListener;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.graphics.Bitmap;
import com.mobideck.appdeck.R;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.ImageLoadingListener;

public class PhotoBrowserImage extends Fragment {

	AppDeck appDeck;
	
	//PhotoBrowser photoBrowser;
	
	String url;
	String urlThumbnail;
	String caption;
	
	//PhotoView photoView;
	ImageView imageView;
	PhotoViewAttacher attacher;
	TextView textView;
	
	public static PhotoBrowserImage newInstance(/*PhotoBrowser photoBrowser, */String url, String thumbnail, String caption)
	{
		PhotoBrowserImage fragment = new PhotoBrowserImage();
		
		Bundle args = new Bundle();
		//args.putString("absoluteURL", absoluteURL);
		args.putString("url", url);
		args.putString("thumbnail", thumbnail);
		args.putString("caption", caption);
		
		fragment.setArguments(args);

		return fragment;		
		
	}
	
	@Override
	public void onCreate(Bundle savedInstanceState) {

    	super.onCreate(savedInstanceState);
        appDeck = ((Loader)getActivity()).appDeck;            
        //setHasOptionsMenu(true);
        Bundle args = getArguments();
		//this.photoBrowser = photoBrowser;
		url = args.getString("url");
		urlThumbnail = args.getString("thumbnail");
		caption = args.getString("caption");
        
	}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.photo_browser_image, container, false);

        imageView = (ImageView)rootView.findViewById(R.id.imageView);
        textView = (TextView)rootView.findViewById(R.id.textView);
        
        attacher = new PhotoViewAttacher(imageView);
        
        attacher.setOnViewTapListener(new OnViewTapListener() {			
			@Override
			public void onViewTap(View view, float x, float y) {
				((Loader)getActivity()).toggleActionBar();
			}
		});
        
        
        if (caption == null || caption.isEmpty())
        	textView.setVisibility(View.INVISIBLE);
        else
        	textView.setText(caption);
        
        return rootView;
    }    
    
    @Override
    public void onStart() {

    	super.onStart();
    	
    	downloadAndDisplayThumbnail();

    }	
    
	@Override
	public void onDestroyView() {
		super.onDestroyView();
		attacher.cleanup();
		//imageView.setImageDrawable(R.drawable.ic_launcher);
	}
    
	
    void downloadAndDisplayThumbnail()
    {
    	DisplayImageOptions displayOptions = new DisplayImageOptions.Builder()
        .cacheInMemory(!appDeck.noCache)
        .cacheOnDisc(!appDeck.noCache)
        .build();    	
    	appDeck.imageLoader.displayImage(urlThumbnail, imageView, displayOptions, new ImageLoadingListener() {
    	    @Override
    	    public void onLoadingStarted(String imageUri, View view) {
    	        
    	    }
    	    @Override
    	    public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
    	    	downloadAndDisplayImage();
    	    }
    	    @Override
    	    public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
    	    	attacher.update();
    	    	downloadAndDisplayImage();
    	    }
    	    @Override
    	    public void onLoadingCancelled(String imageUri, View view) {
    	    	downloadAndDisplayImage();
    	    }
    	});
    }
    
    void downloadAndDisplayImage()
    {
    	DisplayImageOptions displayOptions = new DisplayImageOptions.Builder()
        .cacheInMemory(!appDeck.noCache)
        .cacheOnDisc(!appDeck.noCache)
        .build();
    	appDeck.imageLoader.displayImage(url, imageView, displayOptions, new ImageLoadingListener() {
    	    @Override
    	    public void onLoadingStarted(String imageUri, View view) {
    	        
    	    }
    	    @Override
    	    public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
    	    	
    	    }
    	    @Override
    	    public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
    	    	attacher.update();
    	    	
    	    }
    	    @Override
    	    public void onLoadingCancelled(String imageUri, View view) {
    	    	downloadAndDisplayImage();
    	    }
    	});    	
    }

}
