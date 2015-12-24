package com.mobideck.appdeck;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.graphics.Point;
import android.support.v4.view.animation.FastOutSlowInInterpolator;
import android.view.Display;
import android.view.View;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.LinearInterpolator;

/**
 * Created by mathieudekermadec on 06/03/15.
 */
public class AppDeckFragmentUpAnimation {
    AppDeckFragment from;
    AppDeckFragment to;

    public AppDeckFragmentUpAnimation(AppDeckFragment from, AppDeckFragment to)
    {
        this.from = from;
        this.to = to;
    }

    //@SuppressWarnings("deprecation")
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

        set.addListener(new Animator.AnimatorListener() {

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

        Display display = from.loader.getWindowManager().getDefaultDisplay();

        Point size = new Point();
        display.getSize(size);

        float height = size.y;
        //float height = (float)display.getHeight();

        set.playTogether(

                ObjectAnimator.ofFloat(toView, "translationY", -height, 0)//,
                //ObjectAnimator.ofFloat(fromView, "scaleX", 1.0f, 0.9f),
                //ObjectAnimator.ofFloat(fromView, "scaleY", 1.0f, 0.9f),
                //ObjectAnimator.ofFloat(toView, "alpha", 0.8f, 1.0f)//,

                //ObjectAnimator.ofInt(fromView, "color", Color.BLUE, Color.BLACK),




                //ObjectAnimator.ofFloat(toView, "translationY", 0, 0)//,
                //ObjectAnimator.ofFloat(toView, "scaleX", 1.1f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "scaleY", 1.1f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "alpha", 0.0f, 1.0f)


        );
        //set.setInterpolator(new AccelerateDecelerateInterpolator());
        //set.setInterpolator(new DecelerateInterpolator());
        set.setInterpolator(new FastOutSlowInInterpolator());
        //set.setInterpolator(new BounceInterpolator());
        //set.setInterpolator(new BounceInterpolator());
        set.setDuration(350).start();
    }
}
