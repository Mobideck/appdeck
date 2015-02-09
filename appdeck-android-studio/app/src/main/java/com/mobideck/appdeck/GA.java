package com.mobideck.appdeck;

import java.util.ArrayList;
import java.util.List;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

import android.content.Context;

public class GA
{
	
	AppDeck appDeck;
	
	GoogleAnalytics ga;
	
	List<Tracker> trackers;
	
	public static String globalTracker = "UA-39746493-1";

	GA(Context context)
	{
		appDeck = AppDeck.getInstance();
		trackers = new ArrayList<Tracker>();
		ga = GoogleAnalytics.getInstance(context);
	}
	
	public void addTracker(String trackerID)
	{
		Tracker tracker = ga.newTracker(trackerID);
				
		trackers.add(tracker);
	}
	

	public void view(String url)
	{
		for (int i = 0; i < trackers.size(); i++) {
			Tracker tracker = trackers.get(i);

			tracker.setScreenName(url);

			// get api key
			String api_key = appDeck.config.app_api_key;
			if (api_key == null)
				api_key = "none";
			
	        // Send the custom dimension value with a screen view.
	        // Note that the value only needs to be sent once.
			tracker.send(new HitBuilders.AppViewBuilder()
	            .setCustomDimension(1, appDeck.packageName)
	            .setCustomDimension(2, api_key)
	            .build()
	        );
						
		}	
	}
	

	public void event(String category, String action, String label, long value)
	{
		for (int i = 0; i < trackers.size(); i++)
		{
			Tracker tracker = trackers.get(i);

	        // Build and send an Event.
			tracker.send(new HitBuilders.EventBuilder()
	            .setCategory(category)
	            .setAction(action)
	            .setLabel(label)
	            .setValue(value)
	            .build());

		}
	}
	
	
}
