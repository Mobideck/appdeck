package com.mobideck.appdeck;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLConnection;
import java.util.List;
import java.util.Map;

import android.annotation.SuppressLint;
import android.webkit.WebResourceResponse;

@SuppressLint("NewApi")
public class CacheManagerEntry {

	private URI uri;
	private Map<String, List<String>> requestHeaders;
	private byte[] data;
	
	public CacheManagerEntry(URI uri, Map<String, List<String>> requestHeaders, byte[] data)
	{
		this.uri = uri;
		this.requestHeaders = requestHeaders;
		this.data = data;
	}
	
	public static CacheManagerEntry createCacheManagerEntry(String absoluteURL)
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
			URI uri = url.toURI();
			Map<String, List<String>> requestHeaders = ucon.getHeaderFields();
			byte[] data = baos.toByteArray();
			
			return new CacheManagerEntry(uri, requestHeaders, data);
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}	
	
	int getSize()
	{
		return data.length;
	}

	public URI getUri() {
		return uri;
	}

	public Map<String, List<String>> getRequestHeaders() {
		return requestHeaders;
	}

	public byte[] getData() {
		return data;
	}
	
	
	public WebResourceResponse getWebResourceResponse()
	{
	    ByteArrayInputStream bais = new ByteArrayInputStream(data);
        /*String mimeType = (String) requestHeaders.get("Content-Type");
        if (mimeType == null)
        	mimeType = "application/octet- stream";
        String encoding = (String) metadata.get("Content-Encoding");
        if (encoding == null)
        	encoding = "identity";
	    */
        WebResourceResponse response = new WebResourceResponse(null, null, bais);
        return response;
	}	
	
}