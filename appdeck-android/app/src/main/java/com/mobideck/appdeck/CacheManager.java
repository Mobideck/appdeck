package com.mobideck.appdeck;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.StreamCorruptedException;
import java.math.BigInteger;
import java.net.CacheResponse;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.zip.GZIPInputStream;

import cz.msebera.android.httpclient.Header;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import com.jakewharton.disklrucache.DiskLruCache;
//import com.wuman.twolevellrucache.TwoLevelLruCache;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.AssetManager;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.util.LruCache;
import android.webkit.WebResourceResponse;

@SuppressLint("NewApi")
public class CacheManager {

	public static String TAG = "CacheManager";
	
	AppDeck appDeck;
	
	private LruCache<String, byte[]> memoryCache;

	String userAgent;
	
	Pattern cdn;
	
	CacheManager()
	{
		appDeck = AppDeck.getInstance();
		
		String regexp = "(.appdeckcdn.com|appdata.static.appdeck.mobi|static.appdeck.mobi|ajax.googleapis.com|cachedcommons.org|cdnjs.cloudflare.com|code.jquery.com|ajax.aspnetcdn.com|ajax.microsoft.com|ads.mobcdn.com|.akamai.net|.akamaiedge.net|.llnwd.net|edgecastcdn.net|.systemcdn.net|hwcdn.net|.panthercdn.com|.simplecdn.net|.instacontent.net|.footprint.net|.ay1.b.yahoo.com|.yimg.|.google.|googlesyndication.|youtube.|.googleusercontent.com|.internapcdn.net|.cloudfront.net|.netdna-cdn.com|.netdna-ssl.com|.netdna.com|.cotcdn.net|.cachefly.net|bo.lt|.cloudflare.com|.afxcdn.net|.lxdns.com|.att-dsa.net|.vo.msecnd.net|.voxcdn.net|.bluehatnetwork.com|.swiftcdn1.com|.cdngc.net|.fastly.net|.nocookie.net|.gslb.taobao.com|.gslb.tbcache.com|.mirror-image.net|.cubecdn.net|.yottaa.net|.r.cdn77.net|.incapdns.net|.bitgravity.com|.r.worldcdn.net|.r.worldssl.net|tbcdn.cn|.taobaocdn.com|.ngenix.net|.pagerain.net|.ccgslb.com|cdn.sfr.net|.azioncdn.net|.azioncdn.com|.azion.net|.cdncloud.net.au|cdn.viglink.com|.ytimg.com|.dmcdn.net|.googleapis.com|.googleusercontent.com|fonts.gstatic.com)";
		
		cdn = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
	}
	
	void init(Context context)
	{

	}
	/*
    private File getDiskCacheDir(Context context, String uniqueName)
    {
    	String cachePath = null;

    	if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()))
    	{
    		if (!Utils.isExternalStorageRemovable())
    		{
    			File dir = Utils.getExternalCacheDir(context);
    			if (dir != null)
    				cachePath = dir.getPath();
    		}
    	}
    	if (cachePath == null)
    	{
    		File dir = context.getCacheDir();
    		if (dir != null)
    			cachePath = dir.getPath();
    	}
    	
	    // Check if media is mounted or storage is built-in, if so, try and use external cache dir
	    // otherwise use internal cache dir
	        //final String cachePath = Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) ||
	        //            !Utils.isExternalStorageRemovable() ?
	        //            Utils.getExternalCacheDir(context).getPath() :
	        //            context.getCacheDir().getPath();
    	//if (cachePath != null)
    	//	return new File(cachePath + File.separator + uniqueName);
    	//return null;
    }*/
	
    // cache Result API
    public class CacheResult
    {
    	public boolean isInCache = false;
    	public long lastModified = 0;
    	
    	public CacheResult(boolean isInCache, long lastModified)
    	{
			this.isInCache = isInCache;
			this.lastModified = lastModified;
		}
        	
    }
        
