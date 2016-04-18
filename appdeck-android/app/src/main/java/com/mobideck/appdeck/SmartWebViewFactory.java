package com.mobideck.appdeck;

import android.content.Intent;
import android.os.Build;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;

public class SmartWebViewFactory {

    public static boolean forceCrossWalk = false;

    public static final int POSITION_LEFT = 1;
    public static final int POSITION_RIGHT = 2;
    public static final int POSITION_HIDDEN = 3;

    public static ArrayList<SmartWebView> smartWebViews = null;

    public static SmartWebView createMenuSmartWebView(Loader loader, String url, int position)
    {
        AppDeckFragment tmp = AppDeckFragment.fragmentWithLoader(loader);
        tmp.alwaysLoadRootPage = true;

        SmartWebView smartWebView = SmartWebViewFactory.createSmartWebView(tmp);

        smartWebView.view.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));

        //this.url = url;
        //this.position = position;

        smartWebView.ctl.setCacheMode(SmartWebViewInterface.LOAD_CACHE_ELSE_NETWORK);

        if (url != null)
            smartWebView.ctl.loadUrl(url);

        return smartWebView;

    }

    public static SmartWebView createSmartWebView(AppDeckFragment root)
    {
        // recycle old SmartWebView
        if (smartWebViews == null)
            smartWebViews = new ArrayList<SmartWebView>();
        if (smartWebViews.size() > 0)
        {
            SmartWebView obj = smartWebViews.remove(0);
            obj.ctl.setRootAppDeckFragment(root);
            obj.ctl.resume();
            return obj;
        }
        // since kitkat, chrome is default webview
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && !SmartWebViewFactory.forceCrossWalk)
        {
            SmartWebViewChrome obj = new SmartWebViewChrome(root);
            return new SmartWebView(obj, obj);
        }
        // use chrome via crosswalk
        SmartWebViewCrossWalk obj = new SmartWebViewCrossWalk(root);
        return new SmartWebView(obj, obj);
    }

    public static void recycleSmartWebView(SmartWebView smartWebView)
    {
        smartWebView.ctl.setRootAppDeckFragment(null);
        smartWebView.ctl.unloadPage();
        smartWebView.ctl.pause();
        //smartWebView.ctl.destroy();
        smartWebView.ctl.setIsWarmUp(true);
        smartWebViews.add(smartWebView);
    }

    public static void setPreferences(Loader loader)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && !SmartWebViewFactory.forceCrossWalk)
            SmartWebViewChrome.setPreferences(loader);
        else
            SmartWebViewCrossWalk.setPreferences(loader);

    }

    public static boolean activityPaused = false;

    public static void onActivityPause(Loader loader)
    {
        SmartWebViewFactory.activityPaused = true;
        SmartWebView smartWebView = SmartWebViewFactory.createMenuSmartWebView(loader, null, POSITION_HIDDEN);
        smartWebView.ctl.onActivityPause(loader);
        smartWebView.ctl.destroy();
    }

    public static void onActivityResume(Loader loader)
    {
        if (SmartWebViewFactory.activityPaused) {
            SmartWebView smartWebView = SmartWebViewFactory.createMenuSmartWebView(loader, null, POSITION_HIDDEN);
            smartWebView.ctl.onActivityResume(loader);
            smartWebView.ctl.destroy();
        }
    }

    public static void onActivityDestroy(Loader loader)
    {

    }

    public  static void onActivityResult(Loader loader, int requestCode, int resultCode, Intent data)
    {
        SmartWebView smartWebView = SmartWebViewFactory.createMenuSmartWebView(loader, null, POSITION_HIDDEN);
        smartWebView.ctl.onActivityResult(loader, requestCode, resultCode, data);
        smartWebView.ctl.destroy();
    }

    public  static void onActivityNewIntent(Loader loader, Intent intent)
    {
        SmartWebView smartWebView = SmartWebViewFactory.createMenuSmartWebView(loader, null, POSITION_HIDDEN);
        smartWebView.ctl.onActivityNewIntent(loader, intent);
        smartWebView.ctl.destroy();
    }

    public static void clearAllCache(Loader loader)
    {
        SmartWebView smartWebView = SmartWebViewFactory.createMenuSmartWebView(loader, null, POSITION_HIDDEN);
        smartWebView.ctl.clearAllCache();
        smartWebView.ctl.destroy();
    }
}
