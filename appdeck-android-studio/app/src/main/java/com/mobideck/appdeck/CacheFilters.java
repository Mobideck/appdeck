package com.mobideck.appdeck;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.zip.GZIPOutputStream;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.DefaultHttpContent;
import io.netty.handler.codec.http.DefaultHttpRequest;
import io.netty.handler.codec.http.DefaultHttpResponse;
import io.netty.handler.codec.http.DefaultFullHttpResponse;
import io.netty.handler.codec.http.DefaultLastHttpContent;
import io.netty.handler.codec.http.HttpContent;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpObject;
import io.netty.handler.codec.http.HttpRequest;
import io.netty.handler.codec.http.HttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.handler.codec.http.HttpVersion;

import org.apache.commons.io.IOUtils;
//import org.apache.commons.io.IOUtils;
import org.apache.http.impl.cookie.DateParseException;
import org.apache.http.impl.cookie.DateUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.littleshoot.proxy.HttpFilters;

import android.util.Log;
import android.webkit.WebResourceResponse;

public class CacheFilters implements HttpFilters {

	public final String TAG = "CacheFilters";
	
	protected AppDeck appDeck;
	
	protected String absoluteURL;
	
	protected boolean isFirstRequest = false;
	protected boolean shouldInjectAppDeckJS = false;
	protected boolean forceCache = false;
	protected boolean forceReadFromCache = false;
	protected boolean isInCache = false;
	protected boolean shouldStoreInCache = false;
	protected int shouldStoreInCacheTTL = 0;
	
    protected final HttpRequest originalRequest;
    protected final ChannelHandlerContext ctx;
    
    protected HttpMethod originalMethod;
    
    
    
    protected OutputStream cacheStream = null;
    protected OutputStream metaStream = null;
    protected boolean skipCacheStream = false;
    
    
    /**
     * Date format pattern used to parse HTTP date headers in RFC 1123 format.
     */
    public static final String PATTERN_RFC1123 = "EEE, dd MMM yyyy HH:mm:ss zzz";    

    public CacheFilters(HttpRequest originalRequest,
            ChannelHandlerContext ctx) {
        this.originalRequest = originalRequest;
        this.ctx = ctx;
        this.appDeck = AppDeck.getInstance();
    }

    public CacheFilters(HttpRequest originalRequest) {
        this(originalRequest, null);
    }
/*
    private HttpResponse setCache(HttpResponse response, String cacheName, int maxage)
    {
    	Date now = new Date();
        Calendar cal = Calendar.getInstance();
        cal.setTime(now);
        cal.add(Calendar.SECOND, maxage);
        Date expire = cal.getTime();    	
        
		response.headers().set("Pragma", "public");
		response.headers().set("Cache-Control", "public, max-age="+maxage);
		
		response.headers().set("Date", DateUtils.formatDate(now));
		response.headers().set("Last-modified", DateUtils.formatDate(now));
		response.headers().set("ETag", "\""+ cacheName + "-appdeck-"+ Utils.randInt(0, 2000000) + "\"");
		response.headers().set("Expires", DateUtils.formatDate(expire));
		
    	return response;
    }
    */
    
    private HttpResponse forceCache(HttpResponse response)
    {
//		response.headers().set("Pragma", "public");
    	String eTag = response.headers().get("ETag");
    	if (eTag == null)
    		response.headers().set("ETag", "appdeck-"+ Utils.randInt(0, 2000000));	
		response.headers().set("Cache-Control", "public, max-age=2592000, max-stale=4592000");
		/*
		response.headers().set("Date", DateUtils.formatDate(now));
		response.headers().set("Last-modified", DateUtils.formatDate(now));
		response.headers().set("ETag", "\""+ cacheName + "-appdeck-"+ Utils.randInt(0, 2000000) + "\"");
		response.headers().set("Expires", DateUtils.formatDate(expire));    	
    	*/
		return response;
    }
    /*
    private HttpResponse storeInCache(HttpResponse response, int maxage)
    {
    	return setCache(response, "store", maxage);
    }    
    
    private HttpResponse backupInCache(HttpResponse response)
    {
    	return setCache(response, "backup", Integer.MAX_VALUE);    	
    }    */ 
    
