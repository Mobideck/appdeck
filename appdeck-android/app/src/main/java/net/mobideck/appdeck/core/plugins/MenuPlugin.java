package net.mobideck.appdeck.core.plugins;

import android.util.Log;

import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.core.MenuManager;
import net.mobideck.appdeck.core.AppDeckMenuItem;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

public class MenuPlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("slidemenu");
        commands.add("menu");
        return commands;
    }

    public boolean slidemenu(final ApiCall call) {
        Log.d(TAG, "slidemenu");

        Log.i("navigation", "appdeck "+call.command.toString());

        String command = call.paramObject.optString("command", "none");
        String position = call.paramObject.optString("position", "none");

        MenuManager menuManager = AppDeckApplication.getActivity().menuManager;

        if (command.equalsIgnoreCase("toggle"))
        {
            if (position.equalsIgnoreCase("left"))
                menuManager.openLeftMenu();
            if (position.equalsIgnoreCase("right"))
                menuManager.openRightMenu();
            if (position.equalsIgnoreCase("main"))
                menuManager.toggleMenu();
        } else if (command.equalsIgnoreCase("open"))
        {
            if (position.equalsIgnoreCase("left"))
                menuManager.openLeftMenu();
            if (position.equalsIgnoreCase("right"))
                menuManager.openRightMenu();
            if (position.equalsIgnoreCase("main"))
                menuManager.closeMenu();
            Log.i("navigation", "1close");
        } else {
            Log.i("navigation", "2close");

            menuManager.closeMenu();
        }
        return true;
    }

    public boolean menu(ApiCall call) {
        Log.d(TAG, "menu");

        String command = call.paramObject.optString("command", "none");
        Log.i("navigation", command);

        /*
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;

        // menu entries
        JSONArray entries = call.inputObject.optJSONArray("param");
        if (entries != null && entries.length() > 0)
        {
            //PageMenuItem defaultMenu[] = apiCall.page.getViewConfig().getDefaultPageMenuItems(uri, this);
            AppDeckMenuItem menuItems[] = new AppDeckMenuItem[entries.length()];

            for (int i = 0; i < entries.length(); i++)
            {
                JSONObject entry = entries.optJSONObject(i);
                String title = entry.optString("title");
                String content = entry.optString("content");
                String icon = entry.optString("icon");
                String type = entry.optString("type");
                String badge = entry.optString("badge");

                //UIImage *iconImage = self.child.loader.conf.icon_action.image;
                AppDeckMenuItem item = new AppDeckMenuItem(title, icon, type, content, badge, apiCall.page);
                menuItems[i] = item;
            }

            apiCall.page.getConfig().setTopMenu(menuItems);
        }*/
        return true;
    }

}
