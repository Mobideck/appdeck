package net.mobideck.appdeck.core.plugins;

import android.support.design.widget.Snackbar;
import android.util.Log;
import android.view.View;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;
import net.mobideck.appdeck.config.ViewConfig;

import org.json.JSONObject;

import java.util.ArrayList;

public class UIPlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("uiconfig");
        commands.add("snackbar");
        commands.add("loadingshow");
        commands.add("loadingset");
        commands.add("loadinghide");
        return commands;
    }

    public class ParamViewConfig {
        @SerializedName("param")
        @Expose
        ViewConfig param;
    }

    public boolean uiconfig(final ApiCall call) {
        Log.d(TAG, "uiconfig");

        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;

        ParamViewConfig paramViewConfig = AppDeckApplication.getAppDeck().gson.fromJson(call.inputJSON, ParamViewConfig.class);
        ViewConfig viewConfig = paramViewConfig.param;

        viewConfig.configure(apiCall.page);

        apiCall.page.onConfigurationChange(apiCall.smartWebView, viewConfig);
        return true;
    }

    public boolean snackbar(final ApiCall call) {
        Log.d(TAG, "snackbar");

        String message = call.paramObject.optString("message");
        String action = call.paramObject.optString("action");

        if (action == null || action.isEmpty())
            action = AppDeckApplication.getActivity().getString(android.R.string.ok);

        call.setResultJSON("true");

        Snackbar snackbar = Snackbar
                .make(AppDeckApplication.getActivity().findViewById(R.id.content_main), message, Snackbar.LENGTH_LONG)
                .setAction(action, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        call.sendCallbackWithResult("success", new JSONObject());
                    }
                })
                .setCallback(new Snackbar.Callback() {
                    @Override
                    public void onDismissed(Snackbar snackbar, int event) {
                        call.sendCallBackWithError("dissmissed");
                    }
                });
/*
            // Changing message text color
            snackbar.setActionTextColor(Color.RED);

            // Changing action button text color
            View sbView = snackbar.getView();
            TextView textView = (TextView) sbView.findViewById(android.support.design.R.id.snackbar_text);
            textView.setTextColor(Color.YELLOW);*/
        snackbar.show();
        return true;
    }

    public boolean loadingshow(final ApiCall call) {
        Log.d(TAG, "loadingshow");
        return true;
    }

    public boolean loadingset(final ApiCall call) {
        Log.d(TAG, "loadingset");
        return true;
    }

    public boolean loadinghide(final ApiCall call) {
        Log.d(TAG, "loadinghide");
        return true;
    }
}
