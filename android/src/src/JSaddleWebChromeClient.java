package systems.obsidian.focus;

import android.webkit.ConsoleMessage;
import android.webkit.WebChromeClient;
import android.util.Log;

public class JSaddleWebChromeClient extends WebChromeClient {

	@Override
	public boolean onConsoleMessage(ConsoleMessage cm)
  {
      Log.d("JSADDLEJS", String.format("%s @ %d: %s", cm.message(), cm.lineNumber(), cm.sourceId()));
      return true;
  }
}
