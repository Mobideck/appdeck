package com.mobideck.appdeck;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import com.crashlytics.android.Crashlytics;

import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.util.Log;

public class Configuration {

	public static String TAG = "Configuration";
	
	//int imageToLoad;
	
	class AppDeckColor
	{
		public int color1;
		public int color2;
		
		public Drawable getDrawable()
		{
			 GradientDrawable gd = new GradientDrawable(
			            GradientDrawable.Orientation.TOP_BOTTOM,
			            new int[] {color1, color2});
			    gd.setCornerRadius(0f);
			    return gd;
		}
	}
		
	public Configuration()
	{
		//imageToLoad = 0;
    }

	public void readConfiguration(String app_json_url)
	{
		// init URI object, it will be used to resolve all URLs
		try {
			json_url = new URI(app_json_url);
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
		
		// first try to load JSon from application embed ressources
		CacheManagerCachedResponse cacheResponse = AppDeck.getInstance().cache.getCachedResponse(app_json_url);
		if (cacheResponse == null)
			cacheResponse = AppDeck.getInstance().cache.getEmbedResponse(app_json_url);
		if (cacheResponse != null)
		{
			InputStream jsonStream = cacheResponse.getStream();
			JSONObject node;
			try {
				String jsonString = Utils.streamGetContent(jsonStream);
				node = (JSONObject) new JSONTokener(jsonString).nextValue();
		    	readConfiguration(node);
		    	return;
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		Crashlytics.log("JSon not in embed ressources");
		Log.e(TAG, "JSon not in embed ressources");
		Utils.killApp(true);
		/*
		// if not available, we download it		
		AsyncHttpClient client = new AsyncHttpClient();
		client.get(url.toString(), new AsyncHttpResponseHandler() {
		    @Override
		    public void onSuccess(String response) {
				JsonNode node = null;
				try {
					ObjectMapper mapper = new ObjectMapper(AppDeck.getInstance().jsonFactory);
					node = mapper.readValue(response, JsonNode.class);
				} catch (JsonParseException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (JsonMappingException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
		    	readConfiguration(node);
		    	return;
		    }
		});			*/	
	}
	
	private void readConfiguration(JSONObject node)
	{
		if (node == null)
		{
			Crashlytics.log("JSon null node");
			return;
		}
		AppDeckJsonNode root = new AppDeckJsonNode(node);
		// load configuration from json
		
		app_version = root.getInt("version");
		app_api_key = root.getString("api_key");
		
		Log.d("Configuration", "Version: " + app_version + " API Key: "+ app_api_key);		
		Crashlytics.log("JSon Version: " + app_version + " API Key: "+ app_api_key);
		
		enable_debug = root.getBoolean("enable_debug");
		
		try {
			String base_url = root.getString("base_url", null);
			if (base_url != null)
				app_base_url = new URI(base_url);
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
		if (app_base_url == null)
			app_base_url = json_url;
		
		// bootstrap
		bootstrapUrl = readURI(root.get("bootstrap"), "url", "/");

		// left menu
		AppDeckJsonNode leftMenu = root.get("leftmenu");
//		leftMenu = null;
		if (leftMenu != null)
		{
			leftMenuUrl = readURI(leftMenu, "url", null);
			leftMenuWidth = leftMenu.getInt("width");
			if (leftMenuWidth == 0)
				leftMenuWidth = 320;
		}

		// right menu
		AppDeckJsonNode rightMenu = root.get("rightmenu");
//		rightMenu = null;
		if (rightMenu != null)
		{
			rightMenuUrl = readURI(rightMenu, "url", null);
			rightMenuWidth = rightMenu.getInt("width");
			if (rightMenuWidth == 0)
				rightMenuWidth = 320;
		}
		
		title = root.getString("title", null);
		
		// colors
		app_color = readColor(root, "app_color");
		app_background_color = readColor(root, "app_background_color");
		leftmenu_background_color = readColor(root, "leftmenu_background_color");
		rightmenu_background_color = readColor(root, "rightmenu_background_color");
		
		control_color = readColor(root, "control_color");
		button_color = readColor(root, "button_color");
		
		topbar_color = readColor(root, "app_topbar_color");
		
		// cache
		AppDeckJsonArray cacheNodes = root.getArray("cache"); 
		if (cacheNodes.length() > 0)
		{
			cache = new Pattern[cacheNodes.length()];
			for (int i = 0; i < cacheNodes.length(); i++) {
				String regexp = cacheNodes.getString(i);
				Pattern p = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
				cache[i] = p;
			}
		}
		
		// CDN
		cdn_enabled = root.getBoolean("cdn_enabled");
		cdn_host = root.getString("cdn_host", null);
		cdn_path = root.getString("cdn_path", null);
		if (app_api_key != null)
		{
			if (cdn_host == null)
				cdn_host = String.format("%s.appdeckcdn.com", app_api_key);
			if (cdn_path == null)
				cdn_path = "";
		}
		if (cdn_host == null || cdn_host.equalsIgnoreCase(""))
			cdn_enabled = false;
		
		// screen Configuration
		AppDeckJsonArray screenNodes = root.getArray("screens"); 
		if (screenNodes.length() > 0)
		{
			screenConfigurations = new ScreenConfiguration[screenNodes.length()];
			for (int i = 0; i < screenNodes.length(); i++) {
				AppDeckJsonNode screen = screenNodes.getNode(i);
				ScreenConfiguration config = new ScreenConfiguration(screen, app_base_url);
				screenConfigurations[i] = config;
			}
		}

		// prefetch url
		prefetch_url = readURI(root, "prefetch_url", String.format("http://%s.appdeckcdn.com/%s.7z", app_api_key, app_api_key));
		prefetch_ttl = root.getInt("prefetch_ttl");
		if (prefetch_ttl == 0)
			prefetch_ttl = 600;
		
		ga = root.getString("ga");
		
		push_register_url = readURI(root, "push_register_url", "http://push.appdeck.mobi/register");

		push_google_cloud_messaging_sender_id = root.getString("push_google_cloud_messaging_sender_id");
		
		embed_url = readURI(root, "embed_url", null);
		embed_runtime_url = readURI(root, "embed_runtime_url", null);
		
		enable_mobilize = root.getBoolean("enable_mobilize");

		icon_theme = "light";
		String icon_theme_suffix = "";
		if (root.getString("icon_theme").equalsIgnoreCase("dark"))
		{
			icon_theme = "dark";
			icon_theme_suffix = "_dark";
		}
			
		
		logoUrl = readURI(root, "logo", null);
		

		icon_action = readURI(root, "icon_action", "http://appdata.static.appdeck.mobi/res/android/icons/action"+icon_theme_suffix+".png");
		icon_ok = readURI(root, "icon_ok", "http://appdata.static.appdeck.mobi/res/android/icons/ok"+icon_theme_suffix+".png");
		icon_cancel = readURI(root, "icon_cancel", "http://appdata.static.appdeck.mobi/res/android/icons/cancel"+icon_theme_suffix+".png");
		icon_close = readURI(root, "icon_close", "http://appdata.static.appdeck.mobi/res/android/icons/close"+icon_theme_suffix+".png");
		icon_config = readURI(root, "icon_config", "http://appdata.static.appdeck.mobi/res/android/icons/config"+icon_theme_suffix+".png");
		icon_info = readURI(root, "icon_info", "http://appdata.static.appdeck.mobi/res/android/icons/info"+icon_theme_suffix+".png");
		icon_menu = readURI(root, "icon_menu", "http://appdata.static.appdeck.mobi/res/android/icons/menu"+icon_theme_suffix+".png");
		icon_next = readURI(root, "icon_next", "http://appdata.static.appdeck.mobi/res/android/icons/next"+icon_theme_suffix+".png");
		icon_previous = readURI(root, "icon_previous", "http://appdata.static.appdeck.mobi/res/android/icons/previous"+icon_theme_suffix+".png");
		icon_refresh = readURI(root, "icon_refresh", "http://appdata.static.appdeck.mobi/res/android/icons/refresh"+icon_theme_suffix+".png");
		icon_search = readURI(root, "icon_search", "http://appdata.static.appdeck.mobi/res/android/icons/search"+icon_theme_suffix+".png");
		icon_up = readURI(root, "icon_up", "http://appdata.static.appdeck.mobi/res/android/icons/up"+icon_theme_suffix+".png");
		icon_down = readURI(root, "icon_down", "http://appdata.static.appdeck.mobi/res/android/icons/down"+icon_theme_suffix+".png");
		icon_user = readURI(root, "icon_user", "http://appdata.static.appdeck.mobi/res/android/icons/user"+icon_theme_suffix+".png");

		image_loader = readURI(root, "image_loader", "http://appdata.static.appdeck.mobi/res/android/images/loader"+icon_theme_suffix+".png");
		image_pull_arrow = readURI(root, "image_pull_arrow", "http://appdata.static.appdeck.mobi/res/android/images/pull_arrow"+icon_theme_suffix+".png");

		image_network_error_url = readURI(root, "image_network_error", "http://appdata.static.appdeck.mobi/res/android/images/network_error.png");
		image_network_error_background_color = readColor(root, "image_network_error_background_color");
		
		Crashlytics.log("Read JSON configuration");
		
	}
    
	
	public ScreenConfiguration getConfiguration(String absoluteURL)
	{
		if (absoluteURL != null && screenConfigurations != null)
		{
			for (int i = 0; i < screenConfigurations.length; i++) {
				ScreenConfiguration screenConfiguration = screenConfigurations[i];
				
				if (screenConfiguration.match(absoluteURL))
					return screenConfiguration;
			}
		}				
		return ScreenConfiguration.defaultConfiguration();
	}	

	int parseColor(String colorTxt)
	{
		// try android parser
		try {
			return Color.parseColor(colorTxt);
		} catch (Exception e) {
			// TODO: handle exception
			//e.printStackTrace();
		}
		// try by appending #
		try {
			return Color.parseColor("#"+colorTxt);
		} catch (Exception e) {
			// TODO: handle exception
			//e.printStackTrace();
		}
		// error case
		return Color.TRANSPARENT;
		
	}
	
	protected AppDeckColor readColor(AppDeckJsonNode root, String name)
	{
		// try as an array
		AppDeckJsonArray array = root.getArray(name);
				
		if (array != null && array.length() == 2)
		{
			AppDeckColor color = new AppDeckColor();
			color.color1 = parseColor(array.getString(0));
			color.color2 = parseColor(array.getString(1));
			return color;
		}

		// try as a string
		String stringValue = root.getString(name);
		if (stringValue != null)
		{
			AppDeckColor color = new AppDeckColor();
			color.color1 = color.color2 = parseColor(stringValue);
			return color;
		}


		return null;
	}

	protected URI readURI(AppDeckJsonNode root, String name, String defaultValue)
	{
		if (root == null)
			return app_base_url.resolve(defaultValue);	
		String uri = root.getString(name, defaultValue);
		if (uri == null)
			return null;
		return app_base_url.resolve(uri);
	}
	
	// store app conf
	public URI json_url;

	public int app_version;

	public String app_api_key;

	public Boolean	enable_debug;

	public URI app_base_url;
	public URI app_conf_url;
	public URI push_register_url;
	
	public String push_google_cloud_messaging_sender_id;

	public URI bootstrapUrl;
	public URI leftMenuUrl;
	public int leftMenuWidth;
	//public int leftMenuReveal;
	public URI rightMenuUrl;
	public int rightMenuWidth;
	//public int rightMenuReveal;

	public AppDeckColor app_color;
	public AppDeckColor app_background_color;
	public AppDeckColor leftmenu_background_color;
	public AppDeckColor rightmenu_background_color;

	public AppDeckColor control_color;
	public AppDeckColor button_color;

	public String title;

	//public String logoUrl;
	public URI logoUrl;

	public Pattern cache[];


	//@property (strong, nonatomic) UIView *statusBarInfo;

	public AppDeckColor topbar_color;

	public URI prefetch_url;
	public int prefetch_ttl;

	// images and icons

	public Boolean         cdn_enabled;
	public String cdn_host;
	public String cdn_path;

	public String icon_theme;
	
	public URI icon_action;
	public URI icon_ok;
	public URI icon_cancel;
	public URI icon_close;
	public URI icon_config;
	public URI icon_info;	
	public URI icon_menu;
	public URI icon_next;
	public URI icon_previous;
	public URI icon_refresh;
	public URI icon_search;	
	public URI icon_up;
	public URI icon_down;
	public URI icon_user;
	public URI image_loader;
	public URI image_pull_arrow;

	public URI image_network_error_url;
	public AppDeckColor image_network_error_background_color;

	public ScreenConfiguration screenConfigurations[];

	public String mobiclickApplicationId;
	public String mobiclickAdMobSub;

	public String ga;
	public URI embed_url;
	public URI embed_runtime_url;

	public Boolean enable_mobilize;		
}
