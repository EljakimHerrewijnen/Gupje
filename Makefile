ifeq ($(ANDROID_NDK_ROOT),)
$(error Error : Set the env variable 'ANDROID_NDK_ROOT' with the path of the Android NDK (version 20))
endif

CC := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android27-clang
AR := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ar
OBJCOPY := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-objcopy
LD := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ld.bfd

#ARM 32 bit
CC_32 := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi27-clang
AR_32 := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ar
OBJCOPY_32 := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/arm-linux-androideabi-objcopy
LD_32 := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ld.bfd

#ARM thumb mode
TOOLCHAIN_ARM_T := $(TOOLCHAINENV)/gcc-arm-none-eabi-10-2020-q4-major/bin/arm-none-eabi-
CC_T = $(TOOLCHAIN_ARM_T)gcc
AS_T = $(TOOLCHAIN_ARM_T)as
OBJCOPY_T = $(TOOLCHAIN_ARM_T)objcopy
LD_T = $(TOOLCHAIN_ARM_T)ld.bfd

CFLAGS := -Werror -Wno-unused-variable -Os
LINKER := /system/bin/linker64
DEBUG := -g

#Thumb cflags
all: error

error:
	@echo "Please specify a target to build (-f devices/nvidia_shield_t)"

clean:
	rm -rf bin/*