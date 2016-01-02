package com.mobideck.appdeck;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URL;

import android.content.Context;
import android.net.Uri;

import com.nostra13.universalimageloader.core.download.BaseImageDownloader;

public class AppDeckBaseImageDownloader extends BaseImageDownloader {

	public AppDeckBaseImageDownloader(Context context) {
		super(context);
	}
	public AppDeckBaseImageDownloader(Context context, int connectTimeout, int readTimeout) {
		super(context, connectTimeout, readTimeout);
	}

	@Override
	public InputStream getStream(String imageUri, Object extra) throws IOException {
		// try from resources first
/*		CacheManagerCachedResponse cachedResponse = AppDeck.getInstance().cache.getEmbedResponse(imageUri);
		if (cachedResponse != null)
			return cachedResponse.getStream();*/
		return super.getStream(imageUri, extra);
	}

	@Override
	protected HttpURLConnection createConnection(String url, Object extra) throws IOException {
		String encodedUrl = Uri.encode(url, ALLOWED_URI_CHARS);
		Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(AppDeck.getInstance().proxyHost, AppDeck.getInstance().proxyPort));
		HttpURLConnection conn = (HttpURLConnection) new URL(encodedUrl).openConnection(proxy);
		conn.setConnectTimeout(connectTimeout);
		conn.setReadTimeout(readTimeout);
		return conn;
	}
}
