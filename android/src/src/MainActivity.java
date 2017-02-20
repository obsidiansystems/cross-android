package systems.obsidian.focus;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebSettings;
import android.view.Window;
import android.view.WindowManager;
import android.os.SystemClock;
import android.util.Log;
import android.os.Handler;

import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends Activity
{

    static {
        System.loadLibrary("@APPNAME@");
    }
    /** Called when the activity is first created. */

    private native void initJSaddle (JSaddleShim callbackObj);
    private native void startJSaddleProcessing ();
    private native void haskellYield ();

    private static final String TAG = "JSADDLE";

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        // Remove title and notification bars, obv.
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        setContentView(R.layout.main);
        // find the web view
        final WebView wv = (WebView) findViewById (R.id.webview);
        // enable javascript and debugging
        WebSettings ws = wv.getSettings();
        ws.setJavaScriptEnabled(true);
        ws.setAllowFileAccessFromFileURLs(true); //Maybe you don't need this rule
        ws.setAllowUniversalAccessFromFileURLs(true);
        wv.setWebContentsDebuggingEnabled(true);
        // init an object managing the JSaddleShim
        JSaddleShim jsaddle = new JSaddleShim(wv);
        // create and set a web view client aware of the JSaddleShim
        JSaddleWebViewClient wv_client = new JSaddleWebViewClient();
        wv.setWebViewClient(wv_client);
        // register jsaddle javascript interface
        wv.addJavascriptInterface(jsaddle, "jsaddle");
        // tell C about the shim so that it can spin up Haskell and connect the two
        Log.v(TAG, "###jsaddle");
        initJSaddle(jsaddle);
        Log.v(TAG, "###loadhtml");
        wv.loadUrl("file:///android_asset/index.html");

        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
          @Override
          public void run() {
            // prepare the page and signal to Haskell that we are ready to start running JSaddle onPageFinished
            startJSaddleProcessing();
            Log.v("JSADDLE", "###startHandlerCalled");
          }
        }, 1000);
    }
}