	public CacheResult isInCache(String absoluteURL)
	{
		InputStream stream = getEmbedResourceStream(absoluteURL);
		if (stream != null)
		{
			try {
				stream.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return new CacheResult(true, System.currentTimeMillis());
		}
		String cache_path =  getCacheEntryPath(absoluteURL);
		File cache_file = new File(cache_path);
		if (cache_file.exists())
		{
			return new CacheResult(true, cache_file.lastModified());
		}
		return new CacheResult(false, 0);
	}

	@SuppressWarnings("deprecation")
	private InputStream getEmbedResourceStream(String absoluteURL)
	{
		AssetManager manager = appDeck.assetManager;
		String asset_path =  absoluteURL.replace("http://", "");
		asset_path =  URLEncoder.encode(asset_path);
		if (asset_path.length() > 48)
		{
			asset_path = asset_path.substring(0, 48) + "_" + Utils.md5(asset_path);
		}
		asset_path = "httpcache/" + asset_path + ".png";
		try {
			InputStream stream = manager.open(asset_path, AssetManager.ACCESS_STREAMING);
			return stream;
		} catch (IOException e) {
			//e.printStackTrace();
			//Crashlytics.log("IOException while loading embed ressource "+absoluteURL+" "+e.getMessage());
		}
		return null;
	}

	private InputStream getEmbedResourceMetaStream(String absoluteURL)
	{
		AssetManager manager = appDeck.assetManager;
		String asset_path =  absoluteURL.replace("http://", "");
		asset_path =  URLEncoder.encode(asset_path);
		if (asset_path.length() > 48)
		{
			asset_path = asset_path.substring(0, 48) + "_" + Utils.md5(asset_path);
		}
		asset_path = "httpcache/" + asset_path + ".meta.png";
		
		 try {
			InputStream stream = manager.open(asset_path);
			return stream;
		} catch (IOException e) {
			e.printStackTrace();
			//Crashlytics.log("IOException while loading embed ressource "+absoluteURL+" "+e.getMessage());
		}
		return null;
	}
			
	void DeleteRecursive(File dir, boolean deleteCurrent)
	{
	    Log.d("DeleteRecursive", "DELETEPREVIOUS TOP" + dir.getPath());
	    if (dir.isDirectory())
	    {
	        String[] children = dir.list();
	        for (int i = 0; i < children.length; i++)
	        {
	            File temp = new File(dir, children[i]);
	            if (temp.isDirectory())
	            {
	                Log.d("DeleteRecursive", "Recursive Call" + temp.getPath());
	                DeleteRecursive(temp, true);
	            }
	            else
	            {
	                Log.d("DeleteRecursive", "Delete File" + temp.getPath());
	                boolean b = temp.delete();
	                if (b == false)
	                {
	                    Log.d("DeleteRecursive", "DELETE FAIL");
	                }
	            }
	        }

	    }
	    if (deleteCurrent)
	    	dir.delete();
	}	

	public void clear()
	{
		String cache_path = getCachePath();
		File dir = new File(cache_path);
		DeleteRecursive(dir, false);
	}

    public void checkBeacon(final Loader loader)
    {
        String embed_beacon = "embed";
        AssetManager manager = appDeck.assetManager;
        try {
            InputStream stream = manager.open("httpcache/beacon");
            embed_beacon = Utils.streamGetContent(stream);
        } catch (Exception e) {
            e.printStackTrace();
        }
        String last_beacon = "last";
        String last_beacon_path = getCachePath() + "beacon";
        try {
            last_beacon = Utils.fileGetContents(last_beacon_path);
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (!embed_beacon.equalsIgnoreCase(last_beacon)) {
            Log.i(TAG, "Check Beacon failed: ["+embed_beacon+"] != ["+last_beacon+"] : we clear cache");
            clear();
			Handler mainHandler = new Handler(loader.getMainLooper());
			Runnable myRunnable = new Runnable() {
				@Override
				public void run() {
					SmartWebViewFactory.clearAllCache(loader);
				}
			};
			mainHandler.post(myRunnable);
        } else {
			Log.v(TAG, "Check Beacon success: ["+embed_beacon+"] != ["+last_beacon+"] : we keep cache");
		}

        Utils.filePutContents(last_beacon_path, embed_beacon);
    }
	
	public String getCachePath()
	{
		return appDeck.cacheDir.toString() + "/httpcache/" /*+ appDeck.config.app_version*/;
	}

	@SuppressWarnings("deprecation")
	public String getCacheEntryPath(String absoluteURL)
	{
		String cache_path =  absoluteURL.replace("http://", "");
		cache_path =  URLEncoder.encode(cache_path);
		if (cache_path.length() > 48)
		{
			cache_path = cache_path.substring(0, 48) + '_' + Utils.md5(cache_path);
		}
		cache_path = getCachePath() + cache_path;
		return cache_path;
	}

	public CacheManagerCachedResponse getCachedResponse(String absoluteURL)
	{
		// step 1: data
		String cache_path = getCacheEntryPath(absoluteURL);
		InputStream streamData = Utils.streamFromFilePath(cache_path);
		 if (streamData == null)
			 return null;
		 
		// step 2: headers
		String cache_path_meta = cache_path+".meta";
		InputStream streamMeta = Utils.streamFromFilePath(cache_path_meta);
		 if (streamMeta == null)
			 return null;
		 
		 CacheManagerCachedResponse cachedResponse = CacheManagerCachedResponse.fromStream(absoluteURL, streamData, streamMeta);
		 return cachedResponse;
	}
	
	public CacheManagerCachedResponse getEmbedResponse(String absoluteURL)
	{
		// step 1: data
		InputStream streamData = getEmbedResourceStream(absoluteURL);
		 if (streamData == null)
			 return null;		 
		// step 2: headers
		InputStream streamMeta = getEmbedResourceMetaStream(absoluteURL);
		 if (streamMeta == null)
			 return null;

		 CacheManagerCachedResponse cachedResponse = CacheManagerCachedResponse.fromStream(absoluteURL, streamData, streamMeta);
		 return cachedResponse;
	}

	public void storeInCache(String absoluteURL, Header[] headers, byte[] content)
	{
		String cache_path = getCacheEntryPath(absoluteURL);
		try {
			Utils.filePutContents(cache_path, content);
			JSONObject jsonObj = new JSONObject();
			for (int k = 0; k < headers.length; k++)
			{
				Header header = headers[k];
				jsonObj.put(header.getName(), header.getValue());
			}
			Utils.filePutContents(cache_path+".meta", jsonObj.toString());
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
/*
	public CacheManagerCachedResponse getResponse(String absoluteURL)
	{
		CacheManagerCachedResponse response = getCachedResponse(absoluteURL);
		if (response == null)
			response = getEmbedResponse(absoluteURL);
		return response;
	}	
	
	// api for webview
	public WebResourceResponse getCachedResource(String absoluteURL)
	{
		CacheManagerCachedResponse cachedResponse = getCachedResponse(absoluteURL);
		if (cachedResponse == null)
			return null;
		WebResourceResponse response = cachedResponse.getWebResourceResponse();
		return response;
	}
	
	public WebResourceResponse getEmbedResource(String absoluteURL)
	{
		CacheManagerCachedResponse cachedResponse = getEmbedResponse(absoluteURL);
		if (cachedResponse == null)
			return null;
		WebResourceResponse response = cachedResponse.getWebResourceResponse();
		return response;
	}*/
	
	public boolean shouldCache(String absoluteURL)
	{
		if (absoluteURL.startsWith("data:"))
			return false;
	
		URL url = null;
		try {
			url = new URL(absoluteURL);
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		String relativeURL = url.getPath().toString();
		
		Pattern cacheRegexp[] = AppDeck.getInstance().config.cache;
		
		if (cacheRegexp == null)
			return false;
		
		for (int i = 0; i < cacheRegexp.length; i++) {
			Pattern p = cacheRegexp[i];
			
			if (p.matcher(absoluteURL).find() || p.matcher(relativeURL).find())
				return true;
			
		}
		
		if (cdn.matcher(url.getHost()).find())
			return true;
		
		return false;
	}
	
}
