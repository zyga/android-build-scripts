# Vanilla config from linaro android build system
MANIFEST_REPO=git://android.git.linaro.org/platform/manifest.git
MANIFEST_BRANCH=linaro_android_4.0.4
MANIFEST_FILENAME=tracking-panda.xml
TARGET_PRODUCT=pandaboard
TARGET_SIMULATOR=false
TOOLCHAIN_URL=http://snapshots.linaro.org/android/~linaro-android/toolchain-4.7-2012.06/5/android-toolchain-eabi-linaro-4.7-2012.06-5-2012-06-20_04-30-11-linux-x86.tar.bz2
TOOLCHAIN_TRIPLET=arm-linux-androideabi
REPO_SEED_URL=http://android-build.linaro.org/seed/uniseed.tar.gz
LAVA_SUBMIT=1
LAVA_SUBMIT_FATAL=0
TARGET_NO_HARDWAREGFX=1
KERNEL_CONFIG=omap4plus_defconfig
LAVA_ANDROID_BINARIES=False
LAVA_TEST_PLAN="busybox,0xbench,glmark2,skia,v8,mmtest,cts,monkey,monkey_long_run"
MONKEY_RUNNER_URL_1="git://android.git.linaro.org/test/linaro/android/system.git"

# List of non-standard variables to pass to android make
pass-to-make = TARGET_NO_HARDWAREGFX KERNEL_CONFIG
# Argument for linaro-android-media-create --dev
lmc-dev = panda
