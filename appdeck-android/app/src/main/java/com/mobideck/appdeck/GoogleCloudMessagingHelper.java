package com.mobideck.appdeck;

import java.io.IOException;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicInteger;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.AsyncTask;
import android.util.Log;

public class GoogleCloudMessagingHelper {

	AppDeck appDeck;
	
	static final String TAG = "GCMHelper";
	
    public static final String EXTRA_MESSAGE = "message";
    public static final String PROPERTY_REG_ID = "registration_id";
    private static final String PROPERTY_APP_VERSION = "appVersion";
    private static final String PROPERTY_SENDER_ID = "senderId";
	//private final static int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;	
	
    String SENDER_ID = "105882851388"; // sender id is configured in app.json, this is default appDeck value usable for test only
	
    GoogleCloudMessaging gcm;
    AtomicInteger msgId = new AtomicInteger();
    SharedPreferences prefs;
    
    
    String regid;

	
	GoogleCloudMessagingHelper(Context context)
	{
		appDeck = AppDeck.getInstance();
		if (appDeck.config.push_google_cloud_messaging_sender_id != null && appDeck.config.push_google_cloud_messaging_sender_id.isEmpty() == false)
			SENDER_ID = appDeck.config.push_google_cloud_messaging_sender_id;
		//this.context = appDeck.getApplicationContext();
		gcmRegister(context);
	}
    
    private void gcmRegister(Context context)
    {
        // Check device for Play Services APK. If check succeeds, proceed with
        //  GCM registration.
        if (checkPlayServices(context)) {
            gcm = GoogleCloudMessaging.getInstance(context);
            regid = getRegistrationId(context);

            if (regid.isEmpty()) {
                registerInBackground(context);
            } else {
            	sendRegistrationIdToBackend();
            }
        } else {
            Log.i(TAG, "No valid Google Play Services APK found.");
        }
    }
	
    
	/**
	 * Check the device to make sure it has the Google Play Services APK. If
	 * it doesn't, display a dialog that allows users to download the APK from
	 * the Google Play Store or enable it in the device's system settings.
	 */
	private boolean checkPlayServices(Context context) {
	    int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(context);
	    if (resultCode != ConnectionResult.SUCCESS) {
	        //if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
	        //    GooglePlayServicesUtil.getErrorDialog(resultCode, appDeck.loader,
	        //            PLAY_SERVICES_RESOLUTION_REQUEST).show();
	        //} else {
	        //    Log.i(TAG, "This device is not supported.");
	        //    //finish();
	        //}
	        return false;
	    }
	    return true;
	}	
	
	/**
	 * Gets the current registration ID for application on GCM service.
	 * <p>
	 * If result is empty, the app needs to register.
	 *
	 * @return registration ID, or empty string if there is no existing
	 *         registration ID.
	 */
	private String getRegistrationId(Context context) {
	    final SharedPreferences prefs = getGCMPreferences(context);
	    String registrationId = prefs.getString(PROPERTY_REG_ID, "");
	    if (registrationId.isEmpty()) {
	        Log.i(TAG, "Registration not found.");
	        return "";
	    }
	    // Check if app was updated; if so, it must clear the registration ID
	    // since the existing regID is not guaranteed to work with the new
	    // app version.
	    int registeredVersion = prefs.getInt(PROPERTY_APP_VERSION, Integer.MIN_VALUE);
	    int currentVersion = getAppVersion(context);
	    if (registeredVersion != currentVersion) {
	        Log.i(TAG, "App version changed.");
	        return "";
	    }
	    // Check if sender id has changed
	    String senderId = prefs.getString(PROPERTY_SENDER_ID, "");
	    if (senderId.equalsIgnoreCase(SENDER_ID) == false) {
	        Log.i(TAG, "SENDER ID changed.");
	        return "";
	    }
	    return registrationId;
	}

	/**
	 * @return Application's {@code SharedPreferences}.
	 */
	private SharedPreferences getGCMPreferences(Context context) {
	    // This sample app persists the registration ID in shared preferences, but
	    // how you store the regID in your app is up to you.
	    return context.getSharedPreferences(AppDeckApplication.class.getSimpleName(),
	            Context.MODE_PRIVATE);
	}	
	
