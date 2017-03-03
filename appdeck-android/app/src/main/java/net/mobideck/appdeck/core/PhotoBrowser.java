package net.mobideck.appdeck.core;

import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.davemorrissey.labs.subscaleview.ImageSource;
import com.davemorrissey.labs.subscaleview.SubsamplingScaleImageView;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;
import net.mobideck.appdeck.config.MenuEntry;
import net.mobideck.appdeck.config.ViewConfig;
import net.mobideck.appdeck.util.Utils;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import okhttp3.Request;

import static android.os.Looper.getMainLooper;

public class PhotoBrowser extends AppDeckView {

	private ViewPager mViewPager;
	private PhotoBrowserAdapter mAdapter;
	
   	private MenuEntry mMenuItemPrevious;
    private MenuEntry mMenuItemNext;
    private MenuEntry mMenuItemShare;
	
   	//private List<MenuEntry> mMenuItems;
   	
	private String mUrl[];
	private String mThumbnail[];
	private String mCaption[];
   	
   	private int mBgColor;
   	private int mStartIndex;

    private ViewConfig mViewConfig;

    private ApiCall mApiCall;

    private List<PhotoBrowserImage> mImages;

	public PhotoBrowser(Context context, ApiCall apiCall)
	{
        mApiCall = apiCall;

		JSONObject config = mApiCall.paramObject;
		JSONArray images = config.optJSONArray("images");
		mBgColor = Utils.parseColor(config.optString("bgcolor"));
		int startIndex = config.optInt("startIndex");
		int nbPhoto = images.length();

		mUrl = new String[nbPhoto];
		mThumbnail = new String[nbPhoto];
		mCaption = new String[nbPhoto];

        mImages = new ArrayList<>();

		for (int i = 0; i < nbPhoto; i++)
		{
			JSONObject image = images.optJSONObject(i);
            String imageUrl = image.optString("url");
            String thumbnailUrl = image.optString("thumbnail");
            if (imageUrl != null && imageUrl != "")
                imageUrl = apiCall.resolveURL(imageUrl);
            if (thumbnailUrl != null && thumbnailUrl != "")
                thumbnailUrl = apiCall.resolveURL(thumbnailUrl);
			mUrl[i] = imageUrl;
			mThumbnail[i] = thumbnailUrl;
			mCaption[i] = image.optString("caption");

            mImages.add(new PhotoBrowserImage(imageUrl, thumbnailUrl, mCaption[i]));
		}

		//String title, String icon, String type, String content, String badge, AppDeckView appDeckView
/*
		menuItemPrevious = new AppDeckMenuItem(AppDeckApplication.getActivity().getResources().getString(R.string.previous), "!previous", "button", "photobrowser:previous", null, this);
		menuItemNext = new AppDeckMenuItem(AppDeckApplication.getActivity().getString(R.string.next), "!next", "button", "photobrowser:next", null, this);
		menuItemShare = new AppDeckMenuItem(AppDeckApplication.getActivity().getString(R.string.action), "!action", "button", "photobrowser:share", null, this);

		menuItems = new AppDeckMenuItem[] {menuItemPrevious, menuItemNext, menuItemShare};
*/

        mMenuItemPrevious = new MenuEntry();
        mMenuItemPrevious.title = AppDeckApplication.getActivity().getString(R.string.previous);
        mMenuItemPrevious.icon = "!previous";
        mMenuItemPrevious.content = "photobrowser:previous";

        mMenuItemNext = new MenuEntry();
        mMenuItemNext.title = AppDeckApplication.getActivity().getString(R.string.next);
        mMenuItemNext.icon = "!next";
        mMenuItemNext.content = "photobrowser:next";

        mMenuItemShare = new MenuEntry();
        mMenuItemShare.title = AppDeckApplication.getActivity().getString(R.string.action);
        mMenuItemShare.icon = "!action";
        mMenuItemShare.content = "photobrowser:share";

        //mMenuItems =  Arrays.asList(mMenuItemPrevious, mMenuItemNext, mMenuItemShare);

        mViewConfig = AppDeckApplication.getAppDeck().getDefaultConfiguration();

        mViewConfig.menu = Arrays.asList(mMenuItemPrevious, mMenuItemNext, mMenuItemShare);

        mViewPager = new ViewPager(context);

        mAdapter = new PhotoBrowserAdapter(context);

        mViewPager.setAdapter(mAdapter);
        mViewPager.setCurrentItem(startIndex);

		try {
            mViewPager.setBackgroundColor(mBgColor);
		} catch (IllegalArgumentException e) {

		}

        mViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			
			@Override
			public void onPageSelected(int position) {
                List<MenuEntry> menu = new ArrayList<MenuEntry>();
				// enable/disable previous
				mMenuItemPrevious.disabled = !(position != 0);
				//Utils.setMenuItemAvailable(menuItemPrevious.me, position != 0);
				// enable/disable previous
				mMenuItemNext.disabled = !(position != (mUrl.length - 1));
				//Utils.setMenuItemAvailable(menuItemNext, position != (nbPhoto - 1));
                AppDeckApplication.getAppDeck().navigation.onViewConfigChange(PhotoBrowser.this, mViewConfig);
			}
			
			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {
			}
			
			@Override
			public void onPageScrollStateChanged(int arg0) {
			}
		});

    }
    
	@Override
	public View getView() {
		return mViewPager;
	}

    @Override
    public ViewPager getViewPager() {
        return mViewPager;
    }

	@Override
	public void destroy() {

	}

	@Override
	public void onResume() {

	}

	@Override
    public void onPause() {

    }

	@Override
	public void onShow() {

	}

	@Override
	public void onHide() {

	}

	@Override
	public boolean shouldOverrideBackButton() {
		return false;
	}

	@Override
	public void evaluateJavascript(String js) {

	}

	@Override
	public ViewConfig getViewConfig() {
		return mViewConfig;
	}

	@Override
	public String getURL() {
		return null;
	}

	@Override
	public String resolveURL(String relativeURL) {
		return mApiCall.resolveURL(relativeURL);
	}

	@Override
	public void loadUrl(String relativeURL) {
        if (relativeURL.equalsIgnoreCase("photobrowser:previous"))
            gotoPrevious();
        else if (relativeURL.equalsIgnoreCase("photobrowser:next"))
            gotoNext();
        else if (relativeURL.equalsIgnoreCase("photobrowser:share"))
            share();
        else
            mApiCall.page.loadUrl(relativeURL);
	}

    private void gotoNext() {
        int currentIndex = mViewPager.getCurrentItem();
        if (currentIndex < mImages.size() - 1)
            mViewPager.setCurrentItem(currentIndex + 1);
    }

    private void gotoPrevious() {
        int currentIndex = mViewPager.getCurrentItem();
        if (currentIndex > 0)
            mViewPager.setCurrentItem(currentIndex - 1);
    }

    private void share() {

        PhotoBrowserImage image = mImages.get(mViewPager.getCurrentItem());
        image.share();
    }

    private class PhotoBrowserImage {

        private String mImageUrl;
        private String mImageThumbnail;
        private String mImageCaption;
        private ViewGroup mRoot;
        private SubsamplingScaleImageView mImageView;
        private TextView mTextView;

        private File mImageFile;

        PhotoBrowserImage(String imageUrl, String imageThumbnail, String imageCaption) {
            mImageUrl = imageUrl;
            mImageThumbnail = imageThumbnail;
            mImageCaption = imageCaption;

            mRoot = (ViewGroup) AppDeckApplication.getActivity().getLayoutInflater().inflate(R.layout.photo_browser_image, null);
            mTextView = (TextView) mRoot.findViewById(R.id.textView);

            if (mImageCaption == null || mImageCaption.isEmpty())
                mTextView.setVisibility(View.INVISIBLE);
            else
                mTextView.setText(mImageCaption);

            mImageView = (SubsamplingScaleImageView) mRoot.findViewById(R.id.imageView);

            //mImageView.setPanLimit(SubsamplingScaleImageView.PAN_LIMIT_CENTER);
            //mImageView.setMinimumScaleType(SubsamplingScaleImageView.SCALE_TYPE_CENTER_CROP);
            mImageView.setMinimumScaleType(SubsamplingScaleImageView.SCALE_TYPE_CUSTOM);
            mImageView.setMaxScale(10f);

            mImageView.setImage(ImageSource.resource(R.drawable.appdeck));

            mImageFile = new File(AppDeckApplication.getAppDeck().cache.getCacheEntryPath(mImageUrl));

            if (mImageFile.exists()) {
                loadImage();
                return;
            }


            new Thread(new Runnable() {
                @Override
                public void run() {
                    downloadImage();
                }
            }, "proxy").start();
        }

        public View getView() {
            return mRoot;
        }

        private void downloadImage() {

            Request request = new Request.Builder()
                    .url(mImageUrl)
                    .build();

            try {
                okhttp3.Response response = AppDeckApplication.getAppDeck().okHttpClient.newCall(request).execute();
                if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
                Utils.streamToFile(response.body().byteStream(), mImageFile);
            } catch (IOException e) {
                e.printStackTrace();
                return;
            }

            Handler mainHandler = new Handler(getMainLooper());
            Runnable myRunnable = new Runnable() {
                @Override
                public void run() {
                    loadImage();
                }
            };
            mainHandler.post(myRunnable);
        }

        private void loadImage() {
            Uri uri = Uri.fromFile(mImageFile);
            mImageView.setImage(ImageSource.uri(uri));
        }

        public void share() {
            AppDeckApplication.getAppDeck().share.shareContent(mImageCaption, null, mImageUrl);
        }
/*
        private void downloadImage() {
            Request request = new Request.Builder()
                    .url("http://publicobject.com/helloworld.txt")
                    .build();

            client.newCall(request).enqueue(new Callback() {
                @Override public void onFailure(Call call, IOException e) {
                    e.printStackTrace();
                }

                @Override public void onResponse(Call call, Response response) throws IOException {
                    if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);

                    Headers responseHeaders = response.headers();
                    for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                        System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                    }

                    System.out.println(response.body().string());
                }
            });
        }*/
    }

   private class PhotoBrowserAdapter extends PagerAdapter {

       public String TAG = "PhotoBrowserAdapter";

       private Context mContext;

       public PhotoBrowserAdapter(Context context) {
           mContext = context;
       }

       @Override
       public Object instantiateItem(ViewGroup collection, int position) {

           PhotoBrowserImage image = mImages.get(position);

           View imageView = image.getView();
           collection.addView(imageView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

           return imageView;
/*
           ViewGroup root = (ViewGroup)AppDeckApplication.getActivity().getLayoutInflater().inflate(R.layout.photo_browser_image, null);

           collection.addView(root, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

           final SubsamplingScaleImageView imageView = (SubsamplingScaleImageView)root.findViewById(R.id.imageView);

           imageView.setPanLimit(SubsamplingScaleImageView.PAN_LIMIT_CENTER);
           imageView.setMinimumScaleType(SubsamplingScaleImageView.SCALE_TYPE_CENTER_CROP);
           final String imageUrl = mUrl[position];
           String imageThumbnail = mThumbnail[position];
           String imageCaption = mCaption[position];
           imageView.setImage(ImageSource.resource(R.drawable.appdeck));

           return root;*/
       }

       @Override
       public void destroyItem(ViewGroup collection, int position, Object view) {
           collection.removeView((View) view);
       }

       @Override
       public boolean isViewFromObject(View view, Object object) {
           return view == object;
       }

       @Override
       public CharSequence getPageTitle(int position) {
           return mUrl[position];
       }

   	    @Override
   	    public int getCount() {
           return mUrl.length;
       }

   }
}
