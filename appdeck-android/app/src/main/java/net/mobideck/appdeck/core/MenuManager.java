package net.mobideck.appdeck.core;

import android.animation.Animator;
import android.animation.ValueAnimator;
import android.graphics.drawable.Drawable;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarDrawerToggle;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.WebView.SmartWebView;
import net.mobideck.appdeck.util.Utils;

public class MenuManager {

    private DrawerLayout mDrawerLayout;
    private ActionBarDrawerToggle mActionBarDrawerToggle;
    private FrameLayout mDrawerLeftMenu;
    private FrameLayout mDrawerRightMenu;
    private ActionBar mActionBar;
    private SmartWebView mLeftMenuWebView;
    private SmartWebView mRightMenuWebView;

    private Drawable mUpArrow;
    private Drawable mCloseArrow;

    public MenuManager(DrawerLayout drawerLayout, ActionBarDrawerToggle actionBarDrawerToggle, FrameLayout drawerLeftMenu, FrameLayout drawerRightMenu, ActionBar actionBar/*, SmartWebView leftMenuWebView, SmartWebView rightMenuWebView*/, Drawable upArrow, Drawable closeArrow) {
        mDrawerLayout = drawerLayout;
        mActionBarDrawerToggle = actionBarDrawerToggle;
        mDrawerLeftMenu = drawerLeftMenu;
        mDrawerRightMenu = drawerRightMenu;
        mActionBar = actionBar;
        //mLeftMenuWebView = leftMenuWebView;
        //mRightMenuWebView = rightMenuWebView;

        mUpArrow = upArrow;
        mCloseArrow = closeArrow;
    }

    public void setLeftMenuWebView(SmartWebView leftMenuWebView) {
        mLeftMenuWebView = leftMenuWebView;
    }

    public void setRightMenuWebView(SmartWebView rightMenuWebView) {
        mRightMenuWebView = rightMenuWebView;
    }

    public void toggleMenu()
    {
        if (isMenuOpen())
            closeMenu();
        else
            openMenu();
    }

    public void toggleLeftMenu()
    {
        if (isMenuOpen())
            closeMenu();
        else
            openLeftMenu();
    }

    public void toggleRightMenu()
    {
        if (isMenuOpen())
            closeMenu();
        else
            openRightMenu();
    }

    public boolean isMenuOpen()
    {
        if (mDrawerLayout == null)
            return false;
        if (mDrawerLeftMenu != null && mDrawerLayout.isDrawerOpen(mDrawerLeftMenu))
            return true;
        if (mDrawerRightMenu != null && mDrawerLayout.isDrawerOpen(mDrawerRightMenu))
            return true;
        return false;
    }

    public boolean isLeftMenuOpen()
    {
        if (mDrawerLayout == null)
            return false;
        if (mDrawerLeftMenu != null && mDrawerLayout.isDrawerOpen(mDrawerLeftMenu))
            return true;
        return false;
    }

    public boolean isRightMenuOpen()
    {
        if (mDrawerLayout == null)
            return false;
        if (mDrawerRightMenu != null && mDrawerLayout.isDrawerOpen(mDrawerRightMenu))
            return true;
        return false;
    }

    public void openLeftMenu()
    {
        closeMenu();
        if (menuEnabled == false)
            return;
        if (mDrawerLayout == null)
            return;
        if (mDrawerLeftMenu != null)
            mDrawerLayout.openDrawer(mDrawerLeftMenu);
    }

    public void openRightMenu()
    {
        closeMenu();
        if (menuEnabled == false)
            return;
        if (mDrawerLayout == null)
            return;
        if (mDrawerRightMenu != null)
            mDrawerLayout.openDrawer(mDrawerRightMenu);
    }

    public void openMenu()
    {
        closeMenu();
        if (menuEnabled == false)
            return;
        if (mDrawerLayout == null)
            return;
        if (mDrawerLeftMenu != null)
        {
            mDrawerLayout.openDrawer(mDrawerLeftMenu);
            return;
        }
        if (mDrawerRightMenu != null)
        {
            mDrawerLayout.openDrawer(mDrawerRightMenu);
            return;
        }
    }

