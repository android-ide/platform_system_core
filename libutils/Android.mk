# Copyright (C) 2008 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH:= $(call my-dir)

# libutils is a little unique: It's built twice, once for the host
# and once for the device.

commonSources:= \
	BasicHashtable.cpp \
	BlobCache.cpp \
	CallStack.cpp \
	FileMap.cpp \
	JenkinsHash.cpp \
	LinearAllocator.cpp \
	LinearTransform.cpp \
	Log.cpp \
	Printer.cpp \
	ProcessCallStack.cpp \
	PropertyMap.cpp \
	RefBase.cpp \
	SharedBuffer.cpp \
	Static.cpp \
	StopWatch.cpp \
	String8.cpp \
	String16.cpp \
	SystemClock.cpp \
	Threads.cpp \
	Timers.cpp \
	Tokenizer.cpp \
	Unicode.cpp \
	VectorImpl.cpp \
	misc.cpp

host_commonCflags := -DLIBUTILS_NATIVE=1 $(TOOL_CFLAGS) -Werror

ifeq ($(HOST_OS),windows)
ifeq ($(strip $(USE_CYGWIN),),)
# Under MinGW, ctype.h doesn't need multi-byte support
host_commonCflags += -DMB_CUR_MAX=1
endif
endif

host_commonLdlibs :=

ifeq ($(TARGET_OS),linux)
host_commonLdlibs += -lrt -ldl
endif


ifndef AIDE_BUILD


# For the host
# =====================================================
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= $(commonSources)
ifeq ($(HOST_OS), linux)
LOCAL_SRC_FILES += Looper.cpp
endif
LOCAL_MODULE:= libutils
LOCAL_STATIC_LIBRARIES := liblog
LOCAL_CFLAGS += $(host_commonCflags)
LOCAL_MULTILIB := both
include $(BUILD_HOST_STATIC_LIBRARY)


# For the host, 64-bit
# =====================================================
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= $(commonSources)
ifeq ($(HOST_OS), linux)
LOCAL_SRC_FILES += Looper.cpp
endif
LOCAL_MODULE:= lib64utils
LOCAL_STATIC_LIBRARIES := liblog
LOCAL_CFLAGS += $(host_commonCflags) -m64
include $(BUILD_HOST_STATIC_LIBRARY)


endif # AIDE_BUILD


# For the device, static
# =====================================================
include $(CLEAR_VARS)


# we have the common sources, plus some device-specific stuff
LOCAL_SRC_FILES:= \
	$(commonSources) \
	Looper.cpp \
	Trace.cpp

ifeq ($(TARGET_ARCH),mips)
LOCAL_CFLAGS += -DALIGN_DOUBLE
endif

ifndef AIDE_BUILD
LOCAL_CFLAGS += -Werror
endif


LOCAL_C_INCLUDES += \
		bionic/libc/private \
		external/zlib

ifdef AIDE_BUILD
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../include/utils
endif


LOCAL_STATIC_LIBRARIES := \
	libcutils

LOCAL_SHARED_LIBRARIES := \
        libbacktrace \
        liblog \
        libdl

ifndef AIDE_BUILD
include external/stlport/libstlport.mk
endif AIDE_BUILD

LOCAL_MODULE:= libutils
include $(BUILD_STATIC_LIBRARY)


ifndef AIDE_BUILD


# For the device, shared
# =====================================================
include $(CLEAR_VARS)
LOCAL_MODULE:= libutils
LOCAL_WHOLE_STATIC_LIBRARIES := libutils
LOCAL_SHARED_LIBRARIES := \
        libbacktrace \
        libcutils \
        libdl \
        liblog
LOCAL_CFLAGS := -Werror

include external/stlport/libstlport.mk

include $(BUILD_SHARED_LIBRARY)

# Include subdirectory makefiles
# ============================================================

# If we're building with ONE_SHOT_MAKEFILE (mm, mmm), then what the framework
# team really wants is to build the stuff defined by this makefile.
ifeq (,$(ONE_SHOT_MAKEFILE))
include $(call first-makefiles-under,$(LOCAL_PATH))
endif

endif # AIDE_BUILD
