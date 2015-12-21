package com.mobideck.appdeck;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.support.annotation.NonNull;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.JsResult;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestHandle;
import com.mopub.mobileads.AdViewController;
import com.mopub.mobileads.CustomEventBanner;
import com.mopub.mobileads.CustomEventInterstitial;
import com.mopub.mobileads.CustomEventInterstitialAdapter;
import com.mopub.mobileads.MoPubErrorCode;
import com.mopub.mobileads.MraidActivity;
import com.mopub.mobileads.factories.MraidControllerFactory;
import com.mopub.mraid.*;

import cz.msebera.android.httpclient.Header;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.UnsupportedEncodingException;
import java.util.Locale;

/**
 * Created by mathieudekermadec on 13/11/15.
 */
public class AppDeckAdNetworkAditic extends AppDeckAdNetwork {


    private static final String INPUT_HTML_DATA = "<html>\n" +
            "<head><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; user-scalable=no;\"></head>\n" +
            "<body style=\"background-color: red;\">\n"+
            "<a href=\"https://www.mobideck.net/agence-mobile-responsive?utm_source=app&amp;utm_medium=banner&amp;utm_campaign=autopromo\"  target=\"_blank\" ><img border=\"0\" src=\"http://appdata.static.appdeck.mobi/images/ad-mobideck-001-320x50.png\" width=\"320\" height=\"50\" alt=\"\" /></a>\n" +
            "</body></html>\n";


    public static String TAG = "Aditic";

    public String aditicBannerId = "";
    public String aditicRectangleId = "";
    public String aditicInterstitialId = "";

    public AppDeckAdNetworkAditic(AppDeckAdManager manager, JSONObject conf)
    {
        super(manager, conf);

        try {
            aditicBannerId = conf.optString("aditicBannerId");
            aditicRectangleId = conf.optString("aditicRectangleId");
            aditicInterstitialId = conf.optString("aditicInterstitialId");
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "Read: aditicBannerId:" + aditicBannerId + " aditicRectangleId:" + aditicRectangleId + " aditicInterstitialId:" + aditicInterstitialId);

    }


    /* Interstitial Ads */
    //private MraidController mInterstitialMraidController;
    private CustomEventInterstitial.CustomEventInterstitialListener mInterstitialEventListener;
    private View mInterstitialAdView;
    private String mInterstitialHTMLData;
    private RequestHandle mInterstitialRequestHandle;

    public boolean supportInterstitial() {
        if (aditicInterstitialId == null || aditicInterstitialId.isEmpty())
            return false;
        return true;
    }

    public void fetchInterstitialAd() {
        String url = getAdUrl("interstitial", aditicInterstitialId);
        Log.d(TAG, "InterstitialAdUrl:" + url);
        mInterstitialRequestHandle = manager.httpClient.post(url, new AsyncHttpResponseHandler() {
            @Override
            public void onFailure(int statusCode, Header[] headers, byte[] errorResponse, Throwable e) {
                Log.e(TAG, "Error: " + statusCode);
                manager.onInterstitialAdFailed(AppDeckAdNetworkAditic.this);
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                try {
                    String response = responseBody == null ? null : new String(responseBody, this.getCharset());
                    Log.i(TAG, "Response: " + response);
                    JSONObject adConf = (JSONObject) new JSONTokener(response).nextValue();
                    mInterstitialHTMLData = adConf.getString("code");

                    mInterstitialEventListener = new CustomEventInterstitial.CustomEventInterstitialListener() {
                        @Override
                        public void onInterstitialLoaded() {
                            Log.d(TAG, "onInterstitialLoaded");
                            manager.onInterstitialAdFetched(AppDeckAdNetworkAditic.this);
                        }

                        @Override
                        public void onInterstitialFailed(MoPubErrorCode errorCode) {
                            Log.d(TAG, "onInterstitialFailed");
                            manager.onInterstitialAdFailed(AppDeckAdNetworkAditic.this);
                        }

                        @Override
                        public void onInterstitialShown() {
                            Log.d(TAG, "onInterstitialShown");
                        }

                        @Override
                        public void onInterstitialClicked() {
                            Log.d(TAG, "onInterstitialClicked");
                            manager.onInterstitialAdClicked(AppDeckAdNetworkAditic.this);
                        }

                        @Override
                        public void onLeaveApplication() {
                            Log.d(TAG, "onLeaveApplication");

                        }

                        @Override
                        public void onInterstitialDismissed() {
                            Log.d(TAG, "onInterstitialDismissed");
                            manager.onInterstitialAdClosed(AppDeckAdNetworkAditic.this);
                        }
                    };

                    MraidActivity.preRenderHtml(manager.loader, mInterstitialEventListener, mInterstitialHTMLData);

                } catch (Exception e) {
                    Log.e(TAG, e.toString());
                    manager.onInterstitialAdFailed(AppDeckAdNetworkAditic.this);
                }

            }
        });

    }

    public boolean showInterstitial() {
        manager.loader.willShowActivity = true;
        //manager.loader.getInterstitialAdViewContainer().addView(mInterstitialAdView);
        //MraidActivity.start(mContext, mAdReport, mHtmlData, mBroadcastIdentifier);
        MraidActivity.start(manager.loader, null, mInterstitialHTMLData, 2222);
        return true;
    }

