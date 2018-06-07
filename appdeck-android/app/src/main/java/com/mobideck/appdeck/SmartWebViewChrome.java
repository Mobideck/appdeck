package com.mobideck.appdeck;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.text.InputType;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.ConsoleMessage;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.ValueCallback;
import android.webkit.WebBackForwardList;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import android.annotation.TargetApi;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;
import com.google.gson.Gson;

import org.json.JSONObject;

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

    // file upload
    public static final int INPUT_FILE_REQUEST_CODE = 4242;
    public static final String EXTRA_FROM_NOTIFICATION = "EXTRA_FROM_NOTIFICATION";
    private ValueCallback<Uri[]> mFilePathCallback;
    private String mCameraPhotoPath;

    private String cookie;

    private boolean firstLoad = true;

    private boolean pageHasFinishLoadingWithError = false;

    public boolean shouldLoadFromCache = false;

    public boolean disableCatchLink = false;

    private SmartWebChromeChromeClient webViewChromeChromeClient;

    public static void setPreferences(Loader loader)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
        {
            boolean shouldEnableDebug = false;
            if (AppDeck.isAppdeckTestApp(loader))
                shouldEnableDebug = true;
            if (0 != (loader.getApplicationInfo().flags &= ApplicationInfo.FLAG_DEBUGGABLE))
                shouldEnableDebug = true;
            if (shouldEnableDebug)
            {
                WebView.setWebContentsDebuggingEnabled(true);
            }
        }
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            WebView.enableSlowWholeDocumentDraw();
        }
    }

    public void setRootAppDeckFragment(AppDeckFragment root)
    {
        this.root = root;
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
        clearHistory();
    }

    @Override
    public void loadUrl(String url)
    {
        if (!url.startsWith("javascript:"))
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
        if (this.getIsWarmUp())
            evaluateJavascript("window.location.href = '"+url+"'", null);
        else
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
        if (baseUrl != null && !baseUrl.startsWith("javascript:"))
        {
            CookieManager cookieManager = CookieManager.getInstance();
            if (url != null && cookieManager != null)
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

        if (appDeck != null && appDeck.config != null) {
            userAgent = webSettings.getUserAgentString() + " AppDeck AppDeck-Android " + appDeck.packageName + "/" + appDeck.config.app_version;
            if (appDeck.userAgent == null)
                appDeck.userAgent = userAgent;
        }

        webSettings.setUserAgentString(userAgent);

        webSettings.setJavaScriptEnabled(true);

        // Allow third party cookies for Android Lollipop
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            CookieManager cookieManager = CookieManager.getInstance();
            cookieManager.setAcceptThirdPartyCookies(this, true);
        }

        // allow mixed content
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        }

        webSettings.setDomStorageEnabled(true);

        webSettings.setPluginState(WebSettings.PluginState.ON);

        if (Build.VERSION.SDK_INT >= 17) {
            webSettings.setMediaPlaybackRequiresUserGesture(false);
        }


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
        if (appDeck != null && appDeck.noCache)
        {
            webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
            webSettings.setAppCacheEnabled(false);
        }

        WebkitProxy3.setProxy(this, root.loader.proxyHost, root.loader.proxyPort, Application.class.getCanonicalName());

        //root.loader.enableProxy();
    }

    public void setCacheMode(int cacheMode)
    {
        if (cacheMode == SmartWebViewInterface.LOAD_DEFAULT) {
            getSettings().setUserAgentString(userAgent);
            getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
            shouldLoadFromCache = false;
        } else if (cacheMode == SmartWebViewInterface.LOAD_NO_CACHE) {
            getSettings().setUserAgentString(userAgent);
            getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
            shouldLoadFromCache = false;
        } else if (cacheMode == SmartWebViewInterface.LOAD_CACHE_ELSE_NETWORK) {
            getSettings().setUserAgentString(userAgent+" FORCE_CACHE");
            getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
            shouldLoadFromCache = true;
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
/*
        //@Override
        public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {
            root.loadUrl(url);
            return false;
        }*/

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, final String url) {

            // if there is a url loading before page finish it is a redirection
            //if (pageHasFinishLoading == false)
            //    return false;

            // this is a form ?
            if (url.contains("_appdeck_is_form=1"))
                return false;

            if (disableCatchLink)
                return false;

            if (root.shouldOverrideUrlLoading(url)) {

                final Gson gson = new Gson();

                String javascript = "app.client.rewriteURL('" + gson.toJson(url) + "')";
                Log.d(TAG, javascript);
                view.evaluateJavascript(javascript, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {
                        String newURL = gson.fromJson(value, String.class);
                        Log.d(TAG, "app.client.rewriteURL:"+value+":"+newURL);
                        if (newURL != null && (newURL.indexOf("http://") == 0 || newURL.indexOf("https://") == 0))
                            root.loadUrl(newURL);
                        else {
                            DebugLog.error("app.client.rewriteURL", "rewrite failed: "+url+" => "+value);
                            root.loadUrl(url);
                        }
                    }
                });
                return true;
            }
            return false;
        }

        @TargetApi(Build.VERSION_CODES.LOLLIPOP)
        @Override
        public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                Log.i(TAG, "shouldInterceptRequest:"+request.getMethod()+" "+request.getUrl()+request.getRequestHeaders().toString());
            }

            String absoluteUrl = request.getUrl().toString();

            if (absoluteUrl.startsWith("about:") || absoluteUrl.startsWith("data:") || absoluteUrl.startsWith("blob:"))
                return null;

            if (absoluteUrl.equalsIgnoreCase("http://appdeck/error")) {
                return new WebResourceResponse ("text/html", "UTF-8", new ByteArrayInputStream( AppDeck.error_html.getBytes() ));
                //WebResourceResponse response = new WebResourceResponse(null, null, 200, "OK", null, new ByteArrayInputStream( AppDeck.error_html.getBytes() ));
            }

            if (true)
                return null;

