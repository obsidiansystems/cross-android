package systems.obsidian.focus;

import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.content.Intent;
import android.net.Uri;

public class JSaddleWebViewClient extends WebViewClient {
  private JSaddleShim jsaddle;
  private boolean hasLoadedPageOnce;
  private boolean hasInitJsaddle;

  public JSaddleWebViewClient (JSaddleShim new_jsaddle) {
    super();
    jsaddle = new_jsaddle;
    hasLoadedPageOnce = false;
    hasInitJsaddle = false;
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
    if(hasLoadedPageOnce) {
      if(!hasInitJsaddle) {
        jsaddle.startHandler();
        hasInitJsaddle = true;
      }
    } else{
      hasLoadedPageOnce = true;
    }
  }
}
