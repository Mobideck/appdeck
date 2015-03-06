package com.mobideck.appdeck;

import android.app.Activity;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.graphics.drawable.shapes.Shape;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.webkit.CookieSyncManager;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

import java.net.URI;
import java.net.URISyntaxException;

public class PopUpFragment extends AppDeckFragment {

    public static final String TAG = "PopUpFragment";
    public static final String ARG_OBJECT = "object";

    FrameLayout layout;

    public PageFragmentSwap page;

    AppDeck appDeck;

    PopUpFragment()
    {

    }

    public static PopUpFragment newInstance(String absoluteURL)
    {
        PopUpFragment popup = new PopUpFragment();

        Bundle args = new Bundle();
        args.putString("absoluteURL", absoluteURL);
        popup.setArguments(args);

        return popup;
    }

    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        this.loader = (Loader)activity;
    }

	@Override
	public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
        this.appDeck = this.loader.appDeck;
        currentPageUrl = getArguments().getString("absoluteURL");
        this.screenConfiguration = this.appDeck.config.getConfiguration(currentPageUrl);
        page = PageFragmentSwap.newInstance(currentPageUrl);
    }
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        // Inflate the layout for this fragment
        rootView = (FrameLayout)inflater.inflate(R.layout.popup_layout, container, false);
        rootView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

/*        FrameLayout.LayoutParams pageLayoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        pageLayoutParams.gravity = Gravity.TOP | Gravity.CENTER;
        //webviewParams.weight = 1;
        layout.addView(page, pageLayoutParams);*/

        /*FragmentManager fragmentManager = getChildFragmentManager();
        FragmentTransaction ft = fragmentManager.beginTransaction();
        ft.add(container.getId(), page);
        ft.commitAllowingStateLoss();*/

        loader.disableMenu();

    	return rootView;
    }    

    @Override
    public void onStart() {
    	super.onStart();
    }


    @Override
    public void onResume() {
        super.onResume();
    };

    @Override
    public void onPause() {
        super.onPause();
    };

    @Override
    public void onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);
    }

    @Override
    public void onDestroyView()
    {
        super.onDestroyView();
    }

    @Override
    public void onDestroy()
    {
        super.onDestroy();
    }

    @Override
    public void onDetach() {
    	super.onDetach();
        loader.enableMenu();
    }	
	
}