/*
            // handle If-None-Match header
            String IfNoneMatch = request.getRequestHeaders().get("If-None-Match");
            if (IfNoneMatch != null && IfNoneMatch.startsWith("appdeckcache")) {
                if (shouldLoadFromCache || appDeck.cache.shouldCache(absoluteUrl) || appDeck.cache.getEmbedResource(absoluteUrl) != null) {
                    WebResourceResponse response = new WebResourceResponse(null, null, 304, "Not Modified", null, new ByteArrayInputStream( "".getBytes() ));
                    return response;
                }
            }*/

            // present in embed ressources ?
            CacheManagerCachedResponse cachedResponse = appDeck.cache.getEmbedResponse(absoluteUrl);

            /*

            // present in cache AND should be cache forever ?
            if (cachedResponse == null && appDeck.cache.shouldCache(absoluteUrl))
                cachedResponse = appDeck.cache.getCachedResponse(absoluteUrl);

            // cached response + ask to cache forever header
            if (cachedResponse != null)
            {
                JSONObject headers = cachedResponse.getHeaders();
                String mimeType = headers.optString("Content-Type", "application/octet-stream");
                String encoding = headers.optString("Content-Encoding", null);
                int statusCode = 200;
                String reasonPhrase = "OK";
                Map<String, String> responseHeaders = new HashMap<String, String>();
                responseHeaders.put("ETag", "appdeckcache"+System.currentTimeMillis());
                responseHeaders.put("Content-Type", mimeType);
                if (encoding != null)
                    responseHeaders.put("Content-Encoding", encoding);
                int cacheTTL = 3600 * 24 * 30 * 365;
                responseHeaders.put("Cache-Control", "public, max-age=" + cacheTTL);
                responseHeaders.put("'X-Accel-Expires", ""+cacheTTL);
                Calendar calendar = Calendar.getInstance(); // gets a calendar using the default time zone and locale.
                calendar.add(Calendar.SECOND, cacheTTL);
                DateFormat df = DateFormat.getTimeInstance();
                df.setTimeZone(TimeZone.getTimeZone("gmt"));
                String gmtTime = df.format(calendar.getTime());
                //responseHeaders.put("Expires", gmtTime);

                InputStream stream = cachedResponse.getStream();
                if (stream != null) {
                    WebResourceResponse response = new WebResourceResponse(mimeType, encoding, statusCode, reasonPhrase, responseHeaders, stream);
                    return response;
                }
                Log.e(TAG, "shouldInterceptRequest: Stream of cached response "+absoluteUrl+" is NULL");
                cachedResponse = null;
            }

            if (cachedResponse == null && shouldLoadFromCache)
                cachedResponse = appDeck.cache.getCachedResponse(absoluteUrl);
            */
            // cached response
            if (cachedResponse != null)
            {
                JSONObject headers = cachedResponse.getHeaders();
                String mimeType = headers.optString("Content-Type", "application/octet-stream").toLowerCase();
                String encoding = headers.optString("Content-Encoding", null);
                int statusCode = 200;
                String reasonPhrase = "OK";
                Map<String, String> responseHeaders = new HashMap<String, String>();
                //responseHeaders.put("ETag", "appdeckcache"+System.currentTimeMillis());
                if (mimeType.contains("text/html"))
                {
                    encoding = "UTF-8";
                    if (mimeType.contains("charset="))
                        encoding = mimeType.substring(mimeType.lastIndexOf("charset=")+8);
                    else if (mimeType.contains("iso-8859-1"))
                        encoding = "ISO-8859-1";
                    else if (mimeType.contains("windows-1251"))
                        encoding = "Windows-1251";
                    mimeType = "text/html";
                }
                responseHeaders.put("Content-Type", mimeType);
                responseHeaders.put("Cache-Control", "max-age=604800");
                if (encoding != null)
                    responseHeaders.put("Content-Encoding", encoding);
                InputStream stream = cachedResponse.getStream();
                if (stream != null) {
                    WebResourceResponse response = new WebResourceResponse(mimeType, encoding, statusCode, reasonPhrase, responseHeaders, stream);
                    return response;
                }
                Log.e(TAG, "shouldInterceptRequest: Stream of cached response "+absoluteUrl+" is NULL");
            }

            return super.shouldInterceptRequest(view, request);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            Log.i(TAG, "**onPageFinished**");

            if (root != null && pageHasFinishLoadingWithError == true) {
                root.progressFailed(view);
                pageHasFinishLoadingWithError = false;
                return;
            }
                //pageHasFinishLoading = true;

            // force inject of appdeck.js if needed
            if (!url.startsWith("about:") && !url.startsWith("data:")) {
                view.evaluateJavascript(SmartWebViewChrome.this.appDeck.appdeck_inject_js, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {
                        Log.i(TAG, "onPageFinishedJSResult: " + value);
                    }
                });
            }

				/*
				evaluateJavascript("history.pushState(null, null, 'http://www.universfreebox.com.dev.dck.io/article/30638/The-OVH-Box-une-nouvelle-box-en-preparation-chez-OVH');", new ValueCallback<String>() {
					@Override
					public void onReceiveValue(String value) {
						Log.d(TAG, value);
					}
				});*/

            //view.loadUrl(SmartWebViewChrome.this.appDeck.appdeck_inject_js);

            if (root != null) {
                root.progressStop(view);
                root.loader.historyUrls.add(url);
            }

            //CookieSyncManager.getInstance().sync();

        }



        @Override
        public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {

            Log.d(TAG, "HTTP Error:" + errorResponse.getStatusCode() + ":" + errorResponse.getReasonPhrase());

            if (request.getUrl().toString().equalsIgnoreCase(url)) {
                pageHasFinishLoadingWithError = true;
                //setVisibility(View.INVISIBLE);
                return;
            }

            //Toast.makeText(getContext(), "" + request.getUrl().toString() + ": (" + url + ") " + errorResponse.getReasonPhrase(), Toast.LENGTH_LONG).show();

        }

        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            Log.d(TAG, "WebView Error:" + error.getErrorCode() + ":" + error.getDescription());

            if (request.getUrl().toString().equalsIgnoreCase(url)) {
                pageHasFinishLoadingWithError = true;
                //setVisibility(View.INVISIBLE);
                return;
            }
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
            Log.d(TAG, "WebView Error:" + errorCode + ":" + description);

            if (failingUrl.equalsIgnoreCase(url)) {
                pageHasFinishLoadingWithError = true;
                //setVisibility(View.INVISIBLE);
                return;
            }

            //Toast.makeText(getContext(), "" + failingUrl + ": (" + url + ") " + description, Toast.LENGTH_LONG).show();

            /*

            // this is the main url that is falling
            if (failingUrl.equalsIgnoreCase(url) && shouldLoadFromCache == true) {
                Toast.makeText(getContext(), "Not in cache: " + failingUrl, Toast.LENGTH_LONG).show();
                view.setVisibility(View.INVISIBLE);

            } else {
                Toast.makeText(getContext(), "" + failingUrl + ": (" + url + ") " + description, Toast.LENGTH_LONG).show();
            }*/
        }
