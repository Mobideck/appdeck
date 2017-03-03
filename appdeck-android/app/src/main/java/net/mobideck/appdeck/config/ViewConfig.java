
package net.mobideck.appdeck.config;

import android.util.Log;
import android.view.View;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckActivity;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;

public class ViewConfig {

    public transient static String TAG = "ViewConfig";

    @SerializedName("title")
    @Expose
    public String title;

    @SerializedName("logo")
    @Expose
    public String logo;

    @SerializedName("color")
    @Expose
    public String color;

    @SerializedName("topbar_color")
    @Expose
    public String topbarColor;

    /*@SerializedName("topbar_color_dark")
    @Expose
    public String topbarColorDark;*/

    @SerializedName("topbar_text_color")
    @Expose
    public String topbarTextColor;

    @SerializedName("actionbar_color")
    @Expose
    public String actionbarColor;

    @SerializedName("bottombar_color")
    @Expose
    public String bottombarColor;

    @SerializedName("bottombar_text_color")
    @Expose
    public String bottombarTextColor;

    @SerializedName("background_color")
    @Expose
    public List<String> backgroundColor;

    /*
    @SerializedName("control_color")
    @Expose
    public String controlColor;*/

    @SerializedName("banners")
    @Expose
    public List<MenuEntry> banners;

    @SerializedName("tabs")
    @Expose
    public List<MenuEntry> tabs;

    @SerializedName("menu")
    @Expose
    public List<MenuEntry> menu;

    @SerializedName("action_menu")
    @Expose
    public List<MenuEntry> actionMenu;

    @SerializedName("floating_button")
    @Expose
    public MenuEntry floatingButton;

    @SerializedName("urls")
    @Expose
    public List<String> urls = null;

    @SerializedName("type")
    @Expose
    public String type;

    @SerializedName("ttl")
    @Expose
    public int ttl;

    @SerializedName("popup")
    @Expose
    public String popup;

    @SerializedName("urlRegexp")
    @Expose
    public List<String> urlRegexp;

    @SerializedName("notUrlRegexp")
    @Expose
    public List<String> notUrlRegexp;

    public transient boolean isDefault = false;

    private transient Pattern mUrlRegexp[];
    private transient Pattern mNotUrlRegexp[];

    /*
    private transient static ViewConfig sDefaultConfiguration = null;

    public static ViewConfig defaultConfiguration()
    {
        if (sDefaultConfiguration == null) {
            //AppDeckActivity activity = AppDeckApplication.getActivity();
            AppDeck appDeck = AppDeckApplication.getAppDeck();
            ViewConfig config = new ViewConfig();
            config.title = "None (default config)";
            config.ttl = 600;
            config.isDefault = true;
            //noinspection ResourceType
            config.topbarColor = activity.getString(R.color.AppDeckColorTopBarBg1);
            //noinspection ResourceType
            config.topbarColorDark = activity.getString(R.color.AppDeckColorApp);
            //noinspection ResourceType
            config.actionBarColor = activity.getString(R.color.AppDeckColorApp);
            config.configure();
            sDefaultConfiguration = config;
        }
        return sDefaultConfiguration;
    }
    */

