package com.mobideck.appdeck;

import android.animation.Animator;
import android.animation.Animator.AnimatorListener;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.view.Display;
import android.view.View;
import android.view.animation.DecelerateInterpolator;

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
		View fromView = from.getView();
		View toView = to.getView();
		
		if (fromView == null)
			return;
		if (toView == null)
			return;		
        AnimatorSet set = new AnimatorSet();
        set.addListener(new AnimatorListener() {
			
			@Override
			public void onAnimationStart(Animator animation) {

				
			}
			
			@Override
			public void onAnimationRepeat(Animator animation) {

				
			}
			
			@Override
			public void onAnimationEnd(Animator animation)
			{
				from.loader.getSupportFragmentManager().beginTransaction().hide(from).commitAllowingStateLoss();
			}
			
			@Override
			public void onAnimationCancel(Animator animation) {

				from.loader.getSupportFragmentManager().beginTransaction().hide(from).commitAllowingStateLoss();
			}
		});        
        
    	Display display = from.getActivity().getWindowManager().getDefaultDisplay();
    	
		float width = (float)display.getWidth();
    	//float height = (float)display.getHeight();        
        
        set.playTogether(
        		
        		ObjectAnimator.ofFloat(fromView, "translationX", 0, -width/3),
                //ObjectAnimator.ofFloat(fromView, "scaleX", 1.0f, 0.9f),
                //ObjectAnimator.ofFloat(fromView, "scaleY", 1.0f, 0.9f),
                ObjectAnimator.ofFloat(fromView, "alpha", 1.0f, 0.8f),
                
                //ObjectAnimator.ofInt(fromView, "color", Color.BLUE, Color.BLACK),

                

        		
        		ObjectAnimator.ofFloat(toView, "translationX", width, 0)//,
                //ObjectAnimator.ofFloat(toView, "scaleX", 1.1f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "scaleY", 1.1f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "alpha", 0.0f, 1.0f)
        		

        );
        //set.setInterpolator(new AccelerateDecelerateInterpolator());
        set.setInterpolator(new DecelerateInterpolator());
        //set.setInterpolator(new BounceInterpolator());        
        //set.setInterpolator(new BounceInterpolator());
        set.setDuration(300).start();
	}
}
