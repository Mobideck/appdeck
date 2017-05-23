
package net.mobideck.appdeck.config;

import android.graphics.drawable.Drawable;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckActivity;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;
import net.mobideck.appdeck.util.Utils;

public class AppConfig {

    // Application

    @SerializedName("title")
    @Expose
    public String title;

    @SerializedName("base_url")
    @Expose
    public String baseUrl;

    @SerializedName("logo")
    @Expose
    public String logo;

    @SerializedName("icon")
    @Expose
    public String icon;

    @SerializedName("icon_android")
    @Expose
    public String iconAndroid;

    @SerializedName("icon_notification")
    @Expose
    public String iconNotification;

    @SerializedName("version")
    @Expose
    public Integer version;

    @SerializedName("api_key")
    @Expose
    public String apiKey;

    // Menu

    @SerializedName("bootstrap")
    @Expose
    public MenuEntry bootstrap;

    @SerializedName("leftmenu")
    @Expose
    public MenuEntry leftMenu;

    @SerializedName("rightmenu")
    @Expose
    public MenuEntry rightMenu;

    @SerializedName("bottom_menu")
    @Expose
    public List<MenuEntry> bottomMenu;

    // Colors

    @SerializedName("icon_theme")
    @Expose
    public String iconTheme;

    @SerializedName("app_color")
    @Expose
    public String appColor;
    //public transient Drawable appColorDrawable;

    @SerializedName("app_topbar_color")
    @Expose
    public String appTopbarColor;
    //public transient Drawable appTopbarColorDrawable;

    @SerializedName("app_topbar_text_color")
    @Expose
    public String appTopbarTextColor;
    //public transient Drawable appTopbarTextColorDrawable;

    @SerializedName("app_actionbar_color")
    @Expose
    public String appActionbarColor;

    @SerializedName("app_bottombar_color")
    @Expose
    public String appBottombarColor;

    @SerializedName("app_bottombar_text_color")
    @Expose
    public String appBottombarTextColor;

    // Other colors

    @SerializedName("app_background_color")
    @Expose
    public List<String> appBackgroundColor;
    //public transient Drawable appBackgroundColorDrawable;

    @SerializedName("leftmenu_background_color")
    @Expose
    public List<String> leftMenuBackgroundColor;
    //public transient Drawable leftMenuBackgroundColorDrawable;

    @SerializedName("rightmenu_background_color")
    @Expose
    public List<String> rightMenuBackgroundColor;
    //public transient Drawable rightMenuBackgroundColorDrawable;

    /*@SerializedName("control_color")
    @Expose
    public String controlColor;
    //public transient Drawable controlColorDrawable;*/

    @SerializedName("image_network_error_background_color")
    @Expose
    public String imageNetworkErrorBackgroundColor;
    //public transient Drawable imageNetworkErrorBackgroundColorDrawable;

    // Icons

    @SerializedName("icon_action")
    @Expose
    public String iconAction;

    @SerializedName("icon_ok")
    @Expose
    public String iconOk;

    @SerializedName("icon_cancel")
    @Expose
    public String iconCancel;

    @SerializedName("icon_close")
    @Expose
    public String iconClose;

    @SerializedName("icon_config")
    @Expose
    public String iconConfig;

    @SerializedName("icon_info")
    @Expose
    public String iconInfo;

    @SerializedName("icon_menu")
    @Expose
    public String iconMenu;

    @SerializedName("icon_next")
    @Expose
    public String iconNext;

    @SerializedName("icon_previous")
    @Expose
    public String iconPrevious;

    @SerializedName("icon_refresh")
    @Expose
    public String iconRefresh;

    @SerializedName("icon_search")
    @Expose
    public String iconSearch;

    @SerializedName("icon_up")
    @Expose
    public String iconUp;

    @SerializedName("icon_down")
    @Expose
    public String iconDown;

    @SerializedName("icon_user")
    @Expose
    public String iconUser;

    // Android icon

    @SerializedName("icon_action_android")
    @Expose
    public String iconActionAndroid;

    @SerializedName("icon_ok_android")
    @Expose
    public String iconOkAndroid;

    @SerializedName("icon_cancel_android")
    @Expose
    public String iconCancelAndroid;

    @SerializedName("icon_close_android")
    @Expose
    public String iconCloseAndroid;

    @SerializedName("icon_config_android")
    @Expose
    public String iconConfigAndroid;

    @SerializedName("icon_info_android")
    @Expose
    public String iconInfoAndroid;

    @SerializedName("icon_menu_android")
    @Expose
    public String iconMenuAndroid;

    @SerializedName("icon_next_android")
    @Expose
    public String iconNextAndroid;

