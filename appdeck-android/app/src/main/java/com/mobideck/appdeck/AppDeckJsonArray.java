package com.mobideck.appdeck;

import org.json.JSONArray;
import org.json.JSONException;

public class AppDeckJsonArray {

	JSONArray array;
	
	AppDeckJsonArray(JSONArray array)
	{
		this.array = array;
	}

	String getString(int idx)
	{
		return getString(idx, "");
	}
	
	String getString(int idx, String defaultValue)
	{
		try {
			return array.getString(idx);
		} catch (JSONException e) {
			e.printStackTrace();
			return defaultValue;
		}
	}

	AppDeckJsonNode getNode(int idx)
	{
		try {
			return new AppDeckJsonNode(array.getJSONObject(idx));
		} catch (JSONException e) {
			return null;
		}		
	}
	
	int length()
	{
		return array.length();
	}
}
