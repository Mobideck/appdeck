package com.mobideck.appdeck;

import android.support.v4.view.ViewPager;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;

public class ViewPagerFixed extends ViewPager {
	public ViewPagerFixed(Context context) {
	    super(context);
	}

	public ViewPagerFixed(Context context, AttributeSet attrs) {
	    super(context, attrs);
	}
/*
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
	    try {
	        return super.onTouchEvent(ev);
	    } catch (IllegalArgumentException ex) {
	        ex.printStackTrace();
	    }
	    return false;
	}

	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
	    try {
	        return super.onInterceptTouchEvent(ev);
	    } catch (IllegalArgumentException ex) {
	        ex.printStackTrace();
	    }
	    return false;
	}*/

    private int childId;



    @Override
    public boolean onInterceptTouchEvent(MotionEvent event) {
        //return false;
        int count = getAdapter().getCount();
        if (count <= 1)
            return false;
        return super.onInterceptTouchEvent(event);
        /*
        if (childId > 0) {
            ViewPager pager = (ViewPager)findViewById(childId);

            if (pager != null) {
                pager.requestDisallowInterceptTouchEvent(true);
            }

        }

        return super.onInterceptTouchEvent(event);*/
    }

    public void setChildId(int id) {
        this.childId = id;
    }

}