    public void closeMenu()
    {
        if (mDrawerLayout == null)
            return;
        mDrawerLayout.closeDrawers();
    }

    private boolean menuEnabled = true;

    public void disableMenu()
    {
        menuEnabled = false;
        closeMenu();
        if (mDrawerLayout == null)
            return;

        AppDeck appDeck = AppDeckApplication.getAppDeck();

        if (appDeck.appConfig.leftMenu != null && appDeck.appConfig.leftMenu.url != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, mDrawerLeftMenu);
        if (appDeck.appConfig.rightMenu != null && appDeck.appConfig.rightMenu.url != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, mDrawerRightMenu);

        /*mActionBar.setDisplayHomeAsUpEnabled(false); // show icon on the left of logo
        mActionBar.setDisplayShowHomeEnabled(true); // show logo
        mActionBar.setHomeButtonEnabled(true); // ???*/
    }

    public void enableMenu()
    {
        menuEnabled = true;
        if (mDrawerLayout == null)
            return;

        AppDeck appDeck = AppDeckApplication.getAppDeck();

        if (appDeck.appConfig.leftMenu != null && appDeck.appConfig.leftMenu.url != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, mDrawerLeftMenu);
        if (appDeck.appConfig.rightMenu != null && appDeck.appConfig.rightMenu.url != null)
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, mDrawerRightMenu);

        /*mActionBar.setDisplayHomeAsUpEnabled(true); // show icon on the left of logo
        mActionBar.setDisplayShowHomeEnabled(true); // make icon + logo + title clickable*/
    }

    private boolean mMenuArrowIsShown = false;
    public void setMenuArrow(boolean show)
    {
        if (mCloseIsShown) {
            shouldShowCloseButton(false);
        }

        if (mMenuArrowIsShown == show)
            return;
        mMenuArrowIsShown = show;
        float start = (show ? 0 : 1);
        float end = (show ? 1 : 0);
        ValueAnimator anim = ValueAnimator.ofFloat(start, end);
        anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator valueAnimator) {
                float slideOffset = (Float) valueAnimator.getAnimatedValue();
                mActionBarDrawerToggle.onDrawerSlide(mDrawerLayout, slideOffset);
            }
        });
        anim.setInterpolator(new DecelerateInterpolator());
        // You can change this duration to more closely match that of the default animation.
        anim.setDuration(500);
        anim.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                if (mMenuArrowIsShown == false)
                    mActionBarDrawerToggle.setDrawerIndicatorEnabled(true);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                if (mMenuArrowIsShown)
                    mActionBarDrawerToggle.setDrawerIndicatorEnabled(false);
                else
                    mActionBarDrawerToggle.setDrawerIndicatorEnabled(true);
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        anim.start();
    }

    private boolean mCloseIsShown = false;
    public void shouldShowCloseButton(boolean showCloseButton)
    {
        if (mCloseIsShown == showCloseButton)
            return;
        if (showCloseButton) {
            mCloseIsShown = true;
            mMenuArrowIsShown = true;
            mActionBar.setDisplayHomeAsUpEnabled(true);
            mActionBar.setHomeAsUpIndicator(mCloseArrow);
        } else {
            mCloseIsShown = true;
            mMenuArrowIsShown = true;
            mActionBar.setDisplayHomeAsUpEnabled(true);
            mActionBar.setHomeAsUpIndicator(mUpArrow);
        }
    }

    public void evaluateJavascript(String js)
    {
        if (mLeftMenuWebView != null)
            mLeftMenuWebView.evaluateJavascript(js, null);
        if (mRightMenuWebView != null)
            mRightMenuWebView.evaluateJavascript(js, null);
    }
    public void reload() {
        if (mLeftMenuWebView != null)
            mLeftMenuWebView.reload();
        if (mRightMenuWebView != null)
            mRightMenuWebView.reload();
    }
}
