package net.mobideck.appdeck.core.plugins;

import android.app.Activity;
import android.content.Intent;

import com.mobideck.appdeck.plugin.Plugin;

import java.util.ArrayList;

public class PluginAdaptater implements Plugin {

    public static String TAG = "PluginAdaptater";

    public void onActivityCreate(Activity activity) {

    }

    public void onActivityPause(Activity activity) {

    }

    public void onActivityResume(Activity activity) {

    }

    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {

    }

    public void onActivityDestroy(Activity activity) {

    }

    public ArrayList<String> getCommands() {
        return new ArrayList<>();
    }

}
