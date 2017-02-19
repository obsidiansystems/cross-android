package systems.obsidian.focus;

import android.webkit.JavascriptInterface;
import android.webkit.WebView;

import android.util.Log;

public class JSaddleShim {
  private WebView wv;

  public JSaddleShim ( WebView n_wv ) {
    wv = n_wv;
  }

  public void loadHTMLString ( String html ) {
    wv.loadData(html, "text/html; charset=utf-8", "UTF-8");
  }

  public void evaluateJavascript ( String javascript ) {
    new JSaddleEvaluateJavascript(wv).execute(javascript);
  }

  @JavascriptInterface
  public boolean postMessage ( String msg ) {
    Log.v("JSADDLE", "###callingPostMessage");
    new ProcessJSaddleMessage().execute(msg);
    return true;
  }

  public void startHandler () {
    Log.v("JSADDLE", "###callingStartHandler");
    new JSaddleStart().execute();
  }

}
