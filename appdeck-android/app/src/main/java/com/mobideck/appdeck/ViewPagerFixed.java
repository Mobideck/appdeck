package com.mobideck.appdeck;

import android.animation.Animator;
import android.support.v4.view.ViewPager;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewAnimationUtils;

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

		try {
			return super.onInterceptTouchEvent(event);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
    }

    public void setChildId(int id) {
        this.childId = id;
    }

	/* material design test */
/*	@Override
	public boolean onTouch(View view, MotionEvent motionEvent) {
		if (motionEvent.getAction() == MotionEvent.ACTION_UP) {
			// get the final radius for the clipping circle
			int finalRadius = Math.max(myView.getWidth(), myView.getHeight()) / 2;

			// create the animator for this view (the start radius is zero)
			Animator anim =
					ViewAnimationUtils.createCircularReveal(myView, (int) motionEvent.getX(), (int) motionEvent.getY(), 0, finalRadius);

			// make the view visible and start the animation
			myView.setVisibility(View.VISIBLE);
			anim.start();
		}
		return false;
	}*/

}
