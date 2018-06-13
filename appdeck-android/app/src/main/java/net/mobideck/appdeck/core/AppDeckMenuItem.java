package net.mobideck.appdeck.core;

import android.graphics.Bitmap;
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

public class AppDeckMenuItem {

    public static String TAG = "AppDeckMenuItem";

    public static int transitionTime = 250;

    private String mTitle;
    private String mIcon;
    //private String type;
    private String mUrl;
    private int mBadge;

    private MenuItem mMenuItem;

    private boolean mIsValid = false;
    private boolean mAvailable = true;

    private ImageView mImageView;
    private FrameLayout mRoot;
    private FrameLayout mBadgeCircle;
    private TextView mBadgeValue;

    private ImageRequest mImageRequest;

    private boolean mIconVisible = false;
    private boolean mBadgeVisible = false;

    private AppDeckView mAppDeckView;

    public AppDeckMenuItem(MenuItem menuItem, AppDeckActivity appDeckActivity) {
        //mRoot = (FrameLayout)appDeckActivity.getLayoutInflater().inflate(R.layout.menu_item, null);
        mRoot = (FrameLayout)menuItem.getActionView();
        mImageView = (ImageView)mRoot.findViewById(R.id.imageView);
        mBadgeCircle = (FrameLayout)mRoot.findViewById(R.id.badgeCircle);
        mBadgeValue = (TextView)mRoot.findViewById(R.id.badgeValue);
        mMenuItem = menuItem;

        //mImageView.setScaleX(0.5f);
        //mImageView.setScaleY(0.5f);
        //mBadgeCircle.setScaleX(0f);

        mRoot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                fire();
            }
        });
    }



    public void configure(String title, String icon, String url, int badge, boolean disabled, AppDeckView appDeckView)
    {
        mAppDeckView = appDeckView;

        mMenuItem.setEnabled(false);
        mMenuItem.setVisible(true);
        mIsValid = true;

        AppDeck appDeck = AppDeckApplication.getAppDeck();

        icon = appDeck.resolveSpecialURL(icon);

        if (appDeckView != null)
            icon = appDeckView.resolveURL(icon);

        boolean shouldUpdateIcon = false;
        boolean shouldAnimateBadgeText = (mBadge != badge && badge > 0 && mBadge > 0);

        if (mIcon == null)
            shouldUpdateIcon = true;
        else if (!mIcon.equalsIgnoreCase(icon))
            shouldUpdateIcon = true;

        mTitle = title;
        mIcon = icon;
        mBadge = badge;
        mUrl = url;
        mAvailable = (!disabled);

        if (mBadge == 0) {
            hideBadge();
            mBadgeValue.setText("");
        } else {
            mBadgeValue.setText(String.valueOf(mBadge));
        }

        if (!shouldUpdateIcon && !shouldAnimateBadgeText && mBadge > 0) {
            showBadge();
        }

        if (!shouldUpdateIcon && shouldAnimateBadgeText) {
            mBadgeValue.setAlpha(0);
            mBadgeValue.animate().alpha(1f).start();
        }

        if (shouldUpdateIcon) {

            if (mIconVisible)
                replaceIcon();
            else
                showIcon();
        } else {
            mImageView.setAlpha(mAvailable ? 1f : 0.64f);
        }
    }

    public MenuItem getMenuItem() {
        return mMenuItem;
    }

    private void replaceIcon() {

        mImageView.setAlpha(1f);
        mImageView.setRotation(0);
        mImageView.setScaleX(1f);
        mImageView.setScaleY(1f);
        hideBadge();

        mImageView.animate().rotation(90).alpha(0).scaleX(0.5f).scaleY(0.5f).setDuration(AppDeckMenuItem.transitionTime).setInterpolator(new FastOutLinearInInterpolator()).withEndAction(new Runnable() {
            @Override
            public void run() {

                if (mImageRequest != null) {
                    mImageRequest.cancel();
                }

                int iconSize = AppDeckApplication.getAppDeck().deviceInfo.topMenuIconSize;

                mImageRequest = new ImageRequest(mIcon, new Response.Listener<Bitmap>() {
                    @Override
                    public void onResponse(Bitmap bitmap) {
                        mImageView.setImageBitmap(bitmap);

                        mImageView.setAlpha(0f);
                        mImageView.setRotation(-90);
                        mImageView.setScaleX(0.5f);
                        mImageView.setScaleY(0.5f);

                        mImageView.setRotation(-90);
                        mImageView.animate().rotation(0).alpha(mAvailable ? 1f : 0.64f).scaleX(1f).scaleY(1f).setDuration(AppDeckMenuItem.transitionTime).setInterpolator(new FastOutLinearInInterpolator()).start();
                        mIconVisible = true;
                        if (mBadge > 0) {
                            showBadge();
                        }
                    }
                }, iconSize, iconSize, null, new Response.ErrorListener() {
                    public void onErrorResponse(VolleyError error) {
                        Log.e(TAG, "Error while fetching AppDeckMenuItem Image: "+mIcon+": "+error.getLocalizedMessage());
                    }
                });
                AppDeckApplication.getAppDeck().addToRequestQueue(mImageRequest);
            }
        }).start();
    }

    public void showIcon() {

        if (mImageRequest != null) {
            mImageRequest.cancel();
        }

        int iconSize = AppDeckApplication.getAppDeck().deviceInfo.topMenuIconSize;

        mImageView.setAlpha(0f);
        mImageView.setRotation(-90);
        mImageView.setScaleX(0.5f);
        mImageView.setScaleY(0.5f);

        mImageRequest = new ImageRequest(mIcon, new Response.Listener<Bitmap>() {
            @Override
            public void onResponse(Bitmap bitmap) {
                mImageView.setImageBitmap(bitmap);
                //mImageView.setRotation(0);
                //mImageView.setAlpha(0);
                //mImageView.setScaleX(0);
                //mImageView.setScaleY(0);
                mImageView.animate().rotation(0).alpha(mAvailable ? 1f : 0.64f).scaleX(1f).scaleY(1f).setDuration(AppDeckMenuItem.transitionTime).setInterpolator(new FastOutLinearInInterpolator()).start();
                mIconVisible = true;
                if (mBadge > 0) {
                    showBadge();
                }
            }
        }, iconSize, iconSize, null, new Response.ErrorListener() {
            public void onErrorResponse(VolleyError error) {
                Log.e(TAG, "Error while fetching AppDeckMenuItem Image: "+mIcon+": "+error.getLocalizedMessage());
            }
        });
        AppDeckApplication.getAppDeck().addToRequestQueue(mImageRequest);
    }

    private void showBadge() {
        //if (mBadgeVisible == false)
        mBadgeCircle.animate().alpha(1f).scaleX(1).scaleY(1).setDuration(AppDeckMenuItem.transitionTime).start();
        mBadgeVisible = true;
    }

    private void hideBadge() {
        mBadgeCircle.animate().alpha(0f).scaleX(0).scaleY(0).setDuration(AppDeckMenuItem.transitionTime).start();
        mBadgeVisible = false;
    }

    public void hide() {
        mIsValid = false;
        if (mImageRequest != null) {
            mImageRequest.cancel();
            mImageRequest = null;
        }
        mImageView.animate().rotation(90).alpha(0).setDuration(AppDeckMenuItem.transitionTime).setInterpolator(new FastOutLinearInInterpolator()).start();
        mBadgeCircle.animate().alpha(0f).setDuration(AppDeckMenuItem.transitionTime).start();
        mTitle = null;
        mIcon = null;
        mBadge = 0;
        mUrl = null;
        mIconVisible = false;
        mMenuItem.setEnabled(false);
        //mMenuItem.setVisible(false);
    }

/*    public void setAvailable(boolean available)
    {
        if (available)
            mRoot.animate().alpha(1f).start();
        else
            mRoot.animate().alpha(0.64f).start();
        mAvailable = available;
    }*/

    public String getUrl() {
        return mUrl;
    }

    public void fire()
    {
        if (!mAvailable)
            return;
        if (!mIsValid)
            return;
        if (mUrl == null)
            return;
        if (mAppDeckView != null) {
            mAppDeckView.loadUrl(mUrl);
            return;
        }
        // ask navigation to handle URL
        AppDeckApplication.getAppDeck().navigation.loadURL(mUrl);
    }

/*    public void fireRoot()
    {
        if (mIsValid == false)
            return;
        if (mUrl == null)
            return;
        // ask navigation to handle URL
        AppDeckApplication.getAppDeck().navigation.loadRootURL(mUrl);
    }*/

}
