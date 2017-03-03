package net.mobideck.appdeck.core.plugins;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Environment;
import android.util.Log;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;
import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.util.Utils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

import okhttp3.OkHttpClient;

public class SharePlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("share");
        return commands;
    }

    public boolean share(final ApiCall call) {
        Log.d(TAG, "share");

        String shareTitle = call.paramObject.optString("title", null);
        String shareUrl = call.paramObject.optString("url", null);
        String shareImageUrl = call.paramObject.optString("imageurl", null);

        AppDeckApplication.getAppDeck().share.shareContent(shareTitle, shareUrl, shareImageUrl);

        return true;
    }

}
