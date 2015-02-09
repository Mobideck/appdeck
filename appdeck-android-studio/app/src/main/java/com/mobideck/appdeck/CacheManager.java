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

import org.apache.http.Header;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import com.jakewharton.disklrucache.DiskLruCache;
//import com.wuman.twolevellrucache.TwoLevelLruCache;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.AssetManager;
import android.os.Environment;
import android.util.Log;
import android.util.LruCache;
import android.webkit.WebResourceResponse;

@SuppressLint("NewApi")
public class CacheManager {

	public static String TAG = "CacheManager";
	
	AppDeck appDeck;
	
	private LruCache<String, byte[]> memoryCache;
	//SimpleDiskCache diskCache;
	
	//@SuppressWarnings("unused")
	//private DiskLruCache diskCache;

	//private TwoLevelLruCache<CacheManagerEntry> cache;
	//private CacheEntryConverter<CacheManagerEntry> converter;
	
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
		/*
		final File diskCacheDir = getDiskCacheDir(context, "webDiskCacheManager");		
		
		userAgent = Utils.getDefaultUserAgentString(context);
		
		userAgent = userAgent + " AppDeck "+appDeck.packageName+"/"+appDeck.config.app_version;
		
		   try {
	           File httpCacheDir = new File(context.getCacheDir(), "http");
	           long httpCacheSize = 100 * 1024 * 1024; // 10 MiB
	           Class.forName("android.net.http.HttpResponseCache")
	                   .getMethod("install", File.class, long.class)
	                   .invoke(null, httpCacheDir, httpCacheSize);
		   }
	       catch (Exception httpResponseCacheNotAvailable) {
	    	   try {
				com.integralblue.httpresponsecache.HttpResponseCache.install(diskCacheDir, 1024 * 1024 * 100);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	       }		
		
		try {
			
			//com.integralblue.httpresponsecache.HttpResponseCache.install(diskCacheDir, 1024 * 1024 * 100);
			converter = new CacheEntryConverter<CacheManagerEntry>();
			cache = new TwoLevelLruCache<CacheManagerEntry>(diskCacheDir, appDeck.config.app_version, 1024 * 1024 * 10, 1024 * 1024 * 100, converter);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	*/	
	}
	
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
    	
    	/*
	    // Check if media is mounted or storage is built-in, if so, try and use external cache dir
	    // otherwise use internal cache dir
	        final String cachePath =
	            Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) ||
	                    !Utils.isExternalStorageRemovable() ?
	                    Utils.getExternalCacheDir(context).getPath() :
	                    context.getCacheDir().getPath();
    	 */
    	if (cachePath != null)
    		return new File(cachePath + File.separator + uniqueName);
    	return null;
    }	
	
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

	/*
	public class AppDeckCacheResponse extends CacheResponse
	{
		InputStream stream;
		
		AppDeckCacheResponse(InputStream stream)
		{
			this.stream = stream;
		}

		@Override
		public InputStream getBody() throws IOException {
			return stream;
		}

		@Override
		public Map<String, List<String>> getHeaders() throws IOException {
			return new HashMap<String, List<String>>();
		}
	}*/
	/*
	public String getCachedData(String absoluteURL)
	{
		InputStream stream = getEmbedResourceStream(absoluteURL);
		if (stream != null)
			return Utils.readStream(stream);
		String cache_path = getCacheEntryPath(absoluteURL);
		 try {
			 File cache_file = new File(cache_path);
			 if (cache_file.exists())
			 {
				 stream = new FileInputStream(cache_file);
				 return Utils.readStream(stream);
			 }
		 } catch (IOException e) {
				e.printStackTrace();
			}
		 return null;
	}*/
	
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
			InputStream stream = manager.open(asset_path);
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
	/*
	public CacheResponse getEmbedResourceCacheResponse(String absoluteURL)
	{
		InputStream stream = getEmbedResourceStream(absoluteURL);
		if (stream != null)
		{
			AppDeckCacheResponse response = new AppDeckCacheResponse(stream);
			return response;
		}
		return null;
	}	*/
	
	public String getCachePath()
	{
		return appDeck.cacheDir.toString() + "/httpcache/" /*+ appDeck.config.app_version*/;
	}
	
	/*
	public void storeInCache(String absoluteURL, URLConnection ucon)
	{
		String cache_path = getCacheEntryPath(absoluteURL);
		 try {
			 File cache_file = new File(cache_path);
			 OutputStream cacheStream = new FileOutputStream(cache_file);
			 Utils.copyStream(ucon.getInputStream(), cacheStream);
		 } catch (IOException e) {
			 e.printStackTrace();
		 }		
	}
	*/

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
	public void writeMetaData(String cache_path, String absoluteURL, String mime_type, String encoding)
	{
		String cache_path_metadata = cache_path + ".metadata";
		try {
			FileOutputStream out = new FileOutputStream(cache_path_metadata);
	        ObjectOutputStream oout = new ObjectOutputStream(out);
	        oout.writeObject(absoluteURL);
	        oout.writeObject(mime_type);
	        oout.writeObject(encoding);
	        oout.close();
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}*/
	/*
	public class CacheMetaData
	{
		public String absoluteURL;
		public String mime_type;
		public String encoding;
		
		CacheMetaData()
		{
			
		}
		
		CacheMetaData(String absoluteURL, String mime_type, String encoding)
		{
			this.absoluteURL = absoluteURL;
			this.mime_type = mime_type;
			this.encoding = encoding;
		}
	}*/
	/*
	public CacheMetaData readMetaData(String cache_path)
	{
		String cache_path_metadata = cache_path + ".metadata";
		try {
			FileInputStream is = new FileInputStream(cache_path_metadata);
			ObjectInputStream ois = new ObjectInputStream(is);
			CacheMetaData cacheMetaData = new CacheMetaData();
			cacheMetaData.absoluteURL = (String) ois.readObject();
			cacheMetaData.mime_type = (String) ois.readObject();
			cacheMetaData.encoding = (String) ois.readObject();
			ois.close();
			return cacheMetaData;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return new CacheMetaData();
	}*/	
	
	/*
	public WebResourceResponse createCacheableResponse(String absoluteURL, String cache_path, String cookie) throws IOException
	{
		Log.i(TAG, "Download : "+absoluteURL);
		// cache does not exist in cache, we create a tee
		URL url = new URL(absoluteURL);
		URLConnection ucon = url.openConnection();
		ucon.setRequestProperty("User-Agent", userAgent);
		ucon.setRequestProperty("Accept-Encoding", "gzip");	
		// set cookie
		if (cookie != null)
			ucon.setRequestProperty("Cookie", cookie.toString());
		try
		{
			// get mime type and text encoding
			final String content_type = ucon.getContentType();
			final String separator = "; charset=";
			final int pos = content_type.indexOf(separator);    // TODO: Better protocol compatibility
			final String mime_type = pos >= 0 ? content_type.substring(0, pos) : content_type;
			final String encoding = pos >= 0 ? content_type.substring(pos + separator.length()) : "UTF-8";
			
			// handle gzip response
			final String content_encoding = ucon.getContentEncoding();
			InputStream inputStream = ucon.getInputStream();
			if (content_encoding != null && content_encoding.equalsIgnoreCase("gzip"))
				inputStream = new GZIPInputStream(inputStream);

			// write meta data
			writeMetaData(cache_path, absoluteURL, mime_type, content_encoding);
			
			BufferedInputStream bufferedInputStream = new BufferedInputStream(inputStream); 
			File cache_file = new File(cache_path);
			OutputStream cacheStream = new FileOutputStream(cache_file);
			BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(cacheStream);
			return null;
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		 return null;
	}*/
	
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
	
	/*
	public InputStream getCachedResourceStream(String absoluteURL)
	{
		String cache_path = getCacheEntryPath(absoluteURL);
		 try {
			 File cache_file = new File(cache_path);
			 // file exist in cache, we use it
			 if (cache_file.exists())
			 {
				 return new FileInputStream(cache_file);
			 }
		 } catch (IOException e) {
			 e.printStackTrace();
		 }
		 return null;
	}*/
	
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
	}
	
	/*
	public WebResourceResponse getCachedResource(String absoluteURL, String cookie)
	{
		String cache_path = getCacheEntryPath(absoluteURL);
		 try {
			 File cache_file = new File(cache_path);
			 // file exist in cache, we use it
			 if (cache_file.exists())
			 {
				 InputStream stream = new FileInputStream(cache_file);
				 CacheMetaData cacheMetaData = readMetaData(cache_path);			 
				 WebResourceResponse response = new WebResourceResponse(cacheMetaData.mime_type, cacheMetaData.encoding, new BufferedInputStream(stream));
				 return response;
			 }
			 // cache does not exist in cache, we create a tee
			 return createCacheableResponse(absoluteURL, cache_path, cookie);
		 } catch (IOException e) {
			 e.printStackTrace();
		 }
		 return null;
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
	
	/*
	public byte[] download(String absoluteURL)
	{
		try {
			URL url = new URL(absoluteURL);
			URLConnection ucon = url.openConnection();
			InputStream inputStream = ucon.getInputStream();
		     ByteArrayOutputStream baos = new ByteArrayOutputStream();  
		     byte[] content = new byte[ 2048 ];  
		     int bytesRead = -1;  
		     while( ( bytesRead = inputStream.read( content ) ) != -1 ) {  
		         baos.write( content, 0, bytesRead );  
		     }  
		     return baos.toByteArray();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
		return null;
	}	*/
	/*
	public WebResourceResponse responseFromData(byte[] data)
	{
	    ByteArrayInputStream bais = new ByteArrayInputStream(data);
        WebResourceResponse response = new WebResourceResponse(null, null, bais);
        return response;
	}*/
	/*
	public Boolean store(String absoluteURL, URLConnection urlConnection)
	{
		try {		
			InputStream inputStream = urlConnection.getInputStream();
			ByteArrayOutputStream baos = new ByteArrayOutputStream();  
			byte[] content = new byte[ 2048 ];  
			int bytesRead = -1;  
			while( ( bytesRead = inputStream.read( content ) ) != -1 ) {  
				baos.write( content, 0, bytesRead );  
			}
			byte[] data = baos.toByteArray();
			memoryCache.put(absoluteURL, data);
			return true;
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
		return false;
	}*/
	/*
	public byte[]load(String absoluteURL)
	{
		return memoryCache.get(absoluteURL);
	}*/
	/*
	public WebResourceResponse getFromCache(String absoluteURL)
	{
		byte[] data = null;
		
		CacheManagerEntry entry = null;
		
		String key = md5(absoluteURL);
		
		entry = cache.get(key);
		if (entry != null)
			return entry.getWebResourceResponse();
		
		entry = CacheManagerEntry.createCacheManagerEntry(absoluteURL);
		
		if (entry != null)
		{
			cache.put(key, entry);
			return entry.getWebResourceResponse();
		}
		
		// memory ?
		data = memoryCache.get(absoluteURL);
		if (data != null)
			return responseFromData(data);
		
		// resource ?
		//TODO: read from resource
		
		// disk ?

		
		// download
		data = download(absoluteURL);
		
		if (data != null)
		{
			memoryCache.put(absoluteURL, data);
			return responseFromData(data);
		}
			
		
		return null;
		
		
//		return null;
	}*/
