package com.mobideck.appdeck;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.mobideck.appdeck.R;

public class ScreenConfiguration {

	public String title;
	public String logo;
	public String type;
	
	public Boolean isPopUp;
	public Boolean enableShare;
	
	public Pattern urlRegexp[];
	
	public int ttl;
	
	
	public static ScreenConfiguration defaultConfiguration()
	{
		ScreenConfiguration config = new ScreenConfiguration();
		config.ttl = 600;
		return config;
	}
	
	private ScreenConfiguration()
	{
		
	}
	
	public PageMenuItem[] getDefaultPageMenuItems(URI baseUrl, AppDeckFragment fragment)
	{
		PageMenuItem refresh = new PageMenuItem(fragment.loader.getResources().getString(R.string.refresh), "!refresh", "button", "appdeckapi:refresh", baseUrl, fragment);
		
		PageMenuItem items[] = new PageMenuItem[1];
		items[0] = refresh;
		
		return items;
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
		if (logo != null)
			logo = baseUrl.resolve(logo).toString(); 
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
				String regexp = urlsNode.getString(i);
				Pattern p = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
				urlRegexp[i] = p;
			}
		}		
	}
	
	public Boolean match(String absoluteURL)
	{
		if (urlRegexp == null)
			return false;
		for (int i = 0; i < urlRegexp.length; i++) {
			Pattern regexp = urlRegexp[i];
			Matcher m = regexp.matcher(absoluteURL);
			if (m.find())
				return true;
		}
		try {
			URI uri = new URI(absoluteURL);
			String path = uri.getPath();
			if (path != null)
			{
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
