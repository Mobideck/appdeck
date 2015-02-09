package com.mobideck.appdeck;

import java.net.URI;
import java.net.URISyntaxException;

import org.json.JSONArray;
import org.json.JSONObject;

public class AppDeckJsonNode
{
	JSONObject root;
	
	AppDeckJsonNode(JSONObject root)
	{
		this.root = root;
	}
	
	Object getObject(String name)
	{
		try {
			return root.get(name);
		} catch (Exception e) {
			return null;
		}
	}
	
	AppDeckJsonNode get(String name)
	{
		Object ret = null;
		//
		
		try {
			ret = root.get(name);
		} catch (Exception e) {
			return null;
		}
		
		if (ret instanceof JSONObject)
			return new AppDeckJsonNode((JSONObject)ret);
		
		return null;
	}
	
	AppDeckJsonArray getArray(String name)
	{
		try {
			return new AppDeckJsonArray(root.getJSONArray(name));
		} catch (Exception e) {
			return new AppDeckJsonArray(new JSONArray());
		}		
	}
	
	int getInt(String name)
	{
		try {
			return root.getInt(name);
		} catch (Exception e) {
			return 0;
		}		
	}
	
	boolean isInt(String name)
	{
		try {
			root.getInt(name);
			return true;
		} catch (Exception e) {
			return false;
		}		
	}
	
	String getString(String name)
	{
		return getString(name, "");
	}

	String getString(String name, String defaultValue)
	{
		try {
			Object ret = root.get(name);
			if (ret instanceof String)
				return (String)ret;
			return defaultValue;//root.getString(name);
		} catch (Exception e) {
			return defaultValue;
		}
	}
		
	boolean getBoolean(String name)
	{
		try {
			return root.getBoolean(name);
		} catch (Exception e) {
			return false;
		}		
	}

	float getFloat(String name)
	{
		try {
			return (float)root.getDouble(name);
		} catch (Exception e) {
			return 0;
		}		
	}	
	
	String toJsonString()
	{
		return root.toString();
	}
	
	/*
	AppDeckJsonNode get(int idx)
	{
		JSONObject ret = root.path(idx);
		if (ret.isMissingNode())
			return null;
		return new AppDeckJsonNode(ret);
	}
	*/

/*
	AppDeckJsonNode path(String name)
	{
		JsonNode ret = root.path(name);
		if (AppDeck.getInstance().isTablet)
		{
			JsonNode alt = root.path(name+"_tablet");
			if (alt.isMissingNode() == false)
				ret = alt;
		}
		return new AppDeckJsonNode(ret);
	}
	
	AppDeckJsonNode path(int idx)
	{
		JsonNode ret = root.path(idx);
		return new AppDeckJsonNode(ret);
	}

	boolean isInt()
	{
		return root.isInt();
	}
	
	int intValue()
	{
		return root.intValue();
	}
	
	String textValue()
	{
		return root.textValue();
	}
	
	boolean booleanValue()
	{
		return root.booleanValue();
	}
	
	boolean isMissingNode()
	{
		return root.isMissingNode();
	}
			
	boolean isArray()
	{
		return root.isArray();
	}
	
	int size()
	{
		return root.size();
	}*/
}