package net.mobideck.appdeck.core;

import android.util.Log;
import android.webkit.JsPromptResult;
import android.webkit.ValueCallback;

import net.mobideck.appdeck.WebView.SmartWebView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public class ApiCall extends com.mobideck.appdeck.plugin.ApiCall {

    public SmartWebView smartWebView;

    /*public String command;
    public String eventID;
    public String inputJSON;

    public String resultJSON;
    public Boolean success;
    public Boolean callBackSend;*/

    //public JSONObject input;
    //public JSONObject param;

    public JsPromptResult result;

    public Page page;

    protected boolean postponeResult = false;

    protected boolean resultSent = false;


    public ApiCall(String command, String inputJSON, JsPromptResult result)
    {
        this.command = command;
        this.inputJSON = inputJSON;
        this.result = result;
        try {
            inputObject = (JSONObject) new JSONTokener(inputJSON).nextValue();
            if (inputObject != null)
                paramObject = inputObject.optJSONObject("param");
            eventID = inputObject.optString("eventid", "false");
        } catch (JSONException e) {
        }
    }

    public void sendCallBackWithError(String error)
    {
        JSONArray result = new JSONArray();
        result.put(error);
        sendCallbackWithResult("error", result);
    }

    public void sendCallbackWithResult(String type, String result) {
        JSONArray results = new JSONArray();
        results.put(result);
        sendCallbackWithResult(type, results);
    }

    public void sendCallbackWithResult(String type, JSONObject result) {
        JSONArray results = new JSONArray();
        results.put(result);
        sendCallbackWithResult(type, results);
    }

    public void sendCallbackWithResult(String type, JSONArray results)
    {
        String detail = "{\"type\": \""+type+"\", \"params\": "+results.toString()+"}";
        String js = "var evt = document.createEvent('Event');evt.initEvent('"+this.eventID+"',true,true); evt.detail = "+detail+"; document.dispatchEvent(evt);";
        this.smartWebView.evaluateJavascript(js, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {

            }
        });
    }

    public void setResultJSON(String json)
    {
        resultJSON = json;
    }

    public void setResult(Object res)
    {
        JSONArray result = new JSONArray();
        result.put(res);
        resultJSON = result.toString();
    }

    public void postponeResult()
    {
        postponeResult = true;
    }

    public void sendPostponeResult(Boolean r)
    {
        postponeResult = false;
        sendResult(r);
    }

    public void sendResult(Boolean r)
    {
        if (postponeResult)
            return;
        if (resultSent)
            return;
        resultSent = true;
        String rs = (r == true ? "1" : "0");
        if (resultJSON == null)
            resultJSON = "[null]";
        String ret = "{\"success\": \""+rs+"\", \"result\": "+resultJSON+"}";
        //result.confirm(ret);
        result.confirm(ret);
    }

    protected void finalize() throws Throwable
    {
        super.finalize();

        if (resultSent == false)
            result.cancel();

    }

    public String resolveURL(String relativeURL) {
        return page.resolveURL(relativeURL);
    }


}
