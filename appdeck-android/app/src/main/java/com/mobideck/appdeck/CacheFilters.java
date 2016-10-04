package com.mobideck.appdeck;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.DefaultFullHttpResponse;
import io.netty.handler.codec.http.HttpContent;
import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpHeaderValues;
import io.netty.handler.codec.http.HttpHeaders;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpObject;
import io.netty.handler.codec.http.HttpRequest;
import io.netty.handler.codec.http.HttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.handler.codec.http.HttpVersion;
import io.netty.handler.codec.http.LastHttpContent;

import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.littleshoot.proxy.HttpFilters;

import android.util.Log;

public class CacheFilters implements HttpFilters {

	public final String TAG = "CacheFilters";
	
	protected AppDeck appDeck;
	
	protected String absoluteURL;
	
	protected boolean isFirstRequest = false;
	//protected boolean shouldInjectAppDeckJS = false;
	protected boolean forceCache = false;
	protected boolean forceReadFromCache = false;
	//protected boolean isInCache = false;
	//protected boolean shouldStoreInCache = false;
	//protected int shouldStoreInCacheTTL = 0;

    protected boolean disableCache = false;

    protected final HttpRequest originalRequest;
    protected final ChannelHandlerContext ctx;
    
    protected HttpMethod originalMethod;
    
    
    
    protected OutputStream cacheStream = null;
    //protected OutputStream metaStream = null;
    protected boolean skipCacheStream = false;
    

	protected boolean isError = false;

    /**
     * Date format pattern used to parse HTTP date headers in RFC 1123 format.
     */
    //public static final String PATTERN_RFC1123 = "EEE, dd MMM yyyy HH:mm:ss zzz";

    public CacheFilters(HttpRequest originalRequest,
            ChannelHandlerContext ctx) {
        this.originalRequest = originalRequest;
        this.ctx = ctx;
        this.appDeck = AppDeck.getInstance();
    }

    /*public CacheFilters(HttpRequest originalRequest, String answer) {
        super(originalRequest, null);
        //this.answer = answer;
    }*/

    public CacheFilters(HttpRequest originalRequest) {
        this(originalRequest, null);
    }

    private HttpResponse forceCache(HttpResponse response)
    {
    	String eTag = response.headers().get("ETag");
    	if (eTag == null)
    		response.headers().set("ETag", "appdeck-"+ Utils.randInt(0, 2000000));	
		response.headers().set("Cache-Control", "public, max-age=2592000, max-stale=4592000");
		return response;
    }
    
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

            HttpHeaders httpHeaders = response.headers();

    	    @SuppressWarnings("unchecked")
			Iterator<String> keys = headers.keys();
    	    while (keys.hasNext())
    	    {
    	        try {
                    String key = keys.next();
    	        	String val = headers.getString(key);
                    Log.d(TAG, "setHeader: "+key+": "+val);
                    httpHeaders.set(key, val);
    	        } catch(Exception e){
    	        	e.printStackTrace();
    	        }
    	    }

            httpHeaders.set(HttpHeaderNames.CONNECTION, HttpHeaderValues.CLOSE);

			forceCache(response);
    		
