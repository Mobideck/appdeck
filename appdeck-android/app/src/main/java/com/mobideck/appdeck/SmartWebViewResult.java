package com.mobideck.appdeck;

public interface SmartWebViewResult {

    public abstract void SmartWebViewResultCancel();

    public abstract void SmartWebViewResultConfirm();

    public abstract void SmartWebViewResultConfirmWithResult(String result);

}
