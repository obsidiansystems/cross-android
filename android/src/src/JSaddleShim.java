package systems.obsidian.focus;

import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.os.Handler;
import java.util.concurrent.SynchronousQueue;

import android.util.Log;

public class JSaddleShim {
  private WebView wv;
  private Handler hnd;
  SynchronousQueue done = new SynchronousQueue<Integer>(); // The Int is unused, but we can't use Void because SynchronousQueue doesn't allow null items
  private native void startProcessing();
  private native void processMessage(String msg);
  private native String processSyncMessage(String msg);

  public native void init();
  public native void deinit();
  public native void injectJavascript();

  public JSaddleShim(WebView _wv, Handler _hnd) {
    wv = _wv;
    hnd = _hnd;
  }

  public void startMain() {
    new Thread() {
      public void run() {
        init();
      }
    }.start();
    try {
      done.take();
    } catch(InterruptedException e) {
      //TODO: Should we do something with this?
    }
  }

  public void mainStarted() {
    try {
      done.put(0); // This value is not significant, but SynchronousQueue requires that it not be null
    } catch(InterruptedException e) {
      //TODO: Should we do something with this?
    }
  }

  public void evaluateJavascript(final String js) {
    hnd.post(new Runnable() {
      @Override
      public void run() {
        // Log.d("JSADDLE", js);
        wv.evaluateJavascript (js, null);
      }
    });
  }

  @JavascriptInterface
  public boolean postMessage(final String msg) {
    hnd.post(new Runnable() {
      @Override
      public void run() {
        // Log.d("JSADDLE", msg);
        processMessage(msg);
      }
    });
    return true;
  }

  @JavascriptInterface
  public String syncMessage(final String msg) {
    // Log.d("JSADDLE", msg);
    return processSyncMessage(msg);
  }

  @JavascriptInterface
  public boolean postReady() {
    hnd.post(new Runnable() {
      @Override
      public void run() {
        // Log.d("JSADDLE", "###startProcessing");
        startProcessing();
      }
    });
    return true;
  }

}