    		return response;
			
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
    }
    
    @Override
    public HttpResponse clientToProxyRequest(HttpObject httpObject) {

/*
        if (httpObject instanceof HttpRequest) {

            HttpRequest httpRequest = (HttpRequest) httpObject;

            Log.d(TAG, "clientToProxyRequest > "+httpRequest.getUri());

            List<Map.Entry<String,String>> headers = httpRequest.headers().entries();

            Log.i(TAG, "HEADERS SIZE: "+headers.size());
            for (Map.Entry<String, String> entry : headers)
            {
                Log.i(TAG, entry.getKey() + ": " + entry.getValue());
            }

        }
*/
		try {
    	if (httpObject instanceof HttpRequest)
    	{
    		//DefaultHttpRequest request = (DefaultHttpRequest)httpObject;
            HttpRequest request = (HttpRequest) httpObject;
    		
    		originalMethod = request.method();

    		absoluteURL = request.uri();
    		if (!absoluteURL.startsWith("http://") && !absoluteURL.startsWith("https://"))
    		{
	    		if (absoluteURL.endsWith(":443"))
	    			absoluteURL = "https://" + absoluteURL.substring(0, absoluteURL.length() - 4);
	    		else
	    			absoluteURL = "http://" + absoluteURL;
    		}

            if (absoluteURL.contains("dailymotion.com") && absoluteURL.contains("#"))
            {
                Log.w(TAG, "Dailymotion FIX: URL ["+absoluteURL+"] should not have a # in it, we remove it.");
                absoluteURL = absoluteURL.substring(0, absoluteURL.indexOf("#"));
                request.setUri(absoluteURL);
            }

    		// sub request always have Referer header
    		isFirstRequest = request.headers().get("Referer") == null;
    		
    		// change user agent
    		String ua = request.headers().get("User-Agent");
            if (ua != null)
        		forceReadFromCache = ua.contains("FORCE_CACHE");
            else
            	Log.e(TAG, "request without User-Agent: "+absoluteURL);

            //request.headers().set("User-Agent", appDeck.userAgent);

    		forceCache = appDeck.cache.shouldCache(absoluteURL);

			if (!originalMethod.toString().equalsIgnoreCase("GET"))
			{
                disableCache = true;
			}

			boolean isCacheMiss = false;

    		// request should be cached ?
            if (!disableCache && (forceCache || forceReadFromCache))
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
						DebugLog.info("CACHE HIT", absoluteURL);
    		    		return response;
           			}
        		}
				isCacheMiss = true;
    		}

    		// embed file ?
    		CacheManagerCachedResponse embedResponse = appDeck.cache.getEmbedResponse(absoluteURL);
    		if (!disableCache && embedResponse != null)
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
					DebugLog.info("EMBED", absoluteURL);
		    		return response;
       			}
    		}

			if (appDeck == null || appDeck.config == null) {
				Log.e(TAG, "appdeck config not ready");
			} else {
				// set app id and user id
				if (appDeck.config.app_api_key != null)
					request.headers().set("AppDeck-App-Key", appDeck.config.app_api_key);
				else
					Log.e(TAG, "app api key is null");
				if (appDeck.uid != null)
					request.headers().set("AppDeck-User-ID", appDeck.uid);
				else
					Log.e(TAG, "app uid is null");
			}

			if (isCacheMiss) {
				Log.i(TAG, " CACHE MISS " + absoluteURL);
				DebugLog.info("CACHE MISS", absoluteURL);
			} else {
				Log.i(TAG, " DOWNLOAD " + absoluteURL);
				DebugLog.warning("DOWNLOAD", absoluteURL);
			}

    	}
		} catch (Exception e) {
			e.printStackTrace();
		}

        return null;
    }

    @Override
    public HttpResponse proxyToServerRequest(HttpObject httpObject) {

        /*
        Log.i(TAG, "proxyToServerRequest < " + absoluteURL);

		if (httpObject instanceof HttpRequest) {
			HttpRequest httpRequest = (HttpRequest) httpObject;

			List<Map.Entry<String,String>> headers = httpRequest.headers().entries();

			Log.i(TAG, "HEADERS SIZE: "+headers.size());
			for (Map.Entry<String, String> entry : headers)
			{
				Log.i(TAG, entry.getKey() + ": " + entry.getValue());
			}

		}*/

		return null;
    }
    
    @Override
    public HttpObject serverToProxyResponse(HttpObject httpObject) {

    	try {
    	// create output stream that will store cache
		if (!skipCacheStream && cacheStream == null && httpObject instanceof HttpResponse)
		{
			HttpResponse response = (HttpResponse)httpObject;
			HttpResponseStatus status = response.status();
			
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
                //Log.i(TAG, "< serverToProxyResponse CACHE_STORE " + absoluteURL);
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
		if (!forceCache && httpObject instanceof HttpResponse)
		{
			Log.i(TAG, "< CACHE MISS SEND: " + absoluteURL);
			DebugLog.info("CACHE MISS", absoluteURL);
			HttpResponse response = (HttpResponse)httpObject;
			return forceCache(response);
		}			
		
    	// write a chunk		
    	if (httpObject instanceof HttpContent)
    	{
			//Log.i(TAG, "< serverToProxyResponse CHUNK " + absoluteURL);
			HttpContent content = (HttpContent)httpObject;

    		if (cacheStream != null)
			{
				try {
                    ByteBuf bb = content.content();
                    byte[] data = bb.array();
                    //Log.i(TAG, "< serverToProxyResponse CHUNK " + bb.readableBytes() + " bytes");

                    cacheStream.write(data, bb.arrayOffset(), bb.readableBytes());
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
    	}
    	
    	// close output stream if needed
    	if (httpObject instanceof LastHttpContent)
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
	public void serverToProxyResponseTimedOut() {
		isError = true;
	}

	@Override
    public HttpObject proxyToClientResponse(HttpObject httpObject) {

		if (isError)
		{
			return null;
		}

		if (httpObject instanceof HttpResponse)
		{
			HttpResponse response = (HttpResponse)httpObject;
			HttpResponseStatus status = response.status();
			
			int code = status.code();
			String reason = status.reasonPhrase();
//			List<Map.Entry<String,String>> headers = response.headers().entries();
			
			Log.i(TAG, "POST CODE: "+code+" REASON: "+reason);
		}
        return httpObject;
    }

    @Override
    public void proxyToServerRequestSending() {

    }

    @Override
    public void proxyToServerRequestSent() {

    }

    @Override
    public void serverToProxyResponseReceiving() {

    }

    @Override
    public void serverToProxyResponseReceived() {

    }

    @Override
    public void proxyToServerConnectionQueued() {

    }

    @Override
    public InetSocketAddress proxyToServerResolutionStarted(String resolvingServerHostAndPort) {
        return null;
    }

	@Override
	public void proxyToServerResolutionFailed(String hostAndPort) {
		isError = true;
	}

	@Override
    public void proxyToServerResolutionSucceeded(String serverHostAndPort, InetSocketAddress resolvedRemoteAddress) {

    }

    @Override
    public void proxyToServerConnectionStarted() {

    }

    @Override
    public void proxyToServerConnectionSSLHandshakeStarted() {

    }

    @Override
    public void proxyToServerConnectionFailed() {
		isError = true;
    }

	@Override
	public void proxyToServerConnectionSucceeded(ChannelHandlerContext serverCtx) {

	}
/*
	@Override
    public void proxyToServerConnectionSucceeded() {

    }*/
}
