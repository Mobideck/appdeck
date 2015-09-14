package com.mobideck.appdeck;

import android.os.Handler;
import android.support.v4.util.ArrayMap;
//import android.util.ArrayMap;

/**
 * Created by Ofek on 19/08/2015.
 */
public class TaskScheduler extends Handler {
    private ArrayMap<Runnable,Runnable> tasks = new ArrayMap<>();
    public void scheduleAtFixedRate(final Runnable task,long delay,final long period) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                task.run();
                postDelayed(this, period);
            }
        };
        tasks.put(task, runnable);
        postDelayed(runnable, delay);
    }
    public void scheduleAtFixedRate(final Runnable task,final long period) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                task.run();
                postDelayed(this, period);
            }
        };
        tasks.put(task, runnable);
        runnable.run();
    }
    public void stop(Runnable task) {
        Runnable removed = tasks.remove(task);
        if (removed!=null) removeCallbacks(removed);
    }

}