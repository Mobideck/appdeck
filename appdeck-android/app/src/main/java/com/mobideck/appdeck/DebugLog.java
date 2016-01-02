package com.mobideck.appdeck;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.ScaleDrawable;
import android.os.Handler;
import android.os.Looper;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.method.ScrollingMovementMethod;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;

public class DebugLog {

    public static int VERBOSE = 0;
    public static int DEBUG = 1;
    public static int INFO = 2;
    public static int WARNING = 3;
    public static int ERROR = 4;

    private static DebugLog instance;

    private TextView mTextView;
    private Button mClose;
    private FrameLayout mLayout;

    private boolean mIsHidden = true;

    private int mErrorCount = 0;

    // Get a handler that can be used to post to the main thread
    Handler mainHandler;

    DebugLog(FrameLayout layout, Button closeButton) {
        DebugLog.instance = this;

        mainHandler = new Handler(AppDeckApplication.getAppContext().getMainLooper());

        mLayout = layout;
        mTextView = (TextView)layout.findViewById(R.id.debugTextView);
        mClose = closeButton;
        mClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsHidden)
                    showLog();
                else
                    hideLog();
                mErrorCount = 0;
                mClose.setText("log");

            }
        });
        mTextView.setMovementMethod(new ScrollingMovementMethod());
        mTextView.setText(Html.fromHtml("<b>AppDeck version "+AppDeck.getInstance().version+"</b>"), TextView.BufferType.SPANNABLE);
        mClose.setVisibility(View.VISIBLE);
        mLayout.setVisibility(View.VISIBLE);

        /*BadgeDrawable drawable = new BadgeDrawable(AppDeckApplication.getAppContext());
        drawable.setCount(42);
        drawable.setBounds(0, 0, (int)(drawable.getIntrinsicWidth()*0.5),
                (int)(drawable.getIntrinsicHeight()*0.5));
        ScaleDrawable sd = new ScaleDrawable(drawable, 0, mClose.getHeight(), mClose.getHeight());
        mClose.setCompoundDrawables( sd.getDrawable(), null, null, null );*/
        /*Button btn = findViewbyId(R.id.yourbtnID);
        btn.setCompoundDrawables(sd.getDrawable(), null, null, null);

        draw.setBounds( 0, 0, mClose.getWidth(), mClose.getHeight());
        mClose.setCompoundDrawables( draw, null, null, null );*/

    }

    private void showLog() {
        if (!mIsHidden)
            return;
        mIsHidden = !mIsHidden;

        mClose.animate().translationY(-mLayout.getHeight()).start();

        // reset state
        mLayout.clearAnimation();
        mLayout.setAlpha(0f);
        mLayout.setTranslationY(mLayout.getHeight());

        mLayout.animate().alpha(1f).translationY(0f).start();
    }

    private void hideLog() {
        if (mIsHidden)
            return;
        mIsHidden = !mIsHidden;

        // reset state
        mLayout.clearAnimation();
        mLayout.setAlpha(1f);
        mLayout.setTranslationY(0f);

        mClose.animate().translationY(0f).start();

        mLayout.animate().alpha(0f).translationY(mLayout.getHeight())
/*                .setListener(new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationEnd(Animator animation) {
                        mLayout.setVisibility(View.INVISIBLE);
                    }
                })*/
                .start();
    }


    private void addMessage(final String title, final String message, final int type) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post(new Runnable() {
                @Override
                public void run() {
                    addMessage(title, message, type);
                }
            });
            return;
        }


/*        Spannable wordtoSpan = new SpannableString(message);
        wordtoSpan.setSpan(new ForegroundColorSpan(Color.BLUE), 0, wordtoSpan.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTextView.append(wordtoSpan);*/

        String color = "grey";
        if (type == VERBOSE) {
            color = "#E1E1FF";
        } else if (type == DEBUG) {
            color = "#8DC7BB";
        } else if (type == INFO) {
            color = "#4FBDDD";
        } else if (type == WARNING) {
            color = "#FFBF48";
        } else if (type == ERROR) {
            color = "#FF4848";
        }

        if (type == ERROR) {
            mErrorCount++;
        }

        String text = "<br /><font color='"+color+"'><b>"+title+"</b> "+message+"</font>";
        mTextView.append(Html.fromHtml(text));

        if (mErrorCount > 0)
            mClose.setText("log +"+mErrorCount);

    }


    public static void verbose(String title, String message) {
        //Log.v(title, message);
        if (DebugLog.instance != null) {
            DebugLog.instance.addMessage(title, message, VERBOSE);
        }
    }
    public static void debug(String title, String message) {
        //Log.d(title, message);
        if (DebugLog.instance != null) {
            DebugLog.instance.addMessage(title, message, DEBUG);
        }
    }
    public static void info(String title, String message) {
        //Log.i(title, message);
        if (DebugLog.instance != null) {
            DebugLog.instance.addMessage(title, message, INFO);
        }
    }
    public static void warning(String title, String message) {
        //Log.i(title, message);
        if (DebugLog.instance != null) {
            DebugLog.instance.addMessage(title, message, WARNING);
        }
    }
    public static void error(String title, String message) {
        //Log.e(title, message);
        if (DebugLog.instance != null) {
            DebugLog.instance.addMessage(title, message, ERROR);
        }
    }
}
