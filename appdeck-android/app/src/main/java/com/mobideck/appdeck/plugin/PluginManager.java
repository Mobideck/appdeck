package com.mobideck.appdeck.plugin;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;

import com.android.vending.billing.IInAppBillingService;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;

public class PluginManager {

    public static String TAG = "PluginManager";

    private static PluginManager sharedInstance;

    public static PluginManager getSharedInstance() {
        if (sharedInstance == null)
            sharedInstance = new PluginManager();
        return sharedInstance;
    }

    ArrayList<Plugin> plugins;
    HashMap<String, Plugin> commands;

    private PluginManager() {

        plugins = new ArrayList<>();
        commands = new HashMap<>();

        // begin register plugins

        registerPlugin(new com.mobideck.appdeck.iap.AppDeckPluginIAP());

        // end register plugins
    }

    public void registerPlugin(Plugin plugin) {

        plugins.add(plugin);

        for (String command : plugin.getCommands()) {
            commands.put(command, plugin);
        }
    }

    public boolean handleCall(ApiCall apiCall) {

        Plugin plugin = commands.get(apiCall.command);

        Log.d(TAG, "Search: '"+apiCall.command+"'");

        if (plugin == null)
            return false;

        //Class[] parameterTypes = new Class[1];
        //parameterTypes[0] = ApiCall.class;
        try {
            Method method = plugin.getClass().getMethod(apiCall.command, ApiCall.class);
            return (boolean)method.invoke(plugin, apiCall);
            } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }

        return false;
    }

    public void onActivityCreate(Activity activity) {
        for (Plugin plugin : plugins) {
            plugin.onActivityCreate(activity);
        }
    }

    public void onActivityPause(Activity activity) {
        for (Plugin plugin : plugins) {
            plugin.onActivityPause(activity);
        }
    }

    public void onActivityResume(Activity activity) {
        for (Plugin plugin : plugins) {
            plugin.onActivityResume(activity);
        }
    }

    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        for (Plugin plugin : plugins) {
            plugin.onActivityResult(activity, requestCode, resultCode, data);
        }

    }


    public void onActivityDestroy(Activity activity) {
        for (Plugin plugin : plugins) {
            plugin.onActivityDestroy(activity);
        }
    }

}
