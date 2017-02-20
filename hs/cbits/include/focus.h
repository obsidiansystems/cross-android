#ifndef _INCLUDE_FOCUS_H_
#define _INCLUDE_FOCUS_H_

typedef struct native_callbacks {
  void (* jsaddleStart) ();
  void (* jsaddleResult) (const char *);
  const char * jsaddleJsData;
  const char * jsaddleHtmlData;
} native_callbacks;

void __stginit_Mobile (void);

native_callbacks* appMain (void (* evaluateJs) (const char*));

int start_logger(const char *app_name);

void evaluateJavascriptWrapper (const char* js);

#endif
