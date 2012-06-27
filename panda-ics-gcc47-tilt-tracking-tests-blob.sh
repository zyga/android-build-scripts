set -x

. common.sh

if [ ! -d android ]; then
    mkdir android
fi
cd android
if [ ! -d .repo ]; then
    repo init -u ${MANIFEST_REPO} -b ${MANIFEST_BRANCH} -m ${MANIFEST_FILENAME}
fi
while ! repo sync --jobs=1; do
    echo "repo sync failed, trying again in 5 seconds"
    sleep 5
done

if [ ! -e $(basename $ZK_TOOLCHAIN_URL) ]; then
    wget --no-check-certificate $ZK_TOOLCHAIN_URL
fi
if [ ! -d android-toolchain-eabi ]; then
    tar -jxvf $(basename $ZK_TOOLCHAIN_URL)
fi

export NUM_PROC=`getconf _NPROCESSORS_ONLN`
. build/envsetup.sh
make clean
repo forall -c git clean -f -x -d
make -j${NUM_PROC} \
    boottarball systemtarball userdatatarball \
    showcommands \
    > ../build_log_$(date +%Y-%m-%d-%H:%M).txt 2>&1 &
