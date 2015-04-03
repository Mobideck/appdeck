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

/*import android.util.Log;
import android.webkit.JsPromptResult;
import android.webkit.WebView;*/

public class AppDeckApiCall {

	//public WebView webview;
	public View webview;
	//public SmartWebView smartWebView;
	//public XSmartWebView smartWebView;
	public SmartWebViewInterface smartWebView;
	public String command;
	public String eventID;
	public String inputJSON;
	public JSONObject inputObject;
	public JSONObject paramObject;
	public AppDeckJsonNode input;
	public AppDeckJsonNode param;
	
	public String resultJSON;
	//@property (strong, nonatomic) id result;
	public Boolean success;
	public Boolean callBackSend;
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
		input = null;
		try {
			//JSONArray inputArray = (JSONArray) new JSONTokener(inputJSON).nextValue();
			inputObject = (JSONObject) new JSONTokener(inputJSON).nextValue();
			input = new AppDeckJsonNode(inputObject);
			param = new AppDeckJsonNode(paramObject);
			eventID = input.getString("eventid", "false");
			Object obj = inputObject.opt("param");
			if (obj instanceof JSONObject)
				param = new AppDeckJsonNode((JSONObject)obj);
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void sendCallBackWithError(String error)
	{
        String[] params = new String[1];
        params[0] = error;
        sendCallbackWithResult("error", params);
	}

    public void sendCallbackWithResult(String type, Object resultObj)
    {
        Object[] params = new String[1];
        params[0] = resultObj;
        sendCallbackWithResult(type, params);
    }

	public void sendCallbackWithResult(String type, Object[] results)
	{
        JSONArray results_json = new JSONArray();
        for (int k = 0; k < results.length; k++)
            results_json.put(results[k]);
        String detail = "{\"type\": \""+type+"\", \"params\": "+results_json.toString()+"}";
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
		//JSONObject jsonObj = (JSONObject) JSONObject.wrap(res);
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
		result.SmartWebViewResultConfirmWithResult(ret);
	}	
	
	protected void finalize() throws Throwable
	{
		super.finalize();

		if (resultSent == false)
			result.SmartWebViewResultCancel();
		
	}
	
	
}
