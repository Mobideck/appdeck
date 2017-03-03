package net.mobideck.appdeck.core.plugins;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.AppDeckApplication;

import java.util.ArrayList;

public class PreferencePlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("preferencesget");
        commands.add("preferencesset");
        return commands;
    }

    public boolean preferencesget(final ApiCall call) {
        Log.i("API", "**PREFERENCES GET**");

        String name = call.paramObject.optString("name");
        String defaultValue = call.paramObject.optString("value", "");

        SharedPreferences prefs = AppDeckApplication.getContext().getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);

        String key = "appdeck_preferences_json1_" + name;
        String finalValueJson = prefs.getString(key, null);

        if (finalValueJson == null)
            call.setResult(defaultValue);
        else
            call.setResult(finalValueJson);
        return true;
    }

    public boolean preferencesset(final ApiCall call) {
        Log.i("API", "**PREFERENCES SET**");

        String name = call.paramObject.optString("name");
        String finalValue = call.paramObject.optString("value", "");

        SharedPreferences prefs = AppDeckApplication.getContext().getSharedPreferences(AppDeckApplication.class.getSimpleName(), Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        String key = "appdeck_preferences_json1_" + name;
        editor.putString(key, finalValue);
        editor.apply();

        call.setResult(finalValue);

        return true;
    }

}
