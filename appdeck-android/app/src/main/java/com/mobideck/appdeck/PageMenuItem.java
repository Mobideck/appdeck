package com.mobideck.appdeck;

import java.net.URI;

import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

import android.app.Activity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.animation.AnimatorSet;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;

public class PageMenuItem {

	public String title;
	public String icon;
	public String type;
	public String content;
	public int badge = 0;
	
	public MenuItem menuItem;
	
	private AppDeck appDeck;
	
	boolean isValid = false;
	boolean available = true;
	
	boolean rotateOnRefresh = false;
	
	AppDeckFragment fragment;
	
	BitmapDrawable draw;
	
	public PageMenuItem(String title, String icon, String type, String content, String badge, URI baseUrl, AppDeckFragment fragment)
	{
		appDeck = AppDeck.getInstance();
		this.fragment = fragment;

		this.title = title;
		
		if (icon == null)
			icon = appDeck.config.icon_action.toString();
		else if (icon.equalsIgnoreCase("!action") == true)
            icon = appDeck.config.icon_action.toString();
        else if (icon.equalsIgnoreCase("!ok") == true)
            icon = appDeck.config.icon_ok.toString();
		else if (icon.equalsIgnoreCase("!cancel") == true)
            icon = appDeck.config.icon_cancel.toString();
        else if (icon.equalsIgnoreCase("!close") == true)
            icon = appDeck.config.icon_close.toString();
        else if (icon.equalsIgnoreCase("!config") == true)
            icon = appDeck.config.icon_config.toString();
        else if (icon.equalsIgnoreCase("!info") == true)
            icon = appDeck.config.icon_info.toString();
        else if (icon.equalsIgnoreCase("!menu") == true)
            icon = appDeck.config.icon_menu.toString();
        else if (icon.equalsIgnoreCase("!next") == true)
            icon = appDeck.config.icon_next.toString();
        else if (icon.equalsIgnoreCase("!previous") == true)
            icon = appDeck.config.icon_previous.toString();
        else if (icon.equalsIgnoreCase("!refresh") == true)
        {
            icon = appDeck.config.icon_refresh.toString();
            rotateOnRefresh = true;
        }
        else if (icon.equalsIgnoreCase("!search") == true)
            icon = appDeck.config.icon_search.toString();
        else if (icon.equalsIgnoreCase("!up") == true)
            icon = appDeck.config.icon_up.toString();
        else if (icon.equalsIgnoreCase("!down") == true)
            icon = appDeck.config.icon_down.toString();
        else if (icon.equalsIgnoreCase("!user") == true)
            icon = appDeck.config.icon_user.toString();
        else if (icon.equalsIgnoreCase("") == true)
            icon = appDeck.config.icon_action.toString();
        else if (baseUrl != null)
        	icon = baseUrl.resolve(icon).toString();
		
		this.icon = icon;
		this.type = type;
		this.content = content;

        try {
            this.badge = Integer.parseInt(badge);
        } catch (Exception e) {

        }
	}
	
	public void cancel()
	{
		isValid = false;
	}
	
	public void setAvailable(boolean available)
	{
		Utils.setMenuItemAvailable(menuItem, available);
		this.available = available;
	}
	
	Drawable rotateDrawable(Drawable d, final float angle) {
	    // Use LayerDrawable, because it's simpler than RotateDrawable.
	    Drawable[] arD = {
	        d
	    };
	    return new LayerDrawable(arD) {
	        @Override
	        public void draw(Canvas canvas) {
	            canvas.save();
	            canvas.rotate(angle);
	            super.draw(canvas);
	            canvas.restore();
	        }
	    };
	}	
	
