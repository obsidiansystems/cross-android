#include <stdlib.h>
#include <assert.h>
#include <jni.h>
#include "HsFFI.h"

#include "focus.h"

static native_callbacks* hsCallbacks = NULL;
static JavaVM* jvm = NULL;
static jobject javaCallback = NULL;
static jmethodID evaluateJSCallback = NULL;

JNIEXPORT jint JNICALL JNI_OnLoad ( JavaVM *vm, void *reserved ) {
  jvm = vm;
  return JNI_VERSION_1_2;
}

JNIEXPORT void JNICALL JNI_OnUnload( JavaVM *vm, void *pvt ) {
    hs_exit();
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_ProcessJSaddleMessage_processMessageShim (JNIEnv *env, jstring msg) {
  const char *msg_str = (*env)->GetStringUTFChars(env, msg, NULL);
  (*(hsCallbacks->jsaddleResult))(msg_str);
  return;
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_JSaddleStart_startHandlerShim (JNIEnv *env) {
  (*(hsCallbacks->jsaddleStart))();
  return;
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_MainActivity_initJSaddle (JNIEnv *env, jobject thisObj, jobject jsaddleObj) {
  static int argc = 0;
  static char *argv[] = {NULL};
  static char **pargv = argv;
  hs_init(&argc, &pargv);

  hs_add_root (__stginit_App);

  javaCallback = (*env)->NewGlobalRef(env, jsaddleObj);
  jclass cls = (*env)->GetObjectClass(env, javaCallback);
  evaluateJSCallback = (*env)->GetMethodID(env, cls, "evaluateJavascript", "(Ljava/lang/String;)V");
  jmethodID loadHTMLStringCallback = (*env)->GetMethodID(env, cls, "loadHTMLString", "(Ljava/lang/String;)V");

  hsCallbacks = appMain (&evaluateJavascriptWrapper);

  jstring html_str = (*env)->NewStringUTF(env, hsCallbacks->jsaddleHtmlData);
  (*env)->CallVoidMethod(env, javaCallback, loadHTMLStringCallback, html_str);

  jstring js_str = (*env)->NewStringUTF(env, hsCallbacks->jsaddleJsData);
  (*env)->CallVoidMethod(env, javaCallback, evaluateJSCallback, js_str);

  return;
}

void evaluateJavascriptWrapper (char* js) {
  JNIEnv *env;
  jint rs = (*jvm)->AttachCurrentThread(jvm, &env, NULL);
  assert (rs == JNI_OK);
  jstring js_str = (*env)->NewStringUTF(env, js);
  (*env)->CallVoidMethod(env, javaCallback, evaluateJSCallback, js_str);
  return;
}