/*
	// disk cache
	@SuppressWarnings("unused")
	private byte[] getFromDisk(String url)
	{

		return null;
	}*/
	
	
	/*private String toInternalKey(String key) {
		return md5(key);
	}*/
/*
	private String md5(String input)
	{
		try {
			String result = input;
		    if(input != null) {
		        MessageDigest md;
		        md = MessageDigest.getInstance("MD5");
		        md.update(input.getBytes());
		        BigInteger hash = new BigInteger(1, md.digest());
		        result = hash.toString(16);
		        while(result.length() < 32) { //40 for SHA-1
		            result = "0" + result;
		        }
		    }
		    return result;
		} catch (NoSuchAlgorithmException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} //or "SHA-1"
		return null;	    
	}	*/
	
	/*
	private String md5(String s) {
		try {
			MessageDigest m = MessageDigest.getInstance("MD5");
			m.update(s.getBytes("UTF-8"));
			byte[] digest = m.digest();
			BigInteger bigInt = new BigInteger(1, digest);
			return bigInt.toString(16);
		} catch (NoSuchAlgorithmException e) {
			throw new AssertionError();
		} catch (UnsupportedEncodingException e) {
			throw new AssertionError();
		}
	}*/
	
	/*
	public class CacheEntryConverter<T>  implements TwoLevelLruCache.Converter<T> {

		public CacheEntryConverter()
		{

		}
				
	    @Override
	    public T from(byte[] bytes) {
			try {
				ObjectInputStream ois = new ObjectInputStream(new ByteArrayInputStream(bytes));
		    	URI uri = (URI)ois.readObject();
		    	@SuppressWarnings("unchecked")
				Map<String, List<String>> requestHeaders = (Map<String, List<String>>)ois.readObject();
		    	//int length = ois.readInt();
		    	int length = ois.readInt();
		    	byte[] data = new byte[length]; 
		    	ois.readFully(data);
		    	ois.close();
		    	@SuppressWarnings("unchecked")
				T t = (T) new CacheManagerEntry(uri, requestHeaders, data);
				return t;
			} catch (StreamCorruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return null;
	    }*/
/*
	    @Override
	    public void toStream(T obj, OutputStream bytes) throws IOException {
	    	CacheManagerEntry entry = (CacheManagerEntry)obj;
	    	ObjectOutputStream oos = new ObjectOutputStream(bytes);
	    	oos.writeObject(entry.getUri());
	    	HashMap<String, ArrayList<String>> requestHeaders = new HashMap<String, ArrayList<String>>(); 
	    	
    		for (@SuppressWarnings("rawtypes") Map.Entry e : entry.getRequestHeaders().entrySet()) {
    			String key = (String) e.getKey();
    			@SuppressWarnings("unchecked")
				List<String> value = (List<String>) e.getValue();
    			
    			requestHeaders.put(key, new ArrayList<String>(value));
    		}
	    	
	    	oos.writeObject(requestHeaders);
	    	byte[] data = entry.getData();
	    	int length = data.length;
	    	oos.writeInt(length);
	    	oos.write(data);
	    	oos.close();
	    }*/
	    
	    /* new version, use metadata */
	    
	    
	    
	    

	
}