	public void setMenuItem(MenuItem menuItem, final Loader loader, Menu menu)
	{
		isValid = true;
        this.menuItem = menuItem;
        this.menuItem.setTitle(title);
        //this.menuItem.setActionView(ActionItemBadge.BadgeStyles.DARK_GREY.getLayout());


        //this.menuItem.setShowAsAction(true);

        //ActionItemBadge.update(this, menu.findItem(R.id.item_samplebadge), FontAwesome.Icon.faw_android, ActionItemBadge.BadgeStyles.DARK_GREY, badgeCount);
        Utils.downloadIcon(icon, appDeck.actionBarHeight, new SimpleMenuItemImageLoadingListener(this) {
            @Override
            public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
                this.pageMenuItem.draw = new BitmapDrawable(loader.getResources(), loadedImage);
                this.pageMenuItem.draw.setAntiAlias(true);
                if (isValid) {
		    		/*ImageView myView = new ImageView(fragment.loader);
		    		myView.setImageDrawable(this.pageMenuItem.draw);
		    		this.pageMenuItem.menuItem.setActionView(myView);*/

                    BadgeDrawable badgeDrawable = new BadgeDrawable(loader);
                    badgeDrawable.setCount(this.pageMenuItem.badge);
                    Drawable[] layers = new Drawable[2];
                    layers[0] = this.pageMenuItem.draw;
                    layers[1] = badgeDrawable;
                    LayerDrawable layer = new LayerDrawable(layers);

                    this.pageMenuItem.menuItem.setIcon(layer);

                    /*
                    if (this.pageMenuItem.badge != null && this.pageMenuItem.badge.length() > 0)
                        ActionItemBadge.update(loader, this.pageMenuItem.menuItem, this.pageMenuItem.draw, ActionItemBadge.BadgeStyles.RED, Integer.parseInt(this.pageMenuItem.badge));
                    else
                        this.pageMenuItem.menuItem.setIcon(this.pageMenuItem.draw);//.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                    */

                    //IconicsDrawable iconDraw = new IconicsDrawable(loader, icon)/*.color()*/.actionBar();


                    //ActionItemBadge.update(loader, this.pageMenuItem.menuItem, this.pageMenuItem.draw, ActionItemBadge.BadgeStyles.RED, 4);

                    this.pageMenuItem.menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM | MenuItem.SHOW_AS_ACTION_WITH_TEXT);

                    //ActionItemBadge.update(loader, this.pageMenuItem.menuItem, this.pageMenuItem.draw, ActionItemBadge.BadgeStyles.DARK_GREY, 42);

                    rotate();
                    //this.pageMenuItem.menuItem.setIcon(this.pageMenuItem.draw).setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                }
                this.pageMenuItem.setAvailable(this.pageMenuItem.available);
            }
        }, loader);
	}
	
    public class SimpleMenuItemImageLoadingListener extends SimpleImageLoadingListener
    {
    	public PageMenuItem pageMenuItem;
    	
    	public SimpleMenuItemImageLoadingListener(PageMenuItem pageMenuItem)
    	{
    		this.pageMenuItem = pageMenuItem;
    	}
    }	

    AnimatorSet set;
    
    public void rotate()
    {    	
    	if (true)
    		return;
		ImageView myView = new ImageView(fragment.loader);
		myView.setImageDrawable(this.draw);
		
    	//Animation animation = AnimationUtils.loadAnimation(fragment.loader, R.anim.rotate_around_center_point);
        //myView.startAnimation(animation);    	
		
		/*
		set = new AnimatorSet();
		set.playTogether(
		    ObjectAnimator.ofFloat(myView, "rotation", 0, 360)
		);
		set.addListener(new AnimatorListenerAdapter() {
			 
			@Override
			public void onAnimationEnd(Animator animation) {
			    super.onAnimationEnd(animation);
			    set.start();
			}
			 
			});
		set.setDuration(1000).start();*/
		
		this.menuItem.setActionView(myView);    	
    }
    
    public void fire()
    {
    	if (rotateOnRefresh)
    	{
    		//rotate();
//    		this.pageMenuItem.menuItem.setIcon(this.pageMenuItem.draw).setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);

    		
    	}
        // ask fragment to handle URL
		fragment.loadUrl(content);
    }
    
}