    @SerializedName("icon_previous_android")
    @Expose
    public String iconPreviousAndroid;

    @SerializedName("icon_refresh_android")
    @Expose
    public String iconRefreshAndroid;

    @SerializedName("icon_search_android")
    @Expose
    public String iconSearchAndroid;

    @SerializedName("icon_up_android")
    @Expose
    public String iconUpAndroid;

    @SerializedName("icon_down_android")
    @Expose
    public String iconDownAndroid;

    @SerializedName("icon_user_android")
    @Expose
    public String iconUserAndroid;

    // Images

    @SerializedName("image_loader")
    @Expose
    public String imageLoader;

    @SerializedName("image_pull_arrow")
    @Expose
    public String imagePullArrow;

    @SerializedName("image_network_error_url")
    @Expose
    public String imageNetworkErrorUrl;

    // Cache

    @SerializedName("cache")
    @Expose
    public List<String> cache;
    public transient Pattern cacheRegexp[];

    @SerializedName("no_cache")
    @Expose
    public boolean noCache;

    // Embed

    @SerializedName("embed")
    @Expose
    public List<String> embed;

    @SerializedName("embed_url")
    @Expose
    public List<String> embedUrl;

    @SerializedName("embedRuntimeUrl")
    @Expose
    public List<String> embedRuntimeUrl;

    // Services

    @SerializedName("ga")
    @Expose
    public String ga;

    @SerializedName("flurry_ios_key")
    @Expose
    public String flurryIosKey;

    @SerializedName("flurry_android_key")
    @Expose
    public String flurryAndroidKey;

    @SerializedName("facebook_ios_app_id")
    @Expose
    public String facebookIosAppId;

    @SerializedName("facebook_android_app_id")
    @Expose
    public String facebookAndroidAppId;

    @SerializedName("fabric_api_key")
    @Expose
    public String fabricApiKey;

    @SerializedName("fabric_build_secret")
    @Expose
    public String fabricBuildSecret;

    @SerializedName("twitter_consumer_key")
    @Expose
    public String twitterConsumerKey;

    @SerializedName("twitter_consumer_secret")
    @Expose
    public String twitterConsumerSecret;

    @SerializedName("presage_key")
    @Expose
    public String presage_key;

    // Prefetch

    @SerializedName("prefetch_url")
    @Expose
    public String prefetchUrl;

    @SerializedName("prefetch_rss")
    @Expose
    public String prefetchRss;

    @SerializedName("prefetch_ttl")
    @Expose
    public int prefetchTtl;

    // Push

    @SerializedName("push_rss")
    @Expose
    public String pushRss;

    @SerializedName("push_register")
    @Expose
    public String pushRegister;

    // Advanced

    @SerializedName("enable_debug")
    @Expose
    public Boolean enableDebug;

    @SerializedName("other_domain")
    @Expose
    public List<String> otherDomain;
    public transient Pattern otherDomainRegexp[];

    @SerializedName("adBlock")
    @Expose
    public String adBlock;

    @SerializedName("extra_resources_ios")
    @Expose
    public String extraResourcesIos;

    // Screens

    @SerializedName("screens")
    @Expose
    public List<ViewConfig> screens;

    private transient URI mBaseURI;

