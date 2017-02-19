#ifndef _INCLUDE_FOCUS_H_
#define _INCLUDE_FOCUS_H_

typedef struct native_callbacks {
  void (* jsaddleStart) ();
  void (* jsaddleResult) (char *);
  char * jsaddleJsData;
  char * jsaddleHtmlData;
} native_callbacks;

void __stginit_App (void);

JNIEXPORT jint JNICALL JNI_OnLoad ( JavaVM *vm, void *reserved );

JNIEXPORT void JNICALL JNI_OnUnload( JavaVM *vm, void *pvt );

JNIEXPORT void JNICALL Java_systems_obsidian_app_ProcessJSaddleMessage_processMessageShim (JNIEnv *env, jstring msg);

JNIEXPORT void JNICALL Java_systems_obsidian_app_JSaddleStart_startHandlerShim (JNIEnv *env);

native_callbacks* appMain (void (* evaluateJs) (char*));

void stubJs (char* js);

#endif
