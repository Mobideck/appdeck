package net.mobideck.appdeck.WebView;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.RippleDrawable;
import android.os.Build;
import android.support.v4.widget.NestedScrollView;
import android.util.AttributeSet;
import android.view.View;

import net.mobideck.appdeck.AppDeckActivity;
import net.mobideck.appdeck.R;


public class NestedScrollWebView extends NestedScrollView {

    public static String TAG = "NestedScrollWebView";

    // store last position of x/y touch
    float lastTouchX;
    float lastTouchY;

    // rippleEffect
    View mRippleView;

    private SmartWebView mSmartWebView;

    public NestedScrollWebView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        preConfigure(context);
    }

    public NestedScrollWebView(Context context, AttributeSet attrs) {
        super(context, attrs);
        preConfigure(context);
    }

    public NestedScrollWebView(Context context) {
        super(context);
        preConfigure(context);
    }

    public void setSmartWebView(SmartWebView smartWebView) {
        mSmartWebView = smartWebView;
    }

    public int pageHeight;

    @Override
    protected void onSizeChanged (int w, int h, int ow, int oh)
    {
        super.onSizeChanged(w, h, ow, oh);
        pageHeight = h;
    }

    private void preConfigure(Context context) {

        setOnScrollChangeListener(new NestedScrollView.OnScrollChangeListener() {
            @Override
            public void onScrollChange(NestedScrollView v, int scrollX, int scrollY, int oldScrollX, int oldScrollY) {
                if (mSmartWebView != null)
                    mSmartWebView.onNestedScrollChange(NestedScrollWebView.this, pageHeight, scrollX, scrollY, oldScrollX, oldScrollY);
            }
        });
        /*
        int[] attrs = new int[]{R.attr.selectableItemBackground};
        TypedArray typedArray = context.obtainStyledAttributes(attrs);
        int backgroundResource = typedArray.getResourceId(0, 0);
        setForeground(context.getResources().getDrawable(backgroundResource));
        typedArray.recycle();
*/
    }
/*
    @Override
    public boolean onTouchEvent(MotionEvent event) {

        lastTouchX = event.getX();
        lastTouchY = event.getY();
        Log.d(TAG, "touch :"+lastTouchX+"x"+lastTouchY);

        switch (event.getAction()) {
            case MotionEvent.ACTION_UP: {
                Log.d(TAG, "touch UP :"+lastTouchX+"x"+lastTouchY);
                showRippleEffect();
            }
        }
        return super.onTouchEvent(event);
    }
*/
    private void showRippleEffect() {
        //mRippleView.setBackgroundColor(Color.parseColor("#ffffff"));


        AppDeckActivity activity = (AppDeckActivity)getContext();

        View rippleView = activity.findViewById(R.id.ripple);


        Drawable background = rippleView.getBackground();

        if(Build.VERSION.SDK_INT >= 21 && background instanceof RippleDrawable)
        {
            final RippleDrawable rippleDrawable = (RippleDrawable) background;

//            rippleDrawable.setBounds(new Rect(0, getScrollY(), getWidth(), getScrollY() + getHeight()));

            rippleDrawable.setHotspot(lastTouchX /* + getScrollX()*/, lastTouchY /*+ getScrollY()*/);

            rippleDrawable.setState(new int[]{android.R.attr.state_pressed, android.R.attr.state_enabled});
/*
            Handler handler = new Handler();

            handler.postDelayed(new Runnable()
            {
                @Override public void run()
                {
                    rippleDrawable.setState(new int[]{});
                }
            }, 200);*/
        }
    }

    private void forceRippleAnimation(float x, float y){
        Drawable background = getForeground();
        if(background instanceof RippleDrawable){
            RippleDrawable ripple = (RippleDrawable)background;
            ripple.setHotspot(x, y);
            ripple.setVisible (true, true);
        }

    }

}
