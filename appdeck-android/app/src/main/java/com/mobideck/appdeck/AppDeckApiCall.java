package com.mobideck.appdeck;

import java.io.IOException;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;
//import org.xwalk.core.XWalkJavascriptResult;
//import org.xwalk.core.XWalkView;

import android.view.View;
import android.webkit.ValueCallback;

import com.mobideck.appdeck.plugin.ApiCall;

/*import android.util.Log;
import android.webkit.JsPromptResult;
import android.webkit.WebView;*/

public class AppDeckApiCall extends ApiCall {

	//public WebView webview;
	public View webview;
	//public SmartWebView smartWebView;
	//public XSmartWebView smartWebView;
	public SmartWebViewInterface smartWebView;
	//public String command;
	//public String eventID;
	//public String inputJSON;
	//public JSONObject inputObject;
	//public JSONObject paramObject;
	public AppDeckJsonNode input;
	public AppDeckJsonNode param;
	
	//public String resultJSON;
	//@property (strong, nonatomic) id result;
	//public Boolean success;
	//public Boolean callBackSend;
	//public JsPromptResult result;
    public SmartWebViewResult result;
	//public XWalkJavascriptResult result;
	public AppDeckFragment appDeckFragment;
	
	protected boolean postponeResult = false;
	
	protected boolean resultSent = false;
	
	public AppDeckApiCall(String command, String inputJSON, SmartWebViewResult/*XWalkJavascriptResult*//*JsPromptResult*/ result)
	{
		this.command = command;
		this.inputJSON = inputJSON;
		this.result = result;
		//input = null;
		try {
			//JSONArray inputArray = (JSONArray) new JSONTokener(inputJSON).nextValue();
			inputObject = (JSONObject) new JSONTokener(inputJSON).nextValue();
			if (inputObject != null)
				paramObject = inputObject.optJSONObject("param");
			input = new AppDeckJsonNode(inputObject);
			param = new AppDeckJsonNode(paramObject);
			eventID = input.getString("eventid", "false");
			/*Object obj = inputObject.opt("param");
			if (obj instanceof JSONObject)
				param = new AppDeckJsonNode((JSONObject)obj);*/
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

    @Override
	public void sendCallBackWithError(String error)
	{
		JSONArray result = new JSONArray();
		result.put(error);
        sendCallbackWithResult("error", result);
	}
/*
    public void sendCallbackWithResult(String type, Object resultObj)
    {
//		JSONArray result = new JSONArray();
//		result.put(resultObj);
//		resultJSON = result.toString();
        Object[] params = new Object[1];
        params[0] = resultObj;
        sendCallbackWithResult(type, params);
    }*/

    @Override
	public void sendCallbackWithResult(String type, String result) {
		JSONArray results = new JSONArray();
		results.put(result);
		sendCallbackWithResult(type, results);
	}

    @Override
	public void sendCallbackWithResult(String type, JSONObject result) {
		JSONArray results = new JSONArray();
		results.put(result);
		sendCallbackWithResult(type, results);
	}

    @Override
	public void sendCallbackWithResult(String type, JSONArray results)
	{
/*        JSONArray results_json = new JSONArray();
        for (int k = 0; k < results.length; k++)
            results_json.put(results[k]);*/
        String detail = "{\"type\": \""+type+"\", \"params\": "+results.toString()+"}";
        String js = "var evt = document.createEvent('Event');evt.initEvent('"+this.eventID+"',true,true); evt.detail = "+detail+"; document.dispatchEvent(evt);";
        this.smartWebView.evaluateJavascript(js, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {

                    }
                });
	}

    @Override
	public void setResultJSON(String json)
	{
		resultJSON = json;
	}

    @Override
	public void setResult(Object res)
	{
		JSONArray result = new JSONArray();
		result.put(res);
		//JSONObject jsonObj = (JSONObject) JSONObject.wrap(res);
		resultJSON = result.toString();
	}

    @Override
	public void postponeResult()
	{
		postponeResult = true;
	}

    @Override
	public void sendPostponeResult(Boolean r)
	{
		postponeResult = false;
		sendResult(r);
	}

    @Override
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
		result.SmartWebViewResultConfirmWithResult(ret);
	}	
	
	protected void finalize() throws Throwable
	{
		super.finalize();

		if (resultSent == false)
			result.SmartWebViewResultCancel();
	}
}
