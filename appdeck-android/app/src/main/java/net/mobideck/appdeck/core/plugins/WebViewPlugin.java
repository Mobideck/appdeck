package net.mobideck.appdeck.core.plugins;

import android.app.DatePickerDialog;
import android.content.DialogInterface;
import android.util.Log;
import android.view.View;
import android.widget.DatePicker;

import com.afollestad.materialdialogs.MaterialDialog;
import com.google.gson.JsonArray;
import net.mobideck.appdeck.UI.DatePickerDialogCustom;
import com.mobideck.appdeck.plugin.ApiCall;

import net.mobideck.appdeck.AppDeckApplication;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;

public class WebViewPlugin extends PluginAdaptater {

    public ArrayList<String> getCommands() {
        ArrayList<String> commands = new ArrayList<>();
        commands.add("load");
        commands.add("ready");
        commands.add("postmessage");
        commands.add("clearcookies");
        commands.add("select");
        commands.add("selectdate");
        commands.add("disable_pulltorefresh");
        commands.add("enable_pulltorefresh");
        commands.add("inhistory");
        return commands;
    }

    public boolean load(final ApiCall call) {
        Log.d(TAG, "load");
        return true;
    }

    public boolean ready(final ApiCall call) {
        Log.d(TAG, "ready");
        return true;
    }

    public boolean postmessage(final ApiCall call) {
        Log.d(TAG, "postmessage");
        String js = "try {app.receiveMessage("+call.inputJSON+".param);} catch (e) {}";
        AppDeckApplication.getAppDeck().evaluateJavascript(js);
        return true;
    }

    public boolean clearcookies(final ApiCall call) {
        Log.d(TAG, "clearcookies");
        AppDeckApplication.getAppDeck().evaluateJavascript("document.cookie.split(\";\").forEach(function(c) { document.cookie = c.replace(/^ +/, \"\").replace(/=.*/, \"=;expires=\" + new Date().toUTCString() + \";path=/\"); });");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        apiCall.smartWebView.clearCookies();
        return true;
    }


    public boolean disable_pulltorefresh(final ApiCall call) {
        Log.d(TAG, "disable_pulltorefresh");
        return true;
    }

    public boolean enable_pulltorefresh(final ApiCall call) {
        Log.d(TAG, "enable_pulltorefresh");
        return true;
    }

    public boolean inhistory(final ApiCall call) {
        Log.d(TAG, "inhistory");
        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        boolean isInCache = false;
        String relativeURL = call.inputObject.optString("param");
        URI url = null;
        try {
            url = new URI(apiCall.page.resolveURL(relativeURL));
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }
        if (url != null)
        {
            String absoluteURL = url.toString();
            //CacheResult value = this.appDeck.cache.isInCache(absoluteURL);
            //isInCache = value.isInCache;
        }
        Boolean result = Boolean.valueOf(isInCache);

        call.setResult(result);

        return true;
    }

    public boolean select(final ApiCall call) {
        Log.d(TAG, "select");

        net.mobideck.appdeck.core.ApiCall apiCall = (net.mobideck.appdeck.core.ApiCall)call;
        String title = call.paramObject.optString("title");
        JSONArray values = call.paramObject.optJSONArray("values");
        CharSequence[] items = new CharSequence[values.length()];
        String[] t = new String[values.length()];
        for (int i = 0; i < values.length(); i++) {
            items[i] = values.optString(i);
            t[i] = values.optString(i);
        }

        new MaterialDialog.Builder(AppDeckApplication.getActivity())
                .title(title)
                .items(t)
                .cancelable(false)
                .itemsCallbackSingleChoice(-1, new MaterialDialog.ListCallbackSingleChoice() {
                    @Override
                    public boolean onSelection(MaterialDialog dialog, View view, int which, CharSequence text) {
                        if (text != null)
                            call.sendCallbackWithResult("success", text.toString());
                        else
                            call.sendCallBackWithError("cancel");
                        call.sendPostponeResult(true);
                        return true;
                    }
                })
                .positiveText(android.R.string.ok)
                .show();

        call.postponeResult();

        return true;
    }

    public boolean selectdate(final ApiCall call) {
        Log.d(TAG, "selectdate");

        String title = call.paramObject.optString("title");
        String year = call.paramObject.optString("year");
        String month = call.paramObject.optString("month");
        String day = call.paramObject.optString("day");

        //call.postponeResult();

        DatePickerDialog.OnDateSetListener d = new DatePickerDialog.OnDateSetListener() {

            @Override
            public void onDateSet(DatePicker view, final int year, final int monthOfYear,
                                  final int dayOfMonth) {

                Log.d("Date", "selected");
                JSONObject result = new JSONObject();
                try {
                    result.put("year", String.valueOf(year));
                    result.put("month", String.valueOf(monthOfYear + 1));
                    result.put("day", String.valueOf(dayOfMonth));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                call.sendCallbackWithResult("success", result);
            }
        };

        int yearValue = call.paramObject.optInt("year");
        int monthValue = call.paramObject.optInt("month");
        int dayValue = call.paramObject.optInt("day");
        Calendar cal = GregorianCalendar.getInstance();
        cal.set(yearValue, monthValue - 1, dayValue);
        //if (yearValue == 0)
        yearValue = cal.get(Calendar.YEAR);
        //if (monthValue == 0)
        monthValue = cal.get(Calendar.MONTH);
        //if (dayValue == 0)
        dayValue = cal.get(Calendar.DAY_OF_MONTH);
        final DatePickerDialogCustom datepicker = new DatePickerDialogCustom(AppDeckApplication.getActivity(), d, yearValue, monthValue, dayValue);
        datepicker.setOnCancelListener(
                new DialogInterface.OnCancelListener() {
                    public void onCancel(DialogInterface dialog) {
                        //call.sendPostponeResult(false);
                        call.sendCallbackWithResult("error", "cancel");
                    }
                });
        datepicker.setOnDismissListener(new DialogInterface.OnDismissListener() {

            @Override
            public void onDismiss(DialogInterface dialog) {
                //call.sendPostponeResult(false);
                call.sendCallbackWithResult("error", "cancel");
            }
        });

        if (year.length() > 0)
            datepicker.setYearEnabled(false);
        if (month.length() > 0)
            datepicker.setMonthEnabled(false);
        if (day.length() > 0)
            datepicker.setDayEnabled(false);
        datepicker.setTitle(title);
        datepicker.show();

        return true;

    }
}
