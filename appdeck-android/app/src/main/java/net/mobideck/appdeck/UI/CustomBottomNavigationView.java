package net.mobideck.appdeck.UI;

import android.content.Context;
import android.content.res.ColorStateList;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.config.AppConfig;
import net.mobideck.appdeck.config.MenuEntry;
import net.mobideck.appdeck.core.AppDeckMenuItem;
import net.mobideck.appdeck.util.Utils;

import java.util.ArrayList;
import java.util.List;


public class CustomBottomNavigationView extends BottomNavigationView {

    public static String TAG = "CustomBottomNavigation";

    private List<AppDeckMenuItem> mMenuEntries;

    public CustomBottomNavigationView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        preConfigure();
    }

    public CustomBottomNavigationView(Context context, AttributeSet attrs) {
        super(context, attrs);
        preConfigure();
    }

    public CustomBottomNavigationView(Context context) {
        super(context);
        preConfigure();
    }

    public void preConfigure() {
        setOnNavigationItemSelectedListener(
                new BottomNavigationView.OnNavigationItemSelectedListener() {
                    @Override
                    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                        for (int k = 0; k < mMenuEntries.size(); k++) {
                            AppDeckMenuItem appDeckMenuItem = mMenuEntries.get(k);
                            if (appDeckMenuItem.getMenuItem() == item) {
                                AppDeckApplication.getAppDeck().navigation.loadRootURL(appDeckMenuItem.getUrl());
                                return true;
                            }
                        }
                        Log.e(TAG, "Clicked AppDeckMenuItem does not belong to this bottomNavigationView");
                        return false;
                    }
                });
    }

    public void configure(AppConfig appConfig) {

        AppDeck appDeck = AppDeckApplication.getAppDeck();

        Menu bottomMenu = getMenu();

        // remove all previous menu item
        for (int k = 0; k < bottomMenu.size(); k++) {
            bottomMenu.removeItem(0);
        }

        if (appConfig.bottomMenu == null || appConfig.bottomMenu.size() == 0) {
            setVisibility(View.GONE);
            return;
        }
        setVisibility(View.VISIBLE);

        mMenuEntries = new ArrayList<>();

        if (appConfig.bottomMenu != null) {
            for (int i = 0; i < appConfig.bottomMenu.size(); i++) {
                MenuEntry menuEntry = appConfig.bottomMenu.get(i);
                MenuItem menuItem = bottomMenu.add(menuEntry.title != null ? menuEntry.title : "");
                AppDeckMenuItem appDeckMenuItem = new AppDeckMenuItem(menuItem, AppDeckApplication.getActivity());
                appDeckMenuItem.configure(menuEntry.title, menuEntry.icon, menuEntry.url, menuEntry.badge, menuEntry.disabled, null);
                mMenuEntries.add(appDeckMenuItem);
                //menuEntry.configureMenuItem(menuItem, appDeck.deviceInfo.bottomNavigationIconSize);
            }
        }

        setBackgroundColor(Utils.parseColor(appConfig.appBottombarColor));

        int[][] states = new int[][] {
                new int[] { android.R.attr.state_enabled}, // enabled
                new int[] {-android.R.attr.state_enabled}, // disabled
                new int[] {-android.R.attr.state_checked}, // unchecked
                new int[] { android.R.attr.state_pressed}  // pressed
        };

        int[] colors = new int[] {
                Utils.parseColor(appDeck.appConfig.appBottombarTextColor),
                Utils.parseColor(appDeck.appConfig.appBottombarTextColor, 0.50f),
                Utils.parseColor(appDeck.appConfig.appBottombarTextColor, 0.50f),
                Utils.parseColor(appDeck.appConfig.appBottombarTextColor)
        };

        setItemTextColor(new ColorStateList(states, colors));
    }

}
