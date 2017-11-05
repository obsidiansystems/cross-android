package systems.obsidian.focus;

import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.os.Handler;

import android.util.Log;

public class JSaddleShim {
  private WebView wv;
  private Handler hnd;
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

  public void evaluateJavascript(final String js) {
    hnd.post(new Runnable() {
      @Override
      public void run() {
        wv.evaluateJavascript (js, null);
      }
    });
  }

  @JavascriptInterface
  public boolean postMessage(final String msg) {
    hnd.post(new Runnable() {
      @Override
      public void run() {
        processMessage(msg);
      }
    });
    return true;
  }

  @JavascriptInterface
  public String syncMessage(final String msg) {
    return processSyncMessage(msg);
  }

  @JavascriptInterface
  public boolean postReady() {
    hnd.post(new Runnable() {
      @Override
      public void run() {
        startProcessing();
      }
    });
    return true;
  }

}
