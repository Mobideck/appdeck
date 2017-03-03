package net.mobideck.appdeck.core;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Point;
import android.support.design.widget.AppBarLayout;
import android.support.v4.view.animation.FastOutSlowInInterpolator;
import android.support.v4.view.animation.LinearOutSlowInInterpolator;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.ViewAnimator;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckApplication;

public class PageAnimation {

    public static boolean isAnimating = false;

    public static int ANIMATION_DELAY = 350;
    private static float DARK_VIEW_ALPHA = 0.75f;
    private static float POPUP_SCALE = 0.80f;

    private Context mContext;

    private View mFromView;
    private View mToView;
    private View mDarkView;

    private PageAnimationListener mAnimationListener;

    public interface PageAnimationListener {

        void onAnimationEnd();
    }

    PageAnimation(Context context) {
        mContext = context;
    }

    private float getWidth() {
        Display display = AppDeckApplication.getActivity().getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        float width = size.x;
        return width;
    }

    private float getHeight() {
        Display display = AppDeckApplication.getActivity().getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        float height = size.y;
        return height;
    }

    private void reset(View view) {
        view.setScaleX(1f);
        view.setScaleY(1f);
        view.setTranslationX(0f);
        view.setTranslationY(0f);
        view.setAlpha(1f);
    }

    private View getCurrentView() {
        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
        if (viewContainer.getChildCount() == 0)
            return null;
        while (viewContainer.getChildCount() > 1)
        {
            viewContainer.removeViewAt(0);
        }
        View currentView = viewContainer.getChildAt(0);
        return currentView;
    }

    private View createDarkView() {
        View darkView = new View(mContext);
        darkView.setBackgroundColor(Color.BLACK);
        return darkView;
    }

