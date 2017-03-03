package net.mobideck.appdeck;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;

import java.io.InputStream;

public class AppDeckApplication extends Application {

    public static String TAG = "AppDeckApplication";

    @Override
    public void onCreate() {
        super.onCreate();
        sAppDeckApplicationInstance = this;
        registerActivityLifecycleCallbacks(new MyActivityLifecycleCallbacks());
    }

    private static AppDeckApplication sAppDeckApplicationInstance;

    public static Context getContext() {
        return sAppDeckApplicationInstance;
    }

    private static AppDeckActivity sAppDeckActivity;

    public static AppDeckActivity getActivity() {
        if (sAppDeckActivity == null)
            Log.e(TAG, "Activity is null");
        return sAppDeckActivity;
    }

    public static void setActivity(AppDeckActivity appDeckActivity) {
        sAppDeckActivity = appDeckActivity;
    }

    private static AppDeck sAppDeck;

    public static AppDeck getAppDeck() {
        return sAppDeck;
    }

    public static void setAppDeck(AppDeck appDeck) {
        sAppDeck = appDeck;
    }

    private static final class MyActivityLifecycleCallbacks implements ActivityLifecycleCallbacks {

        public void onActivityCreated(Activity activity, Bundle bundle) {
            if (activity.getLocalClassName().equalsIgnoreCase("AppDeckActivity"))
                sAppDeckActivity = (AppDeckActivity)activity;
        }

        public void onActivityDestroyed(Activity activity) {
            if (sAppDeckActivity == activity)
                sAppDeckActivity = null;
        }

        public void onActivityPaused(Activity activity) {

        }

        public void onActivityResumed(Activity activity) {

        }

        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }

        public void onActivityStarted(Activity activity) {
            if (activity.getLocalClassName().equalsIgnoreCase("AppDeckActivity"))
                sAppDeckActivity = (AppDeckActivity)activity;
        }

        public void onActivityStopped(Activity activity) {
            //Log.d(TAG,"onActivityStopped:" + activity.getLocalClassName());
            //appDeckActivity = null;
        }
    }

}
