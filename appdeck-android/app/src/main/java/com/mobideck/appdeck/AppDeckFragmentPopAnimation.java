package com.mobideck.appdeck;

import android.animation.Animator;
import android.animation.Animator.AnimatorListener;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.graphics.Point;
import android.view.Display;
import android.view.View;
import android.view.animation.DecelerateInterpolator;

public class AppDeckFragmentPopAnimation {
	AppDeckFragment from;
	AppDeckFragment to;
	
	public AppDeckFragmentPopAnimation(AppDeckFragment from, AppDeckFragment to)
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

				to.loader.getSupportFragmentManager().beginTransaction().show(to).commitAllowingStateLoss();
			}
			
			@Override
			public void onAnimationRepeat(Animator animation) {

				
			}
			
			@Override
			public void onAnimationEnd(Animator animation)
			{
				to.loader.getSupportFragmentManager().beginTransaction().remove(from).commitAllowingStateLoss();
				to.setIsMain(true);
			}
			
			@Override
			public void onAnimationCancel(Animator animation) {

				to.loader.getSupportFragmentManager().beginTransaction().remove(from).commitAllowingStateLoss();
				to.setIsMain(true);
			}
		});
        //set.setInterpolator(new AccelerateDecelerateInterpolator());
        
       	Display display = from.getActivity().getWindowManager().getDefaultDisplay();
    	//float width = (float)display.getWidth();
    	//float height = (float)display.getHeight();

        Point size = new Point();
        display.getSize(size);
        float width = size.x;
        
        set.playTogether(
                ObjectAnimator.ofFloat(toView, "translationX", -width/3, 0),
                //ObjectAnimator.ofFloat(toView, "scaleX", 0.8f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "scaleY", 0.8f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "alpha", 0.8f, 1.0f),

                ObjectAnimator.ofFloat(fromView, "translationX", 0, width)//,
                //ObjectAnimator.ofFloat(fromView, "scaleX", 1.0f, 1.2f),
                //ObjectAnimator.ofFloat(fromView, "scaleY", 1.0f, 1.2f),
                //ObjectAnimator.ofFloat(fromView, "alpha", 1.0f, 0.0f)                
        );
        set.setInterpolator(new DecelerateInterpolator());
        set.setDuration(350).start();
	}
}