    public void root(AppDeckView appDeckView)
    {
        View toView = appDeckView.getView();
        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
        viewContainer.removeAllViews();
        viewContainer.addView(toView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        if (mAnimationListener != null)
            mAnimationListener.onAnimationEnd();
    }

    public void push(AppDeckView appDeckView)
    {
        View toView = appDeckView.getView();

        mFromView = getCurrentView();
        mToView = toView;
        mDarkView = createDarkView();

        if (mFromView == null || mToView == null)
            return;

        PageAnimation.isAnimating = true;

        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
        viewContainer.addView(mDarkView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        viewContainer.addView(mToView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        float width = getWidth();

        // setup initial state
        reset(mFromView);
        reset(mToView);
        //mFromView.setTranslationX(0);
        mDarkView.setAlpha(0);
        mToView.setTranslationX(width);

        // animate
        mFromView.animate()
                .setDuration(ANIMATION_DELAY)
                .translationX(-width/3)
                .setInterpolator(new FastOutSlowInInterpolator())
                .withLayer()
                .withEndAction(new Runnable(){
                    public void run(){
                        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
                        viewContainer.removeView(mDarkView);
                        viewContainer.removeView(mFromView);
                        PageAnimation.isAnimating = false;
                        if (mAnimationListener != null)
                            mAnimationListener.onAnimationEnd();
                    }
                });

        mDarkView.animate()
                .setDuration(ANIMATION_DELAY)
                .alpha(PageAnimation.DARK_VIEW_ALPHA)
                .setInterpolator(new FastOutSlowInInterpolator())
                .withLayer();

        mToView.animate()
                .setDuration(ANIMATION_DELAY)
                .translationX(0)
                .setInterpolator(new LinearOutSlowInInterpolator())
                .withLayer();
    }

    public void pop(AppDeckView appDeckView)
    {
        View toView = appDeckView.getView();

        mFromView = getCurrentView();
        mToView = toView;
        mDarkView = createDarkView();

        if (mFromView == null || mToView == null)
            return;

        PageAnimation.isAnimating = true;

        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
        viewContainer.addView(mToView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        viewContainer.addView(mDarkView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        viewContainer.bringChildToFront(mFromView);

        float width = getWidth();

        // setup initial state
        reset(mFromView);
        reset(mToView);
        //mFromView.setTranslationX(0);
        mDarkView.setAlpha(DARK_VIEW_ALPHA);
        mToView.setTranslationX(-width/3);

        // animate
        mFromView.animate()
                .setDuration(ANIMATION_DELAY)
                .translationX(width)
                .setInterpolator(new FastOutSlowInInterpolator())
                .withLayer()
                .withEndAction(new Runnable(){
                    public void run(){
                        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
                        viewContainer.removeView(mFromView);
                        viewContainer.removeView(mDarkView);
                        PageAnimation.isAnimating = false;
                        if (mAnimationListener != null)
                            mAnimationListener.onAnimationEnd();
                    }
                });

        mDarkView.animate()
                .setDuration(ANIMATION_DELAY)
                .alpha(0)
                .setInterpolator(new FastOutSlowInInterpolator())
                .withLayer();

        mToView.animate()
                .setDuration(ANIMATION_DELAY)
                .translationX(0)
                .setInterpolator(new LinearOutSlowInInterpolator())
                .withLayer();
    }

    public void setAnimationListener(PageAnimationListener animationListener) {
        mAnimationListener = animationListener;
    }

    public void popup(AppDeckView appDeckView)
    {
        View toView = appDeckView.getView();
        mFromView = getCurrentView();
        mToView = toView;
        mDarkView = createDarkView();

        if (mFromView == null || mToView == null)
            return;

        PageAnimation.isAnimating = true;

        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
        viewContainer.addView(mDarkView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        viewContainer.addView(mToView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        final float height = getHeight();

        // setup initial state

        final AppBarLayout appBarLayout = AppDeckApplication.getActivity().getAppBarLayout();

        reset(mFromView);
        reset(mToView);
        mDarkView.setAlpha(0);
        mToView.setTranslationY(height /*+ appBarLayout.getHeight()*/);

        // animate
        appBarLayout.animate()
                .setDuration(ANIMATION_DELAY)
                .setInterpolator(new LinearOutSlowInInterpolator())
                .translationY(-appBarLayout.getHeight())
                .withLayer()
                .withEndAction(new Runnable(){
                    public void run(){
                        AppDeckApplication.getActivity().menuManager.shouldShowCloseButton(true);
                        appBarLayout.setTranslationY(height);
                        appBarLayout.animate()
                                .setDuration(ANIMATION_DELAY)
                                .translationY(0)
                                .setInterpolator(new LinearOutSlowInInterpolator())
                                .withLayer();

                        mToView.animate()
                                .setDuration(ANIMATION_DELAY)
                                .translationY(0)
                                .setInterpolator(new LinearOutSlowInInterpolator())
                                .withLayer();
                    }
                });

        mFromView.animate()
                .setDuration(ANIMATION_DELAY * 2)
                .scaleX(POPUP_SCALE)
                .scaleY(POPUP_SCALE)
                .setInterpolator(new FastOutSlowInInterpolator())
                .withLayer()
                .withEndAction(new Runnable(){
                    public void run(){
                        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
                        viewContainer.removeView(mDarkView);
                        viewContainer.removeView(mFromView);
                        PageAnimation.isAnimating = false;
                        if (mAnimationListener != null)
                            mAnimationListener.onAnimationEnd();
                    }
                });

        mDarkView.animate()
                .setDuration(ANIMATION_DELAY * 2)
                .alpha(DARK_VIEW_ALPHA)
                .setInterpolator(new FastOutSlowInInterpolator())
                .withLayer();
    }

    public void popdown(final AppDeckView appDeckView)
    {
        View toView = appDeckView.getView();

        mFromView = getCurrentView();
        mToView = toView;
        mDarkView = createDarkView();

        if (mFromView == null || mToView == null)
            return;

        PageAnimation.isAnimating = true;

        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
        viewContainer.addView(mToView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        viewContainer.addView(mDarkView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        viewContainer.bringChildToFront(mFromView);

        final AppBarLayout appBarLayout = AppDeckApplication.getActivity().getAppBarLayout();

        final float height = getHeight();

        // setup initial state
        reset(mFromView);
        reset(mToView);
        mDarkView.setAlpha(DARK_VIEW_ALPHA);
        mToView.setScaleX(POPUP_SCALE);
        mToView.setScaleY(POPUP_SCALE);

        // animate

        appBarLayout.animate()
                .setDuration(ANIMATION_DELAY)
                .setInterpolator(new LinearOutSlowInInterpolator())
                .translationY(height)
                .withLayer()
                .withEndAction(new Runnable(){
                    public void run(){
                        AppDeckApplication.getActivity().menuManager.shouldShowCloseButton(appDeckView.viewState.isPopUp);
                        appBarLayout.setTranslationY(-appBarLayout.getHeight());
                        appBarLayout.animate()
                                .setDuration(ANIMATION_DELAY)
                                .translationY(0)
                                .setInterpolator(new LinearOutSlowInInterpolator())
                                .withLayer();
                    }
                });

        mFromView.animate()
                //.setStartDelay(ANIMATION_DELAY)
                .setDuration(ANIMATION_DELAY)
                .translationY(height)
                .setInterpolator(new FastOutSlowInInterpolator())
                .withLayer();

        mDarkView.animate()
                .setDuration(ANIMATION_DELAY * 2)
                .alpha(0)
                .setInterpolator(new FastOutSlowInInterpolator())
                .withLayer();

        mToView.animate()
                .setDuration(ANIMATION_DELAY * 2)
                .scaleX(1f)
                .scaleY(1f)
                .setInterpolator(new LinearOutSlowInInterpolator())
                .withLayer()
                .withEndAction(new Runnable(){
                    public void run(){
                        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
                        viewContainer.removeView(mFromView);
                        viewContainer.removeView(mDarkView);
                        PageAnimation.isAnimating = false;
                        if (mAnimationListener != null)
                            mAnimationListener.onAnimationEnd();
                    }
                });
    }

}