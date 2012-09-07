# Vanilla config from linaro android build system
MANIFEST_REPO=git://android.git.linaro.org/platform/manifest.git
MANIFEST_BRANCH=linaro_android_4.1.1
MANIFEST_FILENAME=staging-panda.xml
TARGET_PRODUCT=pandaboard
TARGET_SIMULATOR=false
TOOLCHAIN_URL=http://snapshots.linaro.org/android/~linaro-android/toolchain-4.7-2012.08/2/android-toolchain-eabi-linaro-4.7-2012.08-2-2012-08-18_18-53-14-linux-x86.tar.bz2
TOOLCHAIN_TRIPLET=arm-linux-androideabi
REPO_SEED_URL=http://android-build.linaro.org/seed/uniseed.tar.gz
LAVA_DEVICE="panda09"
LAVA_SUBMIT=1
LAVA_SUBMIT_FATAL=0
LAVA_TEST_PLAN="busybox,0xbench,glmark2,skia,v8,mmtest,monkey,monkey_long_run,[system-reboot],hostshell-connect-lab-wifi,methanol,methanol(-b CHROME),methanol(-t svg),methanol(-t svg -b CHROME),methanol(-t smp),methanol(-t smp -b CHROME)"
MONKEY_RUNNER_URL_1="file:///home/vishalbhoj/benchmarks"
MONKEY_RUNNER_URL_2="git://android.git.linaro.org/test/linaro/android/system.git"
BUILD_FS_IMAGE=1

# List of non-standard variables to pass to android make
pass-to-make = 
# Argument for linaro-android-media-create --dev
lmc-dev = panda
