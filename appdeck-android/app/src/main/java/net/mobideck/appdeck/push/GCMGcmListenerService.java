package net.mobideck.appdeck.push;

import android.app.NotificationManager;
        import android.app.PendingIntent;
        import android.content.Context;
        import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.RingtoneManager;
        import android.net.Uri;
        import android.os.Bundle;
        import android.support.v4.app.NotificationCompat;
        import android.util.Log;
import android.util.TypedValue;

import com.android.volley.toolbox.ImageRequest;
import com.android.volley.toolbox.RequestFuture;
import com.google.android.gms.gcm.GcmListenerService;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckActivity;
import net.mobideck.appdeck.AppDeckActivity_;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;
import net.mobideck.appdeck.core.RemoteAppCache;
import net.mobideck.appdeck.util.Utils;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class GCMGcmListenerService extends GcmListenerService {

    private static final String TAG = "GCMGcmListenerService";

    /**
     * Called when message is received.
     *
     * @param from SenderID of the sender.
     * @param data Data bundle containing message data as key/value pairs.
     *             For Set of keys use data.keySet().
     */
    // [START receive_message]
    @Override
    public void onMessageReceived(String from, Bundle data) {
        String message = data.getString("message");
        Log.d(TAG, "From: " + from);
        Log.d(TAG, "Message: " + message);

        if (from.startsWith("/topics/")) {
            // message received from some topic.
        } else {
            // normal downstream message.
        }

        // [START_EXCLUDE]
        /**
         * Production applications would usually process the message here.
         * Eg: - Syncing with server.
         *     - Store message in local database.
         *     - Update UI.
         */

        /**
         * In some cases it may be useful to show a notification indicating to the user
         * that a message was received.
         */
        sendNotification(data);
        // [END_EXCLUDE]
    }
    // [END receive_message]

    /**
     * Create and show a simple notification containing the received GCM message.
     *
     * @param data GCM message received.
     */
    private void sendNotification(Bundle data) {

        String title = data.getString("title");
        String url = data.getString("action_url");
        String message = data.getString("title");
        String imageUrl = data.getString("image_url");//"http://www.universfreebox.com/IMG/arton33964.jpg";//data.getString("image");

        Bitmap image = null;

        if (imageUrl != null && !imageUrl.isEmpty()) {
            int width = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 64, getResources().getDisplayMetrics());
            RequestFuture<Bitmap> future = RequestFuture.newFuture();
            ImageRequest request = new ImageRequest(imageUrl, future, width, width, Bitmap.Config.ARGB_8888, future);
            AppDeckApplication.getAppDeck().addToRequestQueue(request);
            try {
                image = future.get(10, TimeUnit.SECONDS);
                if (image != null) {
                    Bitmap cropedImage = Utils.cropToSquare(image);
                    if (cropedImage != null) {
                        image.recycle();
                        image = cropedImage;
                    }
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (ExecutionException e) {
                e.printStackTrace();
            } catch (TimeoutException e) {
                e.printStackTrace();
            }
        }

        if (image == null) {
            image = BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher);
        }

        int requestCode =  (int)System.currentTimeMillis()/1000;

        Intent notificationIntent = new Intent(this, AppDeckActivity_.class);
        notificationIntent.setFlags(/*Intent.FLAG_ACTIVITY_CLEAR_TOP | */Intent.FLAG_ACTIVITY_SINGLE_TOP);

        Bundle bundle = new Bundle();
        bundle.putString(Push.PUSH_URL, url);
        bundle.putString(Push.PUSH_TITLE, title);
        notificationIntent.putExtras(bundle);
        PendingIntent contentIntent = PendingIntent.getActivity(this, requestCode,
                notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.mipmap.ic_push)
                .setLargeIcon(image)
                //.setColor(getResources().getColor(R.color.AppDeckColorApp))
                .setContentTitle(Utils.getApplicationName(this))
                .setContentText(title)
                .setTicker(title)
                .setAutoCancel(true)
                .setSound(defaultSoundUri)
                //.setStyle(new NotificationCompat.BigTextStyle().bigText(title))
                .setContentIntent(contentIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(requestCode /* ID of notification */, notificationBuilder.build());

        try {
            AppDeck appDeck = AppDeckApplication.getAppDeck();
            if (appDeck != null) {
                RemoteAppCache remote = appDeck.fetchRemoteAppCache();
                if (remote != null) {
                    remote.downloadAppCache();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


}
