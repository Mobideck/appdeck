package com.mobideck.appdeck;

import android.view.View;

public class SmartWebView {
    public SmartWebView(View _view, SmartWebViewInterface _ctl) { this.view = _view; this.ctl = _ctl; }

    public View view;
    public SmartWebViewInterface ctl;
}
