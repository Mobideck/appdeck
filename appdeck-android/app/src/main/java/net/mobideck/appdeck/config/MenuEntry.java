
package net.mobideck.appdeck.config;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.util.Log;
import android.view.MenuItem;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import net.mobideck.appdeck.AppDeckApplication;

public class MenuEntry {

    public static String TAG = "Config.MenuEntry";

    @SerializedName("url")
    @Expose
    public String url;

    @SerializedName("content")
    @Expose
    public String content;

    @SerializedName("title")
    @Expose
    public String title;

    @SerializedName("subtitle")
    @Expose
    public String subtitle;

    @SerializedName("image")
    @Expose
    public String image;

    @SerializedName("type")
    @Expose
    public String type;

    @SerializedName("icon")
    @Expose
    public String icon;

    @SerializedName("width")
    @Expose
    public int width;

    @SerializedName("height")
    @Expose
    public String height;

    @SerializedName("color")
    @Expose
    public String color;

    @SerializedName("background_color")
    @Expose
    public String backgroundColor;

    @SerializedName("foreground_color")
    @Expose
    public String foregroundColor;

    @SerializedName("badge")
    @Expose
    public int badge;

    @SerializedName("selected")
    @Expose
    public boolean selected;

    @SerializedName("disabled")
    @Expose
    public boolean disabled;
    /*
    public void configureMenuItem(final MenuItem menuItem, int iconSize) {
        AppDeckApplication.getAppDeck().addToRequestQueue(new ImageRequest(icon, new Response.Listener<Bitmap>() {
            @Override
            public void onResponse(Bitmap bitmap) {
                //mImageView.setImageBitmap(bitmap);
                menuItem.setIcon(new BitmapDrawable(bitmap));
            }
        }, iconSize, iconSize, null, new Response.ErrorListener() {
            public void onErrorResponse(VolleyError error) {
                Log.e(TAG, "Error while fetching MenuItem Image: "+icon+": "+error.getLocalizedMessage());
            }
        }));
    }*/

    public String getAbsoluteURL() {
        return AppDeckApplication.getAppDeck().appConfig.resolveURL(url);
    }
}
