package com.mobideck.appdeck;

import android.app.Application;
import android.content.Context;
import android.support.multidex.MultiDex;

public class AppDeckApplication extends Application {

	private static AppDeck appDeck = null;
    private static Context context = null;

    public boolean isInitialLoading = false;

	@Override
    public void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(base);
    }

	@Override
	public void onCreate()
	{
        super.onCreate();
        AppDeckApplication.context = getApplicationContext();
	}

    public static AppDeck getAppDeck() { return appDeck; }
	public static Context getAppContext() { return context; }

	public void setupAppDeck(AppDeck appdeck) { appDeck = appdeck; }
}