    public void configure(AppDeck appDeck) {

        // Application

        try {
            mBaseURI = new URI(baseUrl);
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }

        // Menu

        if (bootstrap == null)
            bootstrap = new MenuEntry();

        if (bootstrap.url == null)
            bootstrap.url = mBaseURI.toString();

        if (leftMenu != null) {
            leftMenu.url = resolveURL(leftMenu.url, null);
            if (leftMenu.width <= 0)
                leftMenu.width = 280;
            if (leftMenu.url == null)
                leftMenu = null;
        }

        if (rightMenu != null) {
            rightMenu.url = resolveURL(rightMenu.url, null);
            if (rightMenu.width <= 0)
                rightMenu.width = 280;
            if (rightMenu.url == null)
                rightMenu = null;
        }

        // Colors
        /*
        appColorDrawable = readColor(appColor, "#000000");
        appTopbarColorDrawable = readColor(appTopbarColor, "#0A728F", "#03405F");
        appTopbarTextColorDrawable = readColor(appTopbarTextColor, "#FFFFFF");
        appBackgroundColorDrawable = readColor(appBackgroundColor, "#FFFFFF", "#EEEEEE");
        leftMenuBackgroundColorDrawable = readColor(leftMenuBackgroundColor, "#FFFFFF", "#EEEEEE");
        rightMenuBackgroundColorDrawable = readColor(rightMenuBackgroundColor, "#FFFFFF", "#EEEEEE");
        controlColorDrawable = readColor(controlColor, "#000000");
        imageNetworkErrorBackgroundColorDrawable = readColor(imageNetworkErrorBackgroundColor, "#FFFFFF");
        */

        /*
        color;
        topbarColor; ok
        topbarColorDark (status);
        topbarTextColor; ok
        controlColor;
        backgroundColor;
        bottombarColor
        */

        // init default colors from activity if needed
        AppDeckActivity activity = AppDeckApplication.getActivity();
        if (appColor == null) {
            //noinspection ResourceType
            appColor = activity.getString(R.color.AppDeckColorApp);
        }
        if (appTopbarColor == null) {
            //noinspection ResourceType
            appColor = activity.getString(R.color.AppDeckColorTopBar);
        }
        if (appTopbarTextColor == null) {
            //noinspection ResourceType
            appTopbarTextColor = activity.getString(R.color.AppDeckColorTopBarText);
        }
        if (appActionbarColor == null) {
            //noinspection ResourceType
            appActionbarColor = activity.getString(R.color.AppDeckColorActionBar);
        }
        if (appBottombarColor == null) {
            //noinspection ResourceType
            appBottombarColor = activity.getString(R.color.AppDeckColorBottomBar);
        }
        if (appBottombarTextColor == null) {
            //noinspection ResourceType
            appBottombarTextColor = activity.getString(R.color.AppDeckColorBottomBarText);
        }
        if (appBackgroundColor == null || appBackgroundColor.size() == 0) {
            appBackgroundColor = new ArrayList<>();
            appBackgroundColor.add("#FFFFFF");
            appBackgroundColor.add("#FFFFFF");
        }
        if (appBackgroundColor.size() == 1)
            appBackgroundColor.add(appBackgroundColor.get(0));
        if (leftMenuBackgroundColor == null || leftMenuBackgroundColor.size() == 0) {
            leftMenuBackgroundColor = new ArrayList<>();
            leftMenuBackgroundColor.add("#FFFFFF");
            leftMenuBackgroundColor.add("#FFFFFF");
        }
        if (leftMenuBackgroundColor.size() == 1)
            leftMenuBackgroundColor.add(leftMenuBackgroundColor.get(0));
        if (rightMenuBackgroundColor == null || rightMenuBackgroundColor.size() == 0) {
            rightMenuBackgroundColor = new ArrayList<>();
            rightMenuBackgroundColor.add("#FFFFFF");
            rightMenuBackgroundColor.add("#FFFFFF");
        }
        if (rightMenuBackgroundColor.size() == 1)
            rightMenuBackgroundColor.add(rightMenuBackgroundColor.get(0));

        // Icons

        if (iconTheme == null)
            iconTheme = "light";
        if (!iconTheme.equalsIgnoreCase("light") && !iconTheme.equalsIgnoreCase("dark"))
            iconTheme = "light";
        String icon_theme_suffix = "";
        if (iconTheme.equalsIgnoreCase("dark"))
            icon_theme_suffix = "_dark";

        // set default icon if needed
        iconAction = resolveURL(iconAction, "http://appdata.static.appdeck.mobi/res/android/icons/action"+icon_theme_suffix+".png");
        iconOk = resolveURL(iconOk, "http://appdata.static.appdeck.mobi/res/android/icons/ok"+icon_theme_suffix+".png");
        iconCancel = resolveURL(iconCancel, "http://appdata.static.appdeck.mobi/res/android/icons/cancel"+icon_theme_suffix+".png");
        iconClose = resolveURL(iconClose, "http://appdata.static.appdeck.mobi/res/android/icons/close"+icon_theme_suffix+".png");
        iconConfig = resolveURL(iconConfig, "http://appdata.static.appdeck.mobi/res/android/icons/config"+icon_theme_suffix+".png");
        iconInfo = resolveURL(iconInfo, "http://appdata.static.appdeck.mobi/res/android/icons/info"+icon_theme_suffix+".png");
        iconMenu = resolveURL(iconMenu, "http://appdata.static.appdeck.mobi/res/android/icons/menu"+icon_theme_suffix+".png");
        iconNext = resolveURL(iconNext, "http://appdata.static.appdeck.mobi/res/android/icons/next"+icon_theme_suffix+".png");
        iconPrevious = resolveURL(iconPrevious, "http://appdata.static.appdeck.mobi/res/android/icons/previous"+icon_theme_suffix+".png");
        iconRefresh = resolveURL(iconRefresh, "http://appdata.static.appdeck.mobi/res/android/icons/refresh"+icon_theme_suffix+".png");
        iconSearch = resolveURL(iconSearch, "http://appdata.static.appdeck.mobi/res/android/icons/search"+icon_theme_suffix+".png");
        iconUp = resolveURL(iconUp, "http://appdata.static.appdeck.mobi/res/android/icons/up"+icon_theme_suffix+".png");
        iconDown = resolveURL(iconDown, "http://appdata.static.appdeck.mobi/res/android/icons/down"+icon_theme_suffix+".png");
        iconUser = resolveURL(iconUser, "http://appdata.static.appdeck.mobi/res/android/icons/user"+icon_theme_suffix+".png");

        // use Android icon if available
        if (iconActionAndroid != null)
            iconAction = iconActionAndroid;
        if (iconOkAndroid != null)
            iconOk = iconOkAndroid;
        if (iconCancelAndroid != null)
            iconCancel = iconCancelAndroid;
        if (iconCloseAndroid != null)
            iconClose = iconCloseAndroid;
        if (iconConfigAndroid != null)
            iconConfig = iconConfigAndroid;
        if (iconInfoAndroid != null)
            iconInfo = iconInfoAndroid;
        if (iconMenuAndroid != null)
            iconMenu = iconMenuAndroid;
        if (iconNextAndroid != null)
            iconNext = iconNextAndroid;
        if (iconPreviousAndroid != null)
            iconPrevious = iconPreviousAndroid;
        if (iconRefreshAndroid != null)
            iconRefresh = iconRefreshAndroid;
        if (iconSearchAndroid != null)
            iconSearch = iconSearchAndroid;
        if (iconUpAndroid != null)
            iconUp = iconUpAndroid;
        if (iconDownAndroid != null)
            iconDown = iconDownAndroid;
        if (iconUserAndroid != null)
            iconUser = iconUserAndroid;

        // Images

        imageLoader = resolveURL(imageLoader, "http://appdata.static.appdeck.mobi/res/android/images/loader"+icon_theme_suffix+".png");
        imagePullArrow = resolveURL(imagePullArrow, "http://appdata.static.appdeck.mobi/res/android/images/pull_arrow"+icon_theme_suffix+".png");
        imageNetworkErrorUrl = resolveURL(imageNetworkErrorUrl, "http://appdata.static.appdeck.mobi/res/android/images/network_error.png");

        // Cache

        cacheRegexp = Utils.initRegexp(cache);

        // Embed

        // Service

        // Prefetch

        prefetchUrl = resolveURL(prefetchUrl, String.format("http://prefetch.appdeck.mobi/%s_android_%s.7z", apiKey, (appDeck.deviceInfo.isTablet ? "_tablet" : "_phone")));
        if (prefetchTtl == 0)
            prefetchTtl = 600;

        // Push

        pushRegister = resolveURL(pushRegister, "http://push.appdeck.mobi/register");

        // Advanced

        otherDomainRegexp = Utils.initRegexp(otherDomain);

        // Screens

        if (screens == null)
            screens = new ArrayList<>();
        for (int i = 0; i < screens.size(); i++) {
            ViewConfig screen = screens.get(i);
            screen.configure(null);
        }

    }

