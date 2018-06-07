package net.mobideck.appdeck.core.plugins;

import android.util.Log;

import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.core.Navigation;

import java.util.ArrayList;

public class NavigationPlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("pageroot");
        commands.add("pagerootreload");
        commands.add("pagepush");
        commands.add("popup");
        commands.add("pagepop");
        commands.add("pagepoproot");
        commands.add("loadextern");
        commands.add("previousnext");
        commands.add("popover");
        return commands;
    }

    public boolean pageroot(final ApiCall call) {
        Log.d(TAG, "pageroot");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        AppDeckApplication.getAppDeck().navigation.loadRootURL(absoluteURL);
        return true;
    }

    public boolean pagerootreload(final ApiCall call) {
        Log.d(TAG, "pagerootreload");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        AppDeckApplication.getAppDeck().navigation.loadRootURL(absoluteURL);

        AppDeckApplication.getActivity().menuManager.reload();

        return true;
    }

    public boolean pagepush(final ApiCall call) {
        Log.d(TAG, "pagepush");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        AppDeckApplication.getAppDeck().navigation.loadURL(absoluteURL);
        return true;
    }

    public boolean popup(final ApiCall call) {
        Log.d(TAG, "popup");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        AppDeckApplication.getAppDeck().navigation.popupURL(absoluteURL);
        return true;
    }

    public boolean pagepop(final ApiCall call) {
        Log.d(TAG, "pagepop");
        //net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        //String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        AppDeckApplication.getAppDeck().navigation.pop();
        return true;
    }

    public boolean pagepoproot(final ApiCall call) {
        Log.d(TAG, "pagepoproot");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        AppDeckApplication.getAppDeck().navigation.loadRootURL(absoluteURL);
        return true;
    }

    public boolean loadextern(final ApiCall call) {
        Log.d(TAG, "loadextern");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        AppDeckApplication.getAppDeck().navigation.loadExternalURL(absoluteURL, true);
        return true;
    }

    public boolean previousnext(final ApiCall call) {
        Log.d(TAG, "previousnext");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        //String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        //AppDeckApplication.getAppDeck().navigation.loadExternalURL(absoluteURL, true);

        String previousPageUrl = call.paramObject.optString("previous_page", null);
        if (previousPageUrl != null && previousPageUrl.equalsIgnoreCase("false"))
            previousPageUrl = null;
        if (previousPageUrl != null && !previousPageUrl.isEmpty())
            previousPageUrl = AppDeckApplication.getAppDeck().appConfig.resolveURL(previousPageUrl);
        String nextPageUrl = call.paramObject.optString("next_page", null);
        if (nextPageUrl != null && nextPageUrl.equalsIgnoreCase("false"))
            nextPageUrl = null;
        if (nextPageUrl != null && !nextPageUrl.isEmpty())
            nextPageUrl = AppDeckApplication.getAppDeck().appConfig.resolveURL(nextPageUrl);
        apiCall.page.setPreviousNext(previousPageUrl, nextPageUrl);

        return true;
    }

    public boolean popover(final ApiCall call) {
        Log.i("popover* ", "popover");
        //net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        //String absoluteURL = apiCall.smartWebView.resolve(call.inputObject.optString("param"));
        //AppDeckApplication.getAppDeck().navigation.popPage();

        String url = call.paramObject.optString("url");

        if (url != null && !url.isEmpty())
        {
            Navigation navigation = AppDeckApplication.getAppDeck().navigation;
            navigation.loadRootURL(url);

        }

        return true;
    }

}
