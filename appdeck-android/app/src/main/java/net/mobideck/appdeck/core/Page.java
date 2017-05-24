package net.mobideck.appdeck.core;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.os.Handler;
import android.support.design.widget.Snackbar;
import android.support.v4.view.ViewPager;
import android.support.v4.widget.NestedScrollView;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewPropertyAnimator;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ProgressBar;

import com.afollestad.materialdialogs.MaterialDialog;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;
import net.mobideck.appdeck.WebView.Factory;
import net.mobideck.appdeck.WebView.NestedScrollWebView;
import net.mobideck.appdeck.WebView.SmartWebView;
import net.mobideck.appdeck.config.ViewConfig;
import net.mobideck.appdeck.util.Utils;

import java.net.URI;
import java.net.URISyntaxException;

public class Page extends AppDeckView {

    public static String TAG = "Page";

    private String mAbsoluteURL;
    private ViewConfig mDefaultViewConfig;

    private ViewConfig mPageConfig;
    private ViewConfig mPageConfigAlt;

    private FrameLayout mRootView;

    private SmartWebView mWebView;
    private SmartWebView mWebViewAlt;

    private SwipeRefreshLayout mSwipeView;
    private SwipeRefreshLayout mSwipeViewAlt;

    private NestedScrollWebView mNestedScrollView;
    private NestedScrollWebView mNestedScrollViewAlt;

    private PageManager mPageManager;

    private ProgressBar mProgressBar;

    public String previousPageUrl;
    public String nextPageUrl;

    private boolean mShouldReloadFromBackgrounfOnError = false;
    private long mLastUrlLoad = 0;
    private boolean mReloadInProgress = false;
    private boolean mSwapInProgress = false;

