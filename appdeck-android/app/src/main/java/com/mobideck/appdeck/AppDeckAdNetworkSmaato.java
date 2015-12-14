package com.mobideck.appdeck;

import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.smaato.soma.AdDimension;
import com.smaato.soma.AdDownloaderInterface;
import com.smaato.soma.AdListenerInterface;
import com.smaato.soma.AdType;
import com.smaato.soma.BannerStateListener;
import com.smaato.soma.BannerView;
import com.smaato.soma.BaseView;
import com.smaato.soma.ReceivedBannerInterface;
import com.smaato.soma.bannerutilities.constant.BannerStatus;
import com.smaato.soma.debug.Debugger;
import com.smaato.soma.exception.ClosingLandingPageFailed;

import org.json.JSONObject;

/**
 * Created by mathieudekermadec on 17/11/15.
 */
public class AppDeckAdNetworkSmaato extends AppDeckAdNetwork {


    public static String TAG = "Smaato";

    public long smaatoPublisherId = 0;
    public long smaatoBannerAdspaceId = 0;
    public long smaatoInterstitialAdspaceId = 0;
    public long smaatoRectagleAdspaceId = 0;

    public AppDeckAdNetworkSmaato(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            smaatoPublisherId = conf.optLong("smaatoPublisherId", 0);
            smaatoBannerAdspaceId = conf.optLong("smaatoBannerAdspaceId", 0);
            smaatoInterstitialAdspaceId = conf.optLong("smaatoInterstitialAdspaceId", 0);
            smaatoRectagleAdspaceId = conf.optLong("smaatoRectagleAdspaceId", 0);
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: smaatoPublisherId:" + smaatoPublisherId + " smaatoBannerAdspaceId:" + smaatoBannerAdspaceId + " smaatoInterstitialAdspaceId:" + smaatoInterstitialAdspaceId + " smaatoRectagleAdspaceId:" + smaatoRectagleAdspaceId);

    }

    /* Banner Ads */

    private RelativeLayout mBannerContainer;
    private BannerView mBanner;

    public boolean supportBanner() {
        if (smaatoPublisherId == 0 || smaatoBannerAdspaceId == 0)
            return false;
        return true;
    }
    public void fetchBannerAd() {

        mBannerContainer = (RelativeLayout) LayoutInflater.from(manager.loader).inflate(R.layout.ad_smaato, null);
        mBanner = (BannerView) mBannerContainer.findViewById(R.id.smaato_banner);
        //mBanner = new BannerView (manager.loader);

        if (manager.shouldEnableTestMode()) {
            mBanner.getAdSettings().setPublisherId(0);
            mBanner.getAdSettings().setAdspaceId(0);
            Debugger.setDebugMode(Debugger.Level_1);
        } else {
            mBanner.getAdSettings().setPublisherId(smaatoPublisherId);
            mBanner.getAdSettings().setAdspaceId(smaatoBannerAdspaceId);
        }

        mBanner.setScalingEnabled(false);
        mBanner.setAutoReloadEnabled(false);
//        mBanner.getAdSettings().setAdType(AdType.RICHMEDIA);
        mBanner.getAdSettings().setAdDimension(AdDimension.DEFAULT);

        mBanner.addAdListener(new AdListenerInterface() {
            @Override
            public void onReceiveAd(AdDownloaderInterface arg0, ReceivedBannerInterface banner) {
                if (banner.getStatus() == BannerStatus.ERROR) {
                    Log.d(TAG, "onReceiveAdError:" + banner.getErrorCode() + ":" + banner.getErrorMessage());
                    manager.onBannerAdFailed(AppDeckAdNetworkSmaato.this, mBanner);
                } else {
                    // Banner download succeeded
                    Log.d(TAG, "onReceiveAd");

/*                    int scaledWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 300, manager.loader.getResources().getDisplayMetrics());
                    int scaledHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 50, manager.loader.getResources().getDisplayMetrics());
                    RelativeLayout.LayoutParams rel_btn = new RelativeLayout.LayoutParams(scaledWidth, scaledHeight);
                    RelativeLayout layout = (RelativeLayout) mBanner;
                    layout.setLayoutParams(rel_btn);
                    manager.onBannerAdFetched(AppDeckAdNetworkSmaato.this, mBanner);*/

                    manager.onBannerAdFetched(AppDeckAdNetworkSmaato.this, mBannerContainer);

                }
            }
        });

        mBanner.setBannerStateListener(new BannerStateListener() {
            @Override
            public void onWillOpenLandingPage(BaseView baseView) {
                Log.d(TAG, "onWillOpenLandingPage");
                manager.onBannerAdClicked(AppDeckAdNetworkSmaato.this, mBanner);
            }

            @Override
            public void onWillCloseLandingPage(BaseView baseView) throws ClosingLandingPageFailed {
                Log.d(TAG, "onWillOpenLandingPage");
                manager.onBannerAdClosed(AppDeckAdNetworkSmaato.this, mBanner);
            }
        });

        mBanner.asyncLoadNewBanner();
    }

    public void destroyBannerAd() {
        if(mBanner != null) {
            mBanner.destroy();
            mBanner = null;
        }
    }
}