	/**
	 * @return Application's version code from the {@code PackageManager}.
	 */
	private static int getAppVersion(Context context) {
	    try {
	        PackageInfo packageInfo = context.getPackageManager()
	                .getPackageInfo(context.getPackageName(), 0);
	        return packageInfo.versionCode;
	    } catch (NameNotFoundException e) {
	        // should never happen
	        throw new RuntimeException("Could not get package name: " + e);
	    }
	}	
	
	
	/**
	 * Registers the application with GCM servers asynchronously.
	 * <p>
	 * Stores the registration ID and app versionCode in the application's
	 * shared preferences.
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	private void registerInBackground(final Context context) {
	    new AsyncTask() {
	        @Override
	        protected String doInBackground(Object... params) {
	            String msg = "";
	            try {
	                if (gcm == null) {
	                    gcm = GoogleCloudMessaging.getInstance(context);
	                }
	                regid = gcm.register(SENDER_ID);
	                msg = "Device registered, registration ID=" + regid;

	                // You should send the registration ID to your server over HTTP,
	                // so it can use GCM/HTTP or CCS to send messages to your app.
	                // The request to your server should be authenticated if your app
	                // is using accounts.
	                sendRegistrationIdToBackend();

	                // For this demo: we don't need to send it because the device
	                // will send upstream messages to a server that echo back the
	                // message using the 'from' address in the message.

	                // Persist the regID - no need to register again.
	                storeRegistrationId(context, regid);
	            } catch (IOException ex) {
	                msg = "Error :" + ex.getMessage();
	                // If there is an error, don't just keep trying to register.
	                // Require the user to click a button again, or perform
	                // exponential back-off.
	            }
	            return msg;
	        }

	        @Override
	        protected void onPostExecute(Object msg) {
	            //mDisplay.append(msg + "\n");
	        }

	    }.execute(null, null, null);
	}
	    /**
	     * Sends the registration ID to your server over HTTP, so it can use GCM/HTTP
	     * or CCS to send messages to your app. Not needed for this demo since the
	     * device sends upstream messages to a server that echoes back the message
	     * using the 'from' address in the message.
	     */
	    private void sendRegistrationIdToBackend() {

	    	if (appDeck.config.push_register_url == null)
	    		return;
	    	
	    	String url = appDeck.config.push_register_url.toString();
	    	StringBuilder finalUrl = new StringBuilder(url);

    		finalUrl.append(url.contains("?") ? "&" : "?");

    		if (appDeck.isTablet)
	    		finalUrl.append("type=androidtablet");
	    	else
	    		finalUrl.append("type=android");

    		finalUrl.append("&apikey=");
    		finalUrl.append(appDeck.config.app_api_key);
    		
    		finalUrl.append("&deviceuid=");
    		finalUrl.append(appDeck.uid);
    		
    		finalUrl.append("&devicetoken=");
    		finalUrl.append(regid);

    		finalUrl.append("&appid=");
    		finalUrl.append(appDeck.packageName);
    		
    		finalUrl.append("&lang=");
    		finalUrl.append(Locale.getDefault().getLanguage());

    		String register_push_url = finalUrl.toString();
    		Log.i(TAG, register_push_url);
			AsyncHttpClient client = new AsyncHttpClient();
			client.get(register_push_url, new AsyncHttpResponseHandler() {
			    @Override
			    public void onSuccess(String response) {
			        Log.i(TAG, response);
			    }
			});

	    }	

	    /**
	     * Stores the registration ID and app versionCode in the application's
	     * {@code SharedPreferences}.
	     *
	     * @param context application's context.
	     * @param regId registration ID
	     */
	    private void storeRegistrationId(Context context, String regId) {
	        final SharedPreferences prefs = getGCMPreferences(context);
	        int appVersion = getAppVersion(context);
	        Log.i(TAG, "Saving regId on app version " + appVersion);
	        SharedPreferences.Editor editor = prefs.edit();
	        editor.putString(PROPERTY_REG_ID, regId);
	        editor.putInt(PROPERTY_APP_VERSION, appVersion);
	        editor.putString(PROPERTY_SENDER_ID, SENDER_ID);
	        editor.commit();
	    }		
	    
}
