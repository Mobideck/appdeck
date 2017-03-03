package net.mobideck.appdeck.push;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckActivity;
import net.mobideck.appdeck.AppDeckApplication;

public class Push {

    public static String TAG = "Push";

    /* push */
    public final static String PUSH_URL = "com.mobideck.appdeck.PUSH_URL";
    public final static String PUSH_TITLE = "com.mobideck.appdeck.PUSH_TITLE";
    public final static String PUSH_IMAGE_URL = "com.mobideck.appdeck.PUSH_IMAGE_URL";

    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;

    public BroadcastReceiver registrationBroadcastReceiver;
    public boolean isReceiverRegistered;

    public Push () {

        if (checkPlayServices() == false)
            return;

        Intent intent = new Intent(AppDeckApplication.getContext(), GCMRegistrationIntentService.class);
        AppDeckApplication.getContext().startService(intent);

        registrationBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
                boolean sentToken = sharedPreferences.getBoolean(GCMRegistrationIntentService.SENT_TOKEN_TO_SERVER, false);
                if (sentToken) {
                    Log.d(TAG, "GCM token sent");
                } else {
                    Log.e(TAG, "GCM token not sent");
                }
            }
        };
        // Registering BroadcastReceiver
        registerReceiver();
    }

    public void registerReceiver() {

        if (registrationBroadcastReceiver == null)
            return;

        if(!isReceiverRegistered) {
            LocalBroadcastManager.getInstance(AppDeckApplication.getContext()).registerReceiver(registrationBroadcastReceiver, new IntentFilter(GCMRegistrationIntentService.REGISTRATION_COMPLETE));
            isReceiverRegistered = true;
        }
    }

    public void unregisterReceiver() {

        if (registrationBroadcastReceiver == null)
            return;

        try {
            LocalBroadcastManager.getInstance(AppDeckApplication.getContext()).unregisterReceiver(registrationBroadcastReceiver);
            isReceiverRegistered = false;
        } catch (Exception e) {

        }
    }

    private boolean checkPlayServices() {
        GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = apiAvailability.isGooglePlayServicesAvailable(AppDeckApplication.getContext());
        if (resultCode != ConnectionResult.SUCCESS) {
            if (apiAvailability.isUserResolvableError(resultCode)) {
                apiAvailability.getErrorDialog(AppDeckApplication.getActivity(), resultCode, PLAY_SERVICES_RESOLUTION_REQUEST)
                        .show();
            } else {
                Log.i(TAG, "This device is not supported.");
            }
            return false;
        }
        return true;
    }

    public boolean shouldHandleIntent(Intent intent) {
        if (intent == null)
            return false;
        Bundle extras = intent.getExtras();
        if (extras == null)
            return false;
        String url = extras.getString(PUSH_URL);
        if (url == null)
            return false;
        String title = extras.getString(PUSH_TITLE);
        //String imageUrl = extras.getString(PUSH_IMAGE_URL);
        Log.i(TAG, "Open Push: "+title+" url: "+url);
        url = AppDeckApplication.getAppDeck().appConfig.resolveURL(url);
        AppDeckApplication.getAppDeck().navigation.loadURL(url);
        return true;
    }

}
