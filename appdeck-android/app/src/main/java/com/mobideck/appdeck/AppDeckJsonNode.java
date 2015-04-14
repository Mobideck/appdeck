package com.mobideck.appdeck;

import android.util.Log;

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

    private String[] getNames(String name)
    {
        String[] names = new String[4];
        if (AppDeck.getInstance().isTablet)
            names[0] = name+"_android_tablet";
        else
            names[0] = name+"_android_phone";
        if (AppDeck.getInstance().isTablet)
            names[1] = name+"_tablet";
        else
            names[1] = name+"_phone";
        names[2] = name+"_android";
        names[3] = name;
        return names;
    }

	AppDeckJsonNode get(String name)
	{
        String[] names = getNames(name);
        JSONObject ret = null;
		//
		
		try {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    ret = root.getJSONObject(names[k]);
                    break;
                }
            }
		} catch (Exception e) {
			return null;
		}

		if (ret instanceof JSONObject)
			return new AppDeckJsonNode((JSONObject)ret);

		return null;
	}
	
	AppDeckJsonArray getArray(String name)
	{
        String[] names = getNames(name);
		try {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    return new AppDeckJsonArray(root.getJSONArray(names[k]));
                }
            }
		} catch (Exception e) {
		}
        return new AppDeckJsonArray(new JSONArray());
	}
	
	int getInt(String name)
	{
        String[] names = getNames(name);
		try {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    return root.getInt(names[k]);
                }
            }
		} catch (Exception e) {

        }
        return 0;
	}
	
	boolean isInt(String name)
	{
        String[] names = getNames(name);
		try {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    root.getInt(names[k]);
                    return true;
                }
            }
		} catch (Exception e) {

		}
        return false;
	}
	
	String getString(String name)
	{
		return getString(name, "");
	}

	String getString(String name, String defaultValue)
	{
        String[] names = getNames(name);
		try {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    Object ret = root.get(names[k]);
                    if (ret instanceof String)
                        return (String)ret;
                }
            }
			return defaultValue;//root.getString(name);
		} catch (Exception e) {
			return defaultValue;
		}
	}
		
	boolean getBoolean(String name)
	{
        String[] names = getNames(name);
		try {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    return root.getBoolean(names[k]);
                }
            }
		} catch (Exception e) {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    String val = getString(names[k]);
                    if (val.equalsIgnoreCase("1"))
                        return true;
                }
            }
		}
        return false;
	}

	float getFloat(String name)
	{
        String[] names = getNames(name);
		try {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    return (float)root.getDouble(names[k]);
                }
            }
		} catch (Exception e) {

		}
        return 0;
	}	
	
	String toJsonString()
	{
		return (root == null ? "" : root.toString());
	}

    String optString(String name, String defaultValue)
    {
        String[] names = getNames(name);
        try {
            for (int k = 0; k < names.length; k++) {
                if (root.has(names[k])) {
                    Object ret = root.get(names[k]);
                    if (ret instanceof String)
                        return (String)ret;
                    if (ret instanceof Number)
                        return ((Number)ret).toString();
                }
            }
            return defaultValue;//root.getString(name);
        } catch (Exception e) {
            e.printStackTrace();
            Log.e("mytag", "mymessage", e);
            return defaultValue;
        }
    }


}