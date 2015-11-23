package com.mobideck.appdeck;

import java.io.File;

import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiskCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

import SevenZip.ArchiveExtractCallback;
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

    public boolean isAppdeckTestApp = false;
    public boolean isDebugBuild = false;


	public static String TAG = "AppDeck";

	public static String version = "1.6.0";

    public static String appdeck_inject_js = "if (typeof(appDeckAPICall)  === 'undefined') { appDeckAPICall = ''; var scr = document.createElement('script'); scr.type='text/javascript'; scr.async = true; scr.src = 'http://appdata.static.appdeck.mobi/js/fastclick.js'; document.getElementsByTagName('head')[0].appendChild(scr); var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/appdeck.js'; scr.async = true; document.getElementsByTagName('head')[0].appendChild(scr); var result = true;} else { var result = false; }";
    //public static String appdeck_inject_js_inline = "javascript:" + appdeck_inject_js;

    public static String error_html_old = "<html><head><meta name=viewport content=\"width=device-width,user-scalable=no\"><style>html{-webkit-font-smoothing:antialiased}body{font-family:HelveticaNeue-Light,\"Helvetica Neue Light\",\"Helvetica Neue\",Helvetica,Arial,\"Lucida Grande\",sans-serif;font-weight:300;color:#BAC1C8}body{margin:0;padding:0;overflow:hidden}.mark{font-size:120px;text-align:center}.title{font-size:40px;text-align:center}</style><body><div class=mark>!</div><div class=title>&lt;network error/&gt;</div></body></html>";

	public static String error_html = "<html><head><meta name=viewport content=\"width=device-width,user-scalable=no\"><style>body{margin:0;padding:0;overflow:hidden}.frame {height: 100%; width: 100%; position: relative;} img { max-height: 100%; max-width: 100%; width: auto; height: auto; position: absolute; top: 0; bottom: 0; left: 0; right: 0; margin: auto;}</style><body><div class=\"framr\"><img src=\"data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4NCjwhLS0gR2VuZXJhdG9yOiBBZG9iZSBJbGx1c3RyYXRvciAxNS4wLjIsIFNWRyBFeHBvcnQgUGx1Zy1JbiAuIFNWRyBWZXJzaW9uOiA2LjAwIEJ1aWxkIDApICAtLT4NCjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+DQo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHZlcnNpb249IjEuMSIgaWQ9IkxheWVyXzEiIHg9IjBweCIgeT0iMHB4IiB3aWR0aD0iNTEycHgiIGhlaWdodD0iNDQxLjA3OHB4IiB2aWV3Qm94PSIwIDAgNTEyIDQ0MS4wNzgiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDUxMiA0NDEuMDc4IiB4bWw6c3BhY2U9InByZXNlcnZlIj4NCjxwYXRoIGQ9Ik01MTIsMTIyLjE3NGMtOS44OC03LjQ3OS0xMDguMzE1LTg3Ljk3NS0yNTUuOTk0LTg3Ljk3NWMtMzMuMDk5LDAtNjMuNTYxLDQuMTc3LTkxLjI3MiwxMC41NTdsMjI3LjE4MiwyMjYuOTY2TDUxMiwxMjIuMTc0ICB6IE02NC4xMDcsMGwtMjguMDQsMjguMDRsNDUuMTk2LDQ1LjE5NUMzNC4xOTksOTQuOTAyLDUuMTY2LDExOC4zMjQsMCwxMjIuMjgxbDI1NS43ODUsMzE4LjY5bDAuMjIxLDAuMTA2bDAuMjItMC4yMTQgIGw4NS43NzMtMTA2Ljg5OGw3Mi45MTksNzIuOTE5bDI4LjAyOS0yOC4wNTFMNjQuMTA3LDB6IiBmaWxsPSIjQ0Q1QzVDIi8+DQo8L3N2Zz4NCg==\"></div></body></html>";

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

    	if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.HONEYCOMB)
    		isLowSystem = true;

        if (context.getPackageName().equalsIgnoreCase("com.mobideck.appdeck"))
            isAppdeckTestApp = true;

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
    	
        if (config.prefetch_url != null && !isLowSystem)
        {
        	//ArchiveExtractCallback.extractDir = this.cacheDir;
        	remote = new RemoteAppCache(config.prefetch_url.toString(), config.prefetch_ttl);
        	remote.downloadAppCache();
        }    	
    }

    public DisplayImageOptions.Builder getDisplayImageOptionsBuilder()
    {
    	DisplayImageOptions.Builder builder = new DisplayImageOptions.Builder();
    	builder.cacheInMemory(!noCache && !isLowSystem);
    	builder.cacheOnDisc(!noCache);
    	
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
