package com.mobideck.appdeck;

import com.mobideck.appdeck.R;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.graphics.drawable.shapes.Shape;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

public class PopUpFragment extends AppDeckFragment {

	String url;
	
    AppDeckFragment origin;
    
    AppDeck appDeck;
    
    FrameLayout bgLayout;
    FrameLayout containerLayout;
    
    private WebView webView;
    
    private View bgView;
    
    PopOverFragment self;
    
    PopUpFragment(AppDeckFragment origin, String url)
	{
		appDeck = AppDeck.getInstance();
		this.origin = origin;
/*		self = this;
		url = origin.resolveURL(call.param.path("url").textValue());
	    width = call.param.path("width").floatValue();
	    height = call.param.path("height").floatValue();
	    alpha = call.param.path("alpha").floatValue();
	    tint = call.param.path("tint").textValue();
	    arrow = call.param.path("arrow").textValue();
	    title = call.param.path("title").textValue();
	    bgcolor = call.param.path("bgcolor").textValue();
	    border = call.param.path("border").floatValue();
	    radius = call.param.path("radius").floatValue();*/
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
    	
    	// set size
    	LayoutParams params = containerLayout.getLayoutParams();
    	float density = getResources().getDisplayMetrics().density;
    	//params.width = (int)(width * density);
    	//params.height = (int)(height * density);
    	containerLayout.setLayoutParams(params);
    	
    	webView = new SmartWebView(this);
    	containerLayout.addView(webView, new ViewGroup.LayoutParams(
		        ViewGroup.LayoutParams.MATCH_PARENT,
		        ViewGroup.LayoutParams.MATCH_PARENT));
    	webView.loadUrl(url);
    	
    	RelativeLayout.LayoutParams webViewLayoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);//(android.widget.RelativeLayout.LayoutParams) containerLayout.getLayoutParams();
    	int margin = (int)(10 * density);
    	webViewLayoutParams.setMargins(margin, margin, margin, margin);
    	webView.setLayoutParams(webViewLayoutParams);
    	
    	RoundRectShape rs = new RoundRectShape(new float[] { 10, 10, 10, 10, 10, 10, 10, 10 }, null, null);
    	ShapeDrawable sd = new CustomShapeDrawable(rs, Color.RED, Color.WHITE, 20);
    	if (Build.VERSION.SDK_INT > Build.VERSION_CODES.JELLY_BEAN)
    		webView.setBackground(sd);
    	
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
	
}
