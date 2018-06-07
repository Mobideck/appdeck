package com.mobideck.appdeck;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.webkit.ValueCallback;

/**
 * Created by mathieudekermadec on 19/02/15.
 */
public interface SmartWebViewInterface {

    int LOAD_DEFAULT = 0;
    int LOAD_CACHE_ELSE_NETWORK = 1;
    int LOAD_NO_CACHE = 2;

    String getUrl();

    void setTouchDisabled(boolean touchDisabled);

    void pause();
    void resume();
    void unloadPage();

    boolean smartWebViewRestoreState(Bundle savedInstanceState);
    boolean smartWebViewSaveState(Bundle outState);

    String resolve(String relativeURL);

    void loadUrl(String absoluteURL);
    void loadDataWithBaseURL(String baseUrl, String data, String mimeType, String encoding, String historyUrl);

    void reload();
    void stopLoading();
    void setCacheMode(int mode);

    void destroy();

    void evaluateJavascript(java.lang.String script, android.webkit.ValueCallback<java.lang.String> callback);

    void sendJsEvent(String eventName, String eventDetailJSon);

    //public void copyScrollTo(SmartWebView target);

    int fetchHorizontalScrollOffset();
    int fetchVerticalScrollOffset();

    void scrollTo(int x, int y);
    void setRootAppDeckFragment(AppDeckFragment root);

    void clearAllCache();
    void clearCookies();

    // Webview API
    void smartWebViewGoBack();
    void smartWebViewGoForward();
    String smartWebViewGetTitle();
    String smartWebViewGetUrl();
    boolean smartWebViewCanGoBack();
    boolean smartWebViewCanGoForward();

    // Activity API
    void onActivityPause(Loader loader);
    void onActivityResume(Loader loader);
    void onActivityDestroy(Loader loader);
    void onActivityResult(Loader loader, int requestCode, int resultCode, Intent data);
    void onActivityNewIntent(Loader loader, Intent intent);

    boolean getIsWarmUp();
    void setIsWarmUp(boolean value);
}
