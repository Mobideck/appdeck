package com.mobideck.appdeck;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.ByteBuffer;
import java.util.Locale;

import android.webkit.CookieManager;

public class InjectJSInputStream extends InputStream {

	String absoluteURL;
	URL	url;
	URLConnection ucon;
	String js;
	InputStream inputStream;
	BufferedInputStream bufferedInputStream;
	
	Boolean patched;
	
	byte[] htmlbuffer;
	
	public InjectJSInputStream(String absoluteURL, String jsURL)
	{
		patched = false;
		this.absoluteURL = absoluteURL;
		this.js = "<script type='text/javascript' src='"+jsURL+"'></script>";
		try {
			CookieManager cookieManager = CookieManager.getInstance();
			
			String auth = cookieManager.getCookie(absoluteURL);			
			
			url = new URL(absoluteURL);
			ucon = url.openConnection();
			if (auth != null)
				ucon.setRequestProperty("Cookie", auth);
			inputStream = ucon.getInputStream();
			//bufferedInputStream = new BufferedInputStream(inputStream);
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
		
/*	@Override
	public int available() throws IOException {
		return inputStream.available();
	}*/
	
	@Override
	public void close() throws IOException {
		//bufferedInputStream.close();
		if (inputStream != null)
			inputStream.close();
	}
	
/*	@Override
	public void mark(int readlimit) {
		inputStream.mark(readlimit);
	}
	
	@Override
	public boolean markSupported() {
		return inputStream.markSupported();
	}
*/	
	
	@Override
	public int read(byte[] buffer) throws IOException {
		
		if (patched)
			return inputStream.read(buffer);
		
		byte[] htmlbytes  = new byte[buffer.length - js.length()];
		int read = inputStream.read(htmlbytes);
		String html = new String(htmlbytes);
		String htmlLower = html.toLowerCase(Locale.US);
		int index = htmlLower.indexOf("head");
		if (index > 0)
		{
			index = htmlLower.indexOf(">", index);
			if (index > 0)
			{
				ByteBuffer buf = ByteBuffer.allocate(buffer.length);
				buf.put(htmlbytes, 0, index + 1);
				buf.put(js.getBytes(), 0, js.length());
				buf.put(htmlbytes, index + 1, read - index - 1);
				System.arraycopy(buf.array(), 0, buffer, 0, read + js.length());
				patched = true;
				return read + js.length();
			}
		}
		System.arraycopy(htmlbytes, 0, buffer, 0, read);
		return read;
	}
	
	@Override
	public int read() throws IOException {
		return inputStream.read();
	}
	
/*	@Override
	public int read(byte[] buffer, int offset, int length) throws IOException {
		return inputStream.read(buffer, offset, length);
	}
	
	
	@Override
	public synchronized void reset () throws IOException
	{
		inputStream.reset();
	}
	
	@Override
	public long skip (long byteCount) throws IOException
	{
		return inputStream.skip(byteCount);
	}*/
}
