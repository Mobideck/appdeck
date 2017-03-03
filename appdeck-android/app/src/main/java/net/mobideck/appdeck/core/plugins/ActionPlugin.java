package net.mobideck.appdeck.core.plugins;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Telephony;
import android.util.Log;

import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.core.PhotoBrowser;

import org.json.JSONArray;

import java.util.ArrayList;

public class ActionPlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("sendsms");
        commands.add("sendemail");
        commands.add("openlink");
        commands.add("photobrowser");
        return commands;
    }

    public boolean sendsms(final ApiCall call) {
        Log.d(TAG, "sendsms");
        String to = call.paramObject.optString("address");
        String message = call.paramObject.optString("body");
        Log.i("API", "**SENDSMS** "+to+": "+message);

        String defaultSmsPackageName = Telephony.Sms.getDefaultSmsPackage(AppDeckApplication.getContext());
        Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:" + to));
        intent.putExtra("sms_body", message);
        if (defaultSmsPackageName != null) {
            intent.setPackage(defaultSmsPackageName);
        }
        AppDeckApplication.getActivity().startActivity(intent);

        return true;
    }

    public boolean sendemail(final ApiCall call) {
        Log.d(TAG, "sendemail");
        String to = call.paramObject.optString("to");
        String subject = call.paramObject.optString("subject");
        String message = call.paramObject.optString("message");
        Log.i("API", "**SENDEMAIL** "+to+": "+subject+": "+message);

        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("message/rfc822");
        intent.putExtra(Intent.EXTRA_EMAIL, new String[]{to});
        intent.putExtra(Intent.EXTRA_SUBJECT, subject);
        intent.putExtra(Intent.EXTRA_TEXT, message);
        AppDeckApplication.getActivity().startActivity(intent);
        return true;
    }

    public boolean openlink(final ApiCall call) {
        Log.d(TAG, "openlink");
        String url = call.paramObject.optString("url");

        Log.i("API", "**OPENLINK** "+url);

        if (!url.contains("://")) {
            url = "http://" + url;
        }

        AppDeckApplication.getAppDeck().navigation.loadExternalURL(url, true);

        return true;
    }

    public boolean photobrowser(final ApiCall call) {
        Log.d(TAG, "photobrowser");

        JSONArray images = call.paramObject.optJSONArray("images");
        if (images != null && images.length() > 0)
        {
            net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
            PhotoBrowser photoBrowser = new PhotoBrowser(AppDeckApplication.getActivity(), apiCall);
            AppDeckApplication.getAppDeck().navigation.push(photoBrowser);
        }


        return true;
    }

}
