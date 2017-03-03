package net.mobideck.appdeck.core;

import android.support.v4.view.ViewPager;
import android.view.View;

import net.mobideck.appdeck.config.MenuEntry;
import net.mobideck.appdeck.config.ViewConfig;

import java.util.List;

public abstract class AppDeckView {

    public ViewState viewState = null;

    public abstract View getView();

    public abstract void destroy();

    public abstract void onResume();

    public abstract void onPause();

    public abstract void onShow();

    public abstract void onHide();

    public abstract boolean shouldOverrideBackButton();

    public abstract void evaluateJavascript(String js);

    public abstract ViewConfig getViewConfig();

    public abstract String getURL();

    public abstract String resolveURL(String relativeURL);

    public abstract void loadUrl(String relativeURL);

    public abstract ViewPager getViewPager();

}
