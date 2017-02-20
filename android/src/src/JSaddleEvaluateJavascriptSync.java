package systems.obsidian.focus;

import android.os.AsyncTask;
import android.webkit.WebView;
import android.webkit.ValueCallback;
import android.util.Log;

public class JSaddleEvaluateJavascriptSync extends AsyncTask <String, Void, String[]> {

  private boolean hasCompleted;
  private WebView wv;

  public JSaddleEvaluateJavascriptSync ( WebView _wv ) {
    hasCompleted = false;
    wv = _wv;
  }

  @Override
  protected String[] doInBackground (String[] msgs) {
    return msgs;
  }

  protected void onPostExecute (String[] scripts) {
    for (String js : scripts) {
      Log.v ("JSADDLE", js);
      ValueCallback wait = new ValueCallback<Boolean>() {
        public void onReceiveValue(Boolean unused) {
          hasCompleted = true;
          return;
        }
      };
      wv.evaluateJavascript ( js, wait );
      while(!hasCompleted){
      }
      Log.v("JSADDLE", "###evaluateJavascriptSyncCalled");
    }
  }
}
