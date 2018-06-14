package net.mobideck.appdeck.core;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.widget.FrameLayout;
import android.widget.Toast;

import net.mobideck.appdeck.AppDeck;
import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;
import net.mobideck.appdeck.config.ViewConfig;
import net.mobideck.appdeck.core.ads.AdManager;

import org.json.JSONArray;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class Navigation {

    private List<AppDeckView> mStack;

    public PageAnimation pageAnimation;

    public Navigation() {
        mStack = new ArrayList<>();
    } //mStack --> root

    public void clean() {
        FrameLayout viewContainer = AppDeckApplication.getActivity().getViewContainer();
        viewContainer.removeAllViews();
        for (int i = 0; i < mStack.size(); i++) {
            AppDeckView appDeckView = mStack.get(i);
            appDeckView.destroy();
        }
        mStack = new ArrayList<>();
    }

    // URL

    public void loadRootURL(String absoluteURL) {

        if (PageAnimation.isAnimating)
            return;

        PageManager pageManager = new PageManager(this, AppDeckApplication.getActivity(), absoluteURL);

        loadRoot(pageManager);
    }

    public void loadURL(String absoluteURL) {

        if (PageAnimation.isAnimating)
            return;
        if (loadSpecialURL(absoluteURL))
            return;
        if (loadExternalURL(absoluteURL, false))
            return;

        PageManager pageManager = new PageManager(this, AppDeckApplication.getActivity(), absoluteURL);

        if (pageManager.getViewConfig().isPopUp())
            popup(pageManager);
        else
            push(pageManager);
    }

    public void popupURL(String absoluteURL) {

        if (PageAnimation.isAnimating)
            return;

        PageManager pageManager = new PageManager(this, AppDeckApplication.getActivity(), absoluteURL);

        popup(pageManager);
    }

    // AppDeckView

    public void loadRoot(AppDeckView appDeckView) {

        if (PageAnimation.isAnimating)
            return;

        appDeckView.viewState = new ViewState();

        AppDeckApplication.getActivity().menuManager.closeMenu();

        // remove and clean previous stack
        //clean(); /* problem onBackpress */

        mStack.add(appDeckView);

        AppDeckApplication.getActivity().setCurrentAppDeckView(appDeckView);

        pageAnimation = new PageAnimation(AppDeckApplication.getActivity());
        pageAnimation.root(appDeckView);

        AppDeckApplication.getActivity().menuManager.setMenuIcon(MenuManager.ICON_HAMBURGER);

        AppDeckApplication.getAppDeck().adManager.showAds(AdManager.EVENT_ROOT);

    }

    public void push(AppDeckView appDeckView) {

        if (PageAnimation.isAnimating)
            return;

        appDeckView.viewState = new ViewState();

        getCurrentAppDeckView().onPause();

        mStack.add(appDeckView);

        AppDeckApplication.getActivity().setCurrentAppDeckView(appDeckView);

//        pageAnimation = new PageAnimation(AppDeckApplication.getActivity());
//        pageAnimation.push(appDeckView);

        AppDeckApplication.getActivity().menuManager.setMenuIcon(MenuManager.ICON_BACK);

        AppDeckApplication.getAppDeck().adManager.showAds(AdManager.EVENT_PUSH);

        AppDeckApplication.getActivity().resetAppBar();
    }

    public void popup(AppDeckView appDeckView) {
        if (PageAnimation.isAnimating)
            return;

        appDeckView.viewState = new ViewState();
        appDeckView.viewState.isPopUp = true;

        getCurrentAppDeckView().onPause();

        mStack.add(appDeckView);

        AppDeckApplication.getActivity().setCurrentAppDeckView(appDeckView);

        pageAnimation = new PageAnimation(AppDeckApplication.getActivity());
        pageAnimation.popup(appDeckView);

        //AppDeckApplication.getActivity().menuManager.setMenuArrow(true);

        AppDeckApplication.getAppDeck().adManager.showAds(AdManager.EVENT_PUSH);

        AppDeckApplication.getActivity().resetAppBar();

        AppDeckApplication.getActivity().menuManager.disableMenu();

        //AppDeckApplication.getActivity().menuManager.showCloseButton();

    }


    public void pop() {

        if (PageAnimation.isAnimating)
            return;

        getCurrentAppDeckView().onPause();

        final AppDeckView toAppDeckView = mStack.get(mStack.size() - 2);
        toAppDeckView.onResume();

        final AppDeckView fromAppDeckView = mStack.get(mStack.size() - 1);
        mStack.remove(mStack.size() - 1);

        AppDeckApplication.getActivity().setCurrentAppDeckView(toAppDeckView);

        pageAnimation = new PageAnimation(AppDeckApplication.getActivity());
        pageAnimation.setAnimationListener(new PageAnimation.PageAnimationListener() {
            @Override
            public void onAnimationEnd() {
                fromAppDeckView.destroy();
                //toPageManager.onResume();

                if (toAppDeckView.viewState.isPopUp)
                    AppDeckApplication.getActivity().menuManager.disableMenu();
                else
                    AppDeckApplication.getActivity().menuManager.enableMenu();
            }
        });

        if (fromAppDeckView.viewState.isPopUp)
            pageAnimation.popdown(toAppDeckView);
        else
            pageAnimation.pop(toAppDeckView);

       /* if (fromAppDeckView.viewState.isPopUp || toAppDeckView.viewState.isPopUp)
            ;
        else */
//       if (mStack.size() == 1)
            AppDeckApplication.getActivity().menuManager.setMenuIcon(MenuManager.ICON_HAMBURGER);
//        else
//            AppDeckApplication.getActivity().menuManager.setMenuIcon(MenuManager.ICON_BACK);

        AppDeckApplication.getAppDeck().adManager.showAds(AdManager.EVENT_POP);

        AppDeckApplication.getActivity().resetAppBar();
    }

    public boolean shouldOverrideBackButton() {

        AppDeckView appDeckView = mStack.get(mStack.size() - 1);

        if (appDeckView.shouldOverrideBackButton())
            return true;

        if (mStack.size() > 1) {
            pop();
            return true;
        }

        return false;
    }

    public AppDeckView getCurrentAppDeckView() {
        return mStack.get(mStack.size() - 1);
    }


    /*
    public PageManager getCurrentPageManager() {
        return mStack.get(mStack.size() - 1);
    }

    public Page getCurrentPage() {
        PageManager pageManager = getCurrentPageManager();
        return pageManager.getCurrentPage();
    }*/

    public boolean loadSpecialURL(String absoluteURL)
    {
        if (absoluteURL.startsWith("javascript:"))
        {
            getCurrentAppDeckView().loadUrl(absoluteURL);
            return true;
        }
        if (absoluteURL.startsWith("tel:"))
        {
            try{
                Intent intent = new Intent(Intent.ACTION_DIAL);
                intent.setData(Uri.parse(absoluteURL));
                AppDeckApplication.getActivity().startActivity(intent);
            }catch (Exception e) {
                e.printStackTrace();
            }
            return true;
        }

        if (absoluteURL.startsWith("mailto:")){
            Intent i = new Intent(Intent.ACTION_SEND);
            i.setType("message/rfc822") ;
            i.putExtra(Intent.EXTRA_EMAIL, new String[]{absoluteURL.substring("mailto:".length())});
            AppDeckApplication.getActivity().startActivity(Intent.createChooser(i, ""));
            return true;
        }
        return false;
    }

    public boolean loadExternalURL(String absoluteURL, boolean force)
    {
        Uri uri = Uri.parse(absoluteURL);
        if (uri != null)
        {
            String host = uri.getHost();
            if (force || (host != null && isSameDomain(host) == false))
            {
                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW, uri);

                    // enable custom tab for chrome
                    String EXTRA_CUSTOM_TABS_SESSION = "android.support.customtabs.extra.SESSION";
                    Bundle extras = new Bundle();
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                        extras.putBinder(EXTRA_CUSTOM_TABS_SESSION, null/*sessionICustomTabsCallback.asBinder() Set to null for no session */);
                    }
                    String EXTRA_CUSTOM_TABS_TOOLBAR_COLOR = "android.support.customtabs.extra.TOOLBAR_COLOR";
                    //intent.putExtra(EXTRA_CUSTOM_TABS_TOOLBAR_COLOR, R.color.AppDeckColorAccent);
                    //intent.putExtra(EXTRA_CUSTOM_TABS_TOOLBAR_COLOR, R.color.AppDeckColorPrimary);
                    extras.putInt(EXTRA_CUSTOM_TABS_TOOLBAR_COLOR, R.color.AppDeckColorApp);

                    intent.putExtras(extras);

                    AppDeckApplication.getActivity().startActivity(intent);
                } catch (Exception e) {
                    Toast.makeText(AppDeckApplication.getActivity(), "No application can handle this request."
                            + " Please install a webbrowser",  Toast.LENGTH_LONG).show();

                    e.printStackTrace();
                }
                return true;
            }
        }
        return false;
    }

    public boolean isSameDomain(String domain)
    {
        if (domain.equalsIgnoreCase(AppDeckApplication.getAppDeck().appConfig.getUrl().getHost()))
            return true;

        Pattern otherDomainRegexp[] = AppDeckApplication.getAppDeck().appConfig.otherDomainRegexp;

        if (otherDomainRegexp == null)
            return false;

        for (int i = 0; i < otherDomainRegexp.length; i++) {
            Pattern p = otherDomainRegexp[i];

            if (p.matcher(domain).find())
                return true;
        }
        return false;
    }

    public void evaluateJavascript(String js) {
        for (int i = 0; i < mStack.size(); i++) {
            AppDeckView appDeckView = mStack.get(i);
            appDeckView.evaluateJavascript(js);
        }
    }

    public int getStackSize() {
        return mStack.size();
    }

    public void onViewConfigChange(AppDeckView appDeckView, ViewConfig viewConfig) {
        if (getCurrentAppDeckView() == appDeckView)
            AppDeckApplication.getActivity().setViewConfig(viewConfig);
    }

}
