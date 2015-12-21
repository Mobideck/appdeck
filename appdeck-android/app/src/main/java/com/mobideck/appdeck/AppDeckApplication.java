package com.mobideck.appdeck;

//import com.testflightapp.lib.TestFlight;

import android.app.Application;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.reflect.Field;

import android.annotation.SuppressLint;
import android.app.Application;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Build;
import android.support.multidex.MultiDex;

import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterCore;

import dalvik.system.DexClassLoader;
import io.fabric.sdk.android.Fabric;

public class AppDeckApplication extends android.support.multidex.MultiDexApplication {
	
	public boolean isInitialLoading;

    @Override
    public void attachBaseContext(Context base) {
        MultiDex.install(base);
        super.attachBaseContext(base);
    }

	@Override
	public void onCreate()
	{
		//android.os.Debug.startMethodTracing("start");
/*	     if (true) {
	         StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder()
	                 .detectDiskReads()
	                 .detectDiskWrites()
	                 .detectNetwork()   // or .detectAll() for all detectable problems
	                 .penaltyLog()
	                 .build());
	         StrictMode.setVmPolicy(new StrictMode.VmPolicy.Builder()
	                 .detectLeakedSqlLiteObjects()
	                 .detectLeakedClosableObjects()
	                 .penaltyLog()
	                 .penaltyDeath()
	                 .build());
	     }*/		
		super.onCreate();
	}		

}
