package net.mobideck.appdeck;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.PorterDuff;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.design.widget.TabLayout;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v4.view.animation.FastOutSlowInInterpolator;
import android.support.v7.app.ActionBar;
import android.util.Log;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.afollestad.materialdialogs.MaterialDialog;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;
import com.crashlytics.android.Crashlytics;
import com.facebook.CallbackManager;
import com.mobideck.appdeck.plugin.PluginManager;
import com.twitter.sdk.android.core.identity.TwitterAuthClient;

import net.mobideck.appdeck.WebView.SmartWebView;
import net.mobideck.appdeck.config.AppConfig;
import net.mobideck.appdeck.config.MenuEntry;
import net.mobideck.appdeck.config.ViewConfig;
import net.mobideck.appdeck.core.ApiCall;
import net.mobideck.appdeck.core.AppDeckBottomMenuItem;
import net.mobideck.appdeck.core.AppDeckView;
import net.mobideck.appdeck.core.Banner;
import net.mobideck.appdeck.core.DebugLog;
import net.mobideck.appdeck.core.MenuManager;
import net.mobideck.appdeck.core.Navigation;
import net.mobideck.appdeck.core.Page;
import net.mobideck.appdeck.core.AppDeckMenuItem;
import net.mobideck.appdeck.core.PageAnimation;
import net.mobideck.appdeck.core.ViewState;
import net.mobideck.appdeck.util.Utils;
import net.mobideck.appdeck.util.ViewTools;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;

import java.util.ArrayList;

import hotchemi.android.rate.AppRate;
import hotchemi.android.rate.OnClickButtonListener;

import static net.mobideck.appdeck.AppDeckApplication.setAppDeck;