    public ViewConfig getViewConfig(String url) {
        for (int k = 0; k < screens.size(); k++) {
            ViewConfig viewConfig = screens.get(k);
            if (viewConfig.match(url))
                return viewConfig;
        }
        return AppDeckApplication.getAppDeck().getDefaultConfiguration();
    }

    public String resolveURL(String relativeURL, String defaultValue) {
        String url = resolveURL(relativeURL);
        if (url == null)
            return defaultValue;
        return url;
    }

    public String resolveURL(String relativeURL) {
        if (relativeURL == null)
            return null;
        try {
            URI uri = new URI(relativeURL);
            return mBaseURI.resolve(uri).toString();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Drawable readColor(String color, String defaultColor) {
        List<String> colors = new ArrayList<>();
        colors.add(color != null ? color : defaultColor);
        return Utils.getColorDrawable(colors);
    }

    private Drawable readColor(List<String> colors, String defaultColor1, String defaultColor2) {
        if (colors == null || colors.size() == 0) {
            colors = new ArrayList<>();
            colors.add(defaultColor1);
            colors.add(defaultColor2);
        }
        return Utils.getColorDrawable(colors);
    }

    public URI getUrl() { return mBaseURI; }

    public ViewConfig getDefaultConfiguration()
    {
        ViewConfig config = new ViewConfig();
        config.title = this.title;
        config.ttl = 600;
        config.isDefault = true;
        // set color config from app config
        config.color = appColor;
        config.topbarColor = appTopbarColor;
        config.topbarTextColor = appTopbarTextColor;
        config.actionbarColor = appActionbarColor;
        config.bottombarColor = appBottombarColor;
        config.bottombarTextColor = appBottombarTextColor;
        config.backgroundColor = appBackgroundColor;
        config.configure(null);
        return config;
    }
}
