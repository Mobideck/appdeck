package com.mobideck.appdeck;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.zip.GZIPInputStream;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.webkit.WebResourceResponse;

public class CacheManagerCachedResponse {
	
	private String absoluteURL;
	private InputStream stream;
	private JSONObject headers;
	
	CacheManagerCachedResponse(String absoluteURL, InputStream stream, JSONObject headers)
	{
		this.absoluteURL = absoluteURL;
		this.stream = stream;
		this.headers = headers;
	}

	InputStream getStream()
	{
		return stream;
	}
	
	JSONObject getHeaders()
	{
		return headers;
	}	
	
	// read a cached response from cache data stream and meta data stream
	public static CacheManagerCachedResponse fromStream(String absoluteURL, InputStream streamData, InputStream streamHeaders)
	{
		String json = Utils.streamGetContent(streamHeaders);
		JSONObject node = null;
		if (json != null)
		{
			try {
				node = (JSONObject) new JSONTokener(json).nextValue();
				streamHeaders.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return new CacheManagerCachedResponse(absoluteURL, streamData, node);		
	}
	
	public WebResourceResponse getWebResourceResponse()
	{
		String encoding = headers.optString("Content-Encoding", null);
		String mime = headers.optString("Content-Type", null);
		InputStream dataStream = stream; 
		
		if (encoding != null && encoding.equalsIgnoreCase("gzip"))
			try {
				dataStream = new GZIPInputStream(dataStream);
				encoding = null;
			} catch (IOException e) {
				e.printStackTrace();
			}
		
		if (mime != null && mime.indexOf(";") != -1)
		{
			mime = mime.substring(0, mime.indexOf(";"));
		}
		
		WebResourceResponse response = new WebResourceResponse(mime, null, new BufferedInputStream(dataStream));

		return response;
	}
	
    public void finalize()
    {
         try {
        	 if (stream != null)
        		 stream.close();
        	 stream = null;
		} catch (Exception e) {

		}
    }
	
}
