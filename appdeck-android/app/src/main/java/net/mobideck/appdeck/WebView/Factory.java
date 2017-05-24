package net.mobideck.appdeck.WebView;

import android.content.Context;
import android.os.Build;

import java.util.ArrayList;

public class Factory {

    public static ArrayList<SmartWebView> smartWebViews = null;

    public static SmartWebView createSmartWebView(Context context)
    {
        // recycle old SmartWebView
        if (smartWebViews == null)
            smartWebViews = new ArrayList<SmartWebView>();
        if (smartWebViews.size() > 0)
        {
            SmartWebView smartWebView = smartWebViews.remove(0);
            smartWebView.pause();
            return smartWebView;
        }
        SmartWebView smartWebView = new SmartWebView(context);
        return smartWebView;
    }

    public static void recycleSmartWebView(SmartWebView smartWebView)
    {
        smartWebView.page = null;
        smartWebView.unloadPage();
        smartWebView.pause();
        //smartWebView.destroy();
        //smartWebView.ctl.setIsWarmUp(true);
        smartWebViews.add(smartWebView);
    }
}
