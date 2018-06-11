package net.mobideck.appdeck.WebView;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.DatePickerDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Vibrator;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.text.InputType;
import android.util.AttributeSet;
import android.util.Log;
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
import android.widget.DatePicker;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;
import com.google.gson.Gson;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckActivity;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;
import net.mobideck.appdeck.UI.DatePickerDialogCustom;
import net.mobideck.appdeck.WebView.Video.VideoEnabledWebChromeClient;
import net.mobideck.appdeck.WebView.Video.VideoEnabledWebView;
import net.mobideck.appdeck.core.ApiCall;
import net.mobideck.appdeck.core.DebugLog;
import net.mobideck.appdeck.core.Cache;
import net.mobideck.appdeck.core.Navigation;
import net.mobideck.appdeck.core.Page;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Map;


public class SmartWebView extends VideoEnabledWebView {

    public static String TAG = "SmartWebView";

    private boolean mFirstLoad = true;

    private boolean mPageHasFinishLoadingWithError = false;

    public boolean shouldLoadFromCache = false;

    public boolean disableCatchLink = false;

    public Page page;

    String url;
    Uri uri;

    // file upload
    public static final int INPUT_FILE_REQUEST_CODE = 4242;
    public static final String EXTRA_FROM_NOTIFICATION = "EXTRA_FROM_NOTIFICATION";
    private ValueCallback<Uri[]> mFilePathCallback;
    private String mCameraPhotoPath;

    private String mCookie;

    private SmartWebChromeChromeClient mWebViewChromeChromeClient;

