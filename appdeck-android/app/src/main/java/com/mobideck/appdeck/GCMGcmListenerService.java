package com.mobideck.appdeck;

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

import com.google.android.gms.gcm.GcmListenerService;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.SyncHttpClient;
import com.mortennobel.imagescaling.ResampleOp;

import cz.msebera.android.httpclient.Header;

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

        final Bitmap[] largeIcon = {null};

        if (imageUrl != null && !imageUrl.isEmpty()) {
            AsyncHttpClient httpClient = new SyncHttpClient();
            httpClient.get(this, imageUrl, new AsyncHttpResponseHandler() {
                @Override
                public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                    Bitmap image = BitmapFactory.decodeByteArray(responseBody, 0, responseBody.length);
                    if (image != null) {
                        Bitmap cropedImage = Utils.cropToSquare(image);
                        if (cropedImage != null) {
                            image.recycle();
                            int width = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 64, getResources().getDisplayMetrics());
                            ResampleOp resampleOp = new ResampleOp(width, width);
                            //resampleOp.setNumberOfThreads(1);
                            Bitmap myscaledBitmap = Bitmap.createBitmap(width, width, Bitmap.Config.ARGB_8888);
                            myscaledBitmap = resampleOp.filter(cropedImage, myscaledBitmap);
                            cropedImage.recycle();
                            if (myscaledBitmap != null) {
                                largeIcon[0] = myscaledBitmap;
                            }
                        }
                    }
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {

                }
            });
        }
        if (largeIcon[0] == null) {
            largeIcon[0] = BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher);
        }


        Intent notificationIntent = new Intent(this, Loader.class);
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        notificationIntent.putExtra(Loader.PUSH_URL, url);
        notificationIntent.putExtra(Loader.PUSH_TITLE, title);
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
                notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);


        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.mipmap.ic_push)
                .setLargeIcon(largeIcon[0])
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

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());

        try {
            AppDeck appDeck = AppDeck.getInstance();
            if (appDeck != null) {
                RemoteAppCache remote = AppDeck.getInstance().remote;
                if (remote != null) {
                    remote.downloadAppCache();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


}
