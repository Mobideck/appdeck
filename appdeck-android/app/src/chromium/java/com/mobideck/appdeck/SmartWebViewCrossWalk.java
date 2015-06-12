package com.mobideck.appdeck;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.View;
import android.webkit.ValueCallback;

/**
 * Created by mathieudekermadec on 03/03/15.
 */
public class SmartWebViewCrossWalk extends View implements SmartWebViewInterface {


    public static void setPreferences(Loader loader)
    {

    }

    public SmartWebViewCrossWalk(AppDeckFragment root) {
        super(root.loader);
    }

    public SmartWebViewCrossWalk(Context context) {
        super(context);
    }

    public SmartWebViewCrossWalk(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public SmartWebViewCrossWalk(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public SmartWebViewCrossWalk(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public void setRootAppDeckFragment(AppDeckFragment root)
    {

    }

    @Override
    public void setTouchDisabled(boolean touchDisabled) {

    }

    @Override
    public boolean getTouchDisabled() {
        return false;
    }

    @Override
    public void pause() {

    }

    @Override
    public void resume() {

    }

    @Override
    public void destroy() {
    }

    @Override
    public void clean() {

    }

    @Override
    public void unloadPage() {

    }

    @Override
    public boolean smartWebViewRestoreState(Bundle savedInstanceState) {
        return false;
    }

    @Override
    public boolean smartWebViewSaveState(Bundle outState) {
        return false;
    }

    @Override
    public String resolve(String relativeURL) {
        return null;
    }

    @Override
    public void loadUrl(String absoluteURL) {

    }

    @Override
    public void reload() {

    }

    @Override
    public void stopLoading() {

    }

    @Override
    public void setForceCache(boolean forceCache) {

    }

    @Override
    public void evaluateJavascript(String script, ValueCallback<String> callback) {

    }

    @Override
    public int fetchHorizontalScrollOffset() {
        return 0;
    }

    @Override
    public int fetchVerticalScrollOffset() {
        return 0;
    }

    public void smartWebViewGoBack() {  }
    public void smartWebViewGoForward() {  }
    public String smartWebViewGetTitle() { return null; }
    public String smartWebViewGetUrl() { return null; }
    public boolean smartWebViewCanGoBack() { return false; }
    public boolean smartWebViewCanGoForward() { return false; }

    public String getUrl() { return null; }

    public void onActivityPause(Loader loader) { }

    public void onActivityResume(Loader loader) { }

    public void onActivityDestroy(Loader loader) { }
    public void onActivityResult(Loader loader, int requestCode, int resultCode, Intent data) { }
    public void onActivityNewIntent(Loader loader, Intent intent) { }
}