    public SmartWebView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        preConfigure(context);
    }

    public SmartWebView(Context context, AttributeSet attrs) {
        super(context, attrs);
        preConfigure(context);
    }

    public SmartWebView(Context context) {
        super(context);
        preConfigure(context);
    }

    public static SmartWebView createMenuSmartWebView(Context context, String  absoluteURL) {
        SmartWebView smartWebView = new SmartWebView(context);
        smartWebView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        smartWebView.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
        smartWebView.loadUrl(absoluteURL);
        return smartWebView;
    }

    private void preConfigure(Context context) {

        configureWebView();

        AppDeckActivity activity = AppDeckApplication.getActivity();

        View loadingView = activity.getLayoutInflater().inflate(R.layout.view_loading_video, null); // Your own view, read class comments
        mWebViewChromeChromeClient = new SmartWebChromeChromeClient(activity.nonVideoLayout, activity.videoLayout, loadingView, this);
        mWebViewChromeChromeClient.setOnToggledFullscreen(new VideoEnabledWebChromeClient.ToggledFullscreenCallback()
        {
            @Override
            public void toggledFullscreen(boolean fullscreen)
            {
                // Your code to handle the full-screen change, for example showing and hiding the title bar. Example:
                if (fullscreen)
                {
                    WindowManager.LayoutParams attrs = AppDeckApplication.getActivity().getWindow().getAttributes();
                    attrs.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;
                    attrs.flags |= WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON;
                    AppDeckApplication.getActivity().getWindow().setAttributes(attrs);
                    if (android.os.Build.VERSION.SDK_INT >= 14)
                    {
                        //noinspection all
                        AppDeckApplication.getActivity().getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);
                    }
                }
                else
                {
                    WindowManager.LayoutParams attrs = AppDeckApplication.getActivity().getWindow().getAttributes();
                    attrs.flags &= ~WindowManager.LayoutParams.FLAG_FULLSCREEN;
                    attrs.flags &= ~WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON;
                    AppDeckApplication.getActivity().getWindow().setAttributes(attrs);
                    if (android.os.Build.VERSION.SDK_INT >= 14)
                    {
                        //noinspection all
                        AppDeckApplication.getActivity().getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
                    }
                }

            }
        });
        setWebViewClient(new SmartWebViewChromeClient());
        setWebChromeClient(mWebViewChromeChromeClient);

        //super.loadDataWithBaseURL("", "<!DOCTYPE html><html><head><title></title></head><body></body></html>", "text/html", "utf-8", "");
    }

    private void configureWebView() {

        AppDeck appDeck = AppDeckApplication.getAppDeck();

        WebSettings webSettings = getSettings();

        String userAgent = appDeck.deviceInfo.userAgent;
        if (userAgent == null) {
            userAgent = webSettings.getUserAgentString() + " AppDeck AppDeck-Android " + appDeck.packageName + "/" + appDeck.appConfig.version;
            appDeck.deviceInfo.userAgent = userAgent;
        }
        webSettings.setUserAgentString(userAgent);

        webSettings.setJavaScriptEnabled(true);

        // Allow third party cookies for Android Lollipop
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            CookieManager cookieManager = CookieManager.getInstance();
            cookieManager.setAcceptThirdPartyCookies(this, true);
        }

        // allow mixed content
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        }

        webSettings.setDomStorageEnabled(true);

        webSettings.setPluginState(WebSettings.PluginState.ON);
        webSettings.setRenderPriority(WebSettings.RenderPriority.HIGH);

        if (Build.VERSION.SDK_INT >= 17) {
            webSettings.setMediaPlaybackRequiresUserGesture(false);
        }

        if (appDeck.appConfig.noCache)
        {
            webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
            webSettings.setAppCacheEnabled(false);
        }
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
        //goBack();
        clearHistory();
    }

    @Override
    public void loadUrl(String url)
    {
        if (!url.startsWith("javascript:"))
        {
            CookieManager cookieManager = CookieManager.getInstance();
            if (cookieManager != null)
                mCookie = cookieManager.getCookie(url);
            else
                mCookie = null;
            this.url = url;
            uri = Uri.parse(url);
            mFirstLoad = true;
        }
        Map <String, String> extraHeaders = new HashMap<String, String>();
        extraHeaders.put("AppDeck-User-Id", AppDeckApplication.getAppDeck().deviceInfo.uid);
        extraHeaders.put("AppDeck-App-Key", AppDeckApplication.getAppDeck().appConfig.apiKey);
        super.loadUrl(url, extraHeaders);
    }

    public String resolve(String relativeURL)
    {
        URI master;
        try {
            master = new URI(this.url);
            return master.resolve(relativeURL).toString();
        } catch (URISyntaxException e) {
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
                mCookie = cookieManager.getCookie(url);
            else
                mCookie = null;
            this.url = baseUrl;
            uri = Uri.parse(baseUrl);
            mFirstLoad = true;
        }
        super.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
    }

    @Override
    public void loadData(String data, String mimeType, String encoding)
    {
        super.loadData(data, mimeType, encoding);
    }

    public class SmartWebViewChromeClient extends WebViewClient {


        public SmartWebViewChromeClient() {

        }

        /**
         * it will always be call.
         */
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            if (mFirstLoad) {
                mFirstLoad = false;
                return;
            }
            Log.d("SmartWebView", "OnPageStarted (not firstLoad) :" + url);;
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, final String url) {

            // this is a form ?
            if (url.contains("_appdeck_is_form=1"))
                return false;

            if (disableCatchLink)
                return false;

            // from menu ?
            if (page == null) {
                AppDeckApplication.getAppDeck().navigation.loadRootURL(url);
                return true;
            }

            if (page.shouldOverrideUrlLoading(url)) {

                /* */
                final Navigation navigation = AppDeckApplication.getAppDeck().navigation;

                final Gson gson = new Gson();

                String javascript = "app.client.rewriteURL('" + gson.toJson(url) + "')";
                Log.d(TAG, javascript);
                view.evaluateJavascript(javascript, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {
                        String newURL = gson.fromJson(value, String.class);
                        Log.d(TAG, "app.client.rewriteURL:"+value+":"+newURL);
                        if (newURL != null && (newURL.indexOf("http://") == 0 || newURL.indexOf("https://") == 0)){
                            //page.loadUrl(newURL);

                            /* */
                            navigation.loadRootURL(newURL);
                        }
                        else {
                            DebugLog.error("app.client.rewriteURL", "rewrite failed: "+url+" => "+value);
                            //page.loadUrl(url);

                            /* */
                            navigation.loadRootURL(url);
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

            String absoluteUrl = request.getUrl().toString();

            if (absoluteUrl.startsWith("about:") || absoluteUrl.startsWith("data:") || absoluteUrl.startsWith("blob:"))
                return null;

            if (absoluteUrl.equalsIgnoreCase("http://appdeck/error")) {
                return new WebResourceResponse ("text/html", "UTF-8", new ByteArrayInputStream(AppDeckApplication.getAppDeck().error_html.getBytes()));
            }

            /*if (true)
                return null;*/

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
            Cache.CachedResponse cachedResponse = AppDeckApplication.getAppDeck().cache.getEmbedResponse(absoluteUrl);

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
                String mimeType = cachedResponse.getHeader("Content-Type", "application/octet-stream").toLowerCase();
                String encoding = cachedResponse.getHeader("Content-Encoding", null);
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
                    Log.i(TAG, "FROM CACHE:"+absoluteUrl);
                    return response;
                }
                Log.e(TAG, "shouldInterceptRequest: Stream of cached response "+absoluteUrl+" is NULL");
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                //Log.i(TAG, "shouldInterceptRequest:"+request.getMethod()+" "+request.getUrl()+request.getRequestHeaders().toString());
            }

            return super.shouldInterceptRequest(view, request);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            Log.i(TAG, "**onPageFinished**");

            if (page != null && mPageHasFinishLoadingWithError == true) {
                page.onLoadFailed(view);
                mPageHasFinishLoadingWithError = false;
                return;
            }
            //pageHasFinishLoading = true;

            // force inject of appdeck.js if needed
            if (!url.startsWith("about:") && !url.startsWith("data:")) {
                view.evaluateJavascript(AppDeckApplication.getAppDeck().APPDECK_INJECT_JS, new ValueCallback<String>() {
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

            if (page != null) {
                page.onLoadSuccess(view);
                AppDeckApplication.getAppDeck().historyUrls.add(url);
            }

            //CookieSyncManager.getInstance().sync();

        }



        @Override
        public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {

            Log.d(TAG, "HTTP Error:" + errorResponse.getStatusCode() + ":" + errorResponse.getReasonPhrase());

            if (request.getUrl().toString().equalsIgnoreCase(url)) {
                mPageHasFinishLoadingWithError = true;
                //setVisibility(View.INVISIBLE);
                return;
            }

            //Toast.makeText(getContext(), "" + request.getUrl().toString() + ": (" + url + ") " + errorResponse.getReasonPhrase(), Toast.LENGTH_LONG).show();

        }

        @TargetApi(Build.VERSION_CODES.M)
        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            Log.d(TAG, "WebView Error:" + error.getErrorCode() + ":" + error.getDescription());

            if (request.getUrl().toString().equalsIgnoreCase(url)) {
                mPageHasFinishLoadingWithError = true;
                //setVisibility(View.INVISIBLE);
                return;
            }
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
            Log.d(TAG, "WebView Error:" + errorCode + ":" + description);

            if (failingUrl.equalsIgnoreCase(url)) {
                mPageHasFinishLoadingWithError = true;
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

        public SmartWebChromeChromeClient(View activityNonVideoView, ViewGroup activityVideoView, View loadingView, VideoEnabledWebView webView) {
            super(activityNonVideoView, activityVideoView, loadingView, webView);
        }

        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            super.onProgressChanged(view, newProgress);

            if (page != null)
                page.onLoadProgress(view, newProgress);

        }

        @Override
        public boolean onJsAlert(WebView view, String url, String message, final JsResult result)
        {
            //if (page != null) {
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
            //}
            return true;
        }

        @Override
        public boolean onJsConfirm(WebView view, String url, String message, final JsResult result)
        {
            //if (page != null) {
                new MaterialDialog.Builder(getContext())
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
            //}
            return true;
        }

        @Override
        public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, final JsPromptResult result)
        {
            if (page == null) {
                result.cancel();
                return true;
            }
            if (message.startsWith("appdeckapi:"))
            {
                ApiCall call = new ApiCall(message.substring(11), defaultValue, result);
                call.smartWebView = SmartWebView.this;
                call.page = page;
                Boolean res = apiCall(call); //root.apiCall(call);
                call.sendResult(res);
                return true;
            }

            new MaterialDialog.Builder(getContext())
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
        }

        @Override
        public boolean onShowFileChooser(
                WebView webView, ValueCallback<Uri[]> filePathCallback,
                WebChromeClient.FileChooserParams fileChooserParams) {
            if(mFilePathCallback != null) {
                mFilePathCallback.onReceiveValue(null);
            }
            mFilePathCallback = filePathCallback;

            Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            if (takePictureIntent.resolveActivity(getContext().getPackageManager()) != null) {
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

            AppDeckApplication.getActivity().smartWebViewRegiteredForActivityResult = SmartWebView.this;

            AppDeckApplication.getActivity().startActivityForResult(chooserIntent, INPUT_FILE_REQUEST_CODE);

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

    public void destroy() {
        setWebChromeClient(null);
        setWebViewClient(null);
        loadUrl("about:blank");
        super.destroy();
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

    public void sendJsEvent(String eventName, String eventDetailJSon)
    {
        String js = "document.dispatchEvent(new CustomEvent('"+eventName+"', "+eventDetailJSon+"));";
        Log.i(TAG, "sendJsEventJS: " + eventName + ": " + js);
        evaluateJavascript(js, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {
                Log.i(TAG, "sendJsEventResult: " + value);
            }
        });
    }

    //int page_height = -1;
    private long mLastScrollToBottomEventTime = -1;
    private int mLastScrollToBottomEventContentHeight = -1;

    public void onNestedScrollChange(NestedScrollWebView nestedScrollWebView, int pageHeight, int scrollX, int scrollY, int oldScrollX, int oldScrollY)
    {
        int content_height = (int)(getContentHeight() * getScale());
        int content_height_limit = content_height - pageHeight - pageHeight / 2;
        int mScrollToBottomEventTimeInterval = 500;
        //Log.d(TAG, "scrollY: " + scrollY + " content_height: "+content_height+" content_height_limit: "+content_height_limit);
        if (true)
        {
            if (scrollY > content_height_limit && content_height_limit > 0)
            {
                long scrollToBottomEventTime = System.currentTimeMillis();
                long scrollEventTimeDiff = scrollToBottomEventTime - mLastScrollToBottomEventTime;

                if (scrollEventTimeDiff > mScrollToBottomEventTimeInterval && mLastScrollToBottomEventContentHeight != content_height)
                {
                    mLastScrollToBottomEventTime = scrollToBottomEventTime;
                    mLastScrollToBottomEventContentHeight = content_height;
                    sendJsEvent("scrollToBottom", "null");
                }
            }
        }
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

    public boolean apiCall(final ApiCall call)
    {
        if (call.command.equalsIgnoreCase("disable_catch_link"))
        {
            Log.i("API", uri.getPath()+" **DISABLE CATCH LINK**");

            // we accept value as boolean or int
            boolean value = call.inputObject.optBoolean("param") || (call.inputObject.optInt("param", 0) == 1);
            disableCatchLink = value;

            return true;
        }


        /***************************************************/

//        if (call.command.equalsIgnoreCase("mylocation")) { /* nouveau composant */ /* local position */
//
//            GpsTracker gpsTracker;
//
//            try {
//                if (ContextCompat.checkSelfPermission(getApplicationContext(), android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED ) {
//                    ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION}, 101);
//                }else{
//                    double latitude = 0, longitude = 0 ;
//                    gpsTracker = new GpsTracker(Loader.this);
//                    if(gpsTracker.canGetLocation()){
//                        latitude = gpsTracker.getLatitude();
//                        longitude = gpsTracker.getLongitude();
//                    }else {
//                        gpsTracker.showSettingsAlert();
//                    }
//
//                    // Create a Uri from an intent string. Use the result to create an Intent.
//                    Uri gmmIntentUri = Uri.parse("google.streetview:cbll="+latitude+","+longitude);
//
//                    // Create an Intent from gmmIntentUri. Set the action to ACTION_VIEW
//                    Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
//                    // Make the Intent explicit by setting the Google Maps package
//                    mapIntent.setPackage("com.google.android.apps.maps");
//
//                    // Attempt to start an activity that can handle the Intent
//                    startActivity(mapIntent);
//                }
//            } catch (Exception e){
//                e.printStackTrace();
//            }
//
//            return true;
//        }
//        /***********************************************************/
//
//        if (call.command.equalsIgnoreCase("geolocation")) {
//
//            String latitude = call.param.getString("latitude");
//            String longitude = call.param.getString("longitude");
//
//            // Create a Uri from an intent string. Use the result to create an Intent.
//            Uri gmmIntentUri = Uri.parse("google.streetview:cbll="+latitude+","+longitude);
//
//            // Create an Intent from gmmIntentUri. Set the action to ACTION_VIEW
//            Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
//            // Make the Intent explicit by setting the Google Maps package
//            mapIntent.setPackage("com.google.android.apps.maps");
//
//            // Attempt to start an activity that can handle the Intent
//            startActivity(mapIntent);
//
//            return true;
//
//        }
//
//        /***********************************************************/
//
//        if (call.command.equalsIgnoreCase("phone")) {
//
//            String phone = call.param.getString("phone");
//
//            Intent intent = new Intent(Intent.ACTION_CALL, Uri.parse("tel:"+phone));
//            startActivity(intent);
//        }
        /***********************************************************/



        if (page!= null)
            return page.apiCall(call);
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
/*        if (disableCatchLink == true)
            return false;*/
        return mWebViewChromeChromeClient.onBackPressed();
    }

    public String getUrl() { return url; }

    public void onActivityResult(AppDeckActivity loader, int requestCode, int resultCode, Intent data)
    {
        if(requestCode != INPUT_FILE_REQUEST_CODE || mFilePathCallback == null) {
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
        return;

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
            CookieSyncManager cookieSyncMngr=CookieSyncManager.createInstance(AppDeckApplication.getContext());
            cookieSyncMngr.startSync();
            CookieManager cookieManager=CookieManager.getInstance();
            cookieManager.removeAllCookie();
            cookieManager.removeSessionCookie();
            cookieSyncMngr.stopSync();
            cookieSyncMngr.sync();
        }
    }

    public boolean shouldOverrideBackButton() {
        return mWebViewChromeChromeClient.onBackPressed();
    }

}