/*
        @TargetApi(Build.VERSION_CODES.M)
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            Log.d(TAG, "Error:"+error.getDescription());
            //loadData(AppDeck.error_html, "text/html", "utf8");
            root.progressFailed(view);
        }
*/
    }

    public class SmartWebChromeChromeClient extends VideoEnabledWebChromeClient /*implements OnCompletionListener, OnErrorListener*/ {

        SmartWebChromeChromeClient(View activityNonVideoView, ViewGroup activityVideoView, View loadingView, VideoEnabledWebView webView) {
            super(activityNonVideoView, activityVideoView, loadingView, webView);
        }

        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            super.onProgressChanged(view, newProgress);

            if (root != null)
                root.progressSet(view, newProgress);

        }

        @Override
        public boolean onJsAlert(WebView view, String url, String message, final JsResult result)
        {
            if (root != null) {
                new MaterialDialog.Builder(getContext())
                        .content(message)
                        .positiveText(android.R.string.ok)
                        .cancelable(false)
                        .onPositive(new MaterialDialog.SingleButtonCallback() {
                            @Override
                            public void onClick(@NonNull MaterialDialog materialDialog, @NonNull DialogAction dialogAction) {
                            result.confirm();
                            }
                        })
                        .show();
            }
            return true;
        };

        @Override
        public boolean onJsConfirm(WebView view, String url, String message, final JsResult result)
        {
            if (root != null) {
                new MaterialDialog.Builder(root.loader)
                        .content(message)
                        .positiveText(android.R.string.ok)
                        .negativeText(android.R.string.cancel)
                        .cancelable(false)
                        .onPositive(new MaterialDialog.SingleButtonCallback() {
                            @Override
                            public void onClick(@NonNull MaterialDialog materialDialog, @NonNull DialogAction dialogAction) {
                                result.confirm();
                            }
                        })
                        .onNegative(new MaterialDialog.SingleButtonCallback() {
                            @Override
                            public void onClick(@NonNull MaterialDialog materialDialog, @NonNull DialogAction dialogAction) {
                                result.cancel();
                            }
                        })
                        .show();
            }
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
            if (root == null) {
                result.cancel();
                return true;
            }
			if (message.startsWith("appdeckapi:"))
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

            new MaterialDialog.Builder(root.loader)
                    //.title(R.string.input)
                    .content(message)
                    .cancelable(false)
                    .inputType(InputType.TYPE_CLASS_TEXT)
                    .input(defaultValue, defaultValue, new MaterialDialog.InputCallback() {
                        @Override
                        public void onInput(MaterialDialog dialog, CharSequence input) {
                            result.confirm(input.toString());
                        }
                    }).show();
            return true;
        };

        @Override
        public boolean onShowFileChooser(
                WebView webView, ValueCallback<Uri[]> filePathCallback,
                WebChromeClient.FileChooserParams fileChooserParams) {
            if(mFilePathCallback != null) {
                mFilePathCallback.onReceiveValue(null);
            }
            mFilePathCallback = filePathCallback;

            Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            if (takePictureIntent.resolveActivity(root.loader.getPackageManager()) != null) {
                // Create the File where the photo should go
                File photoFile = null;
                try {
                    photoFile = createImageFile();
                    takePictureIntent.putExtra("PhotoPath", mCameraPhotoPath);
                } catch (IOException ex) {
                    // Error occurred while creating the File
                    Log.e(TAG, "Unable to create Image File", ex);
                }

                // Continue only if the File was successfully created
                if (photoFile != null) {
                    mCameraPhotoPath = "file:" + photoFile.getAbsolutePath();
                    takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT,
                            Uri.fromFile(photoFile));
                } else {
                    takePictureIntent = null;
                }
            }

            Intent contentSelectionIntent = new Intent(Intent.ACTION_GET_CONTENT);
            contentSelectionIntent.addCategory(Intent.CATEGORY_OPENABLE);
            contentSelectionIntent.setType("image/*");

            Intent[] intentArray;
            if(takePictureIntent != null) {
                intentArray = new Intent[]{takePictureIntent};
            } else {
                intentArray = new Intent[0];
            }

            Intent chooserIntent = new Intent(Intent.ACTION_CHOOSER);
            chooserIntent.putExtra(Intent.EXTRA_INTENT, contentSelectionIntent);
            chooserIntent.putExtra(Intent.EXTRA_TITLE, "Image Chooser");
            chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);

            root.loader.smartWebViewRegiteredForActivityResult = SmartWebViewChrome.this;;

            root.loader.startActivityForResult(chooserIntent, INPUT_FILE_REQUEST_CODE);

            return true;
        }

        public boolean onConsoleMessage (ConsoleMessage consoleMessage)
        {
            if (consoleMessage.messageLevel() == ConsoleMessage.MessageLevel.TIP) {
                DebugLog.verbose("JavaScript:"+consoleMessage.sourceId()+":"+consoleMessage.lineNumber(), consoleMessage.message());
            } else if (consoleMessage.messageLevel() == ConsoleMessage.MessageLevel.DEBUG) {
                DebugLog.debug("JavaScript:"+consoleMessage.sourceId()+":"+consoleMessage.lineNumber(), consoleMessage.message());
            } else if (consoleMessage.messageLevel() == ConsoleMessage.MessageLevel.LOG) {
                DebugLog.info("JavaScript:"+consoleMessage.sourceId()+":"+consoleMessage.lineNumber(), consoleMessage.message());
            } else if (consoleMessage.messageLevel() == ConsoleMessage.MessageLevel.WARNING) {
                DebugLog.warning("JavaScript:"+consoleMessage.sourceId()+":"+consoleMessage.lineNumber(), consoleMessage.message());
            } else if (consoleMessage.messageLevel() == ConsoleMessage.MessageLevel.ERROR) {
                DebugLog.error("JavaScript:"+consoleMessage.sourceId()+":"+consoleMessage.lineNumber(), consoleMessage.message());
            } else
                DebugLog.error("JavaScript:unknowlevel:"+consoleMessage.sourceId()+":"+consoleMessage.lineNumber(), consoleMessage.message());
            return false;
        }
    }

    /**
     * More info this method can be found at
     * http://developer.android.com/training/camera/photobasics.html
     *
     * @return
     * @throws IOException
     */
    private File createImageFile() throws IOException {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES);
        File imageFile = File.createTempFile(
                imageFileName,  /* prefix */
                ".jpg",         /* suffix */
                storageDir      /* directory */
        );
        return imageFile;
    }

    public void pause() {
        onPause();
    }

    public void resume(){
        onResume();
    }

    private void postPonedDestroy() {
        super.destroy();
    }

    public void destroy() {
        setWebViewClient(null);
        setWebChromeClient(null);
        super.removeAllViews();

        final SmartWebViewChrome self = this;

        Handler handler = new Handler();
        handler.postDelayed(new Runnable()
        {
            @Override
            public void run()
            {
                self.postPonedDestroy();
            }
        }, 5000);

        //super.destroy();
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
        Log.i(TAG, "sendJsEventJS: " + eventName + ": " + js);
        evaluateJavascript(js, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {
                Log.i(TAG, "sendJsEventResult: " + value);
            }
        });
