LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libiconv
LOCAL_SRC_FILES := libiconv.so

include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libcharset
LOCAL_SRC_FILES := libcharset.so

include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := app
LOCAL_SRC_FILES := @APPLIBNAME@
LOCAL_SHARED_LIBRARIES := libiconv libcharset

include $(PREBUILT_SHARED_LIBRARY)
