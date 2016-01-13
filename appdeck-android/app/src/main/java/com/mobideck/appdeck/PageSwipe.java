package com.mobideck.appdeck;

import com.mobideck.appdeck.R;

import android.animation.Animator;
import android.animation.AnimatorInflater;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;

public class PageSwipe extends AppDeckFragment {

	public static final String TAG = "PageSwipe";
	public static final String ARG_OBJECT = "object";
	
	FrameLayout layout;
	 
	AppDeck appDeck;
	
	public PageFragmentSwap previousPage;
	public PageFragmentSwap currentPage;
	public PageFragmentSwap nextPage;
	
	protected Fragment.SavedState previousPageState;
	protected Fragment.SavedState currentPageState;
	protected Fragment.SavedState nextPageState;
	
	PageSwipeAdapter adapter;

    ViewPagerFixed pager;
	
	public boolean ready = false;

	public View circularView;

	public static PageSwipe newInstance(String absoluteURL)
	{
		PageSwipe pageSwipe = new PageSwipe();

	    Bundle args = new Bundle();
	    args.putString("absoluteURL", absoluteURL);
	    pageSwipe.setArguments(args);

	    return pageSwipe;
	}	
	
	@Override
	public void onAttach (Activity activity)
	{
		super.onAttach(activity);
		this.loader = (Loader)activity;
	}
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
		this.appDeck = this.loader.appDeck;    	
    	currentPageUrl = getArguments().getString("absoluteURL");
    	if (this.appDeck != null && this.appDeck.config != null)
			this.screenConfiguration = this.appDeck.config.getConfiguration(currentPageUrl);
    	currentPage = PageFragmentSwap.newInstance(currentPageUrl);
		currentPage.event = this.event;
		currentPage.loader = this.loader;
    	currentPage.pageSwipe = this;    	
	}
	
	int currentPageIdx;
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
    	
        // Inflate the layout for this fragment
    	//pager = new CustomViewPager(getActivity());
    	pager = new ViewPagerFixed(loader);
        //pager.setBackground(appDeck.config.app_background_color.getDrawable());
        //pager.setLayerType(View.LAYER_TYPE_HARDWARE, null);
    	pager.setOffscreenPageLimit(2);
    	pager.setId(loader.findUnusedId(0x1000));
    	adapter = new PageSwipeAdapter(getChildFragmentManager(), this);
    	pager.setAdapter(adapter);

        pager.addOnPageChangeListener(new OnPageChangeListener() {

			@Override
			public void onPageSelected(int position) {
				currentPageIdx = position;
			}

			@Override
			public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

				if (position == 0 && previousPage != null)
				{
					previousPage.setIsOnScreen(true);
				}
				if (position == 1 && nextPage != null)
				{
					nextPage.setIsOnScreen(true);
				}
			}

			@Override
			public void onPageScrollStateChanged(int state) {
				// scroll just end, we check if we should update page
				if (state == ViewPager.SCROLL_STATE_IDLE) {
					// if only one page ... there is nothing to do
					if (adapter.getCount() <= 1)
						return;
					int position = currentPageIdx;
					Log.i("PageSwipe", "position " + position);
					if (position == 0 && previousPage == null)
						return;
					//if (position == 1)
					//	return;
					currentPage.setIsMain(false);
					if (position == 1 && previousPage == null && nextPage != null) {
						previousPage = currentPage;
						currentPage = nextPage;
						nextPage = null;
					}
					if (position == 0) {
						nextPage = currentPage;
						currentPage = previousPage;
						previousPage = null;
					}
					if (position == 2) {
						previousPage = currentPage;
						currentPage = nextPage;
						nextPage = null;
					}
					currentPage.setIsMain(true);
					initPreviousNext();
					adapter.notifyDataSetChanged();
				}
			}
		});    	
    	
