package com.mobideck.appdeck;

import android.animation.Animator;
import android.animation.Animator.AnimatorListener;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.graphics.Point;
import android.support.v4.view.animation.LinearOutSlowInInterpolator;
import android.view.Display;
import android.view.View;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.LinearInterpolator;

public class AppDeckFragmentPushAnimation {
	AppDeckFragment from;
	AppDeckFragment to;
	
	public AppDeckFragmentPushAnimation(AppDeckFragment from, AppDeckFragment to)
	{
		this.from = from;
		this.to = to;
	}
	
	@SuppressWarnings("deprecation")
	public void start()
	{
		final View fromView = from.getView();
		final View toView = to.getView();

		fromView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
		toView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

		if (fromView == null)
			return;
		if (toView == null)
			return;		
        AnimatorSet set = new AnimatorSet();
        //ValueAnimator.setFrameDelay(24);
        //set.setInterpolator(new LinearInterpolator());
        set.addListener(new AnimatorListener() {
			
			@Override
			public void onAnimationStart(Animator animation) {

				
			}
			
			@Override
			public void onAnimationRepeat(Animator animation) {

				
			}
			
			@Override
			public void onAnimationEnd(Animator animation) {
				fromView.setLayerType(View.LAYER_TYPE_NONE, null);
				toView.setLayerType(View.LAYER_TYPE_NONE, null);
				from.loader.getSupportFragmentManager().beginTransaction().hide(from).commitAllowingStateLoss();
			}
			
			@Override
			public void onAnimationCancel(Animator animation) {
				fromView.setLayerType(View.LAYER_TYPE_NONE, null);
				toView.setLayerType(View.LAYER_TYPE_NONE, null);
				from.loader.getSupportFragmentManager().beginTransaction().hide(from).commitAllowingStateLoss();
			}
		});        
        
    	Display display = from.getActivity().getWindowManager().getDefaultDisplay();

        Point size = new Point();
        display.getSize(size);

        float width = size.x;
//        float width = (float)display.getWidth();
    	//float height = (float)display.getHeight();        
        
        set.playTogether(
        		
        		ObjectAnimator.ofFloat(fromView, "translationX", 0, -width/3),
                //ObjectAnimator.ofFloat(fromView, "scaleX", 1.0f, 0.9f),
                //ObjectAnimator.ofFloat(fromView, "scaleY", 1.0f, 0.9f),

                //ObjectAnimator.ofFloat(fromView, "alpha", 1.0f, 0.8f),
                
                //ObjectAnimator.ofInt(fromView, "color", Color.BLUE, Color.BLACK),

                

        		
        		ObjectAnimator.ofFloat(toView, "translationX", width, 0)//,
                //ObjectAnimator.ofFloat(toView, "scaleX", 1.1f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "scaleY", 1.1f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "alpha", 0.0f, 1.0f)
        		

        );
        //set.setInterpolator(new AccelerateDecelerateInterpolator());
        set.setInterpolator(new LinearOutSlowInInterpolator());
        //set.setInterpolator(new BounceInterpolator());        
        //set.setInterpolator(new BounceInterpolator());
        set.setDuration(350).start();
	}
}
