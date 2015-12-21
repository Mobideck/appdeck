package com.mobideck.appdeck;

import java.io.File;
import java.io.IOException;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.BinaryHttpResponseHandler;
import com.loopj.android.http.FileAsyncHttpResponseHandler;
import com.loopj.android.http.SyncHttpClient;

import android.util.Log;

import MySevenZip.J7zip;
import cz.msebera.android.httpclient.Header;

public class RemoteAppCache {

	static String TAG = "RemoteAppCache";
	
	String url;
	int ttl;
	String outputPath;
	byte[] _data;
	
	RemoteAppCache(String url, int ttl)
	{
		this.url = url;
		this.ttl = ttl;
		outputPath = AppDeck.getInstance().cacheDir + "/httpcache/";
	}

	public void downloadAppCache() {
		new Thread(new Runnable() {
			@Override
			public void run() {
				downloadAppCacheThreaded();
			}
		}, "remoteAppCache").start();
	}


	private void downloadAppCacheThreaded()
	{
		SyncHttpClient client = new SyncHttpClient();

		// create outputPath if needed
		File folder = new File(outputPath);
		boolean success = true;
		if(!folder.exists()){
			success = folder.mkdirs();
			if (!success){
				Log.d(TAG,"Folder not created.");
			}
			else{
				Log.d(TAG,"Folder created!");
			}
		}
		final String archivePath = outputPath + "archive.7z";
		File archive = new File(archivePath);
		client.get(url, new FileAsyncHttpResponseHandler(archive, false) {

			@Override
			public void onFailure(int statusCode, Header[] headers, Throwable throwable, File file) {
				Log.d(TAG, "failed to download remoteCache");
			}

			@Override
			public void onSuccess(int statusCode, Header[] headers, File file) {
				String[] args = {"x", archivePath, outputPath};
				try {
					J7zip.main(args);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
/*
		client.get(url, new BinaryHttpResponseHandler(new String[] { ".*"}) {

		     @Override
			 public void onSuccess(int statusCode, Header[] headers, byte[] data) {
		         // Successfully got a response
		    	 Log.d(TAG,"URL Downloaded: " + url);
		    	 _data = data;
		    	 new Thread(new Runnable() {
		    	        public void run() {
		   		    	 try {

                             // create outputPath if needed
                             File folder = new File(outputPath);
                             boolean success = true;
                             if(!folder.exists()){
                                 success = folder.mkdirs();
                                 if (!success){
                                     Log.d(TAG,"Folder not created.");
                                 }
                                 else{
                                     Log.d(TAG,"Folder created!");
                                 }
                             }


                             String input = outputPath + "archive.7z";
                             Utils.filePutContents(input, _data);

                            String[] args = {"x", input, outputPath};

                             J7zip.main(args);

		 					//RemoteAppCacheRandomAccessMemory istream = new RemoteAppCacheRandomAccessMemory(_data);
		 					//extractAppCache(istream, outputPath);
		 				} catch (IOException e) {
		 					// TODO Auto-generated catch block
		 					e.printStackTrace();
		 				} catch (Exception e) {
                             e.printStackTrace();
                         }
                        }
		    	    }).start();
		     }


			@Override
			public void onFailure(int statusCode, Header[] headers, byte[] errorResponse, Throwable e) {
				// called when response HTTP status is "4XX" (eg. 401, 403, 404)
				Log.d(TAG, "Failed to download: " + url);
			}
		     
		 });	*/
	}
    
}
