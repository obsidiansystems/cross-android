#ifndef _INCLUDE_FOCUS_H_
#define _INCLUDE_FOCUS_H_

typedef struct native_callbacks {
  void (* jsaddleStart) ();
  void (* jsaddleResult) (const char *);
  const char * jsaddleJsData;
  const char * jsaddleHtmlData;
} native_callbacks;

void __stginit_App (void);

JNIEXPORT jint JNICALL JNI_OnLoad ( JavaVM *vm, void *reserved );

JNIEXPORT void JNICALL Java_systems_obsidian_app_ProcessJSaddleMessage_processMessageShim (JNIEnv *env, jstring msg);

JNIEXPORT void JNICALL Java_systems_obsidian_app_JSaddleStart_startHandlerShim (JNIEnv *env);

JNIEXPORT void JNICALL Java_systems_obsidian_app_MainActivity_initJSaddle (JNIEnv *env, jobject thisObj, jobject jsaddleObj);

native_callbacks* appMain (void (* evaluateJs) (const char*));

void evaluateJavascriptWrapper (const char* js);

int start_logger(const char *app_name);

#endif
