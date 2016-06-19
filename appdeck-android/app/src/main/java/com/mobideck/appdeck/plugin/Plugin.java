package com.mobideck.appdeck.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import java.util.ArrayList;

public interface Plugin {

    public void onActivityCreate(Activity activity);

    public void onActivityPause(Activity activity);

    public void onActivityResume(Activity activity);

    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data);

    public void onActivityDestroy(Activity activity);

    ArrayList<String> getCommands();

}
