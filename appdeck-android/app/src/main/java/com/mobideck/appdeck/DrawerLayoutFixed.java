package com.mobideck.appdeck;

import android.content.Context;
import android.support.v4.widget.DrawerLayout;
import android.util.AttributeSet;
import android.view.MotionEvent;

/**
 * Created by mathieudekermadec on 23/11/15.
 */
public class DrawerLayoutFixed extends DrawerLayout {
    public DrawerLayoutFixed(Context context) {
        super(context);
    }

    public DrawerLayoutFixed(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public DrawerLayoutFixed(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        try {
            return super.onInterceptTouchEvent(ev);
        } catch (Throwable t) {
            t.printStackTrace();
            return false;
        }
    }
}
