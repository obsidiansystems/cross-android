#ifndef _INCLUDE_FOCUS_H_
#define _INCLUDE_FOCUS_H_

JNIEXPORT jint JNICALL JNI_OnLoad ( JavaVM *vm, void *reserved );

JNIEXPORT void JNICALL JNI_OnUnload( JavaVM *vm, void *pvt );

JNIEXPORT void JNICALL Java_systems_obsidian_focus_ProcessJSaddleMessage_processMessageShim (JNIEnv *env, jstring msg);

JNIEXPORT void JNICALL Java_systems_obsidian_focus_JSaddleStart_startHandlerShim (JNIEnv *env);

#endif
