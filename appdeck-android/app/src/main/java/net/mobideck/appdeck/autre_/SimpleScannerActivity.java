package net.mobideck.appdeck.autre_;

import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.Toast;

import com.google.zxing.Result;

import net.mobideck.appdeck.R;
import net.mobideck.appdeck.core.ApiCall;

import org.json.JSONArray;

import me.dm7.barcodescanner.zxing.ZXingScannerView;

public class SimpleScannerActivity extends BaseScannerActivity implements ZXingScannerView.ResultHandler {
    private ZXingScannerView mScannerView;

    public static ApiCall apiCall ;

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        setContentView(R.layout.activity_simple_scanner);
        setupToolbar();

        ViewGroup contentFrame = (ViewGroup) findViewById(R.id.content_frame);
        mScannerView = new ZXingScannerView(this);
        contentFrame.addView(mScannerView);
    }

    @Override
    public void onResume() {
        super.onResume();
        mScannerView.setResultHandler(this);
        mScannerView.startCamera();
    }

    @Override
    public void onPause() {
        super.onPause();
        mScannerView.stopCamera();
    }

    @Override
    public void handleResult(final Result rawResult) {
        Toast.makeText(this, "Contents = " + rawResult.getText() +
                ", Format = " + rawResult.getBarcodeFormat().toString(), Toast.LENGTH_SHORT).show();


        Handler mainHandler = new Handler(getMainLooper());
        Runnable myRunnable = new Runnable() {
            @Override
            public void run() {

                final JSONArray results = new JSONArray();
                results.put(rawResult.getText().toString());
                apiCall.sendCallbackWithResult("callback", results);
            }
        };
        mainHandler.post(myRunnable);

        //Log.i("result ", results.toString());


        // Note:
        // * Wait 2 seconds to resume the preview.
        // * On older devices continuously stopping and resuming camera preview can result in freezing the app.
        // * I don't know why this is the case but I don't have the time to figure out.
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                mScannerView.resumeCameraPreview(SimpleScannerActivity.this);
            }
        }, 1000);


        finish();
    }
}
