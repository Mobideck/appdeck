package com.mobideck.appdeck;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

/**
 * Created by mathieudekermadec on 17/04/15.
 */
public class AppDeckBroadcastReceiver extends BroadcastReceiver {

    public static String TAG = "AppDeckBroadcastReceiver";

    public Loader loaderActivity;

    public AppDeckBroadcastReceiver(Loader loaderActivity) {
        this.loaderActivity = loaderActivity;
    }

    public void clean()
    {
        loaderActivity = null;
    }

    @Override
    public void onReceive(Context context, Intent intent) {

        Bundle extras = intent.getExtras();
        String title = extras.getString("title");
        String url = extras.getString("action_url");
        String image_url = extras.getString("image_url");

        // not a push ?
        if (title == null || url == null || title.equalsIgnoreCase("")|| url.equalsIgnoreCase(""))
            return;

        abortBroadcast();
        if (loaderActivity == null)
        {
            Log.e(TAG, "receive Intent but null loaderActivity");
        }
        Log.i(TAG, "Push: "+title);
        loaderActivity.handlePushNotification(title, url, image_url);

    }

}
