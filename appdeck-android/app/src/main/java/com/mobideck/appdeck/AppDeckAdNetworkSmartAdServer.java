package com.mobideck.appdeck;

import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.smartadserver.android.library.SASBannerView;
import com.smartadserver.android.library.SASInterstitialView;
import com.smartadserver.android.library.model.SASAdElement;
import com.smartadserver.android.library.ui.SASAdView;
import com.smartadserver.android.library.ui.SASRotatingImageLoader;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 16/11/15.
 */
public class AppDeckAdNetworkSmartAdServer extends AppDeckAdNetwork {

    public static String TAG = "SmartAdServer";

    public int smartSiteId = 0;
    public String smartPageId = "";
    public int smartBannerFormatId = 0;
    public int smartInterstitialFormatId = 0;
    public int smartNetworkId = 0;
    /*
    -FormatID : 14839
            - SiteID : 4605
            - Page Id: 535525
*/
    public AppDeckAdNetworkSmartAdServer(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            smartSiteId = conf.optInt("smartSiteId");
            smartPageId = conf.optString("smartPageId");
            smartBannerFormatId = conf.optInt("smartBannerFormatId");
            smartInterstitialFormatId = conf.optInt("smartInterstitialFormatId");
            smartNetworkId = conf.optInt("smartNetworkId");
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: smartSiteId:" + smartSiteId + " smartPageId:" + smartPageId + " smartBannerFormatId:" + smartBannerFormatId + " smartInterstitialFormatId:" + smartInterstitialFormatId + " smartNetworkId:" + smartNetworkId);

    }

    /* Interstitial Ads */

    private SASInterstitialView mInterstitialView;

    public boolean supportInterstitial() {
        if (smartInterstitialFormatId == 0)
            return false;
        return true;
    }
    public void fetchInterstitialAd() {
        mInterstitialView = new SASInterstitialView(manager.loader);
        //mInterstitialView.setLoaderView(new SASRotatingImageLoader(manager.loader));
        //(int siteId, String pageId, int formatId, boolean master, String target, SASAdView.AdResponseHandler handler, int timeout, boolean prefetch, boolean isRefreshTimerCall)
        SASAdView.AdResponseHandler adResponseHandler = new SASAdView.AdResponseHandler() {
            public String TAG = "SmartAdServer::Interstitial";
            @Override
            public void adLoadingCompleted(SASAdElement sasAdElement) {
                Log.d(TAG, "adLoadingCompleted");
                mInterstitialView.executeOnUIThread(new Runnable() {
                    @Override
                    public void run() {
                        manager.onInterstitialAdFetched(AppDeckAdNetworkSmartAdServer.this);
                        manager.onInterstitialAdDisplayed(AppDeckAdNetworkSmartAdServer.this);
                    }
                });
            }

            @Override
            public void adLoadingFailed(Exception e) {
                Log.d(TAG, "adLoadingFailed:"+e.getMessage());
                mInterstitialView.executeOnUIThread(new Runnable() {
                    @Override
                    public void run() {
                        manager.onInterstitialAdFailed(AppDeckAdNetworkSmartAdServer.this);
                    }
                });
            }
        };
        mInterstitialView.loadAd(smartSiteId, smartPageId, smartInterstitialFormatId, true, "appdeck", adResponseHandler);

    }

    public boolean showInterstitial() {
/*        if (mInterstitial.isReady()) {
            manager.loader.willShowActivity = true;
            mInterstitial.show();
            return true;
        }*/
        return false;
    }

    public void destroyInterstitial() {
        if (mInterstitialView != null)
            mInterstitialView.onDestroy();
        mInterstitialView = null;
    }

    /* Banner Ads */

    private SASBannerView mBannerView;
    private LinearLayout mBannerViewContainer;

    public boolean supportBanner() {
        if (smartBannerFormatId == 0)
            return false;
        return true;
    }
    public void fetchBannerAd() {

        // Create banner instance
        mBannerView = new SASBannerView(manager.loader);

        SASAdView.AdResponseHandler adResponseHandler = new SASAdView.AdResponseHandler() {
            public String TAG = "SmartAdServer::Banner";
            @Override
            public void adLoadingCompleted(SASAdElement sasAdElement) {
                Log.d(TAG, "adLoadingCompleted");
                mBannerView.executeOnUIThread(new Runnable() {
                    @Override
                    public void run() {
                        manager.onBannerAdFetched(AppDeckAdNetworkSmartAdServer.this, mBannerViewContainer);
                    }
                });
            }

            @Override
            public void adLoadingFailed(Exception e) {
                Log.d(TAG, "adLoadingFailed:"+e.getMessage());
                mBannerView.executeOnUIThread(new Runnable() {
                    @Override
                    public void run() {
                        manager.onBannerAdFailed(AppDeckAdNetworkSmartAdServer.this, mBannerViewContainer);
                    }
                });
            }
        };

        /*
        int dpHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 50, manager.loader.getResources().getDisplayMetrics());
        mBannerView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT, dpHeight));
        mBannerViewContainer = (LinearLayout)LayoutInflater.from(manager.loader).inflate(R.layout.ad_smart, null);
        mBannerViewContainer.addView(mBannerView);*/

        mBannerViewContainer = (LinearLayout)LayoutInflater.from(manager.loader).inflate(R.layout.ad_smart, null);
        mBannerView = (SASBannerView)mBannerViewContainer.findViewById(R.id.smartBanner);

        mBannerView.loadAd(smartSiteId, smartPageId, smartBannerFormatId, true, "appdeck", adResponseHandler);
    }

    public void destroyBannerAd() {
        if (mBannerView != null)
            mBannerView.onDestroy();
        mBannerView = null;
    }


}
