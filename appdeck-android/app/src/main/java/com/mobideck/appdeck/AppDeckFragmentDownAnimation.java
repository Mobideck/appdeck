package com.mobideck.appdeck;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.graphics.Point;
import android.support.v4.view.animation.LinearOutSlowInInterpolator;
import android.view.Display;
import android.view.View;
import android.view.animation.DecelerateInterpolator;

/**
 * Created by mathieudekermadec on 06/03/15.
 */
public class AppDeckFragmentDownAnimation {
    AppDeckFragment from;
    AppDeckFragment to;

    public AppDeckFragmentDownAnimation(AppDeckFragment from, AppDeckFragment to)
    {
        this.from = from;
        this.to = to;
    }

    public void start()
    {
        final View fromView = from.getView();
        final View toView = to.getView();

        if (fromView == null)
            return;
        if (toView == null)
            return;

        fromView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        toView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        AnimatorSet set = new AnimatorSet();
        set.addListener(new Animator.AnimatorListener() {

            @Override
            public void onAnimationStart(Animator animation) {

                to.loader.getSupportFragmentManager().beginTransaction().show(to).commitAllowingStateLoss();
            }

            @Override
            public void onAnimationRepeat(Animator animation) {


            }

            @Override
            public void onAnimationEnd(Animator animation) {
                fromView.setLayerType(View.LAYER_TYPE_NONE, null);
                toView.setLayerType(View.LAYER_TYPE_NONE, null);

                to.loader.getSupportFragmentManager().beginTransaction().remove(from).commitAllowingStateLoss();
                to.setIsMain(true);
            }

            @Override
            public void onAnimationCancel(Animator animation) {
                fromView.setLayerType(View.LAYER_TYPE_NONE, null);
                toView.setLayerType(View.LAYER_TYPE_NONE, null);

                to.loader.getSupportFragmentManager().beginTransaction().remove(from).commitAllowingStateLoss();
                to.setIsMain(true);
            }
        });
        //set.setInterpolator(new AccelerateDecelerateInterpolator());

        Display display = from.loader.getWindowManager().getDefaultDisplay();
        //float width = (float)display.getWidth();
        //float height = (float)display.getHeight();

        Point size = new Point();
        display.getSize(size);
        float height = size.y;

        set.playTogether(
                ObjectAnimator.ofFloat(fromView, "translationY", 0, -height)//,
                //ObjectAnimator.ofFloat(toView, "scaleX", 0.8f, 1.0f),
                //ObjectAnimator.ofFloat(toView, "scaleY", 0.8f, 1.0f),
                //ObjectAnimator.ofFloat(fromView, "alpha", 1.0f, 0.8f)//,

                //ObjectAnimator.ofFloat(fromView, "translationX", 0, width)//,
                //ObjectAnimator.ofFloat(fromView, "scaleX", 1.0f, 1.2f),
                //ObjectAnimator.ofFloat(fromView, "scaleY", 1.0f, 1.2f),
                //ObjectAnimator.ofFloat(fromView, "alpha", 1.0f, 0.0f)
        );
        //set.setInterpolator(new DecelerateInterpolator());
        set.setInterpolator(new LinearOutSlowInInterpolator());
        set.setDuration(350).start();
    }

}
