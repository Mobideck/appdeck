package net.mobideck.appdeck.WebView;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.view.View;
import android.view.ViewGroup;


public class SmartPagerAdapter extends PagerAdapter {

    private Context mContext;

    public SmartPagerAdapter(Context context) {
        mContext = context;
    }

    @Override
    public Object instantiateItem(ViewGroup collection, int position) {
            /*
            LayoutInflater inflater = LayoutInflater.from(mContext);
            ViewGroup layout = (ViewGroup) inflater.inflate(R.layout.content_webview, collection, false);
            collection.addView(layout);

            WebView webView = (WebView)findViewById(R.id.webview);
            webView.loadUrl("https://app.nextinpact.com/");
            */

        SmartWebView webView = new SmartWebView(mContext);
        //webView.loadUrl("https://app.nextinpact.com/");

            /*int[] attrs = new int[]{R.attr.selectableItemBackground};
            TypedArray typedArray = mContext.obtainStyledAttributes(attrs);
            int backgroundResource = typedArray.getResourceId(0, 0);
            webView.setBackgroundResource(backgroundResource);*/

        NestedScrollWebView nestedScrollView = new NestedScrollWebView(mContext);
        nestedScrollView.addView(webView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        //CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams)webView.getLayoutParams();
        //params.setBehavior(new AppBarLayout.ScrollingViewBehavior());

        collection.addView(nestedScrollView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        return nestedScrollView;
    }

    @Override
    public void destroyItem(ViewGroup collection, int position, Object view) {
        collection.removeView((View) view);
    }

    @Override
    public int getCount() {
        return 3;//CustomPagerEnum.values().length;
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return view == object;
    }

    @Override
    public CharSequence getPageTitle(int position) {
        if (position == 0)
            return "Tab 1";
        if (position == 1)
            return "Tab 2";
        return "Tab 3";
    }

}
