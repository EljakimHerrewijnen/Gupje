ifeq ($(ANDROID_NDK_ROOT),)
$(error Error : Set the env variable 'ANDROID_NDK_ROOT' with the path of the Android NDK (version 20))
endif

CC := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android27-clang
AR := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ar
OBJCOPY := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-objcopy
LD := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ld.bfd

CFLAGS_BASE_DEVICE := -Werror -Wno-unused-variable -Os -Idevices/base_device/
base_device:
	[ -d bin/base_device ] || mkdir -p bin/base_device/
	$(CC) arm64_stub.S -c -o bin/base_device/entry.o $(CFLAGS_BASE_DEVICE)
	$(CC) debugger.c -c -o bin/base_device/debugger.o $(CFLAGS_BASE_DEVICE)
	$(LD) -T devices/base_device/linkscript.ld bin/base_device/entry.o bin/base_device/debugger.o -o bin/base_device/debugger.elf --just-symbols=devices/base_device/symbols.txt
	$(OBJCOPY) -O binary bin/base_device/debugger.elf bin/base_device/debugger.bin