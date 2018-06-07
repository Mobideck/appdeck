package net.mobideck.appdeck.core;

import android.content.Context;
import android.graphics.Color;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.config.MenuEntry;
import net.mobideck.appdeck.config.ViewConfig;

import java.util.ArrayList;
import java.util.List;

public class PageManager extends AppDeckView {

    private Context mContext;

    private ViewPager mViewPager;

    private List<Page> mPageList;
    //private List<String> mTabTitle;

    //private Navigation mNavigation;

    //private int mCurrentPageIdx;

    // Tab mode
    private boolean mTabEnabled = false;
    private List<MenuEntry> mTabs;

    private PagerAdapter mTabPagerAdapter;
    private PagerAdapter mPreviousNextPagerAdapter;

    // Previous/Next mode
    private Page mPreviousPage;
    private Page mCurrentPage; // Warning: on Tab mode, current page may not the current one
    private Page mNextPage;

    public PageManager(Navigation navigation, Context context, String absoluteURL) {
        //mNavigation = navigation;
        mContext = context;
        mViewPager = new ViewPager(mContext);
        //mViewPager.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        mViewPager.setBackgroundColor(Color.WHITE);
        mPageList = new ArrayList<>();
        mCurrentPage = new Page(this, absoluteURL);
        mPageList.add(mCurrentPage);
        //mTabTitle = new ArrayList<>();
        //mTabTitle.add(mCurrentPage.getViewConfig().title != null ? mCurrentPage.getViewConfig().title : "#1");
        //mCurrentPageIdx = 0;
        mTabPagerAdapter = new PageManagerTabAdaptater();
        mPreviousNextPagerAdapter = new PageManagerPreviousNextAdaptater();
        mViewPager.setAdapter(mPreviousNextPagerAdapter);


        mViewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {

            int mCurrentPageIdx = -1;

            @Override
            public void onPageSelected(int position) {

                if (mTabEnabled) {
/*
                    if (position < 0 || position >= mPageList.size())
                        return;

                    Page oldPage = getCurrentPage();
                    Page newPage = mPageList.get(position);

                    boolean shouldUpdateViewConfig = oldPage != newPage;

                    if (shouldUpdateViewConfig)
                        oldPage.onHide();

                    mCurrentPageIdx = position;

                    if (shouldUpdateViewConfig) {
                        AppDeckApplication.getAppDeck().navigation.onViewConfigChange(PageManager.this, checkViewConfig(newPage.getViewConfig()));
                        newPage.onShow();
                    }*/
                    boolean shouldUpdateViewConfig = (mCurrentPageIdx != position) && (mCurrentPageIdx != -1);

                    // index out of bounds ?
                    if (position < 0 || position >= mPageList.size()) {
                        return;
                    }

                    // call onHide if needed
                    if (shouldUpdateViewConfig) {
                        //mPageList.get(mCurrentPageIdx).onHide();
                        Page page = getCurrentPage();
                        page.onHide();
                    }

                    mCurrentPageIdx = position;

                    // call on show
                    if (shouldUpdateViewConfig) {
                        Page page = mPageList.get(mCurrentPageIdx);
                        AppDeckApplication.getAppDeck().navigation.onViewConfigChange(PageManager.this, checkViewConfig(page.getViewConfig()));
                        page.onShow();
                    }

                } else {
                    mCurrentPageIdx = position;
                }

                /*
                boolean shouldUpdateViewConfig = mTabEnabled && (mCurrentPageIdx != position) && (mCurrentPageIdx != -1);

                // index out of bounds ?
                if (position < 0 || position >= mPageList.size()) {
                    return;
                }

                // call onHide if needed
                if (shouldUpdateViewConfig) {
                    //mPageList.get(mCurrentPageIdx).onHide();
                    Page page = getCurrentPage();
                    page.onHide();
                }

                mCurrentPageIdx = position;

                // call on show
                if (shouldUpdateViewConfig) {
                    Page page = mPageList.get(mCurrentPageIdx);
                    AppDeckApplication.getAppDeck().navigation.onViewConfigChange(PageManager.this, checkViewConfig(page.getViewConfig()));
                    page.onShow();
                }*/
            }

            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

                /*
                if (mTabEnabled) {
                    return;
                }

                if (position == 0 && previousPage != null)
                {
                    previousPage.setIsOnScreen(true);
                }
                if (position == 1 && nextPage != null)
                {
                    nextPage.setIsOnScreen(true);
                }*/
            }

            @Override
            public void onPageScrollStateChanged(int state) {
                // scroll just end, we check if we should update page
                if (state == ViewPager.SCROLL_STATE_IDLE) {
                    // if tab mode do nothing
                    if (mTabEnabled)
                        return;
                    // if only one page ... there is nothing to do
                    if (mPreviousNextPagerAdapter.getCount() <= 1)
                        return;
                    int position = mCurrentPageIdx;
                    Log.i("PageSwipe", "position " + position);
                    if (position == 0 && mPreviousPage == null)
                        return;
                    //if (position == 1)
                    //	return;
                    mCurrentPage.onHide();
                    if (position == 1 && mPreviousPage == null && mNextPage != null) {
                        mPreviousPage = mCurrentPage;
                        mCurrentPage = mNextPage;
                        mNextPage = null;
                    }
                    if (position == 0) {
                        mNextPage = mCurrentPage;
                        mCurrentPage = mPreviousPage;
                        mPreviousPage = null;
                    }
                    if (position == 2) {
                        mPreviousPage = mCurrentPage;
                        mCurrentPage = mNextPage;
                        mNextPage = null;
                    }
                    AppDeckApplication.getAppDeck().navigation.onViewConfigChange(PageManager.this, checkViewConfig(mCurrentPage.getViewConfig()));
                    mCurrentPage.onShow();
                    initPreviousNext();
                    mPreviousNextPagerAdapter.notifyDataSetChanged();
                }
            }
        });
    }

    public ViewPager getViewPager() {
        return mViewPager;
    }

    public Page getCurrentPage() {
        if (mTabEnabled) {
            int currentItemIdx = mViewPager.getCurrentItem();
            return mPageList.get(currentItemIdx);
        }
        return mCurrentPage;
    }

    // Tabs

    private void updateTabs(List<MenuEntry> tabs) {

        // save old pages : all but current page
        List<Page> oldPageList = new ArrayList<>();
        oldPageList.addAll(mPageList);
        if (mPreviousPage != null) {
            oldPageList.add(mPreviousPage);
            mPreviousPage = null;
        }
        if (mNextPage != null) {
            oldPageList.add(mNextPage);
            mNextPage = null;
        }
        if (oldPageList.contains(mCurrentPage))
            oldPageList.remove(mCurrentPage);

        // where will be current page ?
        int currentPageIndex = 0;

        for (int i = 0; i < tabs.size(); i++) {
            MenuEntry tab = tabs.get(i);
            if (tab.selected)
                currentPageIndex = i;
        }

        // new tab configuration
        List<Page> newPageList = new ArrayList<>();

        // apply new configuration
        for (int i = 0; i < tabs.size(); i++) {
            MenuEntry tab = tabs.get(i);

            Page pageToAdd = null;

            // current page ?
            if (i == currentPageIndex) {
                pageToAdd = mCurrentPage;

            } else {
                String absoluteURL = mCurrentPage.resolveURL(tab.content);

                if (absoluteURL == null)
                    absoluteURL = mCurrentPage.getURL();

                // search if this page have been previously initialized

                for (Page page : oldPageList) {
                    if (page.getURL().equalsIgnoreCase(absoluteURL)) {
                        pageToAdd = page;
                    }
                }
                if (pageToAdd != null)
                    oldPageList.remove(pageToAdd);
                else
                    pageToAdd = new Page(this, absoluteURL);
            }

            newPageList.add(pageToAdd);
        }

        mPageList = newPageList;
        //mTabTitle = newTabTitle;
        mTabs = tabs;

        if (mPageList.size() > 1 && !mTabEnabled) {
            mTabEnabled = true;
            mViewPager.setAdapter(mTabPagerAdapter);
            //mViewPager.setCurrentItem(currentPageIndex);
        }

        mTabPagerAdapter.notifyDataSetChanged();

        mViewPager.setCurrentItem(currentPageIndex);
    }


    public class PageManagerTabAdaptater extends PagerAdapter {

        @Override
        public Object instantiateItem(ViewGroup collection, int position) {

            Page page = mPageList.get(position);

            View pageView = page.getView();

            collection.addView(pageView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

            return pageView;
        }

        @Override
        public void destroyItem(ViewGroup collection, int position, Object view) {
            collection.removeView((View) view);
        }

        @Override
        public int getCount() {
            return mPageList.size();
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            return view == object;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            MenuEntry menuEntry = mTabs.get(position);
            if (menuEntry.title != null && !menuEntry.title.isEmpty())
                return menuEntry.title;
            return "#" + (position + 1);
        }
    }

    public boolean initPreviousNext()
    {
        if (mTabEnabled)
            return false;

        if (mCurrentPage == null)
            return false;

        boolean shouldUpdate = false;
        if (mPreviousPage == null && mCurrentPage.previousPageUrl != null && mCurrentPage.previousPageUrl.isEmpty() == false)
        {
            mPreviousPage = new Page(this, mCurrentPage.previousPageUrl);
            shouldUpdate = true;
        }
        if (mNextPage == null && mCurrentPage.nextPageUrl != null && mCurrentPage.nextPageUrl.isEmpty() == false)
        {
            mNextPage = new Page(this, mCurrentPage.nextPageUrl);
            shouldUpdate = true;
        }
        return shouldUpdate;
    }

    // Previous / Next

    public void updatePreviousNext(Page origin)
    {
        if (mTabEnabled)
            return;
        if (origin != mCurrentPage)
            return;
        boolean shouldUpdate = false;
        shouldUpdate = shouldUpdate || initPreviousNext();
        if (shouldUpdate)
        {
            if (mPreviousNextPagerAdapter != null)
                mPreviousNextPagerAdapter.notifyDataSetChanged();
        }
    }

    public class PageManagerPreviousNextAdaptater extends PagerAdapter {

        private Page getPage(int i)
        {
            if (mPreviousPage == null && mNextPage == null)
                return mCurrentPage;
            if (mPreviousPage != null && mNextPage != null)
            {
                if (i == 0)
                    return mPreviousPage;
                if (i == 1)
                    return mCurrentPage;
                if (i == 2)
                    return mNextPage;
            }
            if (mPreviousPage != null && mNextPage == null)
            {
                if (i == 0)
                    return mPreviousPage;
                if (i == 1)
                    return mCurrentPage;
            }
            if (mPreviousPage == null && mNextPage != null)
            {
                if (i == 0)
                    return mCurrentPage;
                if (i == 1)
                    return mNextPage;
            }
            Log.e("PreviousNext", "should not reach this point");
            return mCurrentPage;
        }

        @Override
        public Object instantiateItem (ViewGroup container, int position)
        {
            Page page = getPage(position);

            if (page == null)
                return null;

            View pageView = page.getView();

            // insert view in container only if needed
            if (container.indexOfChild(pageView) == -1)
            {
                container.addView(pageView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            }

            return page;
        }

        @Override
        public void destroyItem (ViewGroup container, int position, Object object)
        {
            // we should keep fragment if it has only been moved
            if (object != null && object != mPreviousPage && object != mCurrentPage && object != mNextPage)
            {
                container.removeView(((Page)object).getView());
            }
        }

        @Override
        public int getCount() {
            int count = (mCurrentPage != null ? 1 : 0)  + (mPreviousPage != null ? 1 : 0) + (mNextPage != null ? 1 : 0);
            return count;
        }

        @Override
        public boolean isViewFromObject(View view, Object object)
        {
            boolean isView = ((Page)object).getView() == view;
            return isView;
        }

        public int getPagePosition(Page page) {
            int position = 0;

            if (page == mPreviousPage)
                return position;
            if (mPreviousPage != null)
                position++;
            if (page == mCurrentPage)
                return position;
            if (page == mNextPage)
                return position + 1;
            return -1;
        }

        @Override
        public int getItemPosition (Object object) {
            Page page = (Page)object;
            int position = getPagePosition(page);
            if (position == -1)
                return POSITION_NONE;
            return position;
        }
    }

    // AppDeckView

    public boolean apiCall(final ApiCall call) { /*** correction ***/

       return AppDeckApplication.getActivity().apiCall(call);

    }

    @Override
    public boolean shouldOverrideBackButton() {
        Page page = getCurrentPage();
        if (page.shouldOverrideBackButton())
            return true;
        return false;
    }

    public void evaluateJavascript(String js) {
        for (int i = 0; i < mPageList.size(); i++) {
            Page page = mPageList.get(i);
            page.evaluateJavascript(js);
        }
    }

    @Override
    public ViewConfig getViewConfig() {
        return checkViewConfig(getCurrentPage().getConfig());
    }

    public void onPause() {
        Page page = getCurrentPage();
        page.onPause();
    }

    public void onResume() {
        Page page = getCurrentPage();
        page.onResume();
    }

    public void destroy() {
        for (int i = 0; i < mPageList.size(); i++) {
            Page page = mPageList.get(i);
            page.destroy();
        }
    }

    private ViewConfig checkViewConfig(ViewConfig oldViewConfig) {

        if (mTabEnabled) {
            ViewConfig newViewConfig = oldViewConfig.copy();
            newViewConfig.tabs = mTabs;
            return newViewConfig;
        }

        return oldViewConfig;
    }

    public void onConfigurationChange(Page page, ViewConfig viewConfig) {

        if (page == mCurrentPage) {
            // update tabs ?
            if (viewConfig.tabs != null && viewConfig.tabs.size() > 0)
                updateTabs(viewConfig.tabs);
        }

        if (page == getCurrentPage()) {

            AppDeckApplication.getAppDeck().navigation.onViewConfigChange(this, checkViewConfig(viewConfig));
        }
    }

    @Override
    public View getView() {
        return mViewPager;
    }

    @Override
    public void onShow() {
        Page page = getCurrentPage();
        page.onShow();
    }

    @Override
    public void onHide() {
        Page page = getCurrentPage();
        page.onHide();
    }

    @Override
    public String getURL() {
        return getCurrentPage().getURL();
    }

    @Override
    public String resolveURL(String relativeURL) {
        return getCurrentPage().resolveURL(relativeURL);
    }

    @Override
    public void loadUrl(String relativeURL) {
        getCurrentPage().loadUrl(relativeURL);
    }
}
