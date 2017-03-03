package net.mobideck.appdeck.core.plugins;

import android.util.Log;

import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.core.DebugLog;

import java.util.ArrayList;

public class DebugPlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("debug");
        commands.add("info");
        commands.add("warning");
        commands.add("error");
        return commands;
    }

    public boolean debug(final ApiCall call) {
        Log.d(TAG, "debug");
        String msg = call.inputObject.optString("param", "");
        DebugLog.debug("JS", msg);
        return true;
    }

    public boolean info(final ApiCall call) {
        Log.d(TAG, "info");
        String msg = call.inputObject.optString("param", "");
        DebugLog.info("JS", msg);
        return true;
    }

    public boolean warning(final ApiCall call) {
        Log.d(TAG, "warning");
        String msg = call.inputObject.optString("param", "");
        DebugLog.warning("JS", msg);
        return true;
    }

    public boolean error(final ApiCall call) {
        Log.d(TAG, "error");
        String msg = call.inputObject.optString("param", "");
        DebugLog.error("JS", msg);
        return true;
    }

}
