package systems.obsidian.focus;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.CookieManager;
import android.webkit.WebView;
import android.webkit.WebSettings;
import android.view.Window;
import android.view.WindowManager;
import android.os.SystemClock;
import android.util.Log;
import android.os.Handler;
import android.os.Process;

import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends Activity
{
    private JSaddleShim jsaddle;

    static {
        System.loadLibrary("@APPNAME@");
    }

    private static final String TAG = "JSADDLE";

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        CookieManager.setAcceptFileSchemeCookies(true);
        super.onCreate(savedInstanceState);
        // Remove title and notification bars, obv.
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        //this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        setContentView(R.layout.main);
        // find the web view
        final WebView wv = (WebView) findViewById (R.id.webview);
        // enable javascript and debugging
        WebSettings ws = wv.getSettings();
        ws.setJavaScriptEnabled(true);
        ws.setAllowFileAccessFromFileURLs(true); //Maybe you don't need this rule
        ws.setAllowUniversalAccessFromFileURLs(true);
        wv.setWebContentsDebuggingEnabled(true);
        // init an object mediating the interaction with JSaddle
        final Handler hnd = new Handler();
        jsaddle = new JSaddleShim(wv, hnd);
        // create and set a web view client aware of the JSaddle
        wv.setWebViewClient(new JSaddleWebViewClient(jsaddle));
        // create and set a web chrome client for console message handling
        wv.setWebChromeClient(new JSaddleWebChromeClient());
        // register jsaddle javascript interface
        wv.addJavascriptInterface(jsaddle, "jsaddle");
        // tell C about the shim so that it can spin up Haskell and connect the two
        Log.d(TAG, "###jsaddle");
        jsaddle.init();
        Log.d(TAG, "###loadhtml");
        wv.loadUrl("file:///android_asset/index.html");
    }
    @Override
    public void onPause() {
        Log.d(TAG, "!!!PAUSE");
        super.onPause();
    }
    @Override
    public void onStop() {
        Log.d(TAG, "!!!STOP");
        CookieManager.getInstance().flush();
        super.onStop();
    }
    @Override
    public void onDestroy() {
        Log.d(TAG, "!!!DESTROY");
        // jsaddle.deinit(); crashes because we're not deinit'ing native threads correctly
        super.onDestroy();
        android.os.Process.killProcess(android.os.Process.myPid()); //TODO: Properly handle the process surviving between invocations which means that the Haskell RTS needs to not be initialized twice.
    }
}
