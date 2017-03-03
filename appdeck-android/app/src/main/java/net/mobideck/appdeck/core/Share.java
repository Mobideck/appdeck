package net.mobideck.appdeck.core;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Environment;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.util.Utils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.util.List;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Request;

public class Share {

    public static String TAG = "Share";

    private String mTitle;
    private String mURL;
    private String mImageURL;

    private Intent mSharingIntent;

    public void shareContent(String title, String url, String imageURL) {
        mTitle = title;
        mURL = url;
        mImageURL = imageURL;

        // no permission needed
        if (mImageURL == null || mImageURL.isEmpty()) {
            doShareWithPermission();
            return;
        }

        int permissionCheck = ContextCompat.checkSelfPermission(AppDeckApplication.getActivity(), Manifest.permission.WRITE_EXTERNAL_STORAGE);

        if (permissionCheck == PackageManager.PERMISSION_GRANTED) {
            doShareWithPermission();
        } else {
            ActivityCompat.requestPermissions(AppDeckApplication.getActivity(),
                    new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                    AppDeck.PERMISSION_SHARE);
        }
    }

    public void doShareWithPermission()
    {
        if (mTitle == null && mURL == null && mImageURL == null)
            return;

        String identifier = (mURL != null ? mURL : mImageURL);
        if (identifier != null)
            identifier = mTitle;

        // add stats
        AppDeckApplication.getAppDeck().stats.event("action", "share", (mURL != null && !mURL.isEmpty() ? mURL : mTitle), 1);

        // create share intent
        mSharingIntent = new Intent(android.content.Intent.ACTION_SEND);

        // trim title if needed
        if (mTitle != null)
            mTitle = mTitle.trim();

        mSharingIntent.setType("text/plain");
        if (mTitle != null && !mTitle.isEmpty())
            mSharingIntent.putExtra(Intent.EXTRA_SUBJECT, mTitle);
        if (mURL != null && !mURL.isEmpty())
            mSharingIntent.putExtra(Intent.EXTRA_TEXT, mURL);

        // not an image ?
        if (mImageURL == null || mImageURL.isEmpty())
        {
            AppDeckApplication.getActivity().startActivity(Intent.createChooser(mSharingIntent, "Share via"));
            mTitle = mURL = mImageURL = null;
            mSharingIntent = null;
            return;
        }

        // patch image URL
        //String absoluteImageUrl = mImageURL;
        if (mImageURL.startsWith("//"))
            mImageURL = "http:"+mImageURL;

        // image ?
        AppDeckApplication.getActivity().showLoading();

        new Thread(new Runnable() {
            @Override
            public void run() {
                Request request = new Request.Builder()
                        .url(mImageURL)
                        .build();

                AppDeckApplication.getAppDeck().okHttpClient.newCall(request).enqueue(new Callback() {
                    @Override
                    public void onFailure(Call call, final IOException e) {
                        e.printStackTrace();
                        AppDeckApplication.getActivity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                AppDeckApplication.getActivity().hideLoading();
                                AppDeckApplication.getActivity().showErrorMessage(e.getLocalizedMessage());
                                mTitle = mURL = mImageURL = null;
                                mSharingIntent = null;
                            }
                        });
                    }

                    @Override
                    public void onResponse(Call call, final okhttp3.Response response) throws IOException {

                        if (!response.isSuccessful()) {
                            Log.e(TAG, "Error: " + response.code());
                            AppDeckApplication.getActivity().runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    AppDeckApplication.getActivity().hideLoading();
                                    AppDeckApplication.getActivity().showErrorMessage(response.message());
                                    mTitle = mURL = mImageURL = null;
                                    mSharingIntent = null;
                                }
                            });
                        } else {
                            List<String> path = response.request().url().pathSegments();
                            String fileName = path.get(path.size() - 1);
                            if (fileName.isEmpty())
                                fileName = "image.jpg";
                            File f = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS) + File.separator + AppDeckApplication.getAppDeck().appConfig.apiKey + File.separator + fileName);
                            try {
                                f.getParentFile().mkdirs();
                                f.createNewFile();
                                Utils.streamToFile(response.body().byteStream(), f);
                            } catch (IOException e) {
                                e.printStackTrace();
                            }

                            final Uri fileImageUri = Uri.fromFile(f);

                            AppDeckApplication.getActivity().runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    AppDeckApplication.getActivity().hideLoading();
                                    mSharingIntent.putExtra(Intent.EXTRA_STREAM, fileImageUri);
                                    mSharingIntent.setType("image/*");
                                    AppDeckApplication.getActivity().startActivity(Intent.createChooser(mSharingIntent, "Share via"));
                                    mTitle = mURL = mImageURL = null;
                                    mSharingIntent = null;
                                }
                            });

                        }
                    }
                });
            }
        }, "shareImage").start();

/*
        // TODO: use OkHTTP directly
        AppDeckApplication.getAppDeck().addToRequestQueue(new ImageRequest(absoluteImageUrl, new Response.Listener<Bitmap>() {
            @Override
            public void onResponse(Bitmap bitmap) {

                ByteArrayOutputStream bytes = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG, 80, bytes);
                File f = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS) + File.separator + "share_image_" + AppDeckApplication.getAppDeck().appConfig.apiKey + ".jpg");
                try {
                    f.getParentFile().mkdirs();
                    f.createNewFile();
                    FileOutputStream fo = new FileOutputStream(f);
                    fo.write(bytes.toByteArray());
                    fo.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                mSharingIntent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(f));
                mSharingIntent.setType("image/*");
                AppDeckApplication.getActivity().startActivity(Intent.createChooser(sharingIntent, "Share via"));
                mTitle = mURL = mImageURL = null;
                mSharingIntent = null;
            }
        }, 0, 0, null, new Response.ErrorListener() {
            public void onErrorResponse(VolleyError error) {
                Log.e(TAG, "Error while fetching Share Image: "+mImageURL+": "+error.getLocalizedMessage());
            }
        }));*/

    }




}