    private HttpResponse createCachedHTTPResponse(CacheManagerCachedResponse cachedResponse)
    {
    	InputStream stream = cachedResponse.getStream();
    	JSONObject headers = cachedResponse.getHeaders();
    	
		try {
			byte[] data = IOUtils.toByteArray(stream);
			ByteBuf buf = Unpooled.wrappedBuffer(data);
			
    		DefaultFullHttpResponse response = new DefaultFullHttpResponse(
                    HttpVersion.HTTP_1_1,
                    HttpResponseStatus.OK,
                    buf);
    		
    		//List<Map.Entry<String,String>> headers
    		
    	    @SuppressWarnings("unchecked")
			Iterator<String> keys = headers.keys();
    	    while (keys.hasNext())
    	    {
    	        String key = keys.next();
    	        String val = null;
    	        try {
    	        	val = headers.getString(key);
    	        	response.headers().set(key, val);
    	        } catch(Exception e){
    	        	e.printStackTrace();
    	        }
    	    }
    		
/*    		if (contentType == null)
    			contentType = "application/octet-stream";
    		response.headers().set("Content-Type", contentType);

    		response.headers().set("Content-Length", data.length);
				    			
			response.headers().set("Vary", "Accept-Encoding");
			response.headers().set("Server", "AppDeck-Embed-Files/1.0");
			response.headers().set("X-Cache", "HIT");
			response.headers().set("Accept-Ranges", "bytes");*/
							
			forceCache(response);
			
			//response.headers().set("Via", "1.1.10.0.2.15");
    		
    		return response;
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
    }
    
    @Override
    public HttpResponse requestPre(HttpObject httpObject) {
		try {
    	if (httpObject instanceof DefaultHttpRequest)
    	{
    		DefaultHttpRequest request = (DefaultHttpRequest)httpObject;
    		
    		originalMethod = request.getMethod();
    		
    		absoluteURL = request.getUri();
    		if (absoluteURL.startsWith("http://") == false && absoluteURL.startsWith("https://") == false)
    		{
	    		if (absoluteURL.endsWith(":443"))
	    			absoluteURL = "https://" + absoluteURL;
	    		else
	    			absoluteURL = "http://" + absoluteURL;
    		}
    		
    		// sub request always have Referer header
    		isFirstRequest = request.headers().get("Referer") == null;
    		
    		// change user agent
    		String ua = request.headers().get("User-Agent");
    		forceReadFromCache = ua.indexOf("FORCE_CACHE") != -1;
    		/*if (ua != null)
    		{
    			ua = ua + " AppDeck"+(appDeck.isTablet? "-tablet" : "-phone" )+" "+appDeck.packageName+"/"+appDeck.config.app_version;
    			request.headers().set("User-Agent", ua);
    		}*/
    		
    		forceCache = appDeck.cache.shouldCache(absoluteURL);
    		
    		// request should be cached ?
    		if (forceCache || forceReadFromCache)
    		{
    			
        		// Already in browser cache ?
        		String etag = request.headers().get("If-None-Match");
        		if (etag != null)
        		{
        			//Log.i(TAG, "CACHE HIT - SEND NOT MODIFIED: "+absoluteURL);
    	    		DefaultFullHttpResponse response = new DefaultFullHttpResponse(
    	                    HttpVersion.HTTP_1_1,
    	                    HttpResponseStatus.NOT_MODIFIED);
    	    		response.headers().set("Cache-Control", "max-age=2592000, max-stale=4592000");
    	    		return response;
        		}
        		// Already in app cache
        		CacheManagerCachedResponse cachedResponse = appDeck.cache.getCachedResponse(absoluteURL);
        		if (cachedResponse != null)
        		{
           			HttpResponse response = createCachedHTTPResponse(cachedResponse);
           			if (response != null)
           			{	    			
    	    			Log.i(TAG, "CACHE HIT: "+absoluteURL);//+" Size:"+(data.length/1024)+"Kb");
    		    		return response;
           			}
        		}        		
    			Log.i(TAG, " CACHE MISS " + absoluteURL + " (ETAG:"+etag+")");
    		}
    		    		
    		// embed file ?
    		CacheManagerCachedResponse embedResponse = appDeck.cache.getEmbedResponse(absoluteURL);
    		if (embedResponse != null)
    		{
        		// already in browser cache ?
        		String etag = request.headers().get("If-None-Match");
        		if (etag != null)
        		{
        			//Log.i(TAG, "EMBED HIT - SEND NOT MODIFIED: "+absoluteURL);
    	    		DefaultFullHttpResponse response = new DefaultFullHttpResponse(
    	                    HttpVersion.HTTP_1_1,
    	                    HttpResponseStatus.NOT_MODIFIED);
    	    		response.headers().set("Cache-Control", "max-age=2592000, max-stale=4592000");
    	    		return response;
        		}
    			// create a embed cached response
        		HttpResponse response = createCachedHTTPResponse(embedResponse);       			
       			if (response != null)
       			{	    			
	    			Log.i(TAG, "EMBED: "+absoluteURL);//+" Size:"+(data.length/1024)+"Kb");
		    		return response;
       			}
    		}

   			Log.i(TAG, " DOWNLOAD " + absoluteURL);

    	}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        return null;
    }

    @Override
    public HttpResponse requestPost(HttpObject httpObject) {
    	//Log.i(TAG, "requestPost < " + absoluteURL);

        return null;
    }
    
    @Override
    public HttpObject responsePre(HttpObject httpObject) {
    	try {
    	// create output stream that will store cache
		if (skipCacheStream == false && cacheStream == null && httpObject instanceof HttpResponse)
		{
			HttpResponse response = (HttpResponse)httpObject;
			HttpResponseStatus status = response.getStatus();
			
			int code = status.code();
			String reason = status.reasonPhrase();
			List<Map.Entry<String,String>> headers = response.headers().entries();
			
			Log.i(TAG, "PRE CODE: "+code+" REASON: "+reason);
			/*Log.i(TAG, "HEADERS SIZE: "+headers.size());
			for (Map.Entry<String, String> entry : headers)
			{
				Log.i(TAG, entry.getKey() + ": " + entry.getValue());
			}*/

			if (code == 200)
			{			
				String path = appDeck.cache.getCacheEntryPath(absoluteURL);
				try {
					cacheStream = new FileOutputStream(new File(path));
				} catch (Exception e) {
					e.printStackTrace();
				}
				
				// write headers into meta
				try {
					JSONObject jsonObj = new JSONObject();
					for (Map.Entry<String, String> entry : headers)
					{
						jsonObj.put(entry.getKey(), entry.getValue());
					}
					Utils.filePutContents(path+".meta", jsonObj.toString());
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
			else
				skipCacheStream = true;
		}
		
    	// make sure cachable content get right cache headers
		if (forceCache == true && httpObject instanceof HttpResponse)
		{
			Log.i(TAG, "< CACHE MISS SEND: " + absoluteURL);
			HttpResponse response = (HttpResponse)httpObject;
			return forceCache(response);
		}			
		
    	// write a chunk		
    	if (httpObject instanceof HttpContent)
    	{
			//Log.i(TAG, "< HttpResponse CHUNK " + absoluteURL);
			HttpContent content = (HttpContent)httpObject;
    		if (cacheStream != null)
			{
				try {
					byte[] data = content.content().array();
					//Log.i(TAG, "< HttpResponse CHUNK " + data.length);
					cacheStream.write(data);
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
    	}
    	
    	// close output stream if needed
    	if (httpObject instanceof DefaultLastHttpContent)
		{
    		//Log.i(TAG, "< HttpResponse LAST CHUNK " + absoluteURL);
    		if (cacheStream != null)
    		{
    			try {
					cacheStream.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
    			cacheStream = null;
    		}
		}    	
		} catch (Exception e) {
			e.printStackTrace();
		}
    	return httpObject;
    }

    @Override
    public HttpObject responsePost(HttpObject httpObject) {
    	
		if (httpObject instanceof HttpResponse)
		{
			HttpResponse response = (HttpResponse)httpObject;
			HttpResponseStatus status = response.getStatus();
			
			int code = status.code();
			String reason = status.reasonPhrase();
//			List<Map.Entry<String,String>> headers = response.headers().entries();
			
			Log.i(TAG, "POST CODE: "+code+" REASON: "+reason);
		}
        return httpObject;
    }
	
}
