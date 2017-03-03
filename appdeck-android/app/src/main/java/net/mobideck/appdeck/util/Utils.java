package net.mobideck.appdeck.util;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.LayerDrawable;
import android.net.Uri;
import android.os.Environment;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.graphics.ColorUtils;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.MenuItem;
import android.view.WindowManager;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;

import net.mobideck.appdeck.AppDeckApplication;

import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

public class Utils {

    public static String TAG = "Utils";

    public static int convertDpToPixels(float dp) {
        Context context = AppDeckApplication.getContext();
        int px = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, context.getResources().getDisplayMetrics());
        return px;
    }

    public static int computeHeight(String height) {
        boolean percent = false;
        if (height == null || height.isEmpty())
            return 0;
        if (height.contains("%")) {
            percent = true;
            height = height.substring(0, height.indexOf("%"));
        }
        int value = Integer.valueOf(height);
        if (percent) {
            return (AppDeckApplication.getAppDeck().deviceInfo.screenHeight * value / 100);
        }
        return Utils.convertDpToPixels(value);
    }

    public static String getUid(Context context) {
        String deviceId = null;
        try {
            TelephonyManager telManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
            if (telManager != null)
                deviceId = telManager.getDeviceId();
            if (telManager != null && deviceId == null)
                deviceId = telManager.getSimSerialNumber();
            if (telManager != null && deviceId == null)
                deviceId = telManager.getSubscriberId();
        } catch (Exception e) {

        }
        if (deviceId == null) {
            SharedPreferences preferences = context.getSharedPreferences("AppDeck", Context.MODE_PRIVATE);
            long uid = preferences.getLong("uid", 0);
            if (uid == 0) {
                uid = System.currentTimeMillis();
                SharedPreferences.Editor editor = preferences.edit();
                editor.putLong("uid", uid);
                editor.apply();
            }
            deviceId = String.valueOf(uid);
        }
        return deviceId;
    }

    /**
     * Checks if the device is a tablet or a phone
     *
     * @param context
     *            The Activity Context.
     * @return Returns true if the device is a Tablet
     */
    public static boolean isTabletDevice(Context context) {
        // Verifies if the Generalized Size of the device is XLARGE to be
        // considered a Tablet
        boolean xlarge = ((context.getResources().getConfiguration().screenLayout &
                android.content.res.Configuration.SCREENLAYOUT_SIZE_MASK) >=
                android.content.res.Configuration.SCREENLAYOUT_SIZE_LARGE);

        // If XLarge, checks if the Generalized Density is at least MDPI
        // (160dpi)
        if (xlarge) {
            DisplayMetrics metrics = new DisplayMetrics();
            //Activity activity = (Activity) activityContext;
            //activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);

            WindowManager wm = (WindowManager)context.getSystemService(Context.WINDOW_SERVICE);
            wm.getDefaultDisplay().getMetrics(metrics);

            // MDPI=160, DEFAULT=160, DENSITY_HIGH=240, DENSITY_MEDIUM=160,
            // DENSITY_TV=213, DENSITY_XHIGH=320
            if (metrics.densityDpi == DisplayMetrics.DENSITY_DEFAULT
                    || metrics.densityDpi == DisplayMetrics.DENSITY_HIGH
                    || metrics.densityDpi == DisplayMetrics.DENSITY_MEDIUM
                    || metrics.densityDpi == DisplayMetrics.DENSITY_TV
                    || metrics.densityDpi == DisplayMetrics.DENSITY_XHIGH
                    || metrics.densityDpi == DisplayMetrics.DENSITY_XXHIGH
                    || metrics.densityDpi == DisplayMetrics.DENSITY_XXXHIGH) {

                // Yes, this is a tablet!
                return true;
            }
        }

        // No, this is not a tablet!
        return false;
    }

    public static String md5(String input)
    {
        try {
            String result = input;
            if(input != null) {
                MessageDigest md;
                md = MessageDigest.getInstance("MD5");
                md.update(input.getBytes());
                BigInteger hash = new BigInteger(1, md.digest());
                result = hash.toString(16);
                while(result.length() < 32) { //40 for SHA-1
                    result = "0" + result;
                }
            }
            return result;
        } catch (NoSuchAlgorithmException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } //or "SHA-1"
        return null;
    }

    public static Drawable getColorDrawable(List<String> colors)
    {
        int color1 = Color.WHITE;
        int color2 = Color.WHITE;

        GradientDrawable gd = new GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                new int[] {color1, color2});
        gd.setCornerRadius(0f);
        return gd;
    }

    public static int parseColor(String colorTxt)
    {
        // try android parser
        try {
            return Color.parseColor(colorTxt);
        } catch (Exception e) {
        }
        // try by appending #
        try {
            return Color.parseColor("#"+colorTxt);
        } catch (Exception e) {
        }
        // error case
        return Color.TRANSPARENT;
    }

    public static int parseColor(String colorTxt, float alpha)
    {
        return ColorUtils.setAlphaComponent(Utils.parseColor(colorTxt), Math.round(255 * alpha));
        /*int color = Utils.parseColor(colorTxt);
        int red = Color.red(color);
        int green = Color.green(color);
        int blue = Color.blue(color);
        return Color.argb(Math.round(255 * alpha), red, green, blue);*/
    }

    public static Pattern[] initRegexp(List<String> urlRegexp) {
        if (urlRegexp == null) {
            return new Pattern[0];
        }
        Pattern [] patterns = new Pattern[urlRegexp.size()];
        for (int i = 0; i < urlRegexp.size(); i++) {
            String regexp = urlRegexp.get(i).trim();
            if (regexp.isEmpty()) {
                patterns[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
                continue;
            }
            try {
                Pattern p = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
                patterns[i] = p;
            } catch (PatternSyntaxException e) {
                Log.w(TAG, "Invalid Regexp #"+i+": "+regexp);
                patterns[i] = Pattern.compile("^$", Pattern.CASE_INSENSITIVE);
            }
        }
        return patterns;
    }
/*
    public static MenuItem setMenuItemAvailable(MenuItem menuItem, boolean available)
    {
        if (menuItem == null)
            return null;
        if (available)
        {
            menuItem.setEnabled(true);
            if (menuItem.getIcon() != null)
                menuItem.getIcon().setAlpha(255);
        } else {
            menuItem.setEnabled(false);
            if (menuItem.getIcon() != null)
                menuItem.getIcon().setAlpha(64);
        }
        return menuItem;
    }
*/
    public static String streamGetContent(InputStream is)
    {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int length = 0;
            while ((length = is.read(buffer)) != -1) {
                baos.write(buffer, 0, length);
            }
            return baos.toString();
        } catch (IOException e1) {
        }
        return null;
    }

    public static JSONObject streamGetJSONObject(InputStream stream) {
        String json = Utils.streamGetContent(stream);
        JSONObject node = null;
        if (json != null)
        {
            try {
                node = (JSONObject) new JSONTokener(json).nextValue();
                stream.close();
            } catch (Exception e) {
                //e.printStackTrace();
                node = null;
            }
        }
        return node;
    }

    public static boolean streamToFile(InputStream is , File targetFile) {
        try {
            OutputStream outStream = new FileOutputStream(targetFile);
            byte[] buffer = new byte[8 * 1024];
            int bytesRead;
            while ((bytesRead = is.read(buffer)) != -1) {
                outStream.write(buffer, 0, bytesRead);
            }
            is.close();
            outStream.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static void filePutContents(String filePath, final String fileContents) {
        try {
            FileOutputStream stream = new FileOutputStream(filePath);
            try {
                stream.write(fileContents.getBytes());
            } finally {
                stream.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static String fileGetContents(String filePath) {
        try {
            File file = new File(filePath);
            int length = (int) file.length();
            byte[] bytes = new byte[length];
            FileInputStream in = new FileInputStream(file);
            try {
                in.read(bytes);
            } finally {
                in.close();
            }
            return new String(bytes);
        } catch (IOException e) {
            //Logger.logError(TAG, e);
        }
        return null;
    }

    public static InputStream streamFromFilePath(String filePath)
    {
        try {
            File cache_file = new File(filePath);
            // file exist in cache, we use it
            if (cache_file.exists())
            {
                return new FileInputStream(cache_file);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String getApplicationName(Context context) {
        int stringId = context.getApplicationInfo().labelRes;
        return context.getString(stringId);
    }

    public static Bitmap cropToSquare(Bitmap bitmap) {
        int width  = bitmap.getWidth();
        int height = bitmap.getHeight();
        int newWidth = (height > width) ? width : height;
        int newHeight = (height > width)? height - ( height - width) : height;
        int cropW = (width - height) / 2;
        cropW = (cropW < 0)? 0: cropW;
        int cropH = (height - width) / 2;
        cropH = (cropH < 0)? 0: cropH;
        Bitmap cropImg = Bitmap.createBitmap(bitmap, cropW, cropH, newWidth, newHeight);
        return cropImg;
    }

    public static boolean equals(String string1, String string2) {
        if (string1 == null && string2 == null)
            return true;
        if (string1 == null || string2 == null)
            return false;
        return string1.equalsIgnoreCase(string2);
    }

    // System Colors
    public static int infoBlueColor() {
        return Color.rgb(47, 112, 225);
    }

    public static int successColor() {
        return Color.rgb(83, 215, 106);
    }

    public static int warningColor() {
        return Color.rgb(221, 170, 59);
    }

    public static int dangerColor() {
        return Color.rgb(229, 0, 15);
    }

    public static int antiqueWhiteColor() {
        return Color.rgb(250, 235, 215);
    }

/*
    public static Drawable getRotateDrawable(final Drawable d, final float angle) {
        Drawable[] arD = {
                d
        };
        final LayerDrawable drawable = new LayerDrawable(arD) {
            @Override
            public void draw(final Canvas canvas) {
                canvas.save();
                canvas.rotate(angle, d.getMinimumWidth() / 2, d.getMinimumWidth() / 2);
                super.draw(canvas);
                canvas.restore();
            }
        };
        return drawable;
    }*/

}
