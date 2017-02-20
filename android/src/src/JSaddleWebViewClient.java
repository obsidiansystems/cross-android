package systems.obsidian.focus;

import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.ConsoleMessage;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

public class JSaddleWebViewClient extends WebViewClient {
  private boolean hasInjectedJSaddle;

  private native void injectJSaddleCode ();
  private native void startJSaddleProcessing ();

  public JSaddleWebViewClient () {
    super();
    hasInjectedJSaddle = false;
  }

  public boolean onConsoleMessage(ConsoleMessage cm)
  {
      Log.v("JSADDLEJS", String.format("%s @ %d: %s", cm.message(), cm.lineNumber(), cm.sourceId()));
      return true;
  }

  @Override
  public boolean shouldOverrideUrlLoading(WebView view, String url) {
    if (Uri.parse(url).getHost().endsWith("obsidian.systems")) {
      return false;
    }

    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
    view.getContext().startActivity(intent);
    return true;
  }

  public void onPageFinished (WebView view, String url) {
    if(!hasInjectedJSaddle) {
      injectJSaddleCode();
      Log.v("JSADDLE", "###jsaddleCodeInjected");
      hasInjectedJSaddle = true;
    }
  }
}
