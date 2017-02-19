#include <stdlib.h>
#include <jni.h>
#include "HsFFI.h"

#include "focus.h"

static native_callbacks* hsCallbacks = NULL;
static jobject javaCallback = NULL;

JNIEXPORT jint JNICALL JNI_OnLoad ( JavaVM *vm, void *reserved ) {
  return JNI_VERSION_1_2;
}

JNIEXPORT void JNICALL JNI_OnUnload( JavaVM *vm, void *pvt ) {
    hs_exit();
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_ProcessJSaddleMessage_processMessageShim (JNIEnv *env, jstring msg) {
  return;
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_JSaddleStart_startHandlerShim (JNIEnv *env) {
  return;
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_MainActivity_initJSaddle (JNIEnv *env, jobject obj) {
  static int argc = 0;
  static char *argv[] = {NULL};
  static char **pargv = argv;
  hs_init(&argc, &pargv);

  hs_add_root (__stginit_App);

  javaCallback = (*env)->NewGlobalRef(env, obj);
  jclass cls = (*env)->GetObjectClass(env, javaCallback);

  hsCallbacks = appMain (&stubJs);

  return;
}

void stubJs (char* js) {
  return;
}
