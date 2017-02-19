package systems.obsidian.focus;

import android.os.AsyncTask;
import android.webkit.WebView;
import android.util.Log;

public class JSaddleEvaluateJavascript extends AsyncTask <String, Void, String[]> {

  private WebView wv;

  public JSaddleEvaluateJavascript ( WebView _wv ) {
    wv = _wv;
  }

  @Override
  protected String[] doInBackground (String[] msgs) {
    return msgs;
  }

  protected void onPostExecute (String[] scripts) {
    for (String js : scripts) {
      Log.v ("JSADDLE", js);
      wv.evaluateJavascript ( js, null );
      Log.v("JSADDLE", "###evaluateJavascriptCalled");
    }
  }
}
