package com.mobideck.appdeck;

import android.content.Intent;
import android.os.Bundle;

/**
 * Created by mathieudekermadec on 19/02/15.
 */
public interface SmartWebViewInterface {

    public String getUrl();

    public void setTouchDisabled(boolean touchDisabled);
    public boolean getTouchDisabled();

    public void pause();
    public void resume();
    public void clean();
    public void unloadPage();

    public boolean smartWebViewRestoreState(Bundle savedInstanceState);

    public boolean smartWebViewSaveState(Bundle outState);

    public String resolve(String relativeURL);

    public void loadUrl(String absoluteURL);
    public void reload();
    public void stopLoading();
    public void setForceCache(boolean forceCache);

    public void destroy();


    void	evaluateJavascript(java.lang.String script, android.webkit.ValueCallback<java.lang.String> callback);

    //public void copyScrollTo(SmartWebView target);

    public int fetchHorizontalScrollOffset();
    public int fetchVerticalScrollOffset();

    public void scrollTo(int x, int y);
    /*{
        SmartWebViewCrossWalk target = (SmartWebViewCrossWalk)_target;
        computeScroll();
        int x = computeHorizontalScrollOffset();
        int y = computeVerticalScrollOffset();
        target.scrollTo(x, y);
    }*/


    public void setRootAppDeckFragment(AppDeckFragment root);

    // Webview API
    public void smartWebViewGoBack();
    public void smartWebViewGoForward();
    public String smartWebViewGetTitle();
    public String smartWebViewGetUrl();
    public boolean smartWebViewCanGoBack();
    public boolean smartWebViewCanGoForward();

    // Activity API
    public void onActivityPause(Loader loader);
    public void onActivityResume(Loader loader);
    public void onActivityDestroy(Loader loader);
    public void onActivityResult(Loader loader, int requestCode, int resultCode, Intent data);
    public void onActivityNewIntent(Loader loader, Intent intent);
}
