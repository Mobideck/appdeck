package com.mobideck.appdeck;

import com.mobideck.appdeck.R;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.graphics.drawable.shapes.Shape;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.webkit.CookieSyncManager;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

public class PopOverFragment extends AppDeckFragment {

	String url;
	float width;
	float height;
    float alpha;
    String tint;
    String arrow;
    String title;
    String bgcolor;
    float border;
    float radius;	
	
    AppDeckFragment origin;
    
    AppDeck appDeck;
    
    FrameLayout bgLayout;
    FrameLayout containerLayout;
    
    private SmartWebView webView;
    
    private View bgView;
    
    PopOverFragment self;
    
	PopOverFragment(AppDeckFragment origin, AppDeckApiCall call)
	{
		appDeck = AppDeck.getInstance();
		this.origin = origin;
		self = this;
		url = origin.resolveURL(call.param.getString("url"));
	    width = call.param.getFloat("width");
	    height = call.param.getFloat("height");
	    alpha = call.param.getFloat("alpha");
	    tint = call.param.getString("tint");
	    arrow = call.param.getString("arrow");
	    title = call.param.getString("title");
	    bgcolor = call.param.getString("bgcolor");
	    border = call.param.getFloat("border");
	    radius = call.param.getFloat("radius");
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);

	}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
    	bgLayout = (FrameLayout)inflater.inflate(R.layout.popover_layout, container, false);
    	
    	containerLayout = (FrameLayout) bgLayout.findViewById(R.id.popover_container);
    	bgView = bgLayout.findViewById(R.id.popover_background);
    	
    	bgView.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				loader.cancelSubViews();
			}
		});
    	
		FrameLayout.LayoutParams frameLayoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
		frameLayoutParams.gravity = Gravity.TOP | Gravity.RIGHT; 
    	float density = getResources().getDisplayMetrics().density;
    	frameLayoutParams.width = (int)(width * density);
    	frameLayoutParams.height = (int)(height * density);
   	
    	
    	/*// set size
    	LayoutParams params = containerLayout.getLayoutParams();
    	float density = getResources().getDisplayMetrics().density;
    	params.width = (int)(width * density);
    	params.height = (int)(height * density);*/
    	
    	containerLayout.setLayoutParams(frameLayoutParams);
    	
/*
    	webView = new SmartWebView(this);
    	
    	containerLayout.addView(webView, new FrameLayout.LayoutParams(
    			FrameLayout.LayoutParams.MATCH_PARENT,
    			FrameLayout.LayoutParams.MATCH_PARENT));
    	webView.loadUrl(url);*/
    	
    	FrameLayout.LayoutParams webViewLayoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);//(android.widget.RelativeLayout.LayoutParams) containerLayout.getLayoutParams();
    	int margin = (int)(10 * density);
    	webViewLayoutParams.setMargins(margin, margin, margin, margin);
    	//webView.setLayoutParams(webViewLayoutParams);
    	webView = new SmartWebView(this);
    	containerLayout.addView(webView, webViewLayoutParams);
    	webView.loadUrl(url);    	
    	
    	/*RoundRectShape rs = new RoundRectShape(new float[] { 10, 10, 10, 10, 10, 10, 10, 10 }, null, null);
    	ShapeDrawable sd = new CustomShapeDrawable(rs, Color.RED, Color.WHITE, 20);
    	webView.setBackground(sd);*/
    	
    	return bgLayout;
    }    
    
    public class CustomShapeDrawable extends ShapeDrawable {
        private final Paint fillpaint, strokepaint;
     
        public CustomShapeDrawable(Shape s, int fill, int stroke, int strokeWidth) {
            super(s);
            fillpaint = new Paint(this.getPaint());
            fillpaint.setColor(fill);
            strokepaint = new Paint(fillpaint);
            strokepaint.setStyle(Paint.Style.STROKE);
            strokepaint.setStrokeWidth(strokeWidth);
            strokepaint.setColor(stroke);
        }
     
        @Override
        protected void onDraw(Shape shape, Canvas canvas, Paint paint) {
            shape.draw(canvas, fillpaint);
            shape.draw(canvas, strokepaint);
        }
    }    
    
    @Override
    public void onStart() {
    	super.onStart();
    }
    
    @Override
    public void onDetach() {
    	super.onDetach();
    }	
	
    @Override
    public void onResume() {
    	super.onResume();
    	CookieSyncManager.getInstance().stopSync();
    	webView.resume();
    };
    
    @Override
    public void onPause() {
    	super.onPause();
    	CookieSyncManager.getInstance().sync();
    	webView.pause();
    };    
    
}
