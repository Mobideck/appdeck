package net.mobideck.appdeck.core;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.Handler;
import android.util.Log;
import android.webkit.WebView;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.WebView.SmartWebView;
import net.mobideck.appdeck.util.Utils;

import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.Map;

public class Cache {

    public static String TAG = "EmbedCache";

    private AppDeck mAppDeck;

    public Cache(AppDeck appDeck) {
        mAppDeck = appDeck;
        checkBeacon();
    }

    @SuppressWarnings("deprecation")
    private InputStream getEmbedResourceStream(String absoluteURL)
    {
        AssetManager manager = AppDeckApplication.getAppDeck().assetManager;
        String asset_path =  absoluteURL.replace("http://", "");
        asset_path =  URLEncoder.encode(asset_path);
        if (asset_path.length() > 48)
        {
            asset_path = asset_path.substring(0, 48) + "_" + Utils.md5(asset_path);
        }
        asset_path = "httpcache/" + asset_path + ".png";
        try {
            InputStream stream = manager.open(asset_path, AssetManager.ACCESS_STREAMING);
            return stream;
        } catch (IOException e) {
        }
        return null;
    }

    private InputStream getEmbedResourceMetaStream(String absoluteURL)
    {
        AssetManager manager = AppDeckApplication.getAppDeck().assetManager;
        String asset_path =  absoluteURL.replace("http://", "");
        asset_path =  URLEncoder.encode(asset_path);
        if (asset_path.length() > 48)
        {
            asset_path = asset_path.substring(0, 48) + "_" + Utils.md5(asset_path);
        }
        asset_path = "httpcache/" + asset_path + ".meta.png";

        try {
            InputStream stream = manager.open(asset_path);
            return stream;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    // cache Result API
    public class CacheResult
    {
        public boolean isInCache = false;
        public long lastModified = 0;

        public CacheResult(boolean isInCache, long lastModified)
        {
            this.isInCache = isInCache;
            this.lastModified = lastModified;
        }
    }

    public CacheResult isInCache(String absoluteURL)
    {
        InputStream stream = getEmbedResourceStream(absoluteURL);
        if (stream != null)
        {
            try {
                stream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return new CacheResult(true, System.currentTimeMillis());
        }
        String cache_path =  getCacheEntryPath(absoluteURL);
        File cache_file = new File(cache_path);
        if (cache_file.exists())
        {
            return new CacheResult(true, cache_file.lastModified());
        }
        return new CacheResult(false, 0);
    }

    public CachedResponse getEmbedResponse(String absoluteURL)
    {
        // step 1: data
        InputStream streamData = getEmbedResourceStream(absoluteURL);
        if (streamData == null)
            return null;
        // step 2: headers
        InputStream streamMeta = getEmbedResourceMetaStream(absoluteURL);
        if (streamMeta == null)
            return null;
        JSONObject headers = Utils.streamGetJSONObject(streamMeta);
        return new CachedResponse(absoluteURL, streamData, headers);
    }

    public CachedResponse getCachedResponse(String absoluteURL)
    {
        CachedResponse cachedResponse = getEmbedResponse(absoluteURL);
        if (cachedResponse != null)
            return cachedResponse;

        // step 1: data
        String cache_path = getCacheEntryPath(absoluteURL);
        InputStream streamData = Utils.streamFromFilePath(cache_path);
        if (streamData == null)
            return null;

        // step 2: headers
        String cache_path_meta = cache_path+".meta";
        InputStream streamMeta = Utils.streamFromFilePath(cache_path_meta);
        if (streamMeta == null)
            return null;

        JSONObject headers = Utils.streamGetJSONObject(streamMeta);
        cachedResponse = new CachedResponse(absoluteURL, streamData, headers);
        return cachedResponse;
    }

    public class CachedResponse {

        private String mAbsoluteURL;
        private InputStream mStream;
        private JSONObject mHeaders;

        CachedResponse(String absoluteURL, InputStream stream, JSONObject headers) {
            mAbsoluteURL = absoluteURL;
            mStream = stream;
            mHeaders = headers;
        }

        public String getHeader(String name, String defaultValue) {
            String headerValue = mHeaders.optString(name);
            if (headerValue != null)
                return headerValue;
            return defaultValue;
        }

        public InputStream getStream() {
            return mStream;
        }
    }

    public String getCachePath()
    {
        return mAppDeck.deviceInfo.cacheDir.toString() + "/httpcache/";
    }

    void deleteRecursive(File dir, boolean deleteCurrent)
    {
        Log.d("DeleteRecursive", "DELETEPREVIOUS TOP" + dir.getPath());
        if (dir.isDirectory())
        {
            String[] children = dir.list();
            for (int i = 0; i < children.length; i++)
            {
                File temp = new File(dir, children[i]);
                if (temp.isDirectory())
                {
                    Log.d("DeleteRecursive", "Recursive Call" + temp.getPath());
                    deleteRecursive(temp, true);
                }
                else
                {
                    Log.d("DeleteRecursive", "Delete File" + temp.getPath());
                    boolean b = temp.delete();
                    if (b == false)
                    {
                        Log.d("DeleteRecursive", "DELETE FAIL");
                    }
                }
            }

        }
        if (deleteCurrent)
            dir.delete();
    }

    public void clear()
    {
        String cache_path = getCachePath();
        File dir = new File(cache_path);
        deleteRecursive(dir, false);
    }

    public void checkBeacon()
    {
        String embed_beacon = "embed";
        AssetManager manager = mAppDeck.assetManager;
        try {
            InputStream stream = manager.open("httpcache/beacon");
            embed_beacon = Utils.streamGetContent(stream);
        } catch (Exception e) {
            e.printStackTrace();
        }
        String last_beacon = "last";
        String last_beacon_path = getCachePath() + "beacon";
        try {
            last_beacon = Utils.fileGetContents(last_beacon_path);
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (!embed_beacon.equalsIgnoreCase(last_beacon)) {
            Log.i(TAG, "Check Beacon failed: ["+embed_beacon+"] != ["+last_beacon+"] : we clear cache");
            clear();
            Handler mainHandler = new Handler(AppDeckApplication.getContext().getMainLooper());
            Runnable myRunnable = new Runnable() {
                @Override
                public void run() {
                    WebView webView = new WebView(AppDeckApplication.getActivity());
                    webView.clearCache(true);
                }
            };
            mainHandler.post(myRunnable);
        } else {
            Log.v(TAG, "Check Beacon success: ["+embed_beacon+"] != ["+last_beacon+"] : we keep cache");
        }

        Utils.filePutContents(last_beacon_path, embed_beacon);
    }

    @SuppressWarnings("deprecation")
    public String getCacheEntryPath(String absoluteURL)
    {
        String cache_path =  absoluteURL.replace("http://", "");
        cache_path =  URLEncoder.encode(cache_path);
        if (cache_path.length() > 48)
        {
            cache_path = cache_path.substring(0, 48) + '_' + Utils.md5(cache_path);
        }
        cache_path = getCachePath() + cache_path;
        return cache_path;
    }
}