    public void configure() {
        if (urlRegexp == null) {
            mUrlRegexp = new Pattern[0];
        } else {
            mUrlRegexp = new Pattern[urlRegexp.size()];
            for (int i = 0; i < urlRegexp.size(); i++) {
                String regexp = urlRegexp.get(i).trim();
                if (regexp.isEmpty()) {
                    mUrlRegexp[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
                    continue;
                }
                try {
                    Pattern p = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
                    mUrlRegexp[i] = p;
                } catch (PatternSyntaxException e) {
                    Log.w(TAG, "Screen: "+title+": Invalid Regexp #"+i+": "+regexp);
                    //e.printStackTrace();
                    mUrlRegexp[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
                }
            }
        }
        if (notUrlRegexp == null) {
            mNotUrlRegexp = new Pattern[0];
        } else {
            mNotUrlRegexp = new Pattern[notUrlRegexp.size()];
            for (int i = 0; i < notUrlRegexp.size(); i++) {
                String regexp = notUrlRegexp.get(i).trim();
                if (regexp.isEmpty()) {
                    mNotUrlRegexp[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
                    continue;
                }
                try {
                    Pattern p = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
                    mNotUrlRegexp[i] = p;
                } catch (PatternSyntaxException e) {
                    Log.w(TAG, "Screen: "+title+": Invalid NotRegexp #"+i+": "+regexp);
                    //e.printStackTrace();
                    mNotUrlRegexp[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
                }
            }
        }
    }

    public boolean match(String absoluteURL)
    {
       for (int i = 0; i < mNotUrlRegexp.length; i++) {
            Pattern regexp = mNotUrlRegexp[i];
            Matcher m = regexp.matcher(absoluteURL);
            if (m.find())
                return false;
        }
        for (int i = 0; i < mUrlRegexp.length; i++) {
            Pattern regexp = mUrlRegexp[i];
            Matcher m = regexp.matcher(absoluteURL);
            if (m.find())
                return true;
        }
        try {
            URI uri = new URI(absoluteURL);
            String path = uri.getPath();
            String query = uri.getQuery();
            if (query != null) {
                path = path + "?" + query;
            }
            if (path != null)
            {
                for (int i = 0; i < mNotUrlRegexp.length; i++) {
                    Pattern regexp = mNotUrlRegexp[i];
                    Matcher m = regexp.matcher(path);
                    if (m.find())
                        return false;
                }
                for (int i = 0; i < mUrlRegexp.length; i++) {
                    Pattern regexp = mUrlRegexp[i];
                    Matcher m = regexp.matcher(path);
                    if (m.find())
                        return true;
                }
            }
        } catch (URISyntaxException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return false;
    }

    private void doMergeDefault(ViewConfig defaultConfig) {
        if (title == null)
            title = defaultConfig.title;
        if (logo == null)
            logo = defaultConfig.logo;
        if (color == null)
            color = defaultConfig.color;
        if (topbarColor == null)
            topbarColor = defaultConfig.topbarColor;
        if (topbarTextColor == null)
            topbarTextColor = defaultConfig.topbarTextColor;
        if (actionbarColor == null)
            actionbarColor = defaultConfig.actionbarColor;
        if (bottombarColor == null)
            bottombarColor = defaultConfig.bottombarColor;
        if (bottombarTextColor == null)
            bottombarTextColor = defaultConfig.bottombarTextColor;
        if (backgroundColor == null)
            backgroundColor = defaultConfig.backgroundColor;
        /*if (controlColor == null)
            controlColor = defaultConfig.controlColor;*/
        if (banners == null)
            banners = defaultConfig.banners;
        if (tabs == null)
            tabs = defaultConfig.tabs;
        if (menu == null)
            menu = defaultConfig.menu;
        if (actionMenu == null)
            actionMenu = defaultConfig.actionMenu;
        if (floatingButton == null)
            floatingButton = defaultConfig.floatingButton;
        if (urls == null)
            urls = defaultConfig.urls;
        if (type == null)
            type = defaultConfig.type;
        if (popup == null)
            popup = defaultConfig.popup;
        if (urlRegexp == null)
            urlRegexp = defaultConfig.urlRegexp;
        if (notUrlRegexp == null)
            notUrlRegexp = defaultConfig.notUrlRegexp;
    }

    public ViewConfig mergeDefault(ViewConfig defaultViewConfig) {
        ViewConfig newViewConfig = copy();
        newViewConfig.doMergeDefault(defaultViewConfig);
        return newViewConfig;
    }

    public ViewConfig copy() {
        ViewConfig config = new ViewConfig();
        config.title = title;
        config.logo = logo;
        config.color= color;
        config.topbarColor = topbarColor;
        config.topbarTextColor = topbarTextColor;
        config.bottombarColor = bottombarColor;
        config.bottombarTextColor = bottombarTextColor;
        config.actionbarColor = actionbarColor;
        config.backgroundColor = backgroundColor;
        //config.controlColor = controlColor;
        config.banners = banners;
        config.tabs = tabs;
        config.menu = menu;
        config.actionMenu = actionMenu;
        config.floatingButton = floatingButton;
        config.urls = urls;
        config.type = type;
        config.ttl = ttl;
        config.popup = popup;
        config.urlRegexp = urlRegexp;
        config.notUrlRegexp = notUrlRegexp;
        config.mUrlRegexp = mUrlRegexp;
        config.mNotUrlRegexp = mNotUrlRegexp;
        config.isDefault = isDefault;
        return config;
    }

    public String getDescription() {
        String r = 	"Title: "+ title + "\n" +
                "logo: "+ logo + "\n" +
                "type: "+ type + "\n" +
                "isPopUp: "+ popup + "\n" +
                "urlRegexp: ";
        for (int i = 0; i < urlRegexp.size(); i++) {
            r = r + " '" + urlRegexp.get(i) + "'";
        }

        r = r + "\nnotUrlRegexp: ";

        for (int i = 0; i < notUrlRegexp.size(); i++) {
            r = r + " '" + notUrlRegexp.get(i) + "'";
        }

        return r;
    }
}
