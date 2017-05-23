package net.mobideck.appdeck.core.plugins;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.util.Log;

import com.mobideck.appdeck.plugin.ApiCall;
import com.mobideck.appdeck.plugin.Plugin;

import net.mobideck.appdeck.AppDeckApplication;

import java.util.ArrayList;

public class InfoPlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("istablet");
        commands.add("isphone");
        commands.add("isios");
        commands.add("isandroid");
        commands.add("islandscape");
        commands.add("isportrait");
        commands.add("getuserid");
        commands.add("getappkey");
        return commands;
    }

    public boolean istablet(final ApiCall call) {
        Log.d(TAG, "istablet");
        call.setResult(Boolean.valueOf(AppDeckApplication.getAppDeck().deviceInfo.isTablet));
        return true;
    }

    public boolean isphone(final ApiCall call) {
        Log.d(TAG, "isphone");
        call.setResult(Boolean.valueOf(!AppDeckApplication.getAppDeck().deviceInfo.isTablet));
        return true;
    }

    public boolean isios(final ApiCall call) {
        Log.d(TAG, "isios");
        call.setResult(Boolean.valueOf(false));
        return true;
    }

    public boolean isandroid(final ApiCall call) {
        Log.d(TAG, "isandroid");
        call.setResult(Boolean.valueOf(true));
        return true;
    }

    public boolean islandscape(final ApiCall call) {
        Log.d(TAG, "islandscape");
        call.setResult(Boolean.valueOf(AppDeckApplication.getActivity().getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE));
        return true;
    }

    public boolean isportrait(final ApiCall call) {
        Log.d(TAG, "isportrait");
        call.setResult(Boolean.valueOf(AppDeckApplication.getActivity().getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT));
        return true;
    }

    public boolean getuserid(final ApiCall call) {
        Log.d(TAG, "getuserid");
        call.setResult(AppDeckApplication.getAppDeck().deviceInfo.uid);
        return true;
    }

    public boolean getappkey(final ApiCall call) {
        Log.d(TAG, "getappkey");
        call.setResult(AppDeckApplication.getAppDeck().appConfig.apiKey);
        return true;
    }

}
