package com.mobideck.appdeck;

import java.io.File;
import java.lang.reflect.Field;
import java.net.URI;
import java.net.URISyntaxException;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Application;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Picture;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.ValueCallback;
import android.webkit.WebBackForwardList;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebSettings.RenderPriority;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;
import android.annotation.TargetApi;

import name.cpr.VideoEnabledWebChromeClient;
import name.cpr.VideoEnabledWebView;

@TargetApi(19)
public class SmartWebViewChrome extends VideoEnabledWebView implements SmartWebViewInterface
{
    static String TAG = "SmartWebViewChrome";

    String userAgent;

    AppDeck appDeck;
    public AppDeckFragment root;
    String url;
    Uri uri;

    private String cookie;

    private boolean firstLoad = true;

    public boolean shouldLoadFromCache = false;

    public boolean catchLink = true;

    private SmartWebChromeChromeClient webViewChromeChromeClient;

    public static void setPreferences(Loader loader)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
        {
            boolean shouldEnableDebug = false;
            if (AppDeck.getInstance().config.app_api_key.equalsIgnoreCase("218hf32d1901627d35131fa83b63f56ae906"))
                shouldEnableDebug = true;
            if (0 != (loader.getApplicationInfo().flags &= ApplicationInfo.FLAG_DEBUGGABLE))
                shouldEnableDebug = true;
            if (shouldEnableDebug)
            {
                WebView.setWebContentsDebuggingEnabled(true);
            }
        }
    }

    public SmartWebViewChrome(AppDeckFragment root) {
        super((Context)root.loader);
        this.root = root;
        appDeck = AppDeck.getInstance();
        configureWebView();
        View loadingView = root.loader.getLayoutInflater().inflate(R.layout.view_loading_video, null); // Your own view, read class comments
        webViewChromeChromeClient = new SmartWebChromeChromeClient(root.loader.nonVideoLayout, root.loader.videoLayout, loadingView, this);
        webViewChromeChromeClient.setOnToggledFullscreen(new VideoEnabledWebChromeClient.ToggledFullscreenCallback()
        {
            @Override
            public void toggledFullscreen(boolean fullscreen)
            {
                // Your code to handle the full-screen change, for example showing and hiding the title bar. Example:
                if (fullscreen)
                {
                    WindowManager.LayoutParams attrs = SmartWebViewChrome.this.root.loader.getWindow().getAttributes();
                    attrs.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;
                    attrs.flags |= WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON;
                    SmartWebViewChrome.this.root.loader.getWindow().setAttributes(attrs);
                    if (android.os.Build.VERSION.SDK_INT >= 14)
                    {
                        //noinspection all
                        SmartWebViewChrome.this.root.loader.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);
                    }
                }
                else
                {
                    WindowManager.LayoutParams attrs = SmartWebViewChrome.this.root.loader.getWindow().getAttributes();
                    attrs.flags &= ~WindowManager.LayoutParams.FLAG_FULLSCREEN;
                    attrs.flags &= ~WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON;
                    SmartWebViewChrome.this.root.loader.getWindow().setAttributes(attrs);
                    if (android.os.Build.VERSION.SDK_INT >= 14)
                    {
                        //noinspection all
                        SmartWebViewChrome.this.root.loader.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
                    }
                }

            }
        });
        setWebViewClient(new SmartWebViewChromeClient());
        setWebChromeClient(webViewChromeChromeClient);
    }

    public void clean()
    {
        super.loadDataWithBaseURL("", "<!DOCTYPE html><html><head><title></title></head><body></body></html>",
                "text/html", "utf-8", "");
        destroy();
    }

    public void unloadPage()
    {
        evaluateJavascript("document.head.innerHTML = document.body.innerHTML = '';", null);
    }

    @Override
    public void loadUrl(String url)
    {
        if (url.startsWith("javascript:") == false)
        {
            CookieManager cookieManager = CookieManager.getInstance();
            if (cookieManager != null)
                cookie = cookieManager.getCookie(url);
            else
                cookie = null;
            this.url = url;
            uri = Uri.parse(url);
            firstLoad = true;
        }
        super.loadUrl(url);
    }

    public String resolve(String relativeURL)
    {
        URI master;
        try {
            master = new URI(this.url);
            return master.resolve(relativeURL).toString();
        } catch (URISyntaxException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void loadDataWithBaseURL(String baseUrl, String data,
                                    String mimeType, String encoding, String historyUrl) {
        if (baseUrl.startsWith("javascript:") == false)
        {
            CookieManager cookieManager = CookieManager.getInstance();
            if (cookieManager != null)
                cookie = cookieManager.getCookie(url);
            else
                cookie = null;
            this.url = baseUrl;
            uri = Uri.parse(baseUrl);
            firstLoad = true;
        }
        super.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
    }

    @Override
    public void loadData(String data, String mimeType, String encoding)
    {
        super.loadData(data, mimeType, encoding);
    }


    @SuppressLint("SetJavaScriptEnabled")
    private void configureWebView()
    {
        WebSettings webSettings = getSettings();
        userAgent = webSettings.getUserAgentString() + " AppDeck AppDeck-Android "+appDeck.packageName+"/"+appDeck.config.app_version;
        webSettings.setUserAgentString(userAgent);

        webSettings.setJavaScriptEnabled(true);

        //setLayerType(View.LAYER_TYPE_HARDWARE, null);

/*        CookieManager.getInstance().setAcceptCookie(true);

        webSettings.setJavaScriptEnabled(true);*/

        /*

        String databasePath = root.loader.getBaseContext().getDir("databases", Context.MODE_PRIVATE).getPath();
        webSettings.setGeolocationDatabasePath(databasePath);

        File cachePath = new File(Environment.getExternalStorageDirectory(), ".appdeck");
        cachePath.mkdirs();

        webSettings.setAppCacheEnabled(true);
        webSettings.setAppCachePath(cachePath.getAbsolutePath());
        Log.i(TAG, "appCache:"+cachePath.getAbsolutePath().toString());

        webSettings.setDomStorageEnabled(true);
        webSettings.setDatabaseEnabled(true);
        */

        /*
        //webSettings.setPluginsEnabled(true);
        //webSettings.setUseDoubleTree(false);
        webSettings.setPluginState(PluginState.ON);
        webSettings.setRenderPriority(RenderPriority.HIGH);
        //webSettings.setEnableSmoothTransition(true);
        setHorizontalScrollBarEnabled(false);


        webSettings.setSupportMultipleWindows(true);
        setLongClickable(true);
        setDrawingCacheEnabled(true);

        // Initialize the WebView
        webSettings.setSupportZoom(false);
        //webSettings.setSupportZoom(false);
        webSettings.setBuiltInZoomControls(false);
        //webSettings.setBuiltInZoomControls(true);
        setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
        setScrollbarFadingEnabled(true);
        webSettings.setLoadsImagesAutomatically(true);

        WebView.setWebContentsDebuggingEnabled(true);
*/
        if (appDeck.noCache)
        {
            webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
            webSettings.setAppCacheEnabled(false);
            webSettings.setAppCacheMaxSize(0);
        }

        try {
            WebkitProxy3.setProxy(this, root.loader.proxyHost, root.loader.proxyPort, Application.class.getCanonicalName());
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public void setForceCache(boolean forceCache)
    {
        shouldLoadFromCache = forceCache;

        if (shouldLoadFromCache == false)
        {
            getSettings().setUserAgentString(userAgent);
            getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
        } else {
            getSettings().setUserAgentString(userAgent+" FORCE_CACHE");
            getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
        }
    }
	
    public class SmartWebViewChromeClient extends WebViewClient {


        public SmartWebViewChromeClient() {

        }

        /**
         * it will always be call.
         */
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            if (firstLoad) {
                firstLoad = false;
                return;
            }
            Log.d("SmartWebView", "OnPageStarted (not firstLoad) :" + url);
        }

        //@Override
        public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {
            root.loadUrl(url);
            return false;
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {

            if (catchLink == false)
                return false;
            root.loadUrl(url);
            return true;
        }

/*
        @Override
        public WebResourceResponse shouldInterceptRequest(final WebView view, String absoluteURL) {

            if (absoluteURL.indexOf("data:") == 0)
                return null;

            if (absoluteURL.indexOf("_appdeck_is_form") != -1)
                return null;

            return null;
        }
*/

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            Log.i(TAG, "**onPageFinished**");

            // force inject of appdeck.js if needed
            view.evaluateJavascript(SmartWebViewChrome.this.appDeck.appdeck_inject_js, new ValueCallback<String>() {
                @Override
                public void onReceiveValue(String value) {
                    Log.i(TAG, "onPageFinishedJSResult: "+value);
                }
            });

            //view.loadUrl(SmartWebViewChrome.this.appDeck.appdeck_inject_js);

            root.progressStop(view);

            //CookieSyncManager.getInstance().sync();

        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
            // this is the main url that is falling
            if (failingUrl.equalsIgnoreCase(url) && shouldLoadFromCache == true) {
                Toast.makeText(getContext(), "Not in cache: " + failingUrl, Toast.LENGTH_LONG).show();
                view.setVisibility(View.INVISIBLE);
            } else {
                Toast.makeText(getContext(), "" + failingUrl + ": (" + url + ") " + description, Toast.LENGTH_LONG).show();
            }

        }
    }

    public class SmartWebChromeChromeClient extends VideoEnabledWebChromeClient /*implements OnCompletionListener, OnErrorListener*/ {

        public SmartWebChromeChromeClient(View activityNonVideoView, ViewGroup activityVideoView, View loadingView, VideoEnabledWebView webView) {
            super(activityNonVideoView, activityVideoView, loadingView, webView);
        }

        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            super.onProgressChanged(view, newProgress);

            root.progressSet(view, newProgress);

        }

        @Override
        public boolean onJsAlert(WebView view, String url, String message, final JsResult result)
        {

            new AlertDialog.Builder(root.loader)
                    .setTitle("javaScript dialog")
                    .setMessage(message)
                    .setPositiveButton(android.R.string.ok,
                            new AlertDialog.OnClickListener()
                            {
                                public void onClick(DialogInterface dialog, int which)
                                {
                                    result.confirm();
                                }
                            })
                    .setCancelable(false)
                    .create()
                    .show();
            return true;
        };

        @Override
        public boolean onJsConfirm(WebView view, String url, String message, final JsResult result)
        {
            new AlertDialog.Builder(root.loader)
                    .setTitle("javaScript dialog")
                    .setMessage(message)
                    .setPositiveButton(android.R.string.ok,
                            new DialogInterface.OnClickListener()
                            {
                                public void onClick(DialogInterface dialog, int which)
                                {
                                    result.confirm();
                                }
                            })
                    .setNegativeButton(android.R.string.cancel,
                            new DialogInterface.OnClickListener()
                            {
                                public void onClick(DialogInterface dialog, int which)
                                {
                                    result.cancel();
                                }
                            })
                    .create()
                    .show();

            return true;
        };

        public class SmartWebViewChromeResult implements SmartWebViewResult
        {
            JsPromptResult result;

            SmartWebViewChromeResult(JsPromptResult result)
            {
                this.result = result;
            }

            public void SmartWebViewResultCancel()
            {
                result.cancel();
            }

            public void SmartWebViewResultConfirm()
            {
                result.confirm();
            }

            public void SmartWebViewResultConfirmWithResult(String strResult)
            {
                result.confirm(strResult);
            }

        }

        @Override
        public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, final JsPromptResult result)
        {
			if (message.startsWith("appdeckapi:") == true)
			{
				AppDeckApiCall call = new AppDeckApiCall(message.substring(11), defaultValue, new SmartWebViewChromeResult(result));
				call.webview = SmartWebViewChrome.this;
				call.smartWebView = SmartWebViewChrome.this;
				call.appDeckFragment = root;
				Boolean res = apiCall(call); //root.apiCall(call);
				call.sendResult(res);
				return true;
			}        	
            final LayoutInflater factory = LayoutInflater.from(root.loader);
            final View v = factory.inflate(R.layout.javascript_prompt_dialog, null);
            ((TextView)v.findViewById(R.id.prompt_message_text)).setText(message);
            ((EditText)v.findViewById(R.id.prompt_input_field)).setText(defaultValue);

            new AlertDialog.Builder(root.loader)
                .setTitle("javaScript dialog")
                .setView(v)
                .setPositiveButton(android.R.string.ok,
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int whichButton) {
                                String value = ((EditText)v.findViewById(R.id.prompt_input_field)).getText()
                                        .toString();
                                result.confirm(value);
                            }
                        })
                .setNegativeButton(android.R.string.cancel,
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int whichButton) {
                                result.cancel();
                            }
                        })
                .setOnCancelListener(
                        new DialogInterface.OnCancelListener() {
                            public void onCancel(DialogInterface dialog) {
                                result.cancel();
                            }
                        })
                .show();
            return true;
        };

    }

    public void pause() {
        onPause();
    }

    public void resume(){
        onResume();
    }
	
    private boolean touchDisabled = false;

    public void setTouchDisabled(boolean touchDisabled)
    {
        this.touchDisabled = touchDisabled;
    }

    public boolean getTouchDisabled()
    {
        return this.touchDisabled;
    }
