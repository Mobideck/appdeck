package com.mobideck.appdeck;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.Reader;
import java.io.Writer;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.math.BigInteger;
import java.net.ServerSocket;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Random;
import java.util.Scanner;

import org.apache.commons.io.IOUtils;

//import org.apache.commons.io.IOUtils;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.assist.ImageSize;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.process.BitmapProcessor;
import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Environment;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.view.ViewGroup.LayoutParams;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.DatePicker;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;

public class Utils {
    public static final int IO_BUFFER_SIZE = 8 * 1024;

    private Utils() {};

    @SuppressLint("NewApi")
	public static boolean isExternalStorageRemovable() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
            return Environment.isExternalStorageRemovable();
        }
        return true;
    }

    public static File getExternalCacheDir(Context context) {
        if (hasExternalCacheDir()) {
            return context.getExternalCacheDir();
        }

        // Before Froyo we need to construct the external cache dir ourselves
        final String cacheDir = "/Android/data/" + context.getPackageName() + "/cache/";
        return new File(Environment.getExternalStorageDirectory().getPath() + cacheDir);
    }

    public static boolean hasExternalCacheDir() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.FROYO;
    }
 
    
    public static void downloadImage(String url, int maxHeight, SimpleImageLoadingListener listener, Context context)
    {
    	AppDeck appDeck = AppDeck.getInstance();
    	
    	final int height = maxHeight;
    	DisplayImageOptions options = appDeck.getDisplayImageOptionsBuilder()
        .preProcessor(new BitmapProcessor() {
			
			@Override
			public Bitmap process(Bitmap in) {
				// TODO Auto-generated method stub
            	int width = in.getWidth() * height / in.getHeight();
            	if (width > 0 && height > 0)
            		return Bitmap.createScaledBitmap(in, width, height, true);
            	return in;
			}
		})
        .build();
        
        // Load image, decode it to Bitmap and return Bitmap to callback
        //appDeck.imageLoader.loadImage(url, options, listener);
        ImageSize targetSize = new ImageSize(0, 0);
        ImageView fakeImage = new ImageView(context);
        fakeImage.setLayoutParams(new LayoutParams(targetSize.getWidth(), targetSize.getHeight()));
        fakeImage.setScaleType(ScaleType.CENTER_CROP);
        appDeck.imageLoader.displayImage(url, fakeImage, options, new Utils.FakeImageSimpleImageLoadingListener(fakeImage, listener) {});        
        
    }
    
    public static void downloadIcon(String url, final int maxHeight, SimpleImageLoadingListener listener, Context context)
    {
    	AppDeck appDeck = AppDeck.getInstance();
    	
    	DisplayImageOptions options = appDeck.getDisplayImageOptionsBuilder()
        .preProcessor(new BitmapProcessor() {
			
			@Override
			public Bitmap process(Bitmap in) {
				// TODO Auto-generated method stub
            	int height = maxHeight;
            	int width = in.getWidth() * height / in.getHeight();
            	if (width > 0 && height > 0)
            		return Bitmap.createScaledBitmap(in, width, height, true);
            	return in;
			}
		})
        .build();

     // Load image, decode it to Bitmap and return Bitmap to callback
        ImageSize targetSize = new ImageSize(maxHeight, maxHeight); // result Bitmap will be fit to this size
        //appDeck.imageLoader.loadImage(url, targetSize, options, listener);

        ImageView fakeImage = new ImageView(context);
        fakeImage.setLayoutParams(new LayoutParams(targetSize.getWidth(), targetSize.getHeight()));
        fakeImage.setScaleType(ScaleType.CENTER_CROP);
        appDeck.imageLoader.displayImage(url, fakeImage, options, new Utils.FakeImageSimpleImageLoadingListener(fakeImage, listener) {});        

    }    

    public static class FakeImageSimpleImageLoadingListener extends SimpleImageLoadingListener {
        protected ImageView fakeImageView;
        protected SimpleImageLoadingListener listener;

        public FakeImageSimpleImageLoadingListener(ImageView fakeImageView, SimpleImageLoadingListener listener) {
            this.fakeImageView = fakeImageView;
            this.listener = listener;
        }
        
        @Override
        public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
        	listener.onLoadingComplete(imageUri, view, loadedImage);
       	}
        
    	@Override
    	public void onLoadingStarted(String imageUri, View view) {
    		listener.onLoadingStarted(imageUri, view);
    	}

    	@Override
    	public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
    		listener.onLoadingFailed(imageUri, view, failReason);
    	}

    	@Override
    	public void onLoadingCancelled(String imageUri, View view) {
    		listener.onLoadingCancelled(imageUri, view);
    	}          
    }      
    
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
 
    public static void copy(File src, File dst) throws IOException {
        InputStream in = new FileInputStream(src);
        OutputStream out = new FileOutputStream(dst);

        Utils.copyStream(in, out);
    }
    
    public static void copyStream(InputStream in, OutputStream out) throws IOException {
        // Transfer bytes from in to out
        byte[] buf = new byte[8096];
        int len;
        while ((len = in.read(buf)) > 0) {
            out.write(buf, 0, len);
        }
        in.close();
        out.close();
    }   
    /*
    public static String readStream(InputStream stream)
    {
    	BufferedInputStream is = new BufferedInputStream(stream);
    	try {
			return IOUtils.toString(is, "UTF-8");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return null;
    }
    */
	public static String getUid(Context context){
		TelephonyManager telManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		String deviceId = telManager.getDeviceId();
		if(deviceId==null){
			deviceId = telManager.getSimSerialNumber();
			if(deviceId==null){
				deviceId = telManager.getSubscriberId();
			}else{
				SharedPreferences preferences = context.getSharedPreferences("AppDeck", Context.MODE_PRIVATE);	
				long uid = preferences.getLong("uid", 0);
				if(uid==0){
					uid = System.currentTimeMillis();
					Editor editor = preferences.edit();
					editor.putLong("uid", uid);
					editor.commit();
				}
				deviceId = String.valueOf(uid);
			}
		}
		return deviceId;
	}	    
    
	public static String getApplicationName(Context context) {
	    int stringId = context.getApplicationInfo().labelRes;
	    return context.getString(stringId);
	}
	
	   /**
     * Kill the app either safely or quickly. The app is killed safely by
     * killing the virtual machine that the app runs in after finalizing all
     * {@link Object}s created by the app. The app is killed quickly by abruptly
     * killing the process that the virtual machine that runs the app runs in
     * without finalizing all {@link Object}s created by the app. Whether the
     * app is killed safely or quickly the app will be completely created as a
     * new app in a new virtual machine running in a new process if the user
     * starts the app again.
     * 
     * <P>
     * <B>NOTE:</B> The app will not be killed until all of its threads have
     * closed if it is killed safely.
     * </P>
     * 
     * <P>
     * <B>NOTE:</B> All threads running under the process will be abruptly
     * killed when the app is killed quickly. This can lead to various issues
     * related to threading. For example, if one of those threads was making
     * multiple related changes to the database, then it may have committed some
     * of those changes but not all of those changes when it was abruptly
     * killed.
     * </P>
     * 
     * @param killSafely
     *            Primitive boolean which indicates whether the app should be
     *            killed safely or quickly. If true then the app will be killed
     *            safely. Otherwise it will be killed quickly.
     */
    @SuppressWarnings("deprecation")
	public static void killApp(boolean killSafely) {
        if (killSafely) {
            /*
             * Notify the system to finalize and collect all objects of the app
             * on exit so that the virtual machine running the app can be killed
             * by the system without causing issues. NOTE: If this is set to
             * true then the virtual machine will not be killed until all of its
             * threads have closed.
             */
            System.runFinalizersOnExit(true);

            /*
             * Force the system to close the app down completely instead of
             * retaining it in the background. The virtual machine that runs the
             * app will be killed. The app will be completely created as a new
             * app in a new virtual machine running in a new process if the user
             * starts the app again.
             */
            System.exit(0);
        } else {
            /*
             * Alternatively the process that runs the virtual machine could be
             * abruptly killed. This is the quickest way to remove the app from
             * the device but it could cause problems since resources will not
             * be finalized first. For example, all threads running under the
             * process will be abruptly killed when the process is abruptly
             * killed. If one of those threads was making multiple related
             * changes to the database, then it may have committed some of those
             * changes but not all of those changes when it was abruptly killed.
             */
            android.os.Process.killProcess(android.os.Process.myPid());
        }
    }
    
    /** find a member field by given name and hide it */
    public static void findAndHideField(DatePicker datepicker, String name) {
        try {
            Field field = DatePicker.class.getDeclaredField(name);
            field.setAccessible(true);
            View fieldInstance = (View) field.get(datepicker);
            fieldInstance.setVisibility(View.GONE);
        } catch (Exception e) {
            //e.printStackTrace();
        }
    }    
    
    
    /** find a member field by given name and show it */
    public static void findAndShowField(DatePicker datepicker, String name) {
        try {
            Field field = DatePicker.class.getDeclaredField(name);
            field.setAccessible(true);
            View fieldInstance = (View) field.get(datepicker);
            fieldInstance.setVisibility(View.VISIBLE);
        } catch (Exception e) {
            //e.printStackTrace();
        }
    }
    
	/**
	 * Checks if the device is a tablet or a phone
	 * 
	 * @param activityContext
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
	
	
	// You may uncomment next line if using Android Annotations library, otherwise just be sure to run it in on the UI thread
	// @UiThread 
	public static String getDefaultUserAgentString(Context context) {
	  if (Build.VERSION.SDK_INT >= 17) {
	    return NewApiWrapper.getDefaultUserAgent(context);
	  }

	  try {
	    Constructor<WebSettings> constructor = WebSettings.class.getDeclaredConstructor(Context.class, WebView.class);
	    constructor.setAccessible(true);
	    try {
	      WebSettings settings = constructor.newInstance(context, null);
	      return settings.getUserAgentString();
	    } finally {
	      constructor.setAccessible(false);
	    }
	  } catch (Exception e) {
	    return new WebView(context).getSettings().getUserAgentString();
	  }
	}

	@TargetApi(17)
	static class NewApiWrapper {
	  static String getDefaultUserAgent(Context context) {
	    return WebSettings.getDefaultUserAgent(context);
	  }
	}	
	
	
	public static boolean isPortAvailable(int port)
	{
		try {		 
			ServerSocket srv = new ServerSocket(port);
			srv.close();
			srv = null;
			return true;
		} catch (IOException e) {
			return false;
		}
	}	
	
	// http://stackoverflow.com/questions/363681/generating-random-numbers-in-a-range-with-java
	/**
	 * Returns a pseudo-random number between min and max, inclusive.
	 * The difference between min and max can be at most
	 * <code>Integer.MAX_VALUE - 1</code>.
	 *
	 * @param min Minimum value
	 * @param max Maximum value.  Must be greater than min.
	 * @return Integer between min and max, inclusive.
	 * @see java.util.Random#nextInt(int)
	 */
	public static int randInt(int min, int max) {

	    // Usually this can be a field rather than a method variable
	    Random rand = new Random();

	    // nextInt is normally exclusive of the top value,
	    // so add 1 to make it inclusive
	    int randomNum = rand.nextInt((max - min) + 1) + min;

	    return randomNum;
	}
	
	public static boolean filePutContents(String fileName, String content)
	{
	    try {
			File outputFile = new File(fileName);
			Writer writer = new BufferedWriter(new FileWriter(outputFile));
	    	writer.write(content);
	    	writer.close();
	    	return true;
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
	}
	
	public static boolean filePutContents(String fileName, byte[] content)
	{
	    try {
			File outputFile = new File(fileName);
			IOUtils.write(content, new FileOutputStream(outputFile));
	    	return true;
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
	}	
	
	public static String readFile(String pathname) throws IOException {

	    File file = new File(pathname);
	    StringBuilder fileContents = new StringBuilder((int)file.length());
	    Scanner scanner = new Scanner(file);
	    String lineSeparator = System.getProperty("line.separator");

	    try {
	        while(scanner.hasNextLine()) {        
	            fileContents.append(scanner.nextLine() + lineSeparator);
	        }
	        return fileContents.toString();
	    } finally {
	        scanner.close();
	    }
	}
	
	public static String fileGetContents(String fileName)
	{
	    try {
	    	String content = Utils.readFile(fileName);
	    	return content;
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}
	
	public static String streamGetContent(InputStream is)
	{
		java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
	    return s.hasNext() ? s.next() : "";
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
}
