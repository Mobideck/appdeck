package net.mobideck.appdeck.core.plugins;

import android.util.Log;

import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.AppDeckApplication;

import java.util.ArrayList;

public class PagePlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("reload");
        commands.add("catchlink");
        return commands;
    }

    public boolean reload(final ApiCall call) {
        Log.d(TAG, "reload");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        if (apiCall.page != null)
            apiCall.page.reloadInBackground();
        return true;
    }


}
