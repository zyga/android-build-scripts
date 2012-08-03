# Vanilla config from linaro android build system
MANIFEST_REPO=git://android.git.linaro.org/platform/manifest.git
MANIFEST_BRANCH=linaro_android_4.0.4
MANIFEST_FILENAME=landing-snowball.xml
TARGET_PRODUCT=snowball
TARGET_SIMULATOR=false
TARGET_BUILD_VARIANT=tests
TOOLCHAIN_URL=http://snapshots.linaro.org/android/~linaro-android/toolchain-4.7-2012.07/1/android-toolchain-eabi-linaro-4.7-2012.07-1-2012-07-16_08-48-35-linux-x86.tar.bz2
REPO_SEED_URL=http://android-build.linaro.org/seed/uniseed.tar.gz
SOURCE_OVERLAY="snowball/20120718/mali/vendor.tar.bz2"
LAVA_SUBMIT=1
LAVA_SUBMIT_FATAL=0
LAVA_TEST_PLAN="busybox,0xbench,glmark2,skia,v8,mmtest,monkey"
MONKEY_RUNNER_URL_1="file:///home/vishalbhoj/benchmarks"
SYNC_JOBS=10

# List of non-standard variables to pass to android make
pass-to-make =
# Argument for linaro-android-media-create --dev
lmc-dev = snowball_sd
