package net.mobideck.appdeck.core;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import android.util.Log;

//import MySevenZip.J7zip;
import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.util.Utils;

import MySevenZip.J7zip;
import okhttp3.Request;
import okhttp3.Response;

public class RemoteAppCache {

	static String TAG = "RemoteAppCache";
	
	private String mUrl;
	private int mTTL;
	private String mOutputPath;

	private Request mRequest;
	private Response mResponse;

	public RemoteAppCache(AppDeck appDeck)
	{
		mUrl = appDeck.appConfig.prefetchUrl;
		mTTL = appDeck.appConfig.prefetchTtl;
		mOutputPath = appDeck.deviceInfo.cacheDir + "/httpcache/";
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
		// create mOutputPath if needed
		File folder = new File(mOutputPath);
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
		final String archivePath = mOutputPath + "archive.7z";
		File archive = new File(archivePath);

		mRequest = new Request.Builder().url(mUrl).build();
		try {
			mResponse = AppDeckApplication.getAppDeck().okHttpClient.newCall(mRequest).execute();

			InputStream in = mResponse.body().byteStream();
			Utils.streamToFile(in, archive);
			mResponse.body().close();

			String[] args = {"x", archivePath, mOutputPath};
			try {
				J7zip.main(args);
			} catch (Exception e) {
				e.printStackTrace();
			}

		} catch (IOException e) {
			e.printStackTrace();
		}
	}
    
}
