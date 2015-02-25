package com.mobideck.appdeck;

import android.os.Build;
import android.view.View;

public class SmartWebViewFactory {

    public static final int POSITION_LEFT = 1;
    public static final int POSITION_RIGHT = 2;

    public static SmartWebView createMenuSmartWebView(Loader loader, String url, int position)
    {
        AppDeckFragment tmp = AppDeckFragment.fragmentWithLoader(loader);
        tmp.alwaysLoadRootPage = true;

        SmartWebView smartWebView = SmartWebViewFactory.createSmartWebView(tmp);

        //this.url = url;
        //this.position = position;

        smartWebView.ctl.loadUrl(url);

        return smartWebView;

    }


    public static SmartWebView createSmartWebView(AppDeckFragment root)
    {
        // since kitkat, chrome is default webview
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
        {
            SmartWebViewChrome obj = new SmartWebViewChrome(root);
            return new SmartWebView(obj, obj);
        }
        // use chrome via crosswalk
        SmartWebViewCrossWalk obj = new SmartWebViewCrossWalk(root);
        return new SmartWebView(obj, obj);

    }

    public static void setPreferences()
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
            SmartWebViewChrome.setPreferences();
        else
            SmartWebViewCrossWalk.setPreferences();

    }

}
