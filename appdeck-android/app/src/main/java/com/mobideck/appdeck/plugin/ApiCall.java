package com.mobideck.appdeck.plugin;

import android.content.Context;
import android.view.View;
import android.webkit.ValueCallback;

import com.mobideck.appdeck.AppDeckFragment;
import com.mobideck.appdeck.AppDeckJsonNode;
import com.mobideck.appdeck.SmartWebViewInterface;
import com.mobideck.appdeck.SmartWebViewResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public abstract class ApiCall {
//    public View webview;
    public String command;
    public String eventID;
    public String inputJSON;
    public JSONObject inputObject;
    public JSONObject paramObject;
//    public AppDeckJsonNode input;
//    public AppDeckJsonNode param;

    public String resultJSON;
    public Boolean success;
    public Boolean callBackSend;
//    public SmartWebViewResult result;
//    public AppDeckFragment appDeckFragment;

//    protected boolean postponeResult = false;

//    protected boolean resultSent = false;

    abstract public void sendCallBackWithError(String error);

    abstract public void sendCallbackWithResult(String type, String result);

    abstract public void sendCallbackWithResult(String type, JSONObject result);

    abstract public void sendCallbackWithResult(String type, JSONArray results);

    abstract public void setResultJSON(String json);

    abstract public void setResult(Object res);

    abstract public void postponeResult();

    abstract public void sendPostponeResult(Boolean r);

    abstract public void sendResult(Boolean r);
}
