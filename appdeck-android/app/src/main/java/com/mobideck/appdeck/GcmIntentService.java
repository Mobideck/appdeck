package com.mobideck.appdeck;

import com.mobideck.appdeck.R;
/*import com.google.android.gms.gcm.GoogleCloudMessaging;*/

import android.app.IntentService;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

public class GcmIntentService extends IntentService {

	static final String TAG = "GCMIntentService";
	
    public static final int NOTIFICATION_ID = 1;
    private NotificationManager mNotificationManager;
    NotificationCompat.Builder builder;

    public GcmIntentService() {
        super("GoogleCloudMessagingIntentService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Bundle extras = intent.getExtras();
        /*
        GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
        // The getMessageType() intent parameter must be the intent you received
        // in your BroadcastReceiver.
        String messageType = gcm.getMessageType(intent);

        if (!extras.isEmpty()) {  // has effect of unparcelling Bundle
            //
            // Filter messages based on message type. Since it is likely that GCM
            // will be extended in the future with new message types, just ignore
            // any message types you're not interested in, or that you don't
            // recognize.
            // 
            if (GoogleCloudMessaging.
                    MESSAGE_TYPE_SEND_ERROR.equals(messageType)) {
                //sendNotification("Send error: " + extras.toString());
            } else if (GoogleCloudMessaging.
                    MESSAGE_TYPE_DELETED.equals(messageType)) {
                //sendNotification("Deleted messages on server: " + extras.toString());
            // If it's a regular GCM message, do some work.
            } else if (GoogleCloudMessaging.
                    MESSAGE_TYPE_MESSAGE.equals(messageType)) {
                // Post notification of received message.
            	Log.i(TAG, "Received: " + extras.toString());
            	sendNotification(extras.getString("title"), extras.getString("action_url"));                
            }
        }
        // Release the wake lock provided by the WakefulBroadcastReceiver.
        GcmBroadcastReceiver.completeWakefulIntent(intent);*/
    }

    // Put the message into a notification and post it.
    // This is just one simple example of what you might choose to do with
    // a GCM message.
    private void sendNotification(String title, String url) {
    	
    	mNotificationManager = (NotificationManager)
                this.getSystemService(Context.NOTIFICATION_SERVICE);

    	Intent notificationIntent = new Intent(this, Loader.class);
    	notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
    	notificationIntent.putExtra(Loader.PUSH_URL, url);
    	notificationIntent.putExtra(Loader.PUSH_TITLE, title);
    	PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
        		notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        //contentIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        
        //PendingIntent pendingNotificationIntent = PendingIntent.getActivity(getApplicationContext(),notificationIndex,notificationIntent,PendingIntent.FLAG_UPDATE_CURRENT);
        
        NotificationCompat.Builder mBuilder =
                new NotificationCompat.Builder(this)
        .setAutoCancel(true)
        .setSmallIcon(R.drawable.ic_launcher)
        .setContentTitle(Utils.getApplicationName(this))
        .setStyle(new NotificationCompat.BigTextStyle()
        .bigText(title))
        .setContentText(title);

        mBuilder.setContentIntent(contentIntent);
        mNotificationManager.notify(NOTIFICATION_ID, mBuilder.build());
    }

}
