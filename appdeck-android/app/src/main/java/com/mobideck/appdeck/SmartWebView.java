package com.mobideck.appdeck;


import android.view.View;
import android.content.Context;
import android.util.AttributeSet;

public class SmartWebView //extends View implements SmartWebViewInterface
{
/*    public SmartWebView(AppDeckFragment root) {
        super(root.getActivity());
    }

    public SmartWebView(Context context, AttributeSet attrs) {
        super(context, attrs);

    }

    public SmartWebView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

    }
    public SmartWebView(Context context) {
        super(context);
    }*/

    public SmartWebView(View _view, SmartWebViewInterface _ctl) {this.view = _view; this.ctl = _ctl; }

    public View view;
    public SmartWebViewInterface ctl;

}
