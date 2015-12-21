package com.mobideck.appdeck;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.webkit.ValueCallback;

/**
 * Created by mathieudekermadec on 19/02/15.
 */
public interface SmartWebViewInterface {

    public static int LOAD_DEFAULT = 0;
    public static int LOAD_CACHE_ELSE_NETWORK = 1;
    public static int LOAD_NO_CACHE = 2;

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
    public void loadDataWithBaseURL(String baseUrl, String data, String mimeType, String encoding, String historyUrl);

    public void reload();
    public void stopLoading();
    public void setCacheMode(int mode);

    public void destroy();


    void	evaluateJavascript(java.lang.String script, android.webkit.ValueCallback<java.lang.String> callback);

    public void sendJsEvent(String eventName, String eventDetailJSon);

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

    public void clearAllCache();

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
