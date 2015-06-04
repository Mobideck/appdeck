package com.mobideck.appdeck;

import android.os.Build;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;

public class SmartWebViewFactory {

    public static boolean forceCrossWalk = false;

    public static final int POSITION_LEFT = 1;
    public static final int POSITION_RIGHT = 2;

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

        //smartWebView.ctl.setForceCache(true);

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
        smartWebViews.add(smartWebView);
    }

    public static void setPreferences(Loader loader)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && !SmartWebViewFactory.forceCrossWalk)
            SmartWebViewChrome.setPreferences(loader);
        else
            SmartWebViewCrossWalk.setPreferences(loader);

    }

}
