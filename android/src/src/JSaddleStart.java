package systems.obsidian.focus;

import android.os.AsyncTask;

import android.util.Log;

public class JSaddleStart extends AsyncTask <Void, Void, Void> {
  @Override
  protected Void doInBackground (Void... unused) {
    startHandlerShim();
    Log.v("JSADDLE", "###startHandlerCalled");
    return null;
  }

  private native void startHandlerShim ();
}