    Page(PageManager pageManager, String absoluteURL) {

        mPageManager = pageManager;

        mAbsoluteURL = absoluteURL;

        AppDeck appDeck = AppDeckApplication.getAppDeck();

        mDefaultViewConfig = appDeck.appConfig.getViewConfig(absoluteURL);
        mPageConfig = mDefaultViewConfig;
        mPageConfigAlt = mDefaultViewConfig;

        mRootView = (FrameLayout)AppDeckApplication.getActivity().getLayoutInflater().inflate(R.layout.page, null);

        mProgressBar = (ProgressBar)mRootView.findViewById(R.id.progressBar);

        mWebView = Factory.createSmartWebView(AppDeckApplication.getActivity());// new SmartWebView(AppDeckApplication.getActivity());
        mWebView.page = this;

        mWebViewAlt = Factory.createSmartWebView(AppDeckApplication.getActivity());//new SmartWebView(AppDeckApplication.getActivity());
        mWebViewAlt.page = this;

        mNestedScrollView = new NestedScrollWebView(AppDeckApplication.getActivity());
        mNestedScrollView.setSmartWebView(mWebView);
        mNestedScrollView.addView(mWebView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        mNestedScrollViewAlt = new NestedScrollWebView(AppDeckApplication.getActivity());
        mNestedScrollViewAlt.setSmartWebView(mWebViewAlt);
        mNestedScrollViewAlt.addView(mWebViewAlt, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        mSwipeView = (SwipeRefreshLayout)mRootView.findViewById(R.id.swipe);
        mSwipeView.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {

            @Override
            public void onRefresh() {
                mSwipeViewAlt.setRefreshing(true);
                mSwipeView.setRefreshing(true);
                reloadInBackground();
            }
        });
        mSwipeView.addView(mNestedScrollView);
        mSwipeView.setColorSchemeResources(R.color.AppDeckColorApp, R.color.AppDeckColorTopBar, R.color.AppDeckColorApp, R.color.AppDeckColorTheme);

        mSwipeViewAlt = (SwipeRefreshLayout)mRootView.findViewById(R.id.swipeAlt);
        mSwipeViewAlt.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                mSwipeViewAlt.setRefreshing(true);
                mSwipeView.setRefreshing(true);
                reloadInBackground();
            }
        });
        mSwipeViewAlt.addView(mNestedScrollViewAlt);
        mSwipeViewAlt.setVisibility(View.GONE);
        mSwipeViewAlt.setColorSchemeResources(R.color.AppDeckColorApp, R.color.AppDeckColorTopBar, R.color.AppDeckColorApp, R.color.AppDeckColorTheme);

        mRootView.bringChildToFront(mSwipeView);

        onLoadStarted(mWebView);
        mWebView.loadUrl(absoluteURL);

    }

    public String getURL() {
        return mAbsoluteURL;
    }

    @Override
    public View getView() {
        return mRootView;
    }

    @Override
    public ViewPager getViewPager() {
        return null;
    }

    public ViewConfig getConfig() { return mPageConfig; }

    public boolean shouldOverrideUrlLoading(String absoluteURL)
    {
        if (absoluteURL.startsWith("javascript:"))
        {
            return false;
        }
        if (mDefaultViewConfig.match(absoluteURL))
        {
            //loader.replacePage(absoluteURL);
            mAbsoluteURL = absoluteURL;
            return false;
        }
        return true;
    }

    public void loadUrl(String absoluteURL)
    {
        if (absoluteURL.startsWith("javascript:"))
        {
            if (mWebView != null)
                mWebView.loadUrl(absoluteURL);
            return;
        }
        if (absoluteURL.startsWith("appdeckapi:refresh"))
        {
            reloadInBackground();
            return;
        }
        if (mDefaultViewConfig.match(absoluteURL))
        {
            if (mWebView != null)
                mWebView.loadUrl(absoluteURL);
            return;
        }
        AppDeckApplication.getAppDeck().navigation.loadURL(absoluteURL);
    }


    private void loadPage(String absoluteURL) {

        AppDeck appDeck = AppDeckApplication.getAppDeck();

        mAbsoluteURL = absoluteURL;

        String toast;
        int toast_color;

        if (mDefaultViewConfig.ttl == -1) {
            toast = "Cache DISABLED ttl: "+mDefaultViewConfig.ttl +" sec";
            mWebView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
            toast_color = Utils.dangerColor();
        } else {
            mWebView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
            AppDeckApplication.getAppDeck().cache.getCachedResponse(absoluteURL);



            Cache.CacheResult cacheResult = appDeck.cache.isInCache(absoluteURL);
            if (cacheResult.isInCache) {
                long now = System.currentTimeMillis();
                long ttl = mDefaultViewConfig.ttl;
                if (appDeck.justLaunch) {
                    ttl = ttl / 10;
                    appDeck.justLaunch = false;
                }
                if (ttl > ((now - cacheResult.lastModified) / 1000)) {
                    toast = "Cache HIT ttl: " + mDefaultViewConfig.ttl + " sec " + (appDeck.justLaunch ? "(app just start, shorten to:" + ttl + ")" : "") + " age: " + (now - cacheResult.lastModified) / 1000 + " sec ";
                    mWebView.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
                    toast_color = Utils.successColor();
                } else {
                    toast = "Cache MISS (DEPRECATED) ttl: " + mDefaultViewConfig.ttl + " sec " + (appDeck.justLaunch ? "(app just start, shorten to:" + ttl + ")" : "") + " age: " + (now - cacheResult.lastModified) / 1000 + " sec ";
                    mWebView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
                    mShouldReloadFromBackgrounfOnError = true;
                    toast_color = Utils.infoBlueColor();
                }
            } else {
                toast = "Cache MISS (NOT IN CACHE) ttl: " + mDefaultViewConfig.ttl + " sec ";
                mWebView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
                mShouldReloadFromBackgrounfOnError = true;
                toast_color = Utils.warningColor();
            }
        }

        if (mDefaultViewConfig.isDefault)
            toast_color = Utils.antiqueWhiteColor();

        if (appDeck.deviceInfo.isDebugBuild) {
            Snackbar
                    .make(AppDeckApplication.getActivity().findViewById(android.R.id.content)
                            , toast, Snackbar.LENGTH_LONG)
                    .setAction((mDefaultViewConfig.title == null || mDefaultViewConfig.title.isEmpty() ? "(no title)" : mDefaultViewConfig.title), new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            new MaterialDialog.Builder(AppDeckApplication.getActivity())
                                    .content("Url: " + mAbsoluteURL + "\n\n" + mDefaultViewConfig.getDescription())
                                    .positiveText(android.R.string.ok)
                                    .show();
                        }
                    })
                    .setActionTextColor(toast_color)
                    .show(); // Don’t forget to show!
            //Toast.makeText(loader, toast, Toast.LENGTH_SHORT).show();
            DebugLog.info(mDefaultViewConfig.title, toast);
        } else {
            Log.i(TAG, mDefaultViewConfig.title + ": "+ toast);
        }
        mWebView.loadUrl(mAbsoluteURL);
        mLastUrlLoad = System.currentTimeMillis();
    }

    private boolean mProgressBarVisible;
    private ViewPropertyAnimator mProgressBarAnimator;

    private void showProgressBar() {
        if (mProgressBarVisible) {
            mProgressBarVisible = true;
            if (mProgressBarAnimator != null) {
                mProgressBarAnimator.cancel();
            }
            mProgressBar.setVisibility(View.VISIBLE);
            //mProgressBar.setAlpha(0);
            mProgressBarAnimator = mProgressBar.animate()
                    .alpha(1)
                    .withLayer()
                    .setStartDelay(100)
                    .withEndAction(new Runnable(){
                        public void run(){

                        }
                    });
        }
    }

    private void hideProgressBar() {
        if (!mProgressBarVisible) {
            mProgressBarVisible = false;
            //
            //mProgressBar.setAlpha(0);
            if (mProgressBarAnimator != null) {
                mProgressBarAnimator.cancel();
            }
            mProgressBar.animate()
                    .alpha(0)
                    .withLayer()
                    .setStartDelay(100)
                    .withEndAction(new Runnable(){
                        public void run(){
                            mProgressBar.setVisibility(View.INVISIBLE);
                        }
                    });
        }
    }

    public void onLoadStarted(WebView origin) {
        if (origin == mWebView) {
            mProgressBar.setVisibility(View.VISIBLE);
            mProgressBar.setAlpha(0);
            mProgressBar.animate().alpha(1).withLayer().setStartDelay(100);
        }
    }

    public void onLoadProgress(WebView origin, int progress) {
        if (origin == mWebView && progress > 25) {
            //mProgressBar.setVisibility(View.VISIBLE);
        }
    }

    public void onLoadSuccess(WebView origin) {
        if (origin == mWebView) {
            mProgressBar.setVisibility(View.INVISIBLE);
        }
        mSwipeView.setRefreshing(false);
        mSwipeViewAlt.setRefreshing(false);

        if (origin == mWebViewAlt)
            swapWebView();
    }

    public void onLoadFailed(WebView origin) {
        if (origin == mWebView) {
            mProgressBar.setVisibility(View.INVISIBLE);
        }

        mSwipeView.setRefreshing(false);
        mSwipeViewAlt.setRefreshing(false);

        if (origin == mWebView)
        {
            Cache.CacheResult cacheResult = AppDeckApplication.getAppDeck().cache.isInCache(mAbsoluteURL);

            if (cacheResult.isInCache) {
                mSwipeViewAlt.setVisibility(View.VISIBLE);
                mRootView.bringChildToFront(mSwipeViewAlt);
                mWebViewAlt.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
                mWebViewAlt.loadUrl(mAbsoluteURL);
            } else {
                mSwipeViewAlt.setVisibility(View.VISIBLE);
                mRootView.bringChildToFront(mSwipeViewAlt);
                mWebViewAlt.loadData(AppDeckApplication.getAppDeck().error_html, "text/html", "utf-8");
            }
        }
        else if (origin == mWebViewAlt)
        {
            Snackbar.make(AppDeckApplication.getActivity().findViewById(R.id.content_main), "Network Error", Snackbar.LENGTH_LONG).show();

            mWebViewAlt.stopLoading();

            //setVisibility(View.INVISIBLE);
            mReloadInProgress = false;
        }
    }

    public void reloadInBackground()
    {
        if (mReloadInProgress)
            return;
        if (mWebView == null || mWebViewAlt == null)
            return;

        mReloadInProgress = true;

        mWebView.stopLoading();
        mWebViewAlt.stopLoading();
        mWebViewAlt.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);

        mRootView.bringChildToFront(mSwipeView);

        mWebViewAlt.loadUrl(mAbsoluteURL);
        mLastUrlLoad = System.currentTimeMillis();
    }

    public void swapWebView()
    {
        if (mSwapInProgress)
            return;

        mSwapInProgress = true;

        mWebView.setTouchDisabled(true);
        mWebViewAlt.setTouchDisabled(true);
        mWebViewAlt.setVerticalScrollBarEnabled(false);


        int x = mWebView.fetchHorizontalScrollOffset();
        int y = mWebView.fetchVerticalScrollOffset();
        mWebViewAlt.scrollTo(x, y);
        //pageWebView.copyScrollTo(pageWebViewAlt);
        mSwipeViewAlt.setAlpha(0f);
        mSwipeViewAlt.setVisibility(View.VISIBLE);
        mRootView.bringChildToFront(mSwipeViewAlt);
        //rootView.bringChildToFront(preLoadingIndicator);

        final Runnable r = new Runnable()
        {
            public void run()
            {
                // Animate the content view to 100% opacity, and clear any animation
                // listener set on the view.
                mSwipeViewAlt.animate()
                        .alpha(1f)
                        .setDuration(250)
                        .setListener(new AnimatorListenerAdapter() {
                            @Override
                            public void onAnimationEnd(Animator animation) {
                                mSwipeView.setVisibility(View.GONE);

                                if (mWebView == null || mWebViewAlt == null)
                                    return;

                                mWebView.stopLoading();

                                mWebView.setTouchDisabled(false);
                                mWebViewAlt.setTouchDisabled(false);
                                mWebViewAlt.setVerticalScrollBarEnabled(true);

                                // swap webview and config
                                SmartWebView tmpWebView = mWebView;
                                mWebView = mWebViewAlt;
                                mWebViewAlt = tmpWebView;

                                ViewConfig tmpConfig = mPageConfig;
                                mPageConfig = mPageConfigAlt;
                                mPageConfigAlt = mPageConfig;

                                mWebViewAlt.unloadPage();

                                SwipeRefreshLayout tmpSwipeView = mSwipeView;
                                mSwipeView = mSwipeViewAlt;
                                mSwipeViewAlt = tmpSwipeView;

                                NestedScrollWebView tmpScrollView = mNestedScrollView;
                                mNestedScrollView = mNestedScrollViewAlt;
                                mNestedScrollViewAlt = tmpScrollView;

                                mRootView.bringChildToFront(mSwipeView);
                                //rootView.bringChildToFront(preLoadingIndicator);

                                mSwapInProgress = false;
                                mReloadInProgress = false;

                                mPageManager.onConfigurationChange(Page.this, mPageConfig);
                            }
                        });
            }
        };


        new Handler().postDelayed(r, 250);
    }


    public boolean apiCall(final ApiCall call) {
        if (mPageManager != null)
            return mPageManager.apiCall(call);
        return AppDeckApplication.getActivity().apiCall(call);
    }

    public boolean shouldOverrideBackButton() {
        if (mWebView.shouldOverrideBackButton())
            return true;
        return false;
    }

    public void evaluateJavascript(String js) {
        mWebView.evaluateJavascript(js, null);
    }

    @Override
    public ViewConfig getViewConfig() {
        return mPageConfig;
    }

    public String resolveURL(String relativeURL) {
        if (relativeURL == null)
            return null;
        //if (relativeURL.startsWith("javascript:"))
        //    return relativeURL;
        if (mAbsoluteURL == null)
            return relativeURL;
        try {
            URI baseURL = new URI(mAbsoluteURL);
            return baseURL.resolve(relativeURL).toString();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }
        return relativeURL;
    }

    /*public void onPageConfigurationChange() {
        pageManager.onPageConfigurationChange(this);
    }*/

    public void setPreviousNext(String previousURL, String nextURL) {
        this.previousPageUrl = previousURL;
        this.nextPageUrl = nextURL;
        mPageManager.updatePreviousNext(this);
    }

    public void onShow() {
        if (mWebView != null)
            mWebView.resume();
        if (mWebViewAlt != null)
            mWebViewAlt.resume();
    }

    public void onHide() {
        if (mWebView != null)
            mWebView.pause();
        if (mWebViewAlt != null)
            mWebViewAlt.pause();
    }

    public void onPause() {
        if (mWebView != null)
            mWebView.pause();
        if (mWebViewAlt != null)
            mWebViewAlt.pause();
    }

    public void onResume() {
        if (mWebView != null)
            mWebView.resume();
        if (mWebViewAlt != null)
            mWebViewAlt.resume();
    }

    public void destroy() {
        if (mWebView != null) {
            mNestedScrollView.removeView(mWebView);
            Factory.recycleSmartWebView(mWebView);
            //mWebView.destroy();
            mWebView = null;
        }
        if (mWebViewAlt != null) {
            mNestedScrollViewAlt.removeView(mWebViewAlt);
            Factory.recycleSmartWebView(mWebViewAlt);
            //mWebViewAlt.destroy();
            mWebViewAlt = null;
        }
    }

    public void onConfigurationChange(SmartWebView origin, ViewConfig appDeckViewConfig) {
        appDeckViewConfig = appDeckViewConfig.mergeDefault(mDefaultViewConfig);
        if (origin == mWebView) {
            mPageConfig = appDeckViewConfig;
            mPageManager.onConfigurationChange(this, mPageConfig);
        }
        if (origin == mWebViewAlt) {
            mPageConfigAlt = appDeckViewConfig;
        }
    }
}
