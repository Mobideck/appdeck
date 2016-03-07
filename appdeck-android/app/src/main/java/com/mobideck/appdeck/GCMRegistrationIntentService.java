package com.mobideck.appdeck;

import android.app.IntentService;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.google.android.gms.gcm.GcmPubSub;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.google.android.gms.iid.InstanceID;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.SyncHttpClient;

import java.io.IOException;
import java.util.Locale;

import cz.msebera.android.httpclient.Header;

public class GCMRegistrationIntentService extends IntentService {

    public static String SENDER_ID = "630861581625";

    private static final String TAG = "RegIntentService";
    private static final String[] TOPICS = {"global"};


    public static final String SENT_TOKEN_TO_SERVER = "sentTokenToServer";
    public static final String REGISTRATION_COMPLETE = "registrationComplete";

    public GCMRegistrationIntentService() {
        super(TAG);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this);

        try {
            // [START register_for_gcm]
            // Initially this call goes out to the network to retrieve the token, subsequent calls
            // are local.
            // R.string.gcm_defaultSenderId (the Sender ID) is typically derived from google-services.json.
            // See https://developers.google.com/cloud-messaging/android/start for details on this file.
            // [START get_token]
            InstanceID instanceID = InstanceID.getInstance(this);
            String token = instanceID.getToken(SENDER_ID,
                    GoogleCloudMessaging.INSTANCE_ID_SCOPE, null);
            // [END get_token]
            Log.i(TAG, "GCM Registration Token: " + token);

            sendRegistrationToServer(token);

            // Subscribe to topic channels
            subscribeTopics(token);

            // You should store a boolean that indicates whether the generated token has been
            // sent to your server. If the boolean is false, send the token to your server,
            // otherwise your server should have already received the token.
            sharedPreferences.edit().putBoolean(GCMRegistrationIntentService.SENT_TOKEN_TO_SERVER, true).apply();
            // [END register_for_gcm]
        } catch (Exception e) {
            Log.d(TAG, "Failed to complete token refresh", e);
            // If an exception happens while fetching the new token or updating our registration data
            // on a third-party server, this ensures that we'll attempt the update at a later time.
            sharedPreferences.edit().putBoolean(GCMRegistrationIntentService.SENT_TOKEN_TO_SERVER, false).apply();
        }
        // Notify UI that registration has completed, so the progress indicator can be hidden.
        Intent registrationComplete = new Intent(GCMRegistrationIntentService.REGISTRATION_COMPLETE);
        LocalBroadcastManager.getInstance(this).sendBroadcast(registrationComplete);
    }

    /**
     * Persist registration to third-party servers.
     *
     * Modify this method to associate the user's GCM registration token with any server-side account
     * maintained by your application.
     *
     * @param token The new token.
     */
    private void sendRegistrationToServer(String token) {

        AppDeck appDeck = AppDeck.getInstance();

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

        finalUrl.append("&senderid=");
        finalUrl.append(SENDER_ID);

        finalUrl.append("&deviceuid=");
        finalUrl.append(appDeck.uid);

        finalUrl.append("&devicetoken=");
        finalUrl.append(token);

        finalUrl.append("&appid=");
        finalUrl.append(appDeck.packageName);

        finalUrl.append("&lang=");
        finalUrl.append(Locale.getDefault().getLanguage());

        final String register_push_url = finalUrl.toString();
        //AsyncHttpClient client = new AsyncHttpClient();

        new Thread(new Runnable() {
            @Override
            public void run() {
                Log.i(TAG, register_push_url);

                SyncHttpClient client = new SyncHttpClient();
                client.get(register_push_url, new AsyncHttpResponseHandler() {
                    @Override
                    public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                        try {
                            String response = responseBody == null?null:new String(responseBody, this.getCharset());
                            Log.i(TAG, response);
                        } catch (Exception e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, byte[] errorResponse, Throwable e) {
                        // called when response HTTP status is "4XX" (eg. 401, 403, 404)
                        Log.e(TAG, "Error: " + statusCode);
                    }
                });

            }
        }, "appdeckPushRegistration").start();

    }

    /**
     * Subscribe to any GCM topics of interest, as defined by the TOPICS constant.
     *
     * @param token GCM token
     * @throws IOException if unable to reach the GCM PubSub service
     */
    // [START subscribe_topics]
    private void subscribeTopics(String token) throws IOException {
        GcmPubSub pubSub = GcmPubSub.getInstance(this);
        for (String topic : TOPICS) {
            pubSub.subscribe(token, "/topics/" + topic, null);
        }
    }
    // [END subscribe_topics]

}