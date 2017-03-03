package net.mobideck.appdeck.core;

import android.animation.ValueAnimator;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;

import net.mobideck.appdeck.AppDeckApplication;
import net.mobideck.appdeck.R;
import net.mobideck.appdeck.config.MenuEntry;
import net.mobideck.appdeck.util.Utils;

import java.util.ArrayList;
import java.util.List;

public class Banner {

    public static String TAG = "BANNER";

    ViewPager mViewPager;

    private int mHeight;

    private List<BannerItem> mBanners;

    private BannerPagerAdaptater mBannerPagerAdaptater;

    public Banner(ViewPager viewPager) {
        mViewPager = viewPager;
        mBannerPagerAdaptater = new BannerPagerAdaptater();
        mViewPager.setAdapter(mBannerPagerAdaptater);
    }

    public void setBanners(List<MenuEntry> banners) {

        mHeight = 0;

        if (banners == null || banners.size() == 0) {
            mBanners = null;
            mBannerPagerAdaptater.notifyDataSetChanged();
            return;
        }

        List<BannerItem> newBanners = new ArrayList<>();

        for (int i = 0; i < banners.size(); i++) {

            BannerItem banner = new BannerImage(banners.get(i));
            int height = banner.getHeight();
            if (height > mHeight)
                mHeight = height;

            newBanners.add(banner);
        }

        mBanners = newBanners;

        mViewPager.setAdapter(mBannerPagerAdaptater);
        //mBannerPagerAdaptater.notifyDataSetChanged();

    }

    public int getHeight() {
        return mHeight;
    }

    public class BannerPagerAdaptater extends PagerAdapter {

        @Override
        public Object instantiateItem(ViewGroup collection, int position) {

            BannerItem banner = mBanners.get(position);

            View bannerView = banner.getView();

            if (bannerView.getParent() == null)
                collection.addView(bannerView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

            return banner;
        }

        @Override
        public void destroyItem(ViewGroup collection, int position, Object object) {
            BannerItem banner = (BannerItem)object;
            collection.removeView(banner.getView());
            banner.cancel();
        }

        @Override
        public int getCount() {
            if (mBanners == null)
                return 0;
            return mBanners.size();
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            BannerItem banner = (BannerItem)object;
            return view == banner.getView();
        }

        @Override
        public CharSequence getPageTitle(int position) {
            /*BannerItem banner = mBanners.get(position);
            String title = banner.getTitle();
            if (title != null && !title.isEmpty())
                return title;*/
            return "#" + (position + 1);
        }
    }

    interface BannerItem {
        View getView();
        void cancel();
        int getHeight();
    }

    class BannerImage implements BannerItem {

        private MenuEntry mBanner;

        private ImageRequest mImageRequest;

        private FrameLayout mRoot;
        private ImageView mImageView;
        private LinearLayout mCaption;
        private TextView mTitle;
        private TextView mSubtitle;
        private int mBannerHeight;

        BannerImage(MenuEntry banner) {
            mBanner = banner;

            mBannerHeight = Utils.computeHeight(mBanner.height);
            if (mBannerHeight == 0) {
                mBannerHeight = Utils.computeHeight("30%");
            }
        }

        public View getView() {

            if (mRoot != null)
                return mRoot;

            mRoot = (FrameLayout)AppDeckApplication.getActivity().getLayoutInflater().inflate(R.layout.banner_image, null);

            mImageView = (ImageView)mRoot.findViewById(R.id.imageView); //new ImageView(AppDeckApplication.getActivity());
            mCaption = (LinearLayout)mRoot.findViewById(R.id.caption);
            mTitle = (TextView)mRoot.findViewById(R.id.title);
            mSubtitle = (TextView)mRoot.findViewById(R.id.subtitle);

            mImageRequest = new ImageRequest(mBanner.image, new Response.Listener<Bitmap>() {
                @Override
                public void onResponse(Bitmap response) {
                    mImageView.setImageDrawable(new BitmapDrawable(response));
                }
            }, AppDeckApplication.getAppDeck().deviceInfo.screenWidth, mBannerHeight, null, new Response.ErrorListener() {
                public void onErrorResponse(VolleyError error) {
                    Log.e(TAG, "Error while fetching Logo : " + error.getLocalizedMessage());
                }
            });
            AppDeckApplication.getAppDeck().addToRequestQueue(mImageRequest);

            if (mBanner.title != null || mBanner.subtitle != null) {
                mCaption.setVisibility(View.VISIBLE);
                if (mBanner.title != null)
                    mTitle.setText(mBanner.title);
                if (mBanner.subtitle != null)
                    mSubtitle.setText(mBanner.subtitle);
            } else {
                mCaption.setVisibility(View.INVISIBLE);
            }

            // colors
            if (mBanner.color != null) {
                mTitle.setTextColor(Utils.parseColor(mBanner.color));
                mSubtitle.setTextColor(Utils.parseColor(mBanner.color));
            }

            if (mBanner.backgroundColor != null) {
                mRoot.setBackgroundColor(Utils.parseColor(mBanner.backgroundColor));
            }

            if (mBanner.foregroundColor != null) {
                mCaption.setBackgroundColor(Utils.parseColor(mBanner.foregroundColor));
            }

            // click
            if (mBanner.content != null) {
                mRoot.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        AppDeckApplication.getAppDeck().navigation.loadURL(mBanner.content);
                    }
                });
            }

            return mRoot;
        }

        public void cancel() {
            if (mImageRequest != null)
                mImageRequest.cancel();
            mImageRequest = null;
        }

        public int getHeight() {
            return mBannerHeight;
        }

    }
}
