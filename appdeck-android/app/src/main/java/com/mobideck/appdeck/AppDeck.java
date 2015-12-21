package com.mobideck.appdeck;

import java.io.File;

import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiskCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;

// TODO:
// - https://github.com/Huppie/Appirater-for-Android
// - https://github.com/Prototik/HoloEverywhere
// - http://code.google.com/p/android-wheel/
// - https://github.com/chrisbanes/PhotoView

public class AppDeck {

    //public boolean isAppdeckTestApp = false;
    public boolean isDebugBuild = false;


	public static String TAG = "AppDeck";

	public static String version = "1.6.0";

    public static String appdeck_inject_js = "if (typeof(appDeckAPICall)  === 'undefined') { appDeckAPICall = ''; var scr = document.createElement('script'); scr.type='text/javascript'; scr.async = true; scr.src = 'http://appdata.static.appdeck.mobi/js/fastclick.js'; document.getElementsByTagName('head')[0].appendChild(scr); var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/appdeck.js'; scr.async = true; document.getElementsByTagName('head')[0].appendChild(scr); var result = true;} else { var result = false; }";
    //public static String appdeck_inject_js_inline = "javascript:" + appdeck_inject_js;

    public static String error_html;

//	public static String error_html_new = "<html><head><meta name=viewport content=\"width=device-width,user-scalable=no\"><style>svg{bottom: 0; height: 150px; left: 0; margin: auto; position: absolute; top: 0; right: 0; width: 150px;}</style></head><body> <svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" id=\"Layer_1\" x=\"0px\" y=\"0px\" width=\"512px\" height=\"441.078px\" viewBox=\"0 0 512 441.078\" enable-background=\"new 0 0 512 441.078\" xml:space=\"preserve\"><path d=\"M512,122.174c-9.88-7.479-108.315-87.975-255.994-87.975c-33.099,0-63.561,4.177-91.272,10.557l227.182,226.966L512,122.174 z M64.107,0l-28.04,28.4l45.196,45.195C34.199,94.902,5.166,118.324,0,122.281l255.785,318.69l0.221,0.106l0.22-0.214 l85.773-106.898l72.919,72.919l28.029-28.051L64.107,0z\" fill=\"#CD5C5C\"/></svg></body></style>";

	public boolean noCache = false;
	
	public boolean ready;
	
	public Configuration config;
	
	public CacheManager cache;
	
	public ImageLoader imageLoader;
	public DisplayImageOptions imageLoaderDefaultOptions;
	
	public String packageName;
	
	public GA ga;
	
	public boolean isTablet = false;

	Boolean appShouldRestart = false;
	
	public int actionBarHeight;
	
	public File cacheDir;
	
	public AssetManager assetManager;
	
	public String uid;
	
	public boolean isLowSystem = false;
	
	public java.net.CookieManager cookieMamager;
	
	private static AppDeck instance;

	public RemoteAppCache remote = null;

	public static AppDeck getInstance()
	{
        return instance;
    }

	public String userAgent;

    AppDeck(Context context, String app_conf_url)
    {
    	instance = this;

		AppDeck.error_html = "<html><head><meta name=viewport content=\"width=device-width,user-scalable=no\"><style>html{-webkit-font-smoothing:antialiased}body{font-family:HelveticaNeue-Light,\"Helvetica Neue Light\",\"Helvetica Neue\",Helvetica,Arial,\"Lucida Grande\",sans-serif;font-weight:300;color:#BAC1C8}body{margin:0;padding:0;overflow:hidden}.mark{font-size:120px;text-align:center}.title{font-size:40px;text-align:center}</style><body><div class=mark>!</div><div class=title>&lt;"+context.getString(R.string.network_error)+"/&gt;</div></body></html>";

    	if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.HONEYCOMB)
    		isLowSystem = true;

        //if (context.getPackageName().equalsIgnoreCase("com.mobideck.appdeck"))
        //    isAppdeckTestApp = true;

        if (0 != (context.getApplicationInfo().flags &= ApplicationInfo.FLAG_DEBUGGABLE))
            isDebugBuild = true;

    	cacheDir = context.getCacheDir();
    	assetManager = context.getAssets();
    	
    	uid = Utils.getUid(context.getApplicationContext());
    	packageName = context.getPackageName();    	
    	
    	if (app_conf_url == null)
    	{
    		ApplicationInfo ai;
    		try {
    			ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
    			Bundle bundle = ai.metaData;
    			noCache = bundle.getBoolean("noCache");
    			app_conf_url = bundle.getString("AppDeckJSONURL");			
    		} catch (NameNotFoundException e) {
    			Log.wtf(TAG, "failed to read app configuration");
    			e.printStackTrace();
    		}
    	}
		    	
    	isTablet = Utils.isTabletDevice(context);

    	java.net.CookieManager cookieManager = new java.net.CookieManager(null, java.net.CookiePolicy.ACCEPT_ALL);
    	java.net.CookieHandler.setDefault(cookieManager);

		//if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
			CookieSyncManager.createInstance(context);
		//}
    	CookieManager.getInstance().setAcceptCookie(true);
    	    	
    	ready = false;    	
    	
    	// Cache Manager, by default only embed resources cache is available
    	cache = new CacheManager();
    	
    	config = new Configuration();
    	config.readConfiguration(app_conf_url);

    	// init sdcard and memory cache
    	cache.init(context);

    	imageLoaderDefaultOptions = getDisplayImageOptionsBuilder().build();    	
    	
    	ImageLoaderConfiguration.Builder builder = new ImageLoaderConfiguration.Builder(context);



    	builder.defaultDisplayImageOptions(imageLoaderDefaultOptions)
    	.discCache(new UnlimitedDiskCache(new File(cache.getCachePath())))
    	//.discCache(new TotalSizeLimitedDiscCache(new File(cache.getCachePath()), new AppDeckCacheFileNameGenerator(), 1024 * 1024 * 100)) // default
    	.imageDownloader(new AppDeckBaseImageDownloader(context))
    	.writeDebugLogs();
    	
    	if (isLowSystem)
    	{
    		//builder.memoryCache(new WeakMemoryCache());
    		builder.threadPoolSize(1);
    	}    	
    	
    	ImageLoaderConfiguration imageConfig = builder.build();
    	
    	imageLoader = ImageLoader.getInstance();
    	imageLoader.init(imageConfig);
    	
    	// Google Analytics
    	ga = new GA(context);
    	if (config.ga != null)
    		ga.addTracker(config.ga);
    	ga.addTracker(GA.globalTracker);    	

    }

	static boolean isAppdeckTestApp(Context context) {
		return context.getPackageName().equalsIgnoreCase("com.mobideck.appdeck");
	}

    public DisplayImageOptions.Builder getDisplayImageOptionsBuilder()
    {
    	DisplayImageOptions.Builder builder = new DisplayImageOptions.Builder();
    	builder.cacheInMemory(!noCache && !isLowSystem);
    	builder.cacheOnDisk(!noCache);
		//builder.imageScaleType(ImageScaleType.EXACTLY);
		builder.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2);

    	if (isLowSystem)
    	{
    		builder.delayBeforeLoading(100);
    		builder.bitmapConfig(Bitmap.Config.RGB_565);
    		builder.imageScaleType(ImageScaleType.IN_SAMPLE_INT);
    		//builder.imageScaleType(ImageScaleType.EXACTLY);
    	}
    	
    	return builder;
    }
    
}
