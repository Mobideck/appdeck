package net.mobideck.appdeck.core;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.support.v4.view.animation.FastOutLinearInInterpolator;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckActivity;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;

public class AppDeckBottomMenuItem {

    public static String TAG = "BottomMenuItem";

    public static int transitionTime = 250;

    private String mTitle;
    private String mIcon;
    //private String type;
    private String mUrl;

    private MenuItem mMenuItem;

    private boolean mIsValid = false;

    private ImageRequest mImageRequest;

    public AppDeckBottomMenuItem(MenuItem menuItem, AppDeckActivity appDeckActivity) {
        mMenuItem = menuItem;

        /*menuItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem menuItem) {
                fire();
                return true;
            }
        });*/
    }

    public void configure(String title, String icon, String url)
    {
        mMenuItem.setVisible(true);

        AppDeck appDeck = AppDeckApplication.getAppDeck();

        icon = appDeck.resolveSpecialURL(icon);

        icon = appDeck.appConfig.resolveURL(icon);

        mIcon = icon;

        mImageRequest = new ImageRequest(mIcon, new Response.Listener<Bitmap>() {
            @Override
            public void onResponse(Bitmap bitmap) {
                mMenuItem.setIcon(new BitmapDrawable(bitmap));
            }
        }, appDeck.deviceInfo.bottomNavigationIconSize, appDeck.deviceInfo.bottomNavigationIconSize, null, new Response.ErrorListener() {
            public void onErrorResponse(VolleyError error) {
                Log.e(TAG, "Error while fetching AppDeckBottomMenuItem Image: "+mIcon+": "+error.getLocalizedMessage());
            }
        });
        AppDeckApplication.getAppDeck().addToRequestQueue(mImageRequest);

    }

    public void hide() {
        mMenuItem.setVisible(false);
    }

    public MenuItem getMenuItem() {
        return mMenuItem;
    }

    public void fire()
    {
        if (mIsValid == false)
            return;
        if (mUrl == null)
            return;
        // ask navigation to handle URL
        AppDeckApplication.getAppDeck().navigation.loadRootURL(mUrl);
    }

}