    public void destroyInterstitial() {
        if (mInterstitialRequestHandle != null) {
            mInterstitialRequestHandle.cancel(true);
            mInterstitialRequestHandle = null;
        }
/*        if (mInterstitialAdView != null) {
            manager.loader.getInterstitialAdViewContainer().removeView(mInterstitialAdView);
            mInterstitialAdView = null;
        }
        if (mInterstitialMraidController != null)
        {
            mInterstitialMraidController.destroy();
            mInterstitialMraidController = null;
        }
        if (bannerHttpClient != null) {
            bannerHttpClient.cancelAllRequests(true);
            bannerHttpClient = null;
        }*/
    }
    /* Banner Ads */

    private MraidController mBannerMraidController;
    private RequestHandle mBannerRequestHandle;
    private LinearLayout mBannerContainer;

    public boolean supportBanner() {
        if (aditicBannerId == null || aditicBannerId.isEmpty())
            return false;
        return true;
    }

    public void fetchBannerAd() {
        String url = getAdUrl("banner", aditicBannerId);
        Log.d(TAG, "adUrl:"+url);
        mBannerRequestHandle = manager.httpClient.post(url, new AsyncHttpResponseHandler() {

            @Override
            public void onFailure(int statusCode, Header[] headers, byte[] errorResponse, Throwable e) {
                // called when response HTTP status is "4XX" (eg. 401, 403, 404)
                Log.e(TAG, "Error: " + statusCode);
                manager.onBannerAdFailed(AppDeckAdNetworkAditic.this, null);
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                try {
                    String response = responseBody == null?null:new String(responseBody, this.getCharset());
                    Log.i(TAG, "Response: "+response);

                    JSONObject adConf = (JSONObject) new JSONTokener(response).nextValue();

                    String html = adConf.getString("code");

                    loadBannerAd(html, 320, 50);

                } catch (Exception e) {
                    Log.e(TAG, e.toString());
                }

            }
        });
    }

    public void loadBannerAd(String htmlData, final int width, final int height)
    {
        mBannerMraidController = new MraidController(manager.loader, null, PlacementType.INLINE);
        //mBannerMraidController.setDebugListener(mDebugListener);
        mBannerMraidController.setMraidListener(new MraidController.MraidListener() {
            @Override
            public void onLoaded(View view) {
                FrameLayout container = (FrameLayout)view;
                int scaledWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, width, manager.loader.getResources().getDisplayMetrics());
                int scaledHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, height, manager.loader.getResources().getDisplayMetrics());
                FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams)new FrameLayout.LayoutParams(scaledWidth, scaledHeight, Gravity.CENTER);
                container.setLayoutParams(lp);

                mBannerContainer = (LinearLayout)LayoutInflater.from(manager.loader).inflate(R.layout.ad_api_banner, null);
                FrameLayout layout = (FrameLayout)mBannerContainer.findViewById(R.id.apiBanner);
                layout.addView(view);
                manager.onBannerAdFetched(AppDeckAdNetworkAditic.this, mBannerContainer);
            }

            @Override
            public void onFailedToLoad() {
                manager.onBannerAdFailed(AppDeckAdNetworkAditic.this, null);
            }

            @Override
            public void onExpand() {
                //mBannerListener.onBannerExpanded();
                //mBannerListener.onBannerClicked();
                manager.onBannerAdClicked(AppDeckAdNetworkAditic.this, null);
            }

            @Override
            public void onOpen() {
                manager.onBannerAdClicked(AppDeckAdNetworkAditic.this, null);
            }

            @Override
            public void onClose() {
                manager.onBannerAdClosed(AppDeckAdNetworkAditic.this, null);
            }
        });

        mBannerMraidController.setDebugListener(new MraidWebViewDebugListener() {
            @Override
            public boolean onJsAlert(@NonNull String message, @NonNull JsResult result) {
                return false;
            }

            @Override
            public boolean onConsoleMessage(@NonNull ConsoleMessage consoleMessage) {
                return false;
            }
        });



        mBannerMraidController.loadContent(htmlData);
    }

    public void destroyBannerAd() {
        if (mBannerRequestHandle != null) {
            mBannerRequestHandle.cancel(true);
            mBannerRequestHandle = null;
        }
        if (mBannerMraidController != null) {
            mBannerMraidController.destroy();
            mBannerMraidController = null;
        }
    }

    /* Utils */

    public String getAdUrl(String adFormat, String adId) {

        String url = "http://xad.appdeck.mobi/aditic?";
        StringBuilder finalUrl = new StringBuilder(url);

        AppDeck appDeck = manager.loader.appDeck;

        if (appDeck.isTablet)
            finalUrl.append("type=androidtablet");
        else
            finalUrl.append("type=android");

        finalUrl.append("&apikey=");
        finalUrl.append(appDeck.config.app_api_key);

        finalUrl.append("&deviceuid=");
        finalUrl.append(appDeck.uid);

        finalUrl.append("&appid=");
        finalUrl.append(appDeck.packageName);

        finalUrl.append("&lang=");
        finalUrl.append(Locale.getDefault().getLanguage());

        ConnectivityManager cm =
                (ConnectivityManager)manager.loader.getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        boolean isConnected = activeNetwork != null && activeNetwork.isConnectedOrConnecting();

        boolean isWiFi = activeNetwork != null && activeNetwork.getType() == ConnectivityManager.TYPE_WIFI;
        if (isWiFi)
            finalUrl.append("&network=wifi");
        else
            finalUrl.append("&network=mobile");

        finalUrl.append("&adformat=");
        finalUrl.append(adFormat);

        finalUrl.append("&adid=");
        finalUrl.append(adId);

        url = finalUrl.toString();

        return url;
    }



}