@EActivity(R.layout.activity_main)
public class AppDeckActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    public static String TAG = "AppDeckActivity";

    @ViewById(R.id.toolbar)
    Toolbar mToolbar;

    @ViewById(R.id.fab)
    FloatingActionButton mFloatingActionButton;

    @ViewById(R.id.drawer_layout)
    DrawerLayout mDrawerLayout;

    @ViewById(R.id.collapsing_toolbar)
    CollapsingToolbarLayout mCollapsingToolbarLayout;

    @ViewById(R.id.coordinator)
    CoordinatorLayout mCoordinatorLayout;

    @ViewById(R.id.appbar)
    AppBarLayout mAppBarLayout;

    @ViewById(R.id.actionmenu)
    Toolbar mActionMenu;

    @ViewById(R.id.content_main)
    FrameLayout mViewContainer;

    @ViewById(R.id.tabs)
    TabLayout mTabLayout;

    @ViewById(R.id.bottom_navigation)
    BottomNavigationView mBottomNavigationView;

    @ViewById(R.id.drawer_layout)
    public View nonVideoLayout;

    @ViewById(R.id.videoLayout)
    public ViewGroup videoLayout;

    @ViewById(R.id.left_drawer)
    FrameLayout mDrawerLeftMenu;

    @ViewById(R.id.right_drawer)
    FrameLayout mDrawerRightMenu;

    @ViewById(R.id.adsBannerContainer)
    View mAdsBannerContainer;

    @ViewById(R.id.bottom_hook)
    View mBottomHook;

    @ViewById(R.id.bannerContainer)
    ViewPager mBannerContainer;
    private Banner mBannerManager;

    @ViewById(R.id.loading)
    FrameLayout mLoading;

    private ActionBar mActionBar;

    private SmartWebView mLeftMenuWebView;
    private SmartWebView mRightMenuWebView;

    private ActionBarDrawerToggle mActionBarDrawerToggle;

    private ImageView mTopBarLogoImageView;

    private Drawable mUpArrow;
    private Drawable mCloseArrow;

    public boolean willShowActivity = false;
    public SmartWebView smartWebViewRegiteredForActivityResult = null;

    public MenuManager menuManager;

    private Page mCurrentPage;

    private AppDeckMenuItem[] mTopMenuItems;
    private AppDeckMenuItem[] mActionMenuItems;
    private AppDeckBottomMenuItem[] mBottomMenuItems;

    private ViewConfig mCurrentViewConfig;


    // services
    Crashlytics crashlytics;
    CallbackManager callbackManager;
    TwitterAuthClient twitterAuthClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        crashlytics = new Crashlytics.Builder().disabled(BuildConfig.DEBUG).build();
        super.onCreate(savedInstanceState);
    }

    @AfterViews
    protected void init() {

        AppDeckApplication.setActivity(this);
        setAppDeck(new AppDeck(this));

        // global configuration
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
        {
            boolean shouldEnableDebug = false;
            if (AppDeckApplication.getAppDeck().deviceInfo.isAppDeckTestApp)
                shouldEnableDebug = true;
            if (0 != (AppDeckApplication.getContext().getApplicationInfo().flags &= ApplicationInfo.FLAG_DEBUGGABLE))
                shouldEnableDebug = true;
            if (shouldEnableDebug)
            {
                WebView.setWebContentsDebuggingEnabled(true);
            }
        }
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            WebView.enableSlowWholeDocumentDraw();
        }

        // Show a dialog if meets conditions
        AppRate.with(this)
                .setInstallDays(10) // default 10, 0 means install day.
                .setLaunchTimes(10) // default 10
                .setRemindInterval(1) // default 1
                .setShowLaterButton(true) // default true
                //.setDebug(true) // default false
                .setOnClickButtonListener(new OnClickButtonListener() { // callback listener.
                    @Override
                    public void onClickButton(int which) {
                        Log.d("AppRater Click", Integer.toString(which));
                    }
                })
                .monitor();
        AppRate.showRateDialogIfMeetsConditions(this);

        setSupportActionBar(mToolbar);

        mActionBar = getSupportActionBar();

        mToolbar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO: implement scrollToTop
                Log.d(TAG, "Scroll To Top");
            }
        });

        // make sure toolbar is above other view
        mCoordinatorLayout.bringChildToFront(mAppBarLayout);

        // Always hide title
        mCollapsingToolbarLayout.setTitle(" ");

        mFloatingActionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        mActionBarDrawerToggle = new ActionBarDrawerToggle(
                this, mDrawerLayout, mToolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close) {

            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {
                super.onDrawerSlide(drawerView, slideOffset);
            }

            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                if (mLeftMenuWebView != null && drawerView == mDrawerLeftMenu)
                    mLeftMenuWebView.sendJsEvent("disappear", "null");
                if (mRightMenuWebView != null && drawerView == mDrawerRightMenu)
                    mRightMenuWebView.sendJsEvent("disappear", "null");
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                if (mLeftMenuWebView != null && drawerView == mDrawerLeftMenu)
                    mLeftMenuWebView.sendJsEvent("appear", "null");
                if (mRightMenuWebView != null && drawerView == mDrawerRightMenu)
                    mRightMenuWebView.sendJsEvent("appear", "null");
            }
        };
        mDrawerLayout.addDrawerListener(mActionBarDrawerToggle);
        mActionBarDrawerToggle.syncState();

        // used only when popup close button is showed
        // => mActionBarDrawerToggle.setDrawerIndicatorEnabled(false);
        mActionBarDrawerToggle.setToolbarNavigationClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (menuManager.isMenuOpen())
                    menuManager.closeMenu();
                else if (AppDeckApplication.getAppDeck().navigation.getStackSize() > 1)
                    AppDeckApplication.getAppDeck().navigation.pop();
                else
                    menuManager.toggleMenu();
            }
        });

        mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));
        mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));

        mUpArrow = ContextCompat.getDrawable(this, R.drawable.ic_arrow_back_white_24dp);
        //mUpArrow = ResourcesCompat.getDrawable(getResources(), R.drawable.ic_arrow_back_white_24dp, null);
        mUpArrow.setColorFilter(getResources().getColor(R.color.AppDeckColorTopBarText), PorterDuff.Mode.SRC_ATOP);
        mActionBarDrawerToggle.setHomeAsUpIndicator(mUpArrow);

        mCloseArrow = ContextCompat.getDrawable(this, R.drawable.ic_close_white_24dp);
        mCloseArrow.setColorFilter(getResources().getColor(R.color.AppDeckColorTopBarText), PorterDuff.Mode.SRC_ATOP);

        /*mTopBarLogoImageView = new ImageView(AppDeckActivity.this);
        ActionBar.LayoutParams layout = new ActionBar.LayoutParams(ActionBar.LayoutParams.MATCH_PARENT, ActionBar.LayoutParams.MATCH_PARENT);
        mActionBar.setCustomView(mTopBarLogoImageView, layout);
        mActionBar.setDisplayShowCustomEnabled(false);*/

        mActionBar.setDisplayHomeAsUpEnabled(true); // show icon on the left of logo
        mActionBar.setDisplayShowHomeEnabled(true); // show logo
        mActionBar.setHomeButtonEnabled(true); // ???

        // Tabs
        mTabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                int index = tab.getPosition();
                if (mCurrentViewConfig.tabs == null || mCurrentViewConfig.tabs.size() < index + 1)
                    return;
                //MenuEntry tabMenuEntry = mCurrentViewConfig.tabs.get(index);
                //AppDeckApplication.getAppDeck().navigation.loadURL(tabMenuEntry);
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {

            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {

            }
        });

        // Action Menu
        Menu actionMenu = mActionMenu.getMenu();
        getMenuInflater().inflate(R.menu.menu, actionMenu);
        mActionMenuItems = new AppDeckMenuItem[5];
        mActionMenuItems[0] = new AppDeckMenuItem(actionMenu.findItem(R.id.menuItem1), this);
        mActionMenuItems[1] = new AppDeckMenuItem(actionMenu.findItem(R.id.menuItem2), this);
        mActionMenuItems[2] = new AppDeckMenuItem(actionMenu.findItem(R.id.menuItem3), this);
        mActionMenuItems[3] = new AppDeckMenuItem(actionMenu.findItem(R.id.menuItem4), this);
        mActionMenuItems[4] = new AppDeckMenuItem(actionMenu.findItem(R.id.menuItem5), this);

        mActionMenu.setOnMenuItemClickListener(new Toolbar.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                for (int i = 0; i < mActionMenuItems.length; i++) {
                    AppDeckMenuItem pageMenuItem = mActionMenuItems[i];
                    if (pageMenuItem.getMenuItem() == item) {
                        pageMenuItem.fire();
                        return true;
                    }
                }
                return false;
            }
        });

        // Bottom Menu
        mBottomNavigationView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                for (int i = 0; i < mBottomMenuItems.length; i++) {
                    AppDeckBottomMenuItem bottomMenuItem = mBottomMenuItems[i];
                    if (bottomMenuItem.getMenuItem() == item) {
                        bottomMenuItem.fire();
                        return true;
                    }
                }
                return false;
            }
        });

        menuManager = new MenuManager(mDrawerLayout, mActionBarDrawerToggle,mDrawerLeftMenu, mDrawerRightMenu, mActionBar/*, mLeftMenuWebView, mRightMenuWebView*/, mUpArrow, mCloseArrow);

        mBannerManager = new Banner(mBannerContainer);

        //mActionBarHeight = mActionMenu.getMeasuredHeight();
        //mBottomBarHeight = mBottomNavigationView.getMeasuredHeight();

        mFloatingActionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mCurrentViewConfig != null && mCurrentViewConfig.floatingButton != null && mCurrentAppDeckView != null)
                    mCurrentAppDeckView.loadUrl(mCurrentViewConfig.floatingButton.content);
            }
        });

        loadAppDeckConfig(getIntent());

        FrameLayout debugLog = (FrameLayout)findViewById(R.id.debugLog);
        Button debugLogButton = (Button) findViewById(R.id.closeDebug);
        if (AppDeckApplication.getAppDeck().deviceInfo.isDebugBuild) {
            new DebugLog(debugLog, debugLogButton);
        } else {

        }
    }

    protected void loadAppDeckConfig(Intent intent) {
        AppDeck appDeck = AppDeckApplication.getAppDeck();
        AppConfig appConfig = appDeck.appConfig;

        unloadAppDeckConfig();

        mCurrentViewConfig = new ViewConfig();

        //if (appDeck.appConfig.topbar_color != null)
        //    mActionBar.setBackgroundDrawable(appDeck.appConfig.topbar_color.getDrawable());

        //if (appDeck.appConfig.title != null)
        //    mActionBar.setTitle(appDeck.appConfig.title);

        menuManager.noMenu = true;
        if (appDeck.appConfig.leftMenu != null && appDeck.appConfig.leftMenu.url != null) {
            menuManager.noMenu = false;
            mLeftMenuWebView = SmartWebView.createMenuSmartWebView(this, appDeck.appConfig.resolveURL(appDeck.appConfig.leftMenu.url));
            if (appDeck.appConfig.leftMenuBackgroundColor != null)
                mDrawerLeftMenu.setBackground(Utils.getColorDrawable(appDeck.appConfig.leftMenuBackgroundColor));
            mDrawerLeftMenu.post(new Runnable() {
                @Override
                public void run() {
                    Resources resources = getResources();
                    float width = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, AppDeckApplication.getAppDeck().appConfig.leftMenu.width, resources.getDisplayMetrics());
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerLeftMenu.getLayoutParams();
                    params.width = (int)(width);
                    mDrawerLeftMenu.setLayoutParams(params);
                    mDrawerLeftMenu.addView(mLeftMenuWebView);
                }
            });
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.left_drawer));
        } else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.left_drawer));
        }
        if (appDeck.appConfig.rightMenu != null && appDeck.appConfig.rightMenu.url != null) {
            menuManager.noMenu = false;
            mRightMenuWebView = SmartWebView.createMenuSmartWebView(this, appDeck.appConfig.resolveURL(appDeck.appConfig.rightMenu.url));
            if (appDeck.appConfig.rightMenuBackgroundColor != null)
                mDrawerRightMenu.setBackground(Utils.getColorDrawable(appDeck.appConfig.rightMenuBackgroundColor));
            mDrawerRightMenu.post(new Runnable() {
                @Override
                public void run() {
                    Resources resources = getResources();
                    float width = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, AppDeckApplication.getAppDeck().appConfig.rightMenu.width, resources.getDisplayMetrics());
                    DrawerLayout.LayoutParams params = (DrawerLayout.LayoutParams) mDrawerRightMenu.getLayoutParams();
                    params.width = (int)(width);
                    mDrawerRightMenu.setLayoutParams(params);
                    mDrawerRightMenu.addView(mRightMenuWebView);
                }
            });
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, findViewById(R.id.right_drawer));
        } else {
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, findViewById(R.id.right_drawer));
        }

        if (menuManager.noMenu)
            mToolbar.setNavigationIcon(null);

        menuManager.setLeftMenuWebView(mLeftMenuWebView);
        menuManager.setRightMenuWebView(mRightMenuWebView);

        if (menuManager.noMenu)
            menuManager.setMenuIcon(MenuManager.ICON_NONE);

        // tabs
        mTabLayout.setTabTextColors(
                Utils.parseColor(appDeck.appConfig.appTopbarTextColor, 0.50f), // unselected
                Utils.parseColor(appDeck.appConfig.appTopbarTextColor) // selected
        );

        // Bottom menu
        Menu bottomMenu = mBottomNavigationView.getMenu();
        while (bottomMenu.size() > 0)
            bottomMenu.removeItem(0);
        if (appConfig.bottomMenu != null && appConfig.bottomMenu.size() > 0) {
            mBottomNavigationView.setVisibility(View.VISIBLE);
            mBottomMenuItems = new AppDeckBottomMenuItem[appConfig.bottomMenu.size()];
            for (int i = 0; i < appConfig.bottomMenu.size(); i++) {
                MenuEntry menuEntry = appConfig.bottomMenu.get(i);
                MenuItem menuItem = bottomMenu.add(menuEntry.title != null ? menuEntry.title : "#"+(i + 1));
                mBottomMenuItems[i] = new AppDeckBottomMenuItem(menuItem, this);
                mBottomMenuItems[i].configure(menuEntry.title, menuEntry.icon, menuEntry.content);
            }
        } else {
            mBottomNavigationView.setVisibility(View.INVISIBLE);
        }

        appDeck.start(this);

        appDeck.push.shouldHandleIntent(intent);
    }

    protected void unloadAppDeckConfig() {
        mDrawerLeftMenu.removeAllViews();
        mDrawerRightMenu.removeAllViews();
        mLeftMenuWebView = null;
        mRightMenuWebView = null;
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        if (mActionBarDrawerToggle != null)
            mActionBarDrawerToggle.syncState();
    }

    @Override
    protected void onResume() {
        super.onResume();
        PluginManager.getSharedInstance().onActivityResume(this);
        AppDeckApplication.getAppDeck().push.registerReceiver();
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        AppDeckApplication.getAppDeck().adManager.onActivityResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        PluginManager.getSharedInstance().onActivityPause(this);
        AppDeckApplication.getAppDeck().push.unregisterReceiver();
        AppDeckApplication.getAppDeck().adManager.onActivityPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        PluginManager.getSharedInstance().onActivityDestroy(this);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mActionBarDrawerToggle.onConfigurationChanged(newConfig);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        AppDeckApplication.getAppDeck().push.shouldHandleIntent(intent);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        if (requestCode == AppDeck.PERMISSION_SHARE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                AppDeckApplication.getAppDeck().share.doShareWithPermission();
            }
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        AppDeckApplication.getAppDeck().adManager.onActivitySaveInstanceState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        AppDeckApplication.getAppDeck().adManager.onActivityRestoreInstanceState(savedInstanceState);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        super.onCreateOptionsMenu(menu);

        getMenuInflater().inflate(R.menu.menu, menu);

        return true;
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        mTopMenuItems = new AppDeckMenuItem[5];
        mTopMenuItems[0] = new AppDeckMenuItem(menu.findItem(R.id.menuItem1), this);
        mTopMenuItems[1] = new AppDeckMenuItem(menu.findItem(R.id.menuItem2), this);
        mTopMenuItems[2] = new AppDeckMenuItem(menu.findItem(R.id.menuItem3), this);
        mTopMenuItems[3] = new AppDeckMenuItem(menu.findItem(R.id.menuItem4), this);
        mTopMenuItems[4] = new AppDeckMenuItem(menu.findItem(R.id.menuItem5), this);
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        // topbar button
        if (mTopMenuItems != null) {
            for (int i = 0; i < mTopMenuItems.length; i++) {
                AppDeckMenuItem pageMenuItem = mTopMenuItems[i];
                if (pageMenuItem.getMenuItem() == item) {
                    pageMenuItem.fire();
                    return true;
                }
            }
        }

        int idx = item.getItemId();

        if (idx == android.R.id.home) {
            if (menuManager.isMenuOpen() == false) {
                if (AppDeckApplication.getAppDeck().navigation.getStackSize() > 0) {
                    AppDeckApplication.getAppDeck().navigation.pop();
                    return true;
                }
            }
        }

        //if (mDrawerToggle.onOptionsItemSelected(item))
        //    return true;

        if (idx == android.R.id.home)
        {
            menuManager.toggleMenu();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_MENU)
        {
            menuManager.toggleMenu();
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    @Override
    public  void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (smartWebViewRegiteredForActivityResult != null) {
            smartWebViewRegiteredForActivityResult.onActivityResult(this, requestCode, resultCode, data);
            smartWebViewRegiteredForActivityResult = null;
        } else {
            //SmartWebViewFactory.onActivityResult(this, requestCode, resultCode, data);
        }
        /*
        if (callbackManager != null)
            callbackManager.onActivityResult(requestCode, resultCode, data);
        if (mTwitterAuthClient != null)
            mTwitterAuthClient.onActivityResult(requestCode, resultCode, data);
        if (pluginManager != null)
            pluginManager.onActivityResult(this, requestCode, resultCode, data);*/
    }

    @Override
    public void onBackPressed() {

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
            return;
        }

        Navigation navigation = AppDeckApplication.getAppDeck().navigation;

        // current page can go back ?
        if (navigation.shouldOverrideBackButton()) {
            return;
        }

        // current page is home ?
        AppDeckView currentAppDeckView = navigation.getCurrentAppDeckView();
        String bootstrapURL = AppDeckApplication.getAppDeck().appConfig.bootstrap.getAbsoluteURL();
        if (!currentAppDeckView.getURL().equalsIgnoreCase(bootstrapURL))
        {
            navigation.loadRootURL(bootstrapURL);
            return;
        }

        super.onBackPressed();
    }

    public boolean apiCall(final ApiCall call) {
        return AppDeckApplication.getAppDeck().apiCall(call);
    }

    private AppDeckView mCurrentAppDeckView;

    public void setCurrentAppDeckView(AppDeckView appDeckView) {
        if (mCurrentAppDeckView != null) {
            mCurrentAppDeckView.onHide();
        }
        mCurrentAppDeckView = appDeckView;
        setViewConfig(appDeckView.getViewConfig());
        mCurrentAppDeckView.onShow();
        //mTabLayout.setupWithViewPager(appDeckView.getViewPager());
        mTabLayout.setupWithViewPager(mCurrentAppDeckView.getViewPager(), true);
    }

    private AnimatorSet mAnimatorSet;

    public void setViewConfig(final ViewConfig viewConfig) {

        AppDeck appDeck = AppDeckApplication.getAppDeck();
        AppConfig appConfig = appDeck.appConfig;

        if (mAnimatorSet != null) {
            mAnimatorSet.cancel();
            mAnimatorSet = null;
        }

        mAnimatorSet = new AnimatorSet();

        mAnimatorSet.setDuration(PageAnimation.ANIMATION_DELAY);
        mAnimatorSet.setInterpolator(new FastOutSlowInInterpolator());

        ArrayList<Animator> animations = new ArrayList<>();

        /*
        color;
        topbarColor; ok
        topbarColorDark (status);
        topbarTextColor; ok
        controlColor;
        backgroundColor;
         */

        // title
        mToolbar.setTitle(viewConfig.title);
        //mCollapsingToolbarLayout.setTitle(viewConfig.title);

        // logo
        String logo = appConfig.logo;
        if (viewConfig.logo != null && !viewConfig.logo.isEmpty())
            logo = viewConfig.logo;

        // disable logo and title if there are some banners
        if (viewConfig.banners != null && viewConfig.banners.size() > 0)
        {
            logo = null;

            /*mToolbar.setTitle("");
            mActionBar.setTitle("");*/
        }

        if (logo != null && !logo.isEmpty()) {
            AppDeckApplication.getAppDeck().addToRequestQueue(new ImageRequest(logo, new Response.Listener<Bitmap>() {
                @Override
                public void onResponse(Bitmap response) {
                BitmapDrawable draw = new BitmapDrawable(getResources(), response);
                mActionBar.setTitle(null);
                mActionBar.setIcon(draw);
                mActionBar.setDisplayShowHomeEnabled(true); // show logo
                mActionBar.setDisplayShowTitleEnabled(false); // hide String title
                }
            }, AppDeckApplication.getAppDeck().deviceInfo.screenWidth, AppDeckApplication.getAppDeck().deviceInfo.actionBarIconSize * 2, ImageView.ScaleType.CENTER_CROP, Bitmap.Config.ARGB_8888, new Response.ErrorListener() {
                public void onErrorResponse(VolleyError error) {
                Log.e(TAG, "Error while fetching Logo : "+error.getLocalizedMessage());
                }
            }));
        } else {
            mActionBar.setIcon(null);
            mActionBar.setDisplayShowHomeEnabled(false); // hide logo
            //mActionBar.setDisplayShowTitleEnabled(true); // show String title
        }

        // topbar color
        if (!Utils.equals(mCurrentViewConfig.topbarColor, viewConfig.topbarColor)) {
            int colorFrom = Utils.parseColor(mCurrentViewConfig.topbarColor);
            int colorTo = Utils.parseColor(viewConfig.topbarColor);
            ValueAnimator colorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(), colorFrom, colorTo);
            colorAnimation.setDuration(250); // milliseconds
            colorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animator) {
                    mAppBarLayout.setBackgroundColor((int) animator.getAnimatedValue());
                    mTabLayout.setBackgroundColor((int) animator.getAnimatedValue());
                }
            });
            mAnimatorSet.play(colorAnimation);
        }

        // TODO: status bar color


        // title color
        if (!Utils.equals(mCurrentViewConfig.topbarTextColor, viewConfig.topbarTextColor)) {
            int colorFrom = Utils.parseColor(mCurrentViewConfig.topbarTextColor);
            int colorTo = Utils.parseColor(viewConfig.topbarTextColor);
            ValueAnimator colorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(), colorFrom, colorTo);
            colorAnimation.setDuration(250); // milliseconds
            colorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animator) {
                    mToolbar.setTitleTextColor((int) animator.getAnimatedValue());
                }
            });
            mAnimatorSet.play(colorAnimation);
        }

        // actionbar color
        if (!Utils.equals(mCurrentViewConfig.actionbarColor, viewConfig.actionbarColor)) {
            int colorFrom = Utils.parseColor(mCurrentViewConfig.actionbarColor);
            int colorTo = Utils.parseColor(viewConfig.actionbarColor);
            ValueAnimator colorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(), colorFrom, colorTo);
            colorAnimation.setDuration(250); // milliseconds
            colorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animator) {
                    mActionMenu.setBackgroundColor((int) animator.getAnimatedValue());
                }
            });
            mAnimatorSet.play(colorAnimation);
        }



        boolean shouldShowActionBar = (viewConfig.actionMenu != null && viewConfig.actionMenu.size() > 0);
        boolean shouldShowBottomBar = (appConfig.bottomMenu != null && appConfig.bottomMenu.size() > 0);

        // Floating Button
        if (viewConfig.floatingButton != null) {
            CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams)mFloatingActionButton.getLayoutParams();
            if (shouldShowActionBar)
                params.setAnchorId(R.id.actionmenu);
            else if (shouldShowBottomBar)
                params.setAnchorId(R.id.bottom_navigation);
            else
                params.setAnchorId(R.id.bottom_hook);

            mFloatingActionButton.setLayoutParams(params);
            //mFloatingActionButton.setVisibility(View.VISIBLE);

            final String icon = AppDeckApplication.getAppDeck().resolveSpecialURL(viewConfig.floatingButton.icon);

            // already hidden ?
            if (mFloatingActionButton.getVisibility() != View.VISIBLE) {
                mFloatingActionButton.setBackgroundTintList(ColorStateList.valueOf(Utils.parseColor((viewConfig.floatingButton.backgroundColor != null ? viewConfig.floatingButton.backgroundColor : mCurrentViewConfig.topbarColor))));
                AppDeckApplication.getAppDeck().addToRequestQueue(new ImageRequest(icon, new Response.Listener<Bitmap>() {
                    @Override
                    public void onResponse(Bitmap response) {
                        mFloatingActionButton.setImageBitmap(response);
                        mFloatingActionButton.show();
                    }
                }, AppDeckApplication.getAppDeck().deviceInfo.floatingButtonIconSize, AppDeckApplication.getAppDeck().deviceInfo.floatingButtonIconSize, null, new Response.ErrorListener() {
                    public void onErrorResponse(VolleyError error) {
                        Log.e(TAG, "Error while fetching Logo : " + error.getLocalizedMessage());
                    }
                }));
            } else {

                boolean shouldUpdateIcon = true;
                if (mCurrentViewConfig != null && mCurrentViewConfig.floatingButton != null && mCurrentViewConfig.floatingButton.icon != null
                        && viewConfig.floatingButton.icon != null
                        && mCurrentViewConfig.floatingButton.icon.equalsIgnoreCase(viewConfig.floatingButton.icon))
                    shouldUpdateIcon = false;

                if (shouldUpdateIcon) {
                    mFloatingActionButton.hide(new FloatingActionButton.OnVisibilityChangedListener() {
                        @Override
                        public void onHidden(FloatingActionButton fab) {
                            super.onHidden(fab);
                            mFloatingActionButton.setBackgroundTintList(ColorStateList.valueOf(Utils.parseColor((viewConfig.floatingButton.backgroundColor != null ? viewConfig.floatingButton.backgroundColor : mCurrentViewConfig.topbarColor))));
                            AppDeckApplication.getAppDeck().addToRequestQueue(new ImageRequest(icon, new Response.Listener<Bitmap>() {
                                @Override
                                public void onResponse(Bitmap response) {
                                    mFloatingActionButton.setImageBitmap(response);
                                    mFloatingActionButton.show();
                                }
                            }, AppDeckApplication.getAppDeck().deviceInfo.floatingButtonIconSize, AppDeckApplication.getAppDeck().deviceInfo.floatingButtonIconSize, null, new Response.ErrorListener() {
                                public void onErrorResponse(VolleyError error) {
                                    Log.e(TAG, "Error while fetching Logo : " + error.getLocalizedMessage());
                                }
                            }));
                        }
                    });
                }
            }
        } else {
            mFloatingActionButton.hide();
        }

        // Bottom bar
        mBottomNavigationView.setBackgroundColor(Utils.parseColor(viewConfig.bottombarColor));
        int[][] states = new int[][] {
                new int[] { android.R.attr.state_enabled}, // enabled
                new int[] {-android.R.attr.state_enabled}, // disabled
                new int[] {-android.R.attr.state_checked}, // unchecked
                new int[] { android.R.attr.state_pressed}  // pressed
        };
        int[] colors = new int[] {
                Utils.parseColor(viewConfig.bottombarTextColor),
                Utils.parseColor(viewConfig.bottombarTextColor, 0.50f),
                Utils.parseColor(viewConfig.bottombarTextColor, 0.50f),
                Utils.parseColor(viewConfig.bottombarTextColor)
        };
        mBottomNavigationView.setItemTextColor(new ColorStateList(states, colors));

        // Ads
        if (appDeck.deviceInfo.adsEnabled)
        {
            CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams) mAdsBannerContainer.getLayoutParams();
            if (shouldShowActionBar)
                params.setAnchorId(R.id.actionmenu);
            else if (shouldShowBottomBar)
                params.setAnchorId(R.id.bottom_navigation);
            else
                params.setAnchorId(R.id.bottom_hook);
            mAdsBannerContainer.setLayoutParams(params);
            //mAdsBannerContainer.setVisibility(View.VISIBLE);
        } else {
            /*CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams) mAdsBannerContainer.getLayoutParams();
            params.setAnchorId(View.NO_ID);
            mAdsBannerContainer.setLayoutParams(params);
            mAdsBannerContainer.setVisibility(View.GONE);*/
        }

        // Action Bar
        if (shouldShowActionBar) {
            //mActionMenu.setVisibility(View.VISIBLE);
            CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams)mActionMenu.getLayoutParams();
            if (shouldShowBottomBar)
                params.setAnchorId(R.id.bottom_navigation);
            else
                params.setAnchorId(R.id.bottom_hook);
            mActionMenu.setLayoutParams(params);
            mActionMenu.setVisibility(View.VISIBLE);

            ValueAnimator anim = ValueAnimator.ofInt(mActionMenu.getMeasuredHeight(), mToolbar.getMeasuredHeight());
            anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator valueAnimator) {
                    int val = (Integer) valueAnimator.getAnimatedValue();
                    ViewGroup.LayoutParams layoutParams = mActionMenu.getLayoutParams();
                    layoutParams.height = val;
                    mActionMenu.setLayoutParams(layoutParams);
                }
            });
            mAnimatorSet.play(anim);

        } else {
            /*CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams)mActionMenu.getLayoutParams();
            params.setAnchorId(View.NO_ID);
            mActionMenu.setLayoutParams(params);
            mActionMenu.setVisibility(View.GONE);*/

            ValueAnimator anim = ValueAnimator.ofInt(mActionMenu.getMeasuredHeight(), 0);
            anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator valueAnimator) {
                    int val = (Integer) valueAnimator.getAnimatedValue();
                    ViewGroup.LayoutParams layoutParams = mActionMenu.getLayoutParams();
                    layoutParams.height = val;
                    mActionMenu.setLayoutParams(layoutParams);
                }
            });
            mAnimatorSet.play(anim);
        }

        // Banner
        if (viewConfig.banners != null && viewConfig.banners.size() > 0) {
            //mBannerContainer.setVisibility(View.VISIBLE);
            mActionBar.setDisplayShowTitleEnabled(false); // show String title
            mBannerManager.setBanners(viewConfig.banners);
            int height = mBannerManager.getHeight();
            ValueAnimator anim = ValueAnimator.ofInt(mBannerContainer.getMeasuredHeight(), height);
            anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator valueAnimator) {
                    int val = (Integer) valueAnimator.getAnimatedValue();
                    ViewGroup.LayoutParams layoutParams = mBannerContainer.getLayoutParams();
                    layoutParams.height = val;
                    mBannerContainer.setLayoutParams(layoutParams);
                }
            });
            mAnimatorSet.play(anim);
        } else {
            //findViewById(R.id.backgroundImageView).setVisibility(View.GONE);
            mBannerManager.setBanners(null);
            ValueAnimator anim = ValueAnimator.ofInt(mBannerContainer.getMeasuredHeight(), 0);
            anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator valueAnimator) {
                    int val = (Integer) valueAnimator.getAnimatedValue();
                    ViewGroup.LayoutParams layoutParams = mBannerContainer.getLayoutParams();
                    layoutParams.height = val;
                    mBannerContainer.setLayoutParams(layoutParams);
                }
            });
            anim.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    //mBannerContainer.setVisibility(View.GONE);
                }
            });
            mAnimatorSet.play(anim);
        }

        // tabs
        if (viewConfig.tabs != null && viewConfig.tabs.size() > 0) {
            mTabLayout.setVisibility(View.VISIBLE);
            mTabLayout.setTabTextColors(
                    Utils.parseColor(viewConfig.topbarTextColor, 0.50f, appConfig.appTopbarTextColor), // unselected
                    Utils.parseColor(viewConfig.topbarTextColor, appConfig.appTopbarTextColor) // selected
            );
        } else {
            mTabLayout.setVisibility(View.GONE);
        }

        /*
        if (animations.size() > 0) {
            AnimatorSet set = new AnimatorSet();
            for (int i = 0; i < animations.size(); i++) {
                Animator anim = animations.get(i);
                set.play(anim);
            }
        }*/

        // Menu
        int i = 0;
        if (viewConfig.menu != null) {
            int menuSize = Math.min(viewConfig.menu.size(), mTopMenuItems.length);
            for (i = 0; i < menuSize; i++) {
                MenuEntry menuEntry = viewConfig.menu.get(i);
                AppDeckMenuItem appDeckMenuItem = mTopMenuItems[mTopMenuItems.length - menuSize + i];
                appDeckMenuItem.configure(menuEntry.title, menuEntry.icon, menuEntry.content, menuEntry.badge, menuEntry.disabled, mCurrentAppDeckView);
            }
            for (i = 0; i < mTopMenuItems.length - menuSize; i++) {
                AppDeckMenuItem appDeckMenuItem = mTopMenuItems[i];
                appDeckMenuItem.hide();
            }
        } else {
            for (i = 0; mTopMenuItems != null && i < mTopMenuItems.length; i++) {
                AppDeckMenuItem appDeckMenuItem = mTopMenuItems[i];
                appDeckMenuItem.hide();
            }
        }

        // Action Menu
        if (viewConfig.actionMenu != null && viewConfig.actionMenu.size() > 0) {
            int actionMenuSize = Math.min(viewConfig.actionMenu.size(), mActionMenuItems.length);
            for (i = 0 ; i < actionMenuSize && i < mActionMenuItems.length; i++) {
                MenuEntry menuEntry = viewConfig.actionMenu.get(i);
                AppDeckMenuItem appDeckMenuItem = mActionMenuItems[mActionMenuItems.length - actionMenuSize + i];
                appDeckMenuItem.configure(menuEntry.title, menuEntry.icon, menuEntry.content, menuEntry.badge, menuEntry.disabled, mCurrentAppDeckView);
            }
            for (i = 0 ; i < mActionMenuItems.length - actionMenuSize && i < mActionMenuItems.length; i++) {
                AppDeckMenuItem appDeckMenuItem = mActionMenuItems[i];
                appDeckMenuItem.hide();
            }
        } else {
            for (i = 0; mActionMenuItems != null && i < mActionMenuItems.length; i++) {
                AppDeckMenuItem appDeckMenuItem = mActionMenuItems[i];
                appDeckMenuItem.hide();
            }
        }

        mCurrentViewConfig = viewConfig.copy();

        mAnimatorSet.start();
    }

    // Utils

    public void resetAppBar() {
        mAppBarLayout.setExpanded(true, true);
    }

    public void evaluateJavascript(String js) {
        menuManager.evaluateJavascript(js);
    }

    public void showLoading() {
        mLoading.clearAnimation();
        mLoading.setVisibility(View.VISIBLE);
        mLoading.setAlpha(0);
        mLoading.animate().withLayer().alpha(1f).start();
    }

    public void hideLoading() {
        mLoading.clearAnimation();
        mLoading.animate().withLayer().alpha(1f)
                .withEndAction(new Runnable() {
                    @Override
                    public void run() {
                        mLoading.setVisibility(View.GONE);
                    }
                })
                .start();
    }

    public void showErrorMessage(String errorMessage) {
        Snackbar
                .make(AppDeckApplication.getActivity().findViewById(android.R.id.content)
                        , errorMessage, Snackbar.LENGTH_LONG)
                .show(); // Don’t forget to show!
    }


    // getter

    public FrameLayout getViewContainer() {
        return mViewContainer;
    }

    public AppBarLayout getAppBarLayout() {
        return mAppBarLayout;
    }

    public FrameLayout getBannerAdViewContainer()
    {
        return (FrameLayout)findViewById(R.id.bannerContainer);
    }
    public FrameLayout getInterstitialAdViewContainer()
    {
        return (FrameLayout)findViewById(R.id.app_container);
    }

}