/*
    @Override
    public boolean onTouchEvent(MotionEvent event) {

        if (touchDisabled)
            return true;

        if (gestureDetector == null || event == null || mPreventAction == null)
            return super.onTouchEvent(event);

        int index = (event.getAction() & MotionEvent.ACTION_POINTER_INDEX_MASK) >> MotionEvent.ACTION_POINTER_INDEX_SHIFT;
        int pointId = event.getPointerId(index);

        // just use one(first) finger, prevent double tap with two and more fingers
        if (pointId == 0){
            gestureDetector.onTouchEvent(event);

            if (mPreventAction.get()){
                if (System.currentTimeMillis() - mPreventActionTime.get() > ViewConfiguration.getDoubleTapTimeout()){
                    mPreventAction.set(false);
                } else {
                    return true;
                }
            }

            return super.onTouchEvent(event);
        } else {
            return true;
        }

    }*/

    public void sendJsEvent(String eventName, String eventDetailJSon)
    {
        String js = null;
        //if (false && Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
        //{
        js = "document.dispatchEvent(new CustomEvent('"+eventName+"', "+eventDetailJSon+"));";
        //} else {
        //    js = "var evt = document.createEvent('Event');evt.initEvent('"+eventName+"',true,true); evt.detail = "+eventDetailJSon+"; document.dispatchEvent(evt);";
        //}
        Log.i(TAG, "sendJsEventJS: "+eventName+": "+js);
        evaluateJavascript(js, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {
                Log.i(TAG, "sendJsEventResult: "+value);
            }
        });

    }

    int page_height = -1;
    long lastScrollToBottomEventTime = -1;
    int lastScrollToBottomEventContentHeight = -1;
    private int scrollToBottomEventTimeInterval = 500;

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt)
    {
        super.onScrollChanged(l, t, oldl, oldt);
        int content_height = (int)(getContentHeight() * getScale());
        int content_height_limit = content_height - page_height - page_height / 2;
        if (true)
        {
            if (t > content_height_limit && content_height_limit > 0)
            {
                long scrollToBottomEventTime = System.currentTimeMillis();
                long scrollEventTimeDiff = scrollToBottomEventTime - lastScrollToBottomEventTime;

                if (scrollEventTimeDiff > scrollToBottomEventTimeInterval && lastScrollToBottomEventContentHeight != content_height)
                {
                    lastScrollToBottomEventTime = scrollToBottomEventTime;
                    lastScrollToBottomEventContentHeight = content_height;
                    sendJsEvent("scrollToBottom", "null");
                }
            }
        }
    }

    @Override
    protected void onSizeChanged (int w, int h, int ow, int oh)
    {
        super.onSizeChanged(w, h, ow, oh);
        page_height = h;
    }

    @Override
    public WebBackForwardList saveState(Bundle outState) {
        outState.putString("url", url);
        return super.saveState(outState);
    }

    @Override
    public WebBackForwardList restoreState(Bundle inState) {
        url = inState.getString("url");
        uri = Uri.parse(url);
        return super.restoreState(inState);
    }

    public boolean smartWebViewRestoreState(Bundle savedInstanceState)
    {
        restoreState(savedInstanceState);
        return true;
    }

    public boolean smartWebViewSaveState(Bundle outState)
    {
        saveState(outState);
        return true;
    }


    public boolean apiCall(final AppDeckApiCall call)
    {
        if (call.command.equalsIgnoreCase("disable_catch_link"))
        {
            Log.i("API", uri.getPath()+" **DISABLE CATCH LINK**");

            boolean value = call.input.getBoolean("param");
            ((SmartWebViewChrome)call.smartWebView).catchLink = value;

            return true;
        }

        if (root != null)
            return root.apiCall(call);
        else
            return false;
    }

    public int fetchHorizontalScrollOffset() {return computeHorizontalScrollOffset(); }
    public int fetchVerticalScrollOffset() {return computeVerticalScrollOffset();}

    public void smartWebViewGoBack() { goBack(); }
    public void smartWebViewGoForward() { goForward(); }
    public String smartWebViewGetTitle() { return getTitle(); }
    public String smartWebViewGetUrl() { return getUrl(); }
    public boolean smartWebViewCanGoBack() { return canGoBack(); }
    public boolean smartWebViewCanGoForward() { return canGoForward(); }

    public boolean canGoBack()
    {
        return webViewChromeChromeClient.onBackPressed();
    }

}
