#include <stdlib.h>
#include <jni.h>
#include "HsFFI.h"

#include "focus.h"

extern void __stginit_App (void);

JNIEXPORT jint JNICALL JNI_OnLoad ( JavaVM *vm, void *reserved ) {
  static int argc = 0;
  static char *argv[] = {NULL};
  static char **pargv = argv;
  hs_init(&argc, &pargv);

  hs_add_root (__stginit_App);

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
