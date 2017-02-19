#include <stdlib.h>
#include <assert.h>
#include <pthread.h>
#include <unistd.h>
#include <jni.h>
#include <stdio.h>
#include <android/log.h>
#include "HsFFI.h"

#include "focus.h"

static native_callbacks* hsCallbacks = NULL;
static JavaVM* jvm = NULL;
static jobject javaCallback = NULL;
static jmethodID evaluateJSCallback = NULL;

static int pfd[2];
static pthread_t thr;
static const char *tag = "";

static void *thread_func(void*);

int start_logger(const char *app_name) {
    tag = app_name;

    /* make stdout line-buffered and stderr unbuffered */
    setvbuf(stdout, 0, _IOLBF, 0);
    setvbuf(stderr, 0, _IONBF, 0);

    /* create the pipe and redirect stdout and stderr */
    pipe(pfd);
    dup2(pfd[1], 1);
    dup2(pfd[1], 2);

    /* spawn the logging thread */
    if(pthread_create(&thr, 0, thread_func, 0) == -1)
        return -1;
    pthread_detach(thr);
    return 0;
}

void *thread_func(void* unused)
{
    ssize_t rdsz;
    char buf[128];
    while((rdsz = read(pfd[0], buf, sizeof buf - 1)) > 0) {
        if(buf[rdsz - 1] == '\n') --rdsz;
        buf[rdsz] = 0;  /* add null-terminator */
        __android_log_write(ANDROID_LOG_DEBUG, tag, buf);
    }
    return 0;
}

JNIEXPORT jint JNICALL JNI_OnLoad ( JavaVM *vm, void *reserved ) {
  jvm = vm;
  return JNI_VERSION_1_2;
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_ProcessJSaddleMessage_processMessageShim (JNIEnv *env, jstring msg) {
  const char *msg_str = (*env)->GetStringUTFChars(env, msg, NULL);
  (*(hsCallbacks->jsaddleResult))(msg_str);
  return;
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_JSaddleStart_startHandlerShim (JNIEnv *env) {
  jstring js_str = (*env)->NewStringUTF(env, hsCallbacks->jsaddleJsData);
  (*env)->CallVoidMethod(env, javaCallback, evaluateJSCallback, js_str);
  (*(hsCallbacks->jsaddleStart))();
  return;
}

JNIEXPORT void JNICALL Java_systems_obsidian_app_MainActivity_initJSaddle (JNIEnv *env, jobject thisObj, jobject jsaddleObj) {
  static int argc = 3;
  static char *argv[] = {"+RTS", "-T", "-RTS"};
  static char **pargv = argv;
  start_logger("JSADDLEC");
  hs_init(&argc, &pargv);

  hs_add_root (__stginit_App);

  javaCallback = (*env)->NewGlobalRef(env, jsaddleObj);
  jclass cls = (*env)->GetObjectClass(env, javaCallback);
  evaluateJSCallback = (*env)->GetMethodID(env, cls, "evaluateJavascript", "(Ljava/lang/String;)V");
  jmethodID loadHTMLStringCallback = (*env)->GetMethodID(env, cls, "loadHTMLString", "(Ljava/lang/String;)V");

  hsCallbacks = appMain (&evaluateJavascriptWrapper);

  jstring html_str = (*env)->NewStringUTF(env, hsCallbacks->jsaddleHtmlData);
  (*env)->CallVoidMethod(env, javaCallback, loadHTMLStringCallback, html_str);

  return;
}

void evaluateJavascriptWrapper (const char* js) {
  JNIEnv *env;
  jint rs = (*jvm)->AttachCurrentThread(jvm, &env, NULL);
  assert (rs == JNI_OK);
  jstring js_str = (*env)->NewStringUTF(env, js);
  (*env)->CallVoidMethod(env, javaCallback, evaluateJSCallback, js_str);
  return;
}