//        pager.requestTransparentRegion(pager);
        
        if (savedInstanceState != null)
        {
        	Log.i(TAG, "onCreateView with State");
        }
        
        //return pager;
                
        layout = (FrameLayout)inflater.inflate(R.layout.activity_page_swipe, container, false);
        FrameLayout.LayoutParams webviewParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
		webviewParams.gravity = Gravity.TOP | Gravity.CENTER; 
		//webviewParams.weight = 1;	        
        layout.addView(pager, webviewParams);

		//circularView = layout.findViewById(R.id.circualView);
		//layout.bringChildToFront(circularView);

    	return layout;
    }
    
    /*
    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim)
    {
        final int animatorId = (enter) ? R.anim.enter : R.anim.exit;
        final Animation anim = AnimationUtils.loadAnimation(getActivity(), animatorId);
        return anim;
        //return super.onCreateAnimation(transit, enter, nextAnim);
   }     
    */
    
    
    @Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
    	super.onViewCreated(view, savedInstanceState);
        
    	if (enablePushAnimation && currentPage.enablePushAnimation)
    	{
    		loader.pushFragmentAnimation(this);
    	}
    }
    
    @Override
    public void onDestroyView()
    {
    	super.onDestroyView();
    	Log.i(TAG, "onDestroyView");
    	//currentPage = previousPage = nextPage = null;
    	//adapter.notifyDataSetChanged();
    }
    
    @Override
    public void onStart() {
    	super.onStart();
    }
    
    @Override
    public void onPause() {
    	if (previousPage != null)
			previousPage.onPause();
		if (nextPage != null)
			nextPage.onPause();
		if (currentPage != null)
			currentPage.onPause();
    	super.onPause();
        /*final ObjectAnimator invisToVis = ObjectAnimator.ofFloat(getView(), "rotationY",
                -90f, 0f);
        invisToVis.setDuration(300);
        invisToVis.setInterpolator(new DecelerateInterpolator());
        
        invisToVis.start();*/
    	//if (adview != null)
    	//	adview.pause();

    }
    
    @Override
    public void onResume() {
    	super.onResume();
		if (previousPage != null)
			previousPage.onResume();
		if (nextPage != null)
			nextPage.onResume();
		if (currentPage != null)
			currentPage.onResume();
    	//if (adview != null)
    	//	adview.resume();
    }
    
    @Override
    public void onDetach() {
    	super.onDetach();
    	// we always set sliding menu as enabled in case pager disable it
    	loader.enableMenu();
    }

    @Override
    public void onSaveInstanceState(Bundle outState)
    {
    	super.onSaveInstanceState(outState);
    	Log.i(TAG, "onSaveInstanceState");
    }

