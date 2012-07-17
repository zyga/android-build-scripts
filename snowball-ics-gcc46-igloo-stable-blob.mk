# Vanilla config from linaro android build system
MANIFEST_REPO=git://android.git.linaro.org/platform/manifest.git
MANIFEST_BRANCH=linaro_android_4.0.4
MANIFEST_FILENAME=landing-snowball.xml
TARGET_PRODUCT=snowball
TARGET_SIMULATOR=false
TARGET_BUILD_VARIANT=tests
TOOLCHAIN_URL=http://snapshots.linaro.org/android/~linaro-android/toolchain-4.6-2012.05/1/android-toolchain-eabi-linaro-4.6-2012.05-1-2012-05-18_15-55-36-linux-x86.tar.bz2
TOOLCHAIN_TRIPLET=arm-linux-androideabi
REPO_SEED_URL=http://android-build.linaro.org/seed/uniseed.tar.gz
SOURCE_OVERLAY=snowball/20120531/vendor.tar.bz2
LAVA_SUBMIT=1
LAVA_SUBMIT_FATAL=0
LAVA_TEST_PLAN="busybox,0xbench,glmark2,skia,v8,mmtest,cts,monkey,monkey_long_run"
SYNC_JOBS=10
MONKEY_RUNNER_URL_1="git://android.git.linaro.org/test/linaro/android/system.git"
MONKEY_RUNNER_URL_2="git://android.git.linaro.org/linaro/benchmarks.git"
CTS_TIMEOUT=36000

# List of non-standard variables to pass to android make
pass-to-make =
# Argument for linaro-android-media-create --dev
lmc-dev = snowball 
