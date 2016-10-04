package com.mobideck.appdeck;

import android.util.Log;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import com.mobideck.appdeck.R;

public class ScreenConfiguration {

	public static String TAG = "ScreenConfiguration";

	public String title;
	public String logo;
	public String type;
	
	public Boolean isPopUp;
	public Boolean enableShare;
	
	public Pattern urlRegexp[];
	public Pattern notUrlRegexp[];
	
	public int ttl;

	public boolean isDefault = false;
	
	public static ScreenConfiguration defaultConfiguration()
	{
		ScreenConfiguration config = new ScreenConfiguration();
		config.title = "None (default config)";
		config.ttl = 600;
		config.isDefault = true;
		return config;
	}
	
	private ScreenConfiguration()
	{
		
	}

	public String getDescription() {
		String r = 	"Title: "+ title + "\n" +
					"logo: "+ logo + "\n" +
					"type: "+ type + "\n" +
					"isPopUp: "+ isPopUp + "\n" +
					"enableShare: "+ enableShare + "\n" +
					"urlRegexp: ";
		for (int i = 0; i < urlRegexp.length; i++) {
			Pattern regexp = urlRegexp[i];
			r = r + " '" + regexp.toString() + "'";
		}

		r = r + "\nnotUrlRegexp: ";

		for (int i = 0; i < notUrlRegexp.length; i++) {
			Pattern regexp = notUrlRegexp[i];
			r = r + " '" + notUrlRegexp.toString() + "'";
		}

		return r;
	}
	
	public PageMenuItem[] getDefaultPageMenuItems(URI baseUrl, AppDeckFragment fragment)
	{
		if (false) {
			PageMenuItem refresh = new PageMenuItem(fragment.loader.getResources().getString(R.string.refresh), "!refresh", "button", "appdeckapi:refresh", null, baseUrl, fragment);

			PageMenuItem items[] = new PageMenuItem[1];
			items[0] = refresh;
			return items;
		}
		return new PageMenuItem[0];
	}	
	
	private String readString(AppDeckJsonNode node, String name)
	{
		String text = node.getString(name, null);
		if (text == null)
			return null;
		if (text.equalsIgnoreCase("") == true)
			return null;
		return text;
	}
	
	public ScreenConfiguration(AppDeckJsonNode node, URI baseUrl)
	{
		title = readString(node, "title");
		logo =  readString(node, "logo");
		try {
			if (logo != null)
				logo = baseUrl.resolve(logo).toString();
		} catch (Exception e) {
			Log.e(TAG, "Screen "+title+" logo is disabled as logo '"+logo+"' is invalid: "+e.getMessage());
		}
		type = readString(node, "type");
		isPopUp = node.getBoolean("popup");
		enableShare = node.getBoolean("enable_share");
		ttl = 600;
		
		if (node.isInt("ttl"))
			ttl = node.getInt("ttl");
		
		AppDeckJsonArray urlsNode = node.getArray("urls"); 
		if (urlsNode.length() > 0)
		{
			urlRegexp = new Pattern[urlsNode.length()];
			for (int i = 0; i < urlsNode.length(); i++) {
				String regexp = urlsNode.getString(i).trim();
				if (regexp.isEmpty()) {
                    urlRegexp[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
                    continue;
                }
				try {
					Pattern p = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
					urlRegexp[i] = p;
				} catch (PatternSyntaxException e) {
					e.printStackTrace();
					urlRegexp[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
				}
			}
		}
		AppDeckJsonArray notUrlsNode = node.getArray("not_urls");
		if (urlsNode.length() > 0)
		{
			notUrlRegexp = new Pattern[notUrlsNode.length()];
			for (int i = 0; i < notUrlsNode.length(); i++) {
				String regexp = notUrlsNode.getString(i).trim();
                if (regexp.isEmpty()) {
					notUrlRegexp[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
                    continue;
                }
				try {
					Pattern p = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
					notUrlRegexp[i] = p;
				} catch (PatternSyntaxException e) {
					e.printStackTrace();
					notUrlRegexp[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
				}
			}
		}

	}
	
	public Boolean match(String absoluteURL)
	{
		if (urlRegexp == null)
			return false;
		if (notUrlRegexp != null) {
			for (int i = 0; i < notUrlRegexp.length; i++) {
				Pattern regexp = notUrlRegexp[i];
				Matcher m = regexp.matcher(absoluteURL);
				if (m.find())
					return false;
			}
		}
		for (int i = 0; i < urlRegexp.length; i++) {
			Pattern regexp = urlRegexp[i];
			Matcher m = regexp.matcher(absoluteURL);
			if (m.find())
				return true;
		}
		try {
			URI uri = new URI(absoluteURL);
			String path = uri.getPath();
			String query = uri.getQuery();
			if (query != null) {
				path = path + "?" + query;
			}
			if (path != null)
			{
				if (notUrlRegexp != null) {
					for (int i = 0; i < notUrlRegexp.length; i++) {
						Pattern regexp = notUrlRegexp[i];
						Matcher m = regexp.matcher(path);
						if (m.find())
							return false;
					}
				}
				for (int i = 0; i < urlRegexp.length; i++) {
					Pattern regexp = urlRegexp[i];
					Matcher m = regexp.matcher(path);
					if (m.find())
						return true;
				}
			}
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}
	
	public Boolean isRelated(String absoluteURL)
	{
		return match(absoluteURL);
	}
}