/*
    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState)
    {
      super.onRestoreInstanceState(savedInstanceState);
      Log.i(TAG, "onRestoreInstanceState");
    }*/

	@Override
	public void onHiddenChanged(boolean hidden)
	{
		if (getActivity() == null)
			return;
    	FragmentManager fragmentManager = getChildFragmentManager();
    	FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
    	if (hidden)
    	{
        	if (previousPage != null)
        		fragmentTransaction.hide(previousPage);
        	if (currentPage != null)
        		fragmentTransaction.hide(currentPage);
        	if (nextPage != null)
        		fragmentTransaction.hide(nextPage);    	
    	}
    	else
    	{
        	if (previousPage != null)
        		fragmentTransaction.show(previousPage);
        	if (currentPage != null)
        		fragmentTransaction.show(currentPage);
        	if (nextPage != null)
        		fragmentTransaction.show(nextPage);    	
    		
    	}
   		fragmentTransaction.commitAllowingStateLoss();		
	}    
    
    public void setIsMain(boolean isMain)
    {
    	if (currentPage != null)	
    		currentPage.setIsMain(isMain);
    }

    public String resolveURL(String relativeUrl)
    {
        if (currentPage != null)
            return currentPage.resolveURL(relativeUrl);
        return super.resolveURL(relativeUrl);
    }

    
	@Override
	public void reload(boolean forceReload)
	{
		super.reload(forceReload);
		if (previousPage != null)
			previousPage.reload(forceReload);
		if (currentPage != null)
			currentPage.reload(forceReload);
		if (nextPage != null)
			nextPage.reload(forceReload);
	}
    
    public boolean initPreviousNext()
    {
    	if (currentPage == null)
    		return false;
    	
    	if (appDeck.isLowSystem)
    		return false;
    	
    	boolean shouldUpdate = false;    	
    	if (previousPage == null && currentPage.previousPageUrl != null && currentPage.previousPageUrl.isEmpty() == false)
    	{
    		previousPage = PageFragmentSwap.newInstance(currentPage.previousPageUrl);
			previousPage.loader = this.loader;
    		previousPage.pageSwipe = this;
    		shouldUpdate = true;
    	}
    	if (nextPage == null && currentPage.nextPageUrl != null && currentPage.nextPageUrl.isEmpty() == false)
    	{
    		nextPage = PageFragmentSwap.newInstance(currentPage.nextPageUrl);
			nextPage.loader = this.loader;
    		nextPage.pageSwipe = this;
    		shouldUpdate = true;
    	}
    	return shouldUpdate;
    }
    
    public void updatePreviousNext(AppDeckFragment origin)
    {
    	if (origin != currentPage)
    		return;
    	boolean shouldUpdate = false;
    	shouldUpdate = shouldUpdate || initPreviousNext();
    	if (shouldUpdate)
    	{
    		if (adapter != null)
    			adapter.notifyDataSetChanged();
    	}
    }
    
    
    private class PageSwipeAdapter extends PagerAdapter {

    	PageSwipe pageSwipe;
    	FragmentManager fm;

        PageSwipeAdapter(FragmentManager fm, PageSwipe pageSwipe) {
            this.fm = fm;
            this.pageSwipe = pageSwipe;
        }

/*        @Override
        public void startUpdate (ViewGroup container)
        {
        	
        }
        
        @Override
        public void finishUpdate (ViewGroup container)
        {

        }*/
        
        AppDeckFragment getView(int i)
        {
        	if (pageSwipe.previousPage == null && pageSwipe.nextPage == null)
        		return pageSwipe.currentPage;
        	if (pageSwipe.previousPage != null && pageSwipe.nextPage != null)
        	{
        		if (i == 0)
        			return pageSwipe.previousPage;
        		if (i == 1)
        			return pageSwipe.currentPage;
        		if (i == 2)
        			return pageSwipe.nextPage;
        	}
        	if (pageSwipe.previousPage != null && pageSwipe.nextPage == null)
        	{
        		if (i == 0)
        			return pageSwipe.previousPage;
        		if (i == 1)
        			return pageSwipe.currentPage;
        	}
        	if (pageSwipe.previousPage == null && pageSwipe.nextPage != null)
        	{
        		if (i == 0)
        			return pageSwipe.currentPage;
        		if (i == 1)
        			return pageSwipe.nextPage;
        	}
        	Log.e("PageSwipe", "should not reach this point");
        	return pageSwipe.currentPage;        	
        }
        
        @Override
        public Object instantiateItem (ViewGroup container, int position)
        {
        	AppDeckFragment fragment = getView(position);
        	
        	if (fragment == null)
        		return null;
        	
        	// insert fragment in container only if needed
        	if (container.indexOfChild(fragment.getView()) == -1)
        	{
        		FragmentTransaction ft = fm.beginTransaction();
        		ft.add(container.getId(), fragment);
        		ft.commitAllowingStateLoss();
        		//fragment.oldPosition = position;
        	}
        	
        	return fragment;
        }
        
        @Override
        public void destroyItem (ViewGroup container, int position, Object object)
        {
        	// we should keep fragment if it has only been moved 
        	if (object != null && object != previousPage && object != currentPage && object != nextPage)
        	{
	    		FragmentTransaction ft = fm.beginTransaction();
	    		ft.remove((Fragment)object);
	    		ft.commitAllowingStateLoss();
        	}
        }
        
		@Override
		public int getCount() {
            int count = (pageSwipe.currentPage != null ? 1 : 0)  + (pageSwipe.previousPage != null ? 1 : 0) + (pageSwipe.nextPage != null ? 1 : 0);
            return count;
		}

		@Override
		public boolean isViewFromObject(View view, Object object)
		{
			boolean isView = ((Fragment)object).getView() == view;
			return isView;
		}
    	
/*		@Override
		public void setPrimaryItem (View container, int position, Object object)
		{
			
		}*/
		
	    public int getFragmentPosition (AppDeckFragment fragment) {
	    	int position = 0;
        	
        	if (fragment == previousPage)
        		return position;
        	if (previousPage != null)
        		position++;
        	if (fragment == currentPage)
        		return position;
        	if (fragment == nextPage)
        		return position + 1;        	

        	return -1;
	    }

		
		@Override
	    public int getItemPosition (Object object) {
			AppDeckFragment fragment = (AppDeckFragment)object;
	    	int position = getFragmentPosition(fragment);
	    	if (position == -1)
	    		return POSITION_NONE;
	    	return position;
	    }
				
		/*
	    @Override
	    public Parcelable saveState()
	    {
	    	Bundle state = new Bundle();
	    	if (previousPage != null)
	    		fm.putFragment(state, "previousPage", previousPage);
	    	if (currentPage != null)
	    		fm.putFragment(state, "currentPage", currentPage);
	    	if (nextPage != null)
	    		fm.putFragment(state, "nextPage", nextPage);
	        return state;
	    }

	    @Override
	    public void restoreState(Parcelable state, ClassLoader loader)
	    {
            Bundle bundle = (Bundle)state;
            bundle.setClassLoader(loader);
            previousPage = (PageFragmentSwap)fm.getFragment(bundle, "previousPage");
            currentPage = (PageFragmentSwap)fm.getFragment(bundle, "currentPage");
            nextPage = (PageFragmentSwap)fm.getFragment(bundle, "nextPage");
	    }	*/	
    }

	public String evaluateJavascript(String js)
	{
		if (previousPage != null)
			previousPage.evaluateJavascript(js);
		if (currentPage != null)
			currentPage.evaluateJavascript(js);
		if (nextPage != null)
			nextPage.evaluateJavascript(js);
		return "";
	}
}