//        document.dispatchEvent(new CustomEvent('scrollToBottom', ''));
    }

    int page_height = -1;
    long lastScrollToBottomEventTime = -1;
    int lastScrollToBottomEventContentHeight = -1;

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt)
    {
        super.onScrollChanged(l, t, oldl, oldt);
        int content_height = (int)(getContentHeight() * getScale());
        int content_height_limit = content_height - page_height - page_height / 2;
        if (t > content_height_limit && content_height_limit > 0)
        {
            long scrollToBottomEventTime = System.currentTimeMillis();
            long scrollEventTimeDiff = scrollToBottomEventTime - lastScrollToBottomEventTime;

            int scrollToBottomEventTimeInterval = 500;
            if (scrollEventTimeDiff > scrollToBottomEventTimeInterval && lastScrollToBottomEventContentHeight != content_height)
            {
                lastScrollToBottomEventTime = scrollToBottomEventTime;
                lastScrollToBottomEventContentHeight = content_height;
                sendJsEvent("scrollToBottom", "null");
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
        if (url != null)
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

    public boolean apiCall(final AppDeckApiCall call) {
        if (call.command.equalsIgnoreCase("disable_catch_link")) {
            Log.i("API", uri.getPath() + " **DISABLE CATCH LINK**");

            ((SmartWebViewChrome) call.smartWebView).disableCatchLink = call.input.getBoolean("param");

            return true;
        }

        return root != null && root.apiCall(call);
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
/*        if (disableCatchLink == true)
            return false;*/
        return webViewChromeChromeClient.onBackPressed();
    }

    public String getUrl() { return url; }

    public void onActivityPause(Loader loader)
    {
        //pauseTimers();
    }

    public void onActivityResume(Loader loader)
    {
        //resumeTimers();
    }

    public void onActivityDestroy(Loader loader)
    {

    }

    public void onActivityResult(Loader loader, int requestCode, int resultCode, Intent data)
    {
        if(requestCode != INPUT_FILE_REQUEST_CODE || mFilePathCallback == null) {
            //super.onActivityResult(requestCode, resultCode, data);
            return;
        }

        Uri[] results = null;

        // Check that the response is a good one
        if(resultCode == Activity.RESULT_OK) {
            if(data == null) {
                // If there is not data, then we may have taken a photo
                if(mCameraPhotoPath != null) {
                    results = new Uri[]{Uri.parse(mCameraPhotoPath)};
                }
            } else {
                String dataString = data.getDataString();
                if (dataString != null) {
                    results = new Uri[]{Uri.parse(dataString)};
                }
            }
        }

        mFilePathCallback.onReceiveValue(results);
        mFilePathCallback = null;
    }

    public void onActivityNewIntent(Loader loader, Intent intent)
    {

    }

    public void clearAllCache()
    {
        clearCache(true);
    }

    public void clearCookies()
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            Log.d(TAG, "Using ClearCookies code for API >=" + String.valueOf(Build.VERSION_CODES.LOLLIPOP_MR1));
            CookieManager.getInstance().removeAllCookies(null);
            CookieManager.getInstance().flush();
        } else
        {
            Log.d(TAG, "Using ClearCookies code for API <" + String.valueOf(Build.VERSION_CODES.LOLLIPOP_MR1));
            CookieSyncManager cookieSyncMngr=CookieSyncManager.createInstance(root.loader);
            cookieSyncMngr.startSync();
            CookieManager cookieManager=CookieManager.getInstance();
            cookieManager.removeAllCookie();
            cookieManager.removeSessionCookie();
            cookieSyncMngr.stopSync();
            cookieSyncMngr.sync();
        }
    }

    private boolean isWarmUp = false;
    public boolean getIsWarmUp() { return isWarmUp; }
    public void setIsWarmUp(boolean value) {isWarmUp = value;}
}